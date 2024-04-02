```@meta
CurrentModule = RateTables
```

# RateTables

Documentation for [RateTables](https://github.com/JuliaSurv/RateTables.jl). This package provides rate tables for person-year computations, alike [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). 

You can install it through : 

```julia
using Pkg
Pkg.add("https://github.com/JuliaSurv/RateTables.jl")
```

Then loading it through 
```@example 1
using RateTables
```

provides a few constants rate tables objects. In particular:  a constant dictionary `RT_HMD` from which countries rate tables can be queried as follows:  
```example 1
rt = RT_HMD[:SVN] # SVN for slovenia.
```


To obtain, for example, the daily hazard rate for a male, slovene, on its 20th birthday on the first of january 2010, you can call the `daily_hazard` function with several syntaxes: 

```@example 1
a = 20*365.241
d = 2010*365.241
s = :male
v1 = daily_hazard(rt, a, d, s)
v2 = daily_hazard(rt, a, d; sex=s)
v3 = daily_hazard(rt[s], a, d)
(v1,v2,v3)
```

Note that there is a discrepency between HMD datasets and datasets from other places. For completeness, this package also include datasets commonly used in R for census datas, in particular the `relsurv::slopop` dataset for slovenia : 

```@example 1
v1 = daily_hazard(slopop, a, d, s)
v2 = daily_hazard(slopop, a, d; sex=s)
v3 = daily_hazard(slopop[s], a, d)
(v1,v2,v3)
```


Sometimes there is more covariates in the datasets than only the sex. Ths is for example the case for the `survival::survexp.usr` dataset that includes the race. In this case, the calling structure is very similar: 
```@example 1
r = :white
v1 = daily_hazard(survexp_usr, a, d, s, r)
v2 = daily_hazard(survexp_usr, a, d; sex=s, race=r)
v3 = daily_hazard(survexp_usr[s, r], a, d)
(v1,v2,v3)
```


Check out the index below for the list of availiable datasets. 


```@index
```

```@autodocs
Modules = [RateTables]
```
