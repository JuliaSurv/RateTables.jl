using RateTables
using Distributions
using Test
using Aqua
using RData

@testset "RateTables.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RateTables;ambiguities=false,persistent_tasks = false)
    end
    # Write your tests here.

    @testset "R rate tables" begin

        for rt in (slopop, survexp_us, survexp_mn, survexp_fr, frpop)

            @test available_covariates(rt, :sex) == (:female, :male) # to check if the function is working. 

            a = 20*365.241 + 365*rand()
            d = 2010*365.241 + 365*rand()
            s = rand() >0.5 ? :male : :female
            v1 = daily_hazard(rt, a, d, s)
            v2 = daily_hazard(rt, a, d; sex=s)
            v3 = daily_hazard(rt[s], a, d)
            @test v1 == v2
            @test v2 == v3

            # check life:
            L = Life(rt[s], a, d)
            e, r = expectation(L), rand(L, 10)
            @test all(a .+ r .<= 120*365.241) # noone lives too long. 
            @test e+a <= 120*365.241
        end
        
        a = 20*365.241 + 365*rand()
        d = 2010*365.241 + 365*rand()
        s = rand() >0.5 ? :male : :female
        r = rand() > 0.5 ? :white : :black
        v1 = daily_hazard(survexp_usr, a, d, s, r)
        v2 = daily_hazard(survexp_usr, a, d; sex=s, race=r)
        v3 = daily_hazard(survexp_usr, a, d; race=r, sex=s)
        v4 = daily_hazard(survexp_usr[s,r], a, d)
        @test v1 == v2
        @test v2 == v3
        @test v4 == v3

        # check life:
        L = Life(survexp_usr[s,r], a, d)
        e, r = expectation(L), rand(L, 10)
        @test all(a .+ r .<= 120*365.241) # noone lives too long. 
        @test e+a <= 120*365.241
    end

    @testset "HMD ratetables" begin
        for c in keys(hmd_countries)
            a = 20*365.241 + 365*rand()
            d = 2010*365.241 + 365*rand()
            s = rand() >0.5 ? :male : :female
            v1 = daily_hazard(hmd_rates, a, d, c, s)
            v2 = daily_hazard(hmd_rates, a, d; sex=s, country=c)
            v3 = daily_hazard(hmd_rates, a, d; country=c, sex=s)
            v4 = daily_hazard(hmd_rates[c,s], a, d)
            @test v1 == v2
            @test v2 == v3
            @test v4 == v3

            # check life:
            L = Life(hmd_rates[c,s],a,d)
            e, r = expectation(L), rand(L, 10)
            @test all(a .+ r .<= 120*365.241) # noone lives too long. 
            @test e+a <= 120*365.241
        end
    end

    @testset "Dont go out of bound" begin
        daily_hazard(survexp_fr[:male], 20*365.241, (survexp_fr[:male].year_min-1)*365.241+12)
    end

    @testset "Test show method running" begin
        show(slopop)
        show(slopop[:male])
    end

    @testset "Life analytic checks (exponential case)" begin
        # Construct a BasicRateTable with a single age/year cell and
        # constant daily hazard lambda, so the associated Life is
        # exactly an exponential distribution with rate lambda.
        λ = 0.02
        values = fill(λ, 1, 1)
        ages = [0]
        years = [0]
        brt = RateTables.BasicRateTable(values, ages, years)
        L = Life(brt, 0.0, 0.0)

        # Check hazard and cumulative hazard against the exponential model
        for t in (10.0, 100.0, 400.0, 1000.0)
            @test isapprox(RateTables.hazard(L, t), λ; rtol=1e-12)
            @test isapprox(RateTables.cumhazard(L, t), λ * t; rtol=1e-12)
            @test isapprox(ccdf(L, t), exp(-λ * t); rtol=1e-12)
            # Consistency relation h(t) = f(t) / S(t)
            @test isapprox(RateTables.hazard(L, t), pdf(L, t) / ccdf(L, t); rtol=1e-12)
        end

        # Analytic expression for E[T^k * exp(-T)] when T ~ Exp(λ):
        #   E[T^k * exp(-T)] = λ * Γ(k+1) / (1 + λ)^(k+1)
        for k in 0:3
            theo = λ * factorial(k) / (1 + λ)^(k + 1)
            emp = RateTables.shifted_moment(L, k)
            @test isapprox(emp, theo; rtol=1e-10, atol=1e-12)
        end
    end

    @testset "Characteristic function vs pdf consistency" begin
        # Build a small BasicRateTable and extract a Life
        using Distributions
        values = [5e-4 5e-4; 5e-4 5e-4]
        brt = RateTables.BasicRateTable(values, [0,1], [2000,2001])
        a = 30*RateTables.RT_DAYS_IN_YEAR
        d = 2000*RateTables.RT_DAYS_IN_YEAR
        L = Life(brt, a, d)

        t0 = 100.0 # time (in days) where we compare pdfs
        pdf_ref = Distributions.pdf(L, t0)

        # Numerical inversion of the characteristic function:
        # f(t) = (1 / (2π)) ∫_{-U}^{U} φ(u) e^{-i u t} du
        U = 200.0
        N = 4001  # odd so that zero is included
        us = range(-U, stop=U, length=N)
        du = (2U) / (N - 1)

        s = zero(ComplexF64)
        for u in us
            s += Distributions.cf(L, u) * exp(-im * u * t0)
        end
        f_est = real(s * du / (2pi))

        @test isfinite(f_est)
        # Loose tolerance because numerical inversion is crude
        @test isapprox(f_est, pdf_ref; atol=1e-3, rtol=1e-2)
    end
end


