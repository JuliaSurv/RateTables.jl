# RateTables

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://lrnv.github.io/RateTables.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lrnv.github.io/RateTables.jl/dev/)
[![Build Status](https://github.com/lrnv/RateTables.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lrnv/RateTables.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lrnv/RateTables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lrnv/RateTables.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/R/RateTables.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/R/RateTables.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


This package provides rate tables for person-year computations, alike [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). 

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
