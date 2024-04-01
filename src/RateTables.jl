module RateTables

import CSV
using DataFrames

const RT_DAYS_IN_YEAR = 365.241

"""
RateTable

This class deals with daily rate tables used in person-years computation. 
For the moment it simply holds data from the HMD. 

"""
struct RateTable
    values::Array{Float64,3}
    extrema_age::Tuple{Int64,Int64}
    extrema_year::Tuple{Int64,Int64}
    country_code::String
    country_name::String
    function RateTable(values,ages,years, country_code, country_name)
        # re-assert the regularity of age and years: 
        @assert all(diff(years) .== 1)
        @assert all(diff(ages) .== 1)
        return new(values, extrema(ages), extrema(years), country_code, country_name)
    end
end
function Base.show(io::IO, rt::RateTable)
    compact = get(io, :compact, false)

    print(io, "RateTable for $(rt.country_name) (code $(rt.country_code)):\n")
    if !compact 
        print(io, "    Ages, in years from $(rt.extrema_age[1]) to $(rt.extrema_age[2]) (in days from $(RT_DAYS_IN_YEAR*rt.extrema_age[1]) to $(RT_DAYS_IN_YEAR*rt.extrema_age[2]))\n")
        print(io, "    Date, in years from $(rt.extrema_year[1]) to $(rt.extrema_year[2]) (in days from $(RT_DAYS_IN_YEAR*rt.extrema_year[1]) to $(RT_DAYS_IN_YEAR*rt.extrema_year[2])) \n")
        print(io, "    Sex is binary coded {0 => female, 1 => male}\n")
        print(io, "You can query daily hazard values through the `daily_hazard` function.")
    end
end
daily_to_yearly(t,minval,maxval) = min(Int(trunc(t/RT_DAYS_IN_YEAR))-minval+1,maxval-minval+1)
"""
    `daily_hazard(rt,age,date,sex)`

This function queries daily hazard values from a given RateTable.
The parameters `age` and `date` have to be in days (1 year = $(RT_DAYS_IN_YEAR) days).
Parameter `sex` is coded 0 for females and 1 for males. 
"""
function daily_hazard(rt,age,date,sex)
    # sex is coded 0 or 1: 0 for females, 1 for males. 
    # age and year are coded in days since 0,0 :)
    return rt.values[
        daily_to_yearly(age,rt.extrema_age...),
        daily_to_yearly(date,rt.extrema_year...),
        sex+1]
end


"""
    `RT_HMD`

Dictionary that contains the rates tables for each country. 
The country codes are used to differentiate them. 

These rates tables contain daily hazard rates for both sexes. They are derived from annual death probabilities (qₓ's) from the Human Mortality Database at https://www.mortality.org/


Dayly hazard for a slovenian male (code 0), born on the 1rst of january 1927, 192 days after his 37th birthday can for example be obtained as follows:

`solovia_rt = RT_HMD[:SVN]`
`daily_hazard(slovenia_rt, 37*RT_DAYS_IN_YEAR + 192, 1927*RT_DAYS_IN_YEAR + 192, 1)`

The list of availiables countries can be queried via: 
```julia
Dict(k => RT_HMD[k].country_name for k in keys(RT_HMD))
```

"""
const RT_HMD = let

    tbls = Dict{Symbol,RateTable}()

    for file in readdir(joinpath(@__DIR__,"..","data","qx"))

        country_code, country_name = String.(split(file,".")[1:2])
        df = CSV.read(joinpath(@__DIR__,"..","data","qx",file), DataFrames.DataFrame)

        # Transform:
        tr_Female = unstack(select(df, [:Year, :Age, :Female]), :Year, :Female)
        tr_Male = unstack(select(df, [:Year, :Age, :Male]), :Year, :Male)

        # trim years with missing values: 
        tr_Female = tr_Female[!, all.(!ismissing, eachcol(tr_Female))]
        tr_Male = tr_Male[!, all.(!ismissing, eachcol(tr_Male))]

        years = parse.(Int64, names(tr_Female)[2:end])
        ages = tr_Female.Age
        
        # Check spacing regularity
        for df in (tr_Male, tr_Female)
            if !all(diff(years) .== 1)
                @show country_code, country_name
            end
            @assert all(diff(years) .== 1)
            @assert all(diff(ages) .== 1)
        end

        # merge males and females: 
        values = zeros(length(ages),length(years),2)
        values[:,:,1] .= tr_Female[1:end,2:end] # dont take the "Age" column.
        values[:,:,2] .= tr_Male[1:end,2:end]

        # make daily hazards for death rates: 
        values .= .- log1p.(.- clamp.(values,0,0.999)) ./ RT_DAYS_IN_YEAR
        @assert all(values .== abs.(values))
        values .= abs.(values)

        push!(tbls, Symbol(country_code) => RateTable(values, ages, years, country_code, country_name))
    end
    tbls
end

export RT_HMD, daily_hazard

end
