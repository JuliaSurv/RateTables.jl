```@meta
CurrentModule = RateTables
CollapsedDocStrings = true
```

# RateTables.jl

The [`RateTables.jl`](https://github.com/JuliaSurv/RateTables.jl) Julia package provides daily rate table objects extracted from census datasets, tailored for person-year computations. This functionality is similar to [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). You can install and load it through:

```julia
using Pkg
Pkg.add("https://github.com/JuliaSurv/RateTables.jl")
```

## `RateTables` objects

Loading this package exports several constant `RateTable` objects, which list [given below](@ref "Exported RateTables"). Since they are exported, you can simply call them after `using RateTables` as follow : 

```@example 1
using RateTables
hmd_rates
```

This `hmd_rates` rate table represents mortality rates extracted from the [Human Mortality Database (HMD)](https://mortality.org). The output of the REPL shows that we have a `RateTable` object with two covariates `:country` and `:sex`. You can query the available covariates of a given `RateTable` as such: 

```@example 1
available_covariates(hmd_rates, :sex)
```

For this specific dataset, the number of countries is huge and calling `available_covariates(hmd_rates, :country)` won't be very useful. Thus, for convenience and only for this dataset we provided details on the country codes separately in another constant object called `hmd_countries`:

```@example 1
hmd_countries
```

You can then use these covariates to subset the Rate Table object: 

```@example 1
brt = hmd_rates[:svn,:male]
```

You obtain another object of the class `BasicRateTable`, as the core of the implementation. These objects have very strict internal characteristics. They mostly hold a matrix of daily hazard rates, indexed by ages (yearly) and dates (yearly too). The show function shows you the ranges of values for both ages and dates. When we constructed the life tables, we took care of other irregularities so that they all have exactly this shape (yearly intervals on both axes). 

The most important thing that you can do with them is querying mortality rates, which is done through the `daily_hazard` function.

## Daily hazard 


Recall that the daily hazard rate of mortality is defined as $-\log(1 - q_x)/365.241$ for an annual death rate $q_x$. We present an alternative approach to displaying mortality tables that is particularly convenient for person-year computations. To obtain daily rates from the tables, you can use the `daily_hazard` function. Its arguments need to be in the following specific format: 

- The `age` parameter should be provided in days, with the conversion factor being 1 year = 365.241 days.
- The `date` parameter should be provided in days as well, with the same conversion factor. 
- The format of other covariates may vary between rate tables, but it's essential to consider that their order is significant.

The `sex` covariate typically has values such as `:male` and `:female`, and sometimes `:total`. For the `hmd_rates` table, we have previously observed two additional covariates: `country` and `sex`. Recall that you can use the `available_covariates` function to obtain these informations.

There are several querying syntax, all lowering to the same code. You are free to choose the syntax that you prefer. Depending on the querying syntax, the order of the passed arguments can be significant. For instance, the daily hazard rate for a Slovene male, on his 20th birthday, which happens to fall on the tenth of January 2010, can be queried using one of the following syntaxes:  

```@example 1
c = :svn # slovenia. 
s = :male
a = 20 * 365.241 # twenty years old
d = 2010 * 365.241 + 10 # tenth of january 2010

v1 = daily_hazard(hmd_rates, a, d, c, s)
v2 = daily_hazard(hmd_rates, a, d; country=c, sex=s)
v3 = daily_hazard(hmd_rates, a, d; sex=s, country=c) # when using kwargs syntax, the order of additional covariates does not matter. 
v4 = daily_hazard(hmd_rates[c, s], a, d) # here, the order of the arguments (c,s) matters. 
(v1,v2,v3,v4)
```

For completeness, this package also includes datasets commonly used in R for census data, particularly, the `relsurv::slopop` dataset pertaining to Slovenia: 

```@example 1
daily_hazard(slopop, a, d; sex=s)
```

Note the discrepancy with the HMD data: the source of the information is not exactly the same and so the rates dont perfectly match. Another example with additional covariates would be the `survival::survexp.usr` dataset which includes `race` as a covariate. In this case, the calling structure remains similar: 

```@example 1
r = :white
v1 = daily_hazard(survexp_usr, a, d, s, r)
v2 = daily_hazard(survexp_usr, a, d; sex=s, race=r)
v3 = daily_hazard(survexp_usr, a, d; race=r, sex=s)
v4 = daily_hazard(survexp_usr[s, r], a, d)
(v1,v2,v3,v4)
```

Please note that retrieving these daily hazards is a highly sensitive operation that is very optimized for speed, especially considering it's often used within critical loops. As such, we prioritized the performance of our fetching algorithms over convenience of other parts of the implementation. The core algorithm is as follows: 

- Fetch the right `BasicRateTable` from a dictionary using the provided covariates
- Convert from days to years the provided ages and dates
- Index the rate matrix at corresponding indices. 

If you feel like you are not getting top fetching performance, please open an issue. 

## Life random variables

The `Life` function is used to extract individual life profiles (as random variables compliant with `Distributions.jl`'s API) from a `RateTable`, by using covariates such as age, gender, and health status or others. Once these life profiles are established, they serve as foundational elements for various analytical practices such as survival probability estimations, expected lifespan calculations, and simulations involving random variables related to life expectancy. 

When applying it to a male individual aged $20$ in $1990$, we get the outcome below: 

```@example 1
L = Life(slopop[:male], 7000, 1990*365.241)
```

Since hazard rates are constants on each cell of a rate tables, the life expectation can be computed exactly through the following formula: 

$$\mathbf{E}(P) = \int_0^\inf S_p (t) dt = \sum_{j=0}^\inf \frac{S_p(t_j)}{\lambda_p(t_j)(1 - exp(-\lambda_p(t_j)(t_{j+1}-t_j)))}$$

Two approximations are made when the life gets out of the life table:

- The last line of the ratetable is assumed to last until eternity. Indeed, the last line represents persons that are already 110 years old, and thus assuming that their future death rates are constants is not that much of an issue. 
- When on the other hand a life exits the ratetable from the right, i.e. into the future but at a young age, we assume the last column of the rate table to define the future for this person.

All this is implemented as a method for the `Distributions.expectation` function, since Lifes are random variables:

```@example 1
expectation(L)/365.241
```

On this example, we get $57.7$ years left, implying a total life expectancy of about $77$ years for the given individual.

These random variables comply with the [`Distributions.jl`](https://github.com/JuliaStats/Distributions.jl)'s API.

## Exported RateTables

```@autodocs
Modules = [RateTables]
Filter = t -> isa(t,RateTables.AbstractRateTable)
```

## Other docstrings

```@autodocs
Modules = [RateTables]
Filter = t -> !isa(t,RateTables.AbstractRateTable)
```
