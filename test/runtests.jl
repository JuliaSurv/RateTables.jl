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

        for rt in (slopop, survexp_us, survexp_mn, survexp_fr)
            a = 20*365.241 + 365*rand()
            d = 2010*365.241 + 365*rand()
            s = rand() >0.5 ? :male : :female
            v1 = daily_hazard(rt, a, d, s)
            v2 = daily_hazard(rt, a, d; sex=s)
            v3 = daily_hazard(rt[s], a, d)
            @test v1 == v2
            @test v2 == v3
        end
        
        a = 20*365.241 + 365*rand()
        d = 2010*365.241 + 365*rand()
        s = rand() >0.5 ? :male : :female
        r = rand() > 0.5 ? :white : :black
        v1 = daily_hazard(survexp_usr, a, d, s, r)
        v2 = daily_hazard(survexp_usr, a, d; sex=s, race=r)
        v3 = daily_hazard(survexp_usr[s,r], a, d)
        @test v1 == v2
        @test v2 == v3
    end

    @testset "HMD ratetables" begin
        for (key,rt) in pairs(RT_HMD)
            a = 20*365.241 + 365*rand()
            d = 2010*365.241 + 365*rand()
            s = rand() >0.5 ? :male : :female
            v1 = daily_hazard(rt, a, d, s)
            v2 = daily_hazard(rt, a, d; sex=s)
            v3 = daily_hazard(rt[s], a, d)
            @test v1 == v2
            @test v2 == v3
        end
    end
end


