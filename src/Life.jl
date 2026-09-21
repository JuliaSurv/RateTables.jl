"""
    Life(brt::BasicRateTable,a,d)

This function returns a random variable that correspond to an extracted Life from the `BasicRateTable` at age `a` and date `d`. 

This works by checking if the individual is closer to the oldest age than the last year in the ratetable, calculating at each step the time difference and the hazard values. For the younger individuals, we assume they go through the last column at the end no matter what age they are. 
"""
struct Life<:Distributions.ContinuousUnivariateDistribution
    ∂t::Vector{Float64}
    λ::Vector{Float64}
end
function Life(brt::BasicRateTable,a,d)
        i, j = dty(a, brt.age_min, brt.age_max), dty(d, brt.year_min, brt.year_max)
    
        rem_a = RT_DAYS_IN_YEAR - rem(a, RT_DAYS_IN_YEAR)
        rem_d = RT_DAYS_IN_YEAR - rem(d, RT_DAYS_IN_YEAR)
    
        # Do we go right or below first ? 
        # Happy birthday (below) or Happy new year (right) first ?
        k,l = rem_a < rem_d ? (i+1,j) : (i,j+1)

        # Cap obtained values to avoid going out of bounds: 
        K,L = size(brt.values)
        k = min(k, K)
        l = min(l, L)
    
        # lengths and hazards in the first two cells:  
        ∂t = [min(rem_a,rem_d), abs(rem_a - rem_d)]
        λ  = [brt.values[i,j],  brt.values[k,l]]
    
        while (k < K) && (l < L)
            i,j,k,l = i+1, j+1, k+1, l+1
            push!(∂t, RT_DAYS_IN_YEAR - ∂t[2], ∂t[2])
            push!(λ, brt.values[i,j], brt.values[k,l])
        end
        if (l >= L) # exit on the right => still young ! 
            # A good approximation is to go through the last column. 
            for m in (k+1):K
                push!(∂t, RT_DAYS_IN_YEAR)
                push!(λ, brt.values[m,end])
            end
        end
        return Life(∂t,λ)
    end
Distributions.@distr_support Life 0.0 Inf

# rescaling mechanisme : 
Base.:*(c::Real, L::Life) = Life(L.∂t .* c, L.λ ./ c)
Base.:*(L::Life, c::Real) = c*L
Base.:/(L::Life, c::Real) = inv(c)*L

function Distributions.expectation(L::Life)
    S = 1.0
    E = 0.0
    for j in eachindex(L.∂t)
        if L.λ[j] > 0
            S_inc = exp(-L.λ[j]*L.∂t[j])
            E += S * (1 - S_inc) / L.λ[j]
            S *= S_inc
        else
            E += S * L.∂t[j]
        end
    end
    # This reminder assumes a exponential life time afer the maximum age.
    R = ifelse(L.λ[end] == 0.0, 0.0, S / L.λ[end])
    return E + R
end
"""
    cumhazard

Assuming the last box is infinitely wide, we calculate the cumulative hazard from ∂t and λ taken from the `Life` function.
"""
function cumhazard(L::Life, t::Real)
    t < 0 && return zero(t) # check for negative values. 
    Λ = 0.0
    u = 0.0
    for j in eachindex(L.∂t)
        u += L.∂t[j]
        if t > u 
            Λ += L.λ[j]*L.∂t[j]
        else
            Λ += L.λ[j]*(t-(u-L.∂t[j]))
            return Λ
        end
    end
    # We consider that the last box is in fact infinitely wide (exponential tail)
    return Λ + (t-u)*L.λ[end] 
end
function hazard(L::Life, t::Real)
    t < 0 && return zero(t) # check for negative values. 
    u = zero(t)
    for j in eachindex(L.∂t)
        u += L.∂t[j]
        t < u && return L.λ[j]
    end
    return L.λ[end] 
end
Distributions.ccdf(L::Life, t::Real) = exp(-cumhazard(L, t))
function Distributions.quantile(L::Life, p::Real)
    Λ_target = -log(1-p)
    Λ = 0.0
    u = 0.0
    for j in eachindex(L.∂t)
        Λ += L.λ[j]*L.∂t[j]
        u += L.∂t[j]
        if Λ_target < Λ
            u -= (Λ - Λ_target) / L.λ[j]
            return u
        end
    end
    return u
