using LinearAlgebra
using BenchmarkTools

function getinput(path="day12/input.txt") 
    groups = map(x->match(r"(\w)(\d+)", x), eachline(path))
    return [g[1] => parse(Int, g[2]) for g in groups]
end

abstract type Navigable end
mutable struct Ship <: Navigable
    dir::Vector{Int}      # direction unit vector
    pos::Vector{Int}      # current position vector
    Ship(dir) = new(dir, [0,0])
end

function rotationmatrix(angle::Int)::Matrix{Int}
    rad = deg2rad(angle)
    c = cos(rad)
    s = sin(rad)
    convert.(Int, round.([c -s ; s c]))
end

# basis vectors
const e₁, e₂ = Int[1, 0], Int[0, 1]
vectorindex = Dict{String, Function}(
    "N" => (d) -> (d * e₁),     # north
    "E" => (d) -> (d * e₂),     # east 
    "S" => (d) -> (d * -e₁),    # south 
    "W" => (d) -> (d * -e₂),    # west
    "F" => (d) -> d,
    "L" => (angle) -> rotationmatrix(-angle),
    "R" => (angle) -> rotationmatrix(angle)
)

function veclookup(p::Pair{<:SubString, Int})
    vfunc = vectorindex[p[1]]
    vfunc(p[2])
end

function move!(s::Navigable, v::Vector{Int})
    s.pos += v
end

function move!(s::Navigable, v::Matrix{Int})
    s.dir = v * s.dir
end

function move!(s::Navigable, d::Int) # forward distance
    s.pos += s.dir * d
end

function move!(s::Navigable, p::Pair{<:SubString, Int})
    #println("Moving $s with $p")
    move!(s, veclookup(p))
end

function l1dist(s::Vector{Int})
    abs(s[1]) + abs(s[2])
end

function part1()
    s = Ship(e₂)
    input = getinput()
    map(p->move!(s, p), input)
    l1dist(s.pos)
end


p1 = @btime part1()
println("Part 1 = $p1")

# part 2

mutable struct WaypointShip <: Navigable
    dir::Vector{Int}    
    pos::Vector{Int}      # current position vector
    WaypointShip(pos) = new(pos, [0,0])
end

function move!(s::WaypointShip, v::Vector{Int})
    s.dir += v
end

function part2()
    s = WaypointShip([1, 10])
    input = getinput()
    map(p->move!(s, p), input)
    l1dist(s.pos)
end

part2()