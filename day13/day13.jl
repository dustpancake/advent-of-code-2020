using BenchmarkTools

function get_input(path="day13/test.txt")
    open(path) do io
        (time, ids) = split(read(io, String), "\n")[1:2]
        time = parse(Int, time)
        (time, ids)
    end
end

function timediff(t::Int, id::Int)::Int
    ceil(t / id) * id - t
end

function next_bus(t, ids::AbstractArray)
    diffs = map(i->timediff(t, i), ids)
    index = argmin(diffs)
    ids[index] * diffs[index]
end


function part1()
    t, ids = get_input("day13/input.txt")
    ids = collect(parse(Int, i) for i in split(ids, ",") if i != "x")
    @btime next_bus(t, ids)
end

# part 2

""" didn't end up using these in favour of chinese remainder theorem, which does what i wanted to with mods
function bezout(x, y, α, β, c)::Function
    # a, b have gcd = c. x and y satisfy ax + by = d
    λ -> (α - λ*(x / c), β + λ*(y / c))
end
 
function diffcalc(id, Δt)
    (c, α, β) = gcdx(id, Δt)
    bezout(Δt, id, α, β, c)
end
"""

function crt(ids::AbstractArray)
    # https://en.wikipedia.org/wiki/Chinese_remainder_theorem#Existence_(direct_construction)
    N = BigInt(mapreduce(i->i[1], *, ids))
    mod(sum(map((i) -> begin 
            nᵢ, aᵢ = i
            yᵢ = N ÷ nᵢ
            zᵢ = invmod(yᵢ, nᵢ)
            -aᵢ * yᵢ * zᵢ
        end, ids
    )), N)
end

function part2()
    t, ids = get_input("day13/input.txt")
    ids = collect((parse(Int, v), i-1) for (i, v) in enumerate(split(ids, ",")) if v != "x")
    crt(ids)
end

part2()