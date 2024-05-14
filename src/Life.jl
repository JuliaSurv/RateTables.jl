
struct Life<:ContinuousUnivariateDistribution
    ∂t::Vector{Float64}
    λ::Vector{Float64}
    function Life(brt::BasicRateTable,a,d)
        i, j = dty(a, brt.extrema_age...), dty(d, brt.extrema_year...)
    
        rem_a = RT_DAYS_IN_YEAR - rem(a, RT_DAYS_IN_YEAR)
        rem_d = RT_DAYS_IN_YEAR - rem(d, RT_DAYS_IN_YEAR)
    
        # Do we go right or below first ? 
        # happy birthday (below) or happy new year (right) first ?
        k,l = rem_a < rem_d ? (i+1,j) : (i,j+1)
    
        # lengths and hazards in the first two cells:  
        ∂t = [min(rem_a,rem_d), abs(rem_a - rem_d)]
        λ  = [brt.values[i,j],  brt.values[k,l]]
    
        while (k < size(brt.values,1)) && (l < size(brt.values,2))
            i,j,k,l = i+1, j+1, k+1, l+1
            push!(∂t, RT_DAYS_IN_YEAR - ∂t[2], ∂t[2])
            push!(λ, brt.values[i,j], brt.values[k,l])
        end
        return new(∂t,λ)
    end
end

function expectation(L::Life)
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
    return E
end
function cumhazard(L::Life, t)
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
    return Λ
end
ccdf(L::Life, t::T) where T<:Real = exp(-cumhazard(L::Life,t))
