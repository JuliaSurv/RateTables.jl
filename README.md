# RateTables

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaSurv.github.io/RateTables.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSurv.github.io/RateTables.jl/dev/)
[![Build Status](https://github.com/JuliaSurv/RateTables.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSurv/RateTables.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaSurv/RateTables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSurv/RateTables.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/R/RateTables.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/R/RateTables.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


This package provides rate tables for person-year computations, alike [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). 

Since it is not registered yet, you can install the package from github with: 
```julia
using Pkg
Pkg.add("https://github.com/JuliaSurv/RateTables.jl")
```

Look at the docs [there](https://JuliaSurv.github.io/RateTables.jl/dev/) for the list of available daily rate tables and the syntax to query from them.

Todo : 

- [x] Add non-HMD rate tables from R packages, whith the same interface. 
- [x] Life tables with covariates (country is already somewhat of a covariate..)
- [ ] better proofness to poor inputs (e.g. return missings ? return errors?)
- [ ] better docs
- [ ] better tests
