```@meta
CurrentModule = RateTables
```

# RateTables

The [RateTables.jl](https://github.com/JuliaSurv/RateTables.jl) Julia package provides daily rate table objects from census datasets targeted at person-year computations, alike [R's `ratetable` class](https://www.rdocumentation.org/packages/survival/versions/3.2-3/topics/ratetable). 

You can install it through: 

```julia
using Pkg
Pkg.add("https://github.com/JuliaSurv/RateTables.jl")
```

Loading this package exports a few constant `RateTable` objects. See the bottom of this page for the available rate tables. For the sake of the example, we'll use the `hmd_rates` dictionary, which stores rates tables extracted from the [Human Mortality Database (HMD)](https://mortality.org).

```@example 1
using RateTables
hmd_rates
```

The output of the REPL show that we have a `RateTable` object with two covariates `:country` and `:sex`. You can query the availiable covariates of a given RateTable: 

```@example 1
availlable_covariates(hmd_rates, :sex)
```

For this specific dataset, the number of countries is huge and calling `availlable_covariates(hmd_rates, :country)` wont be very usefull. For convenience, we provided details on the country codes separately in an other constant object `hmd_countries`:

```@example 1
hmd_countries
```

Recall that a daily hazard rate of mortality is defined as $-\log(1 - q_x)/365.241$ for an annual death rate $q_x$. This is an alternative form of presenting mortality tables that is particularly convenient for person-year computations. To obtain daily rates from the tables, you have to use the `daily_hazard` function. It needs to be called with arguments in a specific format: 

- The `age` needs to be given in days, and the converting factor is 1 year = 365.241 days.
- The `date` also needs to be given in days, same converting factor. 
- Other covariates formats vary from rate tables to rate tables, but their order matters.

Usually, the `sex` covariates has values `:male`, `:female`, sometimes `:total`. For `hmd_rates`, we already saw that there was two additional covariates: `country` and `sex`. 

Depending on the querying syntax, the order of the passed argument can matter. For example, the daily hazard rate for a slovene male, on its 20th birthday the first of january 2010 can be queried with one of the following syntaxes:  

```@example 1
c = :svn # slovenia. 
a = 20*365.241
d = 2010*365.241
s = :male
v1 = daily_hazard(hmd_rates, a, d, c, s)
v2 = daily_hazard(hmd_rates, a, d; country=c, sex=s)
v3 = daily_hazard(hmd_rates, a, d; sex=s, country=c) # when using kwargs syntax, order of additional covariates does not matter. 
v4 = daily_hazard(hmd_rates[c, s], a, d) # here the order of arguments (c,s) also matter. 
(v1,v2,v3, v4)
```

For completeness, this package also include datasets commonly used in R for census datas, in particular the `relsurv::slopop` dataset for slovenia: 

```@example 1
daily_hazard(slopop, a, d; sex=s)
```

Note the discrepency with HMD data. 

Another example with additional covariates is the `survival::survexp.usr` dataset that includes a race covariate from us census data. In this case, the calling structure is very similar: 
```@example 1
r = :white
v1 = daily_hazard(survexp_usr, a, d, s, r)
v2 = daily_hazard(survexp_usr, a, d; sex=s, race=r)
v3 = daily_hazard(survexp_usr, a, d; race=r, sex=s)
v4 = daily_hazard(survexp_usr[s, r], a, d)
(v1,v2,v3,v4)
```

Note that fetching these daily hazard is a very sensitive operation that should be as fast as possible since it is usually used in the middle of very-hot loops. Therefore, we take care of the performance of our fetching algorithms.

Check out the following index for a list of availiable ratetables:

## Life function

The `Life` function is used to extract individual life profiles from a comprehensive ratetable, by using covariates such as age, gender, and health status or others. Once these life profiles are established, they serve as foundational elements for various analytical practices such as survival probability estimations, expected lifespan calculations, and simulations involving random variables related to life expectancy. 

When applying it to a male individual aged $20$ in $1990$, we get the outcome below: 

```@example 1
L = Life(slopop[:male], 7000, 1990*365.241)
```

With these results, the approximated lifespan left is thus calculated using: 

$$ \mathbf{E}(P) = \int_0^\inf S_p (t) dt = \sum_{j=0}^\inf \frac{S_p(t_j)}{\lambda_p(t_j)(1 - exp(-\lambda_p(t_j)(t_{j+1}-t_j)))} $$

Simplified by the function `expectation`:

```@example 1
expectation(L)/365.241
```

We get $57.7$ years left, meaning the life expectancy is around $77$ years old for the given individual.

## Package contents

```@index
```

```@autodocs
Modules = [RateTables]
```
