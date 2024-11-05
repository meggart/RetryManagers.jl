using RetryManagers
using Test
using RetryManagers.Distributed

@testset "RetryManagers.jl" begin
    addprocs(RetryManager(3))

    r = pmap(_->myid(),1:10)
    @test all(in((2,3,4)),r)

    rmprocs(workers())
end
