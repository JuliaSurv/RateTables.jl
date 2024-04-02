
"""

    `slopop`

This ratetable corresponds to R's package `relsurv`, drawn from census data set for the Slovene population. 
"""
slopop
const slopop = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","relsurv.slopop.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end


const survexp_us = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survival.survexp_us.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end
const survexp_usr = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survival.survexp_usr.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    df.race = Symbol.(df.race)
    RateTable(df)
end
const survexp_mn = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survival.survexp_mn.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end


"""

    `survexp_us`
    `survexp_usr`
    `survexp_mn`

Census data sets for the US population, drawn from R's package `survival`.

- `survexp_us`: total United States population, by age and sex, 1940 to 2012.
- `survexp_usr`: United States population, by age, sex and race, 1940 to 2014. Race is white or black. For 1960 and 1970 the black population values were not reported separately, so the nonwhite values were used. (Over the years, the reported tables have differed wrt reporting non-white and/or black.)
- `survexp_mn`: total Minnesota population, by age and sex, 1970 to 2013.
    
Each of these tables contains the daily hazard rate for a matched subject from the population, defined as ``-\\log(1-qₓ)`` for ``qₓ`` the 1 year probability of death as reported in the original tables from the US Census. For age 25 in 1970, for instance, ``pₓ=1−qₓ`` is is the probability that a subject who becomes 25 years of age in 1970 will achieve his/her 26th birthday. The tables are recast in terms of hazard per day for computational convenience.
    
age and dates dimensions are in days.
"""
survexp_us, survexp_usr, survexp_mn



"""

    `survexp_fr`

French census datas, drawn from R's package `survexp.fr`.
Death rates are available from 1977 to 2019 for males and females aged from 0 to 99

Source: https://www.insee.fr/fr/statistiques/fichier/5390366/fm_t68.xlsx

References: Institut National de la Statistique et des Etudes Economiques
"""
const survexp_fr = let 
    df = CSV.read(joinpath(@__DIR__,"..","data","R_data","survexp_fr.survexp_fr.csv"), DataFrames.DataFrame)
    df.sex = Symbol.(df.sex)
    RateTable(df)
end