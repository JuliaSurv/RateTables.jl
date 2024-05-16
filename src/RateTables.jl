module RateTables

import CSV
using DataFrames
using Distributions
import Distributions: ccdf, cdf, expectation
using Base.Cartesian

const RT_DAYS_IN_YEAR = 365.241
const RT_YEARS_IN_DAY = Float64(1/big"365.241") # precise

include("RateTable.jl")
include("hmd_rates.jl")
include("r_rates.jl")
include("Life.jl")

export hmd_rates,
       hmd_countries,
       slopop,
       survexp_us,
       survexp_usr,
       survexp_mn,
       survexp_fr,
       daily_hazard,
       availlable_covariates,
       frpop,
       Life,
       expectation,
       cumhazard,
       ccdf

end
