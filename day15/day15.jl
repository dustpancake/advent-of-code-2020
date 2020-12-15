using DataStructures: DefaultDict
using Test
using BenchmarkTools: @btime 

input = Int[0, 3, 6]

PositionLookup = DefaultDict{Int, Array{Int, 1}}

function nextitem(item::Int, lookup::PositionLookup)
    positions = lookup[item]
    if length(positions) < 2
        return 0
    else
        return positions[end] - positions[end-1]
    end
end

function populate!(lookup::PositionLookup, val::Int, pos::Int)
    push!(lookup[val], pos)
end

function populate!(lookup::PositionLookup, input::Array{Int, 1})
    foreach(i -> populate!(lookup, i[2], i[1]), enumerate(input))
end


function runseries(input::Array{Int, 1}, turns=10)
    lookup = PositionLookup(Array{Int, 1})
    populate!(lookup, input)

    ni = input[end]
    for i in (1+length(input)):turns
        ni = nextitem(ni, lookup)
        populate!(lookup, ni, i)
    end

    ni
end

@testset "Part 1" begin
    @test runseries([0, 3, 6], 2020) == 436
    @test runseries([1, 3, 2], 2020) == 1
    @test runseries([2, 1, 3], 2020) == 10
    @test runseries([1, 2, 3], 2020) == 27
    @test runseries([2, 3, 1], 2020) == 78
    @test runseries([3, 2, 1], 2020) == 438
    @test runseries([3, 1, 2], 2020) == 1836
end

function part1()
    runseries([14,3,1,0,9,5], 2020)
end


#@testset "Part 2" begin # these take a while to eval ://
#     @test runseries([0, 3, 6], 30000000) == 175594
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
