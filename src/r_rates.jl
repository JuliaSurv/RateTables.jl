
"""

    `slopop`

Slovene census data. Correspond to R's `relsurv::slopop` ratetable from the `relsurv` package. Segmented by `sex ∈ (:male, :female)`.
"""
slopop
const slopop = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","relsurv.slopop.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end

"""

    `survexp_us`

Census data set for the US population, drawn from R's package `survival`. RateTable `survexp_us` gives total United States population, by age and sex, 1940 to 2012. Segmented by `sex ∈ (:male, :female)`
"""
const survexp_us = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survival.survexp_us.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end

"""

    `survexp_usr`

Census data set for the US population, drawn from R's package `survival`. RateTable `survexp_usr` gives the United States population, by age, sex and race, 1940 to 2014. Race is white or black. For 1960 and 1970 the black population values were not reported separately, so the nonwhite values were used. (Over the years, the reported tables have differed wrt reporting non-white and/or black.). Segmented by `sex ∈ (:male, :female)` and `race `∈ (:white, :black)`. 
"""
const survexp_usr = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survival.survexp_usr.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    df.race = Symbol.(df.race)
    RateTable(df)
end

"""

    `survexp_mn`

Census data set for the US population, drawn from R's package `survival`. RateTable `survexp_mn` gives total Minnesota population, by age and sex, 1970 to 2013. Segmented by `sex ∈ (:male, :female)`
"""
const survexp_mn = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survival.survexp_mn.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end


"""

    `survexp_fr`

French census datas, drawn from R's package `survexp.fr`. Death rates are available from 1977 to 2019 for males and females aged from 0 to 99. Segmented by `sex ∈ (:male, :female)`

Source: https://www.insee.fr/fr/statistiques/fichier/5390366/fm_t68.xlsx

References: Institut National de la Statistique et des Etudes Economiques
"""
const survexp_fr = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survexp_fr.survexp_fr.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end


"""

    `frpop`

French census datas, sourced from the Human mortality database (not exaclty the same series as hmd_rates[:fr]). 

Segmented by `sex ∈ (:male, :female)`
"""
const frpop = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","frpop.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end