module RateTables

import CSV
using DataFrames

const RT_DAYS_IN_YEAR = 365.241

include("RateTable.jl")
include("RT_HMD.jl")
include("RT_R.jl")

export RT_HMD, slopop, survexp_us, survexp_usr, survexp_mn, survexp_fr, daily_hazard

end
