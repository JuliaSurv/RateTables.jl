```@meta
CurrentModule = RateTables
```

# RateTables

The [RateTables.jl](https://github.com/JuliaSurv/RateTables.jl) Julia package provides daily rate table objects extracted from census datasets, tailored for person-year computations. This functionality is similar to [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). 

You can install it using the command below: 

```julia
using Pkg
Pkg.add("https://github.com/JuliaSurv/RateTables.jl")
```

Loading this package exports constant `RateTable` objects. The index refering to all the available rate tables can be found at the bottom of this page. For the sake of this example, we'll use the `hmd_rates` dictionary which stores rates tables extracted from the [Human Mortality Database (HMD)](https://mortality.org).

```@example 1
using RateTables
hmd_rates
```

The output of the REPL shows that we have a `RateTable` object with two covariates `:country` and `:sex`. You can query the available covariates of a given RateTable as such: 

```@example 1
availlable_covariates(hmd_rates, :sex)
```

For this specific dataset, the number of countries is huge and calling `availlable_covariates(hmd_rates, :country)` won't be very useful. Thus, for convenience, we provided details on the country codes separately in another constant object called `hmd_countries`:

```@example 1
hmd_countries
```

Recall that the daily hazard rate of mortality is defined as $-\log(1 - q_x)/365.241$ for an annual death rate $q_x$. We present an alternative approach to displaying mortality tables that is particularly convenient for person-year computations. To obtain daily rates from the tables, you can use the `daily_hazard` function. Its arguments need to be in the following specific format: 

- The `age` parameter should be provided in days, with the conversion factor being 1 year = 365.241 days.
- The `date` parameter should be provided in days as well, with the same conversion factor. 
- The format of other covariates may vary between rate tables, but it's essential to consider that their order is significant.

The `sex` covariate typically has values such as `:male` and `:female`, and sometimes `:total`. For the `hmd_rates` table, we have previously observed two additional covariates: `country` and `sex`. 

Depending on the querying syntax, the order of the passed arguments can be significant. For instance, the daily hazard rate for a Slovene male, on his 20th birthday, which happens to fall on the first of january 2010, can be queried using one of the following syntaxes:  

```@example 1
c = :svn # slovenia. 
a = 20*365.241
d = 2010*365.241
s = :male
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

Note the discrepency with the HMD data. 

Another example with additional covariates would be the `survival::survexp.usr` dataset which includes `race` as a covariate. In this case, the calling structure remains similar: 

```@example 1
r = :white
v1 = daily_hazard(survexp_usr, a, d, s, r)
v2 = daily_hazard(survexp_usr, a, d; sex=s, race=r)
v3 = daily_hazard(survexp_usr, a, d; race=r, sex=s)
v4 = daily_hazard(survexp_usr[s, r], a, d)
(v1,v2,v3,v4)
```

Please note that retrieving these daily hazards is a highly sensitive operation that should be optimized for speed, especially considering it's often used within critical loops. As such, we prioritize the performance of our fetching algorithms.

For a list of the available rate tables, kindly refer to the following index:

## Life random variables

The `Life` function is used to extract individual life profiles (as random variables complient with `Distributions.jl`'s API) from a comprehensive ratetable, by using covariates such as age, gender, and health status or others. Once these life profiles are established, they serve as foundational elements for various analytical practices such as survival probability estimations, expected lifespan calculations, and simulations involving random variables related to life expectancy. 

When applying it to a male individual aged $20$ in $1990$, we get the outcome below: 

```@example 1
L = Life(slopop[:male], 7000, 1990*365.241)
```

Due to the constance of the hazard rates on each cell of the lifetable, the life expectation can be computed through the following formula: 

$$ \mathbf{E}(P) = \int_0^\inf S_p (t) dt = \sum_{j=0}^\inf \frac{S_p(t_j)}{\lambda_p(t_j)(1 - exp(-\lambda_p(t_j)(t_{j+1}-t_j)))} $$

Implemented in the function `Distributions.expectation`:

```@example 1
expectation(L)/365.241
```

We get $57.7$ years left, implying a total life expectancy of about $77$ years for the given individual.

These random variables comply with the [`Distributions.jl`](https://github.com/JuliaStats/Distributions.jl)'s API.

## Package contents

```@index
```

```@autodocs
Modules = [RateTables]
```
