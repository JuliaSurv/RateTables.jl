"""
    hmd_rates

RateTable providing daily hazard rates for both sexes for several countries. They are derived from annual death probabilities (qₓ's) from the [Human Mortality Database](https://www.mortality.org/)

Segmented by `country ∈ keys(hmd_countries)` and `sex ∈ (:male, :female, :total)`. 

The list of countries codes is given with details in the [`hmd_countries`](@ref) constant. 
"""
const hmd_rates = let

    dfs = []
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
        df[!,:country] .= Symbol(lowercase(country_code))
        push!(dfs, df)
    end
    dfss = vcat(dfs...)
    select!(dfss, [:country, :sex, :age, :year, :value])
    sort!(dfss)
    RateTable(dfss)
end

"""
    hmd_countries

Gives a list of countries codes used in the `hmd_rates` dataset. 
"""
const hmd_countries = let 
    dfs = Dict{Symbol, String}()
    for file in readdir(joinpath(@__DIR__,"..","data","HMD_data"))

        country_code, country_name = String.(split(file,".")[1:2])
        push!(dfs, Symbol(lowercase(country_code)) => country_name)
    end
    dfs
end