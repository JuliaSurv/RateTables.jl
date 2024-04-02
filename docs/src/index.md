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

Then loading this package provides a few constants rate tables objects. See the bottom of this page for the available rate tables. For the sake of the example, we'll use the `hmd_rates` dictionary, which stores rates tables extracted from the [Human Mortality Database (HMD)](https://mortality.org).

```@example 1
using RateTables
hmd_rates
```

To obtain, for example, the daily hazard rate for a male, slovene, on its 20th birthday on the first of january 2010, you can call the `daily_hazard` function. It needs to be called with the arguments in a specific format: 

- The age needs to be given in days, and the converting factor is 1 year = 365.241 days.
- The date also needs to be given in days, same converting factor. 
- Other covariates formats depend on the rate table. Usually, there is a `sex` covariates with values `:male` and `:female`, sometimes `:total` too, but other covariates might have different format depending on the rate table. In particular, the country is a covariate in this particular ratetable. 

For `hmd_rates`, there are two additional covariates: country and sex, in this order. Depending on the querying syntax, the order of the passed argument might matter: 
```@example 1
c = :svn # slovenia. 
a = 20*365.241
d = 2010*365.241
s = :male
v1 = daily_hazard(hmd_rates, a, d, c, s)
v2 = daily_hazard(hmd_rates, a, d; country=c, sex=s)
v3 = daily_hazard(hmd_rates, a, d; sex=s, country=c) # when using kwargs syntax, order of additional covariates does not matter. 
v4 = daily_hazard(hmd_rates[c, s], a, d) # here the order of arguments (c,s) also matter. 
(v1,v2,v3, v4)
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

Fetching these daily hazard is a very sensitive operation that should be as fast as possible since it is usually used in the middle of very-hot loops. Therefore, we take care of the performance of our fetching algorithms.

Check out the folliwng index for a list of availiable ratetables:

```@index
```

```@autodocs
Modules = [RateTables]
```
