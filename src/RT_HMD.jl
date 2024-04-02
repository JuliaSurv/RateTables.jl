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

    for file in readdir(joinpath(@__DIR__,"..","data","HMD_data"))

        country_code, country_name = String.(split(file,".")[1:2])
        df = CSV.read(joinpath(@__DIR__,"..","data","HMD_data",file), DataFrames.DataFrame)

        # make daily hazards from death rates: 
        df.value .= abs.(log1p.(.- clamp.(df.value,0,0.999)) ./ RT_DAYS_IN_YEAR)

        # Transform:
        tr_Female = unstack(select(filter(r -> r.sex == "female",df), Not(:sex)), :year, :value)
        tr_Male = unstack(select(filter(r -> r.sex == "male",df) ,Not(:sex)), :year, :value)

        # trim years with missing values: 
        tr_Female = tr_Female[!, all.(!ismissing, eachcol(tr_Female))]
        tr_Male = tr_Male[!, all.(!ismissing, eachcol(tr_Male))]

        years = parse.(Int64, names(tr_Female)[2:end])
        ages = tr_Female.age
        
        # Check spacing regularity
        for df in (tr_Male, tr_Female)
            if !all(diff(years) .== 1)
                @show country_code, country_name
            end
            @assert all(diff(years) .== 1)
            @assert all(diff(ages) .== 1)
        end

        df.sex = Symbol.(df.sex)
        push!(tbls, Symbol(country_code) => RateTable(df))
    end
    tbls
end