using RateTables
using Test
using Aqua
using RData

@testset "RateTables.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RateTables;ambiguities=false,persistent_tasks = false)
    end
    # Write your tests here.


    @testset "slopop" begin
        slopop = HMDRateTables["SVN"] # slovenia's ratetable
        # daily hazard for a female (code 1)
        # aged 12 in 1979 (at begining of study)
        # after 37 days of study.
        daily_hazard(slopop, 12*365.241 + 37, 1979*365.241 + 37, 1)
    end
end


r_slopop = load("test/slopop.rda")["slopop"]