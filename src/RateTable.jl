
# So, I think that what we need is 
# one rate table for only age/year, the only things that gets added time. 

# then everythign else is a predictor: sex, of course, but any other categorical variable. 

# then we use some kind of "joining" mechanisme to make these tables appear as one and only one. 

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
daily_to_yearly(t,minval,maxval) = min(Int(trunc(t/RT_DAYS_IN_YEAR))-minval+1,maxval-minval+1)
"""
    `daily_hazard(rt::BasicRateTable,age,date)`

This function queries daily hazard values from a given BasicRateTable.
The parameters `age` and `date` have to be in days (1 year = $(RT_DAYS_IN_YEAR) days).
"""
function daily_hazard(rt::BasicRateTable,age_daily, date_daily)
    return rt.values[
        daily_to_yearly(age_daily,rt.extrema_age...),
        daily_to_yearly(date_daily,rt.extrema_year...)
    ]
end
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




"""
    `RateTable`

This class contains daily rate tables used in person-years computation. 

Each of these tables contains the daily hazard rate for a matched subject from the population, defined as ``-\\log(1-qₓ)`` for ``qₓ`` the 1 year probability of death as reported in the original tables from the US Census. The tables are given in terms of hazard per day for computational convenience.
"""
struct RateTable{N,Tmap} <: AbstractRateTable
    axes_names::NTuple{N,Symbol}
    map::Tmap
    function RateTable(axes_names, mapping)
        return new{length(axes_names),typeof(mapping)}(axes_names, mapping)
    end
end
function RateTable(df)
    axes_names = Symbol.(names(select(df,Not([:age, :year, :value]))))
    sort!(df, axes_names) # sorting. 

    if length(axes_names) == 0
        return BasicRateTable(df)
    end
    grid = combine(d -> BasicRateTable(select(d,[:age,:year,:value])), groupby(df, axes_names))
    rename!(grid, :x1 => :value)
    predictors = names(select(grid,Not(:value)))
    map = Dict(NamedTuple(r[predictors]) => r.value for r in eachrow(grid))
    N = length(axes_names)
    tpl_axes_names = NTuple{N,Symbol}(axes_names)
    return RateTable(tpl_axes_names, map)
end
function Base.show(io::IO, rt::RateTable)
    compact = get(io, :compact, false)
    if compact 
        print(io, "RT$(rt.axes_names)")
    else
        ex = rt.map[first(keys(rt.map))]
        print(io, "RT$(rt.axes_names) with elements BRT($(ex.extrema_age[1])..$(ex.extrema_age[2]) × $(ex.extrema_year[1])..$(ex.extrema_year[2])).")
    end
end

function Base.getindex(rt::RateTable{N,T},args...) where {N,T}
    if length(args) == length(rt.axes_names)
        return rt.map[NamedTuple(rt.axes_names[i] => args[i] for i in 1:N)]
    else
        # TODO : filter the map
        @error "filtering the map is not implemented yet" 
    end
end
function Base.getindex(rt::RateTable{N,T}; kwargs...) where {N,T}
    if length(kwargs) == length(rt.axes_names)
        return rt.map[NamedTuple(n => kwargs[n] for n in rt.axes_names)]
    else
        # TODO : filter the map
        @error "filtering the map is not implemented yet" 
    end
end
function daily_hazard(rt::RateTable,age_daily, date_daily; kwargs...)
    return daily_hazard(rt.map[NamedTuple(n => kwargs[n] for n in rt.axes_names)], age_daily,date_daily)
end
function daily_hazard(rt::RateTable{N,T},age_daily, date_daily, args...) where {N,T}
    return daily_hazard(rt.map[NamedTuple(rt.axes_names[i] => args[i] for i in 1:N)], age_daily,date_daily)
end