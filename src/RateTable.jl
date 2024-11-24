
################################## Types

abstract type AbstractRateTable end
struct BasicRateTable <: AbstractRateTable
    values::Array{Float64,2}
    extrema_age::Tuple{Int64,Int64}
    extrema_year::Tuple{Int64,Int64}
    function BasicRateTable(values,ages,years)
        @assert all(diff(years) .== 1)
        @assert all(diff(ages) .== 1)
        return new(values, extrema(ages), extrema(years))
    end
end

"""
    RateTable

This class contains daily rate tables used in person-years computation. 

Each of these tables contains the daily hazard rate for a matched subject from the population, defined as ``-\\log(1-qₓ)`` for ``qₓ`` the 1 year probability of death as reported in the original tables from the US Census. The tables are given in terms of hazard per day for computational convenience.
"""
struct RateTable{n_axes,axes_type,map_type} <: AbstractRateTable
    axes::axes_type
    map::map_type
    function RateTable(axes, mapping)
        return new{length(axes),typeof(axes),typeof(mapping)}(axes, mapping)
    end
end

################################## Constructors

function BasicRateTable(df)
    @assert ncol(df)==3
    @assert "age" ∈ names(df)
    @assert "year" ∈ names(df)
    @assert "value" ∈ names(df)
    years = sort(unique(df.year))
    ages = sort(unique(df.age))
    
    # Ensure regular spacing: 
    for year in minimum(years):maximum(years)
        if !(year ∈ years)
            sbs = filter(row -> row.year == year-1, df)
            sbs.year .+= 1
            df = vcat(df, sbs)
        end
    end

    # sort, unpack and return: 
    sort!(df)
    values = zeros(length(ages),length(years))
    values .= unstack(df, :year, :value)[!,2:end]
    return BasicRateTable(values, ages, years)
end
function RateTable(df)
    nms = Symbol.(names(select(df,Not([:age, :year, :value]))))
    sort!(df, nms) # sorting. 
    axes = NamedTuple(n => tuple(sort(unique(df[!,n]))...) for n in nms)

    if length(nms) == 0 
        # no predictors, directly give the BRT
        return BasicRateTable(df)
    else 
        grid = combine(d -> BasicRateTable(select(d,[:age,:year,:value])), groupby(df, nms))
        if length(nms) == 1
            # only one predictor, provide a namedtuple
            map = NamedTuple(grid[i,nms[1]] => grid[i,:x1] for i in 1:nrow(grid))
        else
            # More than one predictor, give a dict. 
            map = Dict(tuple(grid[i,nms]...) => grid[i,:x1] for i in 1:nrow(grid))
        end
        return RateTable(axes, map)
    end
end

################################## Show methods

function Base.show(io::IO, rt::BasicRateTable)
    compact = get(io, :compact, false)
    if !compact 
        print(io, "BasicRateTable:\n")
        print(io, "    ages, in years from $(rt.extrema_age[1]) to $(rt.extrema_age[2]) (in days from $(RT_DAYS_IN_YEAR*rt.extrema_age[1]) to $(RT_DAYS_IN_YEAR*rt.extrema_age[2]))\n")
        print(io, "    date, in years from $(rt.extrema_year[1]) to $(rt.extrema_year[2]) (in days from $(RT_DAYS_IN_YEAR*rt.extrema_year[1]) to $(RT_DAYS_IN_YEAR*rt.extrema_year[2])) \n")
    else
        print(io, "BRT($(rt.extrema_age[1])..$(rt.extrema_age[2]) × $(rt.extrema_year[1])..$(rt.extrema_year[2]))")
    end
end
function Base.show(io::IO, rt::RateTable)
    compact = get(io, :compact, false)
    print(io, "RateTable$(keys(rt.axes))")
end

################################## Functionalities. 

predictors(::BasicRateTable) = () # empty tuple. 
predictors(rt::RateTable) = keys(rt.axes)
available_covariates(rt::RateTable, axe) = rt.axes[axe]

Base.getindex(rt::RateTable, arg)       = rt.map[arg]
Base.getindex(rt::RateTable, args...)   = rt.map[args]
Base.getindex(rt::RateTable; kwargs...) = getindex(rt, collect(kwargs[n] for n in keys(rt.axes))...)

# Helper function. 
dty(t,minval,maxval) = clamp(Int(trunc(t*RT_YEARS_IN_DAY))-minval+1, 1, maxval-minval+1)

"""
    daily_hazard(rt::BasicRateTable, age, date)
    daily_hazard(rt::RateTable,      age, date, args...)
    daily_hazard(rt::RateTable,      age, date; kwargs...)

This function queries daily hazard values from a given BasicRateTable.
The parameters `age` and `date` have to be in days (1 year = $(RT_DAYS_IN_YEAR) days).
Potential args and kwargs will be used to subset the ratetable.
"""
@inline daily_hazard(rt::BasicRateTable,a, d) = rt.values[dty(a,rt.extrema_age...),dty(d,rt.extrema_year...)]
@inline daily_hazard(rt::RateTable, a, d; kwargs...) = daily_hazard(getindex(rt; kwargs...), a, d)
@inline daily_hazard(rt::RateTable, a, d, args...)   = daily_hazard(getindex(rt, args...),   a, d)


