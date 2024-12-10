using RateTables
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
end


