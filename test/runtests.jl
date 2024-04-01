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
        slopop = RT_HMD[:SVN] # slovenia's ratetable
        # daily hazard for a female (code 1)
        # aged 12 in 1979 (at begining of study)
        # after 37 days of study.
        daily_hazard(slopop, 12*365.241 + 37, 1989*365.241 + 37, 1)
    end

    # issue: this rate table from R has not the same sources as the HMD ones... 
    # So we need to do something else for ratetables used in person-year work in R... 
    r_slopop = load(joinpath(@__DIR__,"slopop.rda"))["slopop"]
    

end


