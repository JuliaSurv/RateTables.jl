# this file is supposed to get the following files from somewhere online: 

# 1) relsurv::slopop : https://github.com/cran/relsurv/blob/master/data/slopop.rda
# 2) survexp.us, survexp.usr and survexp.mn from survival there https://github.com/therneau/survival/blob/master/man/survexp.us.Rd


# But for the moment it simply gets them from an instance of R loading the corersponding packages. 
# I am sure this could be done a lot better. 




using RCall, DataFrames, CSV

###################################### Helper functions. 
# Load the data from R to Julia
R"""
extract <- function(rt){
    df = expand.grid(dimnames(rt))
    df$value = c(rt)
    return(df)
}
"""
function massage(df)

    # this assumes that predictors are of the form "age, year, sex" at least. 
    # this should be checked manually. 

    df.age = parse.(Int, string.(df.age))
    df.year = parse.(Int, string.(df.year))
    df.sex = Symbol.(string.(df.sex))

    # check spacings: 
    availiable_years = sort(unique(df.year))
    for year in minimum(availiable_years):maximum(availiable_years)
        if !(year ∈ availiable_years)
            subset_previous_year = filter(row -> row.year == year-1, df)
            subset_previous_year.year .+= 1
            df = vcat(df, subset_previous_year)
        end
    end
    sort!(df)
    @assert all(diff(sort(unique(df.year))) .== 1)
    @assert all(diff(sort(unique(df.age))) .== 1)

    return df
end


################################### relsurv::slopop
df = massage(rcopy(R"extract(relsurv::slopop)"))
path = joinpath(@__DIR__, "R_data", "relsurv.slopop.csv")
CSV.write(path, df)

####################################### survival::survexp.us
df = massage(rcopy(R"extract(survival::survexp.us)"))
path = joinpath(@__DIR__, "R_data", "survival.survexp_us.csv")
CSV.write(path, df)

df = massage(rcopy(R"extract(survival::survexp.usr)"))
path = joinpath(@__DIR__, "R_data", "survival.survexp_usr.csv")
CSV.write(path, df)

df = massage(rcopy(R"extract(survival::survexp.mn)"))
path = joinpath(@__DIR__, "R_data", "survival.survexp_mn.csv")
CSV.write(path, df)


####################################### survexp.fr::survexp.fr
df = rcopy(R"extract(survexp.fr::survexp.fr)")
rename!(df, :Var1 => :age, :Var2 => :sex, :Var3 => :year)
df = massage(df)
path = joinpath(@__DIR__, "R_data", "survexp_fr.survexp_fr.csv")
CSV.write(path, df)
