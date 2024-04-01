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

provides a constant dictionary `RT_HMD` from which countries rate tables can be queried as follows:  
```example 1
RT_HMD[:SVN]
julia>
```

The list of availiable countries is as follows: 

```@example 1
Dict(k => RT_HMD[k].country_name for k in keys(RT_HMD))
```

To obtain, for example, the daily hazard rate for a male (code 1), from slovenia, on it's 80th birthday on the 1rst january 2019: 

```@example 1
daily_hazard(RT_HMD[:SVN], 365.241*80, 365.241*2019, 1)
```

```@index
```

```@autodocs
Modules = [RateTables]
```