end
function Distributions.cf(L::Life, u)
    t, Λ, R, R_prev, rez = 0.0, 0.0, 1.0, 1.0, 0.0
    iu = im*u
    for j in eachindex(L.∂t)
        λⱼ, ∂tⱼ = L.λ[j], L.∂t[j]
        t += ∂tⱼ
        Λ += λⱼ * ∂tⱼ
        R_prev = R
        R = exp(iu * t - Λ)
        rez += λⱼ / (iu - λⱼ) * (R - R_prev)
    end
    return rez
end
function Distributions.mgf(L::Life, u)
    # The mgf M(u) = E[exp(u T)] exists only for u < λ_last,
    # where λ_last is the hazard on the (infinite) tail interval.
    λ_last = L.λ[end]
    u ≥ λ_last && throw(DomainError(u, "mgf is undefined for u ≥ λ_last"))

    t = 0.0
    Λ = 0.0
    R = 1.0   # exp(u * 0 - Λ(0))
    rez = 0.0
    tol = eps(Float64)

    for j in eachindex(L.∂t)
        Δ = L.∂t[j]
        λ = L.λ[j]
        t += Δ
        Λ += λ * Δ
        R_prev = R
        R = exp(u * t - Λ)
        z = u - λ
        if abs(z) < tol * max(1.0, abs(λ))
            # Limit z → 0 of λ/(z) * (R - R_prev)
            rez += λ * R_prev * Δ
        else
            rez += λ / z * (R - R_prev)
        end
    end

    # Add contribution of the exponential tail starting at t with hazard λ_last.
    # For u < λ_last, this is λ_last / (λ_last - u) * R, where
    # R = exp(u * t - Λ(t)).
    rez += λ_last / (λ_last - u) * R

    return rez
end
function Distributions.pdf(L::Life, t::Real) 
    t ≤ 0 && return zero(t)
    Λ = 0.0
    u = 0.0
    for j in eachindex(L.∂t)
        u += L.∂t[j]
        if t <= u
            local λj = L.λ[j]
            local τj = t - (u - L.∂t[j])
            return λj * exp(- (Λ + λj * τj))
        else
            Λ += L.λ[j] * L.∂t[j]
        end
    end
    λlast = L.λ[end]
    return λlast * exp(-Λ - λlast * (t - u))
end
Distributions.logpdf(L::Life, t::Real) = log(pdf(L,t))


"""
    shifted_moment(L::Life, k::Integer)

Compute the quantity E[T^k * exp(-T)] for a `Life` random variable T,
using its piecewise-constant hazard representation. This is done by
integrating t^k * exp(-t) * f(t) over each interval (and the
exponential tail) in closed form.
"""
function shifted_moment(L::Life, k::Integer)
    k < 0 && throw(ArgumentError("k must be nonnegative"))
    # order of the moment in the incomplete-gamma representation
    ν = Float64(k + 1)

    # Main accumulation over the piecewise-constant hazard intervals.
    Λ = 0.0   # cumulative hazard up to the start of current interval
    u = 0.0   # time at start of current interval
    res = 0.0

    for j in eachindex(L.∂t)
        Δ = L.∂t[j]
        λ = L.λ[j]
        if λ > 0.0
            α = 1.0 + λ
            a = u
            b = u + Δ
            # Constant factor λ * exp(-Λ + λ * a)
            C = λ * exp(-Λ + λ * a)
            # Integral \int_a^b t^k e^{-α t} dt via upper incomplete gamma
            αν = α^(-ν)
            res += C * αν * (gamma(ν, α * a) - gamma(ν, α * b))
        end
        Λ += L.λ[j] * Δ
        u += Δ
    end

    # Exponential tail with rate λ_last, same as in `pdf` / `expectation`.
    λ_last = L.λ[end]
    if λ_last > 0.0
        α = 1.0 + λ_last
        a = u
        C = λ_last * exp(-Λ + λ_last * a)
        αν = α^(-ν)
        # Tail integral \int_a^∞ t^k e^{-α t} dt = α^{-(k+1)} Γ(k+1, α a)
        res += C * αν * gamma(ν, α * a)
    end

    return res
end


