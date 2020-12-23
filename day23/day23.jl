import Base: getindex, setindex!, popat!

using BenchmarkTools: @btime

mutable struct CupGame
    current::Int
    cups::Dict{Int, Int} # single direction linked list analog
    pickup::Vector{Int}
    minval::Int
    maxval::Int
end

function CupGame(cups::Vector{Int})::CupGame
    cdict = Dict{Int, Int}(v=>cups[i+1] for (i, v) in enumerate(cups[1:end-1]))
    cdict[cups[end]] = cups[1]
    CupGame(cups[1], cdict, zeros(Int, 3), minimum(cups), maximum(cups))
end

function pickup!(c::CupGame, ptr::Int)
    for i in 1:3
        ptr = c.cups[ptr]
        c.pickup[i] = ptr
    end
    c.cups[c.current] = c.cups[ptr]
end

function getdest(c::CupGame)::Int
    dest = c.current
    while dest in c.pickup || dest == c.current
        dest -= 1
        if dest < c.minval
            dest = c.maxval
        end
    end
    dest
end

function movehand!(c::CupGame, dest::Int)
    link = c.cups[dest]
    c.cups[dest] = c.pickup[1]
    c.cups[c.pickup[3]] = link
end

function play!(c::CupGame)
    ptr = c.current
    
    #println("pickup")
    #@btime pickup!($c, $ptr)
    pickup!(c, ptr)
    
    #println("dest")
    #dest = @btime getdest($c)
    dest = getdest(c)
    
    #println("movehand")
    #@btime movehand!($c, $dest)
    movehand!(c, dest)

    c.current = c.cups[c.current]
end

function assemble(c::CupGame)::String 
    arr = Int[]
    i = c.cups[1]
    while i != 1
        push!(arr, i)
        i = c.cups[i]
    end
    join(arr)
end

function playrounds!(c::CupGame, n::Int)
    for i in 1:n
        #println("\nMOVE $i")
        #@show c.current
        play!(c)
    end
    c
end


test = map(i->parse(Int, i), split("389125467", "")) 
input = map(i->parse(Int, i), split("792845136", "")) 

c = CupGame(input)
c = playrounds!(c, 100)
@show assemble(c)


# part 2 naive
function makemillion!(vec::Vector{Int})::Vector{Int}
    for i in (maximum(vec)+1):1000000
        push!(vec, i)
    end
    vec
end

c2 = CupGame(makemillion!(input))
playrounds!(c2, 10000000)

v1 = c2.cups[1]
v2 = c2.cups[v1]
@show v1, v2
v1 * v2