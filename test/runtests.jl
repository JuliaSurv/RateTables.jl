using RateTables
using Test
using Aqua

@testset "RateTables.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RateTables)
    end
    # Write your tests here.
end
