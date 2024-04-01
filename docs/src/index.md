```@meta
CurrentModule = RateTables
```

# RateTables

Documentation for [RateTables](https://github.com/lrnv/RateTables.jl). This package provides rate tables for person-year computations, alike [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). 

You can install it through : 

```julia
] add https://github.com/JuliaSurv/RateTables.jl
```

Then loading it through 
```julia
using RateTables
```

provides a constant dictionary `RT_HMD` from which countries rate tables can be queried as follows:  
```julia
julia> RT_HMD[:SVN]
RateTable for Slovenia (code SVN):
    Ages, in years from 0 to 110 (in days from 0.0 to 40176.509999999995)
    Date, in years from 1983 to 2019 (in days from 724272.9029999999 to 737421.579)
    Sex is binary coded {0 => female, 1 => male}
You can query daily hazard values through the `daily_hazard` function.

julia>
```

To obtain, for example, the daily hazard rate for a male (code 1), from slovenia, on it's 80th birthday on the 1rst january 2019: 

```julia
julia>  daily_hazard(RT_HMD[:SVN], 365.241*80, 365.241*2019, 1)
0.00016397140489082858

julia> 
```


```@index
```

```@autodocs
Modules = [RateTables]
```
