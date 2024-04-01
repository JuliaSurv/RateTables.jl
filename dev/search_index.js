var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = RateTables","category":"page"},{"location":"#RateTables","page":"Home","title":"RateTables","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for RateTables. This package provides rate tables for person-year computations, alike R's ratetable class. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can install it through : ","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"https://github.com/JuliaSurv/RateTables.jl\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Then loading it through ","category":"page"},{"location":"","page":"Home","title":"Home","text":"using RateTables","category":"page"},{"location":"","page":"Home","title":"Home","text":"provides a constant dictionary RT_HMD from which countries rate tables can be queried as follows:  ","category":"page"},{"location":"","page":"Home","title":"Home","text":"RT_HMD[:SVN]\njulia>","category":"page"},{"location":"","page":"Home","title":"Home","text":"The list of availiable countries is as follows: ","category":"page"},{"location":"","page":"Home","title":"Home","text":"Dict(k => RT_HMD[k].country_name for k in keys(RT_HMD))","category":"page"},{"location":"","page":"Home","title":"Home","text":"To obtain, for example, the daily hazard rate for a male (code 1), from slovenia, on it's 80th birthday on the 1rst january 2019: ","category":"page"},{"location":"","page":"Home","title":"Home","text":"daily_hazard(RT_HMD[:SVN], 365.241*80, 365.241*2019, 1)","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [RateTables]","category":"page"},{"location":"#RateTables.RT_HMD","page":"Home","title":"RateTables.RT_HMD","text":"`RT_HMD`\n\nDictionary that contains the rates tables for each country.  The country codes are used to differentiate them. \n\nThese rates tables contain daily hazard rates for both sexes. They are derived from annual death probabilities (qₓ's) from the Human Mortality Database at https://www.mortality.org/\n\nDayly hazard for a slovenian male (code 0), born on the 1rst of january 1927, 192 days after his 37th birthday can for example be obtained as follows:\n\nsolovia_rt = RT_HMD[:SVN] daily_hazard(slovenia_rt, 37*RT_DAYS_IN_YEAR + 192, 1927*RT_DAYS_IN_YEAR + 192, 1)\n\nThe list of availiables countries can be queried via: \n\nDict(k => RT_HMD[k].country_name for k in keys(RT_HMD))\n\n\n\n\n\n","category":"constant"},{"location":"#RateTables.RateTable","page":"Home","title":"RateTables.RateTable","text":"RateTable\n\nThis class deals with daily rate tables used in person-years computation.  For the moment it simply holds data from the HMD. \n\n\n\n\n\n","category":"type"},{"location":"#RateTables.daily_hazard-NTuple{4, Any}","page":"Home","title":"RateTables.daily_hazard","text":"`daily_hazard(rt,age,date,sex)`\n\nThis function queries daily hazard values from a given RateTable. The parameters age and date have to be in days (1 year = 365.241 days). Parameter sex is coded 0 for females and 1 for males. \n\n\n\n\n\n","category":"method"}]
}
