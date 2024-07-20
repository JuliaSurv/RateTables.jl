"""
    Life(brt::BasicRateTable,a,d)

This function returns a random variable that correspond to an extracted Life from the `BasicRateTable` at age `a` and date `d`. 

This works by checking if the individual is closer to the oldest age than the last year in the ratetable, calculating at each step the time difference and the hazard values. When reaching the borders of the table we follow them until the last cell, which runs till infinity. 
"""
struct Life<:Distributions.ContinuousUnivariateDistribution
    ∂t::Vector{Float64}
    λ::Vector{Float64}
    function Life(brt::BasicRateTable,a,d)
        # Current position in the life table: 
        i, j = dty(a, brt.extrema_age...), dty(d, brt.extrema_year...)

        # Next position: Happy new year (right, →) or happy birthday (below, ↓) first ?
        # Cap obtained values to avoid going out of bounds.
        rem_a = RT_DAYS_IN_YEAR - rem(a, RT_DAYS_IN_YEAR)
        rem_d = RT_DAYS_IN_YEAR - rem(d, RT_DAYS_IN_YEAR)
        k, l = rem_a < rem_d ? (i+1,j) : (i,j+1)
        K, L = size(brt.values)
        k, l = min(k, K), min(l, L)
        
        # We can extract time spend and daily hazard in the first two cells,
        # Either going →↓ or ↓→ as needed.
        ∂t = [min(rem_a,rem_d), abs(rem_a - rem_d)]
        λ  = [brt.values[i,j],  brt.values[k,l]]
    
        # Then go to the next two cells: 
        while (k < K) || (l < L)
            i,j,k,l = i+1, j+1, k+1, l+1
            if (k < K) || (l < L) # We go →↓ or ↓→
                push!(∂t, RT_DAYS_IN_YEAR - ∂t[2], ∂t[2])
                push!(λ, brt.values[i,j], brt.values[k,l])
            else
                if (l < L) # We exit →→→→→→→→ along the bottom row
                    append!(∂t, ones(L-l) .* RT_DAYS_IN_YEAR)
                    append!(λ, brt.values[end, (l+1):end])
                else # We exit ↓↓↓↓↓↓↓↓ along the last column
                    append!(∂t, ones(K-k) .* RT_DAYS_IN_YEAR)
                    append!(λ, brt.values[(k+1):end, end])
                end
                break
            end
        end
        return new(∂t,λ)
    end
end
Distributions.@distr_support Life 0.0 Inf
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
Distributions.ccdf(L::Life, t::Real) = exp(-cumhazard(L::Life,t))
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