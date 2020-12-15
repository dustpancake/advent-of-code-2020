using DataStructures: DefaultDict, CircularBuffer
using Test
using BenchmarkTools: @btime 


PositionStorage = CircularBuffer{Int}
PositionLookup = DefaultDict{Int, PositionStorage}

function nextitem(item::Int, lookup::PositionLookup)
    positions = lookup[item]
    if length(positions) >= 2
        return positions[end] - positions[end-1]
    else
        return 0
    end
end

function populate!(lookup::PositionLookup, val::Int, pos::Int)
    push!(lookup[val], pos)
end

@inline function populate!(lookup::PositionLookup, input::Array{Int, 1})
    foreach(i -> populate!(lookup, i[2], i[1]), enumerate(input))
end


function runseries(input::Array{Int, 1}, turns=10)
    lookup = PositionLookup(_->PositionStorage(2))
    populate!(lookup, input)

    ni = input[end]
    for i in (1+length(input)):turns
        #print("Turn $i, processing $ni")
        ni = nextitem(ni, lookup)
        #println(" yielding $ni")
        populate!(lookup, ni, i)
        #@show lookup
        #println()
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
#@btime part2()
