module RateTables

import CSV
using DataFrames

const RT_DAYS_IN_YEAR = 365.241

include("RateTable.jl")
include("hmd_rates.jl")
include("r_rates.jl")

export hmd_rates, hmd_countries, slopop, survexp_us, survexp_usr, survexp_mn, survexp_fr, daily_hazard, availlable_covariates

end
