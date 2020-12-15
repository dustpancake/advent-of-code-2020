using Test
using BenchmarkTools: @btime 

PositionLookup = Dict{Int, Int}

@inline function nextitem!(lookup::PositionLookup, item::Int, pos::Int)
    if haskey(lookup, item)
        ni = pos - lookup[item]
        lookup[item] = pos
        return ni
    else
        lookup[item] = pos
        return 0
    end
end

function runseries(input::Array{Int, 1}, turns=10)
    ni = pop!(input)
    lookup = PositionLookup((val, index) for (index, val) in enumerate(input))

    for i in (1+length(input)):(turns-1)
        ni = nextitem!(lookup, ni, i)
    end

    ni
end

@testset "Part 1" begin
    @test runseries([0, 3, 6], 2020) == 436
    @test runseries([1, 3, 2], 2020) == 1
    @test runseries([2, 3, 1], 2020) == 78
    @test runseries([2, 1, 3], 2020) == 10
    @test runseries([1, 2, 3], 2020) == 27
    @test runseries([3, 2, 1], 2020) == 438
    @test runseries([3, 1, 2], 2020) == 1836
end

function part1()
    runseries([14,3,1,0,9,5], 2020)
end


#@testset "Part 2" begin # these take a while to eval ://
#    @test runseries([0, 3, 6], 30000000) == 175594
#    @test runseries([1, 3, 2], 2020) == 1
#    @test runseries([2, 1, 3], 2020) == 10
#    @test runseries([1, 2, 3], 2020) == 27
#    @test runseries([2, 3, 1], 2020) == 78
#    @test runseries([3, 1, 2], 2020) == 1836
#    @test runseries([3, 2, 1], 2020) == 438
#end

function part2()
    runseries([14,3,1,0,9,5], 30000000)
end

@btime part1()
@time part2()

#runseries([0, 3, 6], 10)