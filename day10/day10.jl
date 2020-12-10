using BenchmarkTools
using Combinatorics

input = map(x->parse(Int, x), eachline("day10/input.txt"))

function diffmap!(input::AbstractArray)::Array{Int, 1}
    sort!(input)
    p1 = @view input[2:end]
    p2 = @view input[1:end-1]
    p1 - p2
end

function part1!(dm::AbstractArray)
    (count(==(1), dm) + 1) * (count(==(3), dm) + 1)
end

input
#@btime part1!(diffmap!($input))
#@show part1!(diffmap!(input))

_tribcache = Int[1, 2, 4]
function tribonacci(n)::Int
    n = max(n, 1)
    if n <= length(_tribcache)
        return _tribcache[n]
    else
        val = tribonacci(n-1) + tribonacci(n-2) + tribonacci(n-3)
        push!(_tribcache, val)
        return _tribcache[n]
    end
end



function part2!(dm::AbstractArray)
    """ using counts of successive ones:                                  permutations
        1 3                                                               : 1
        1 1 3          2 3                                                : 2
        1 1 1 3        2 1 3,   1 2 3,   3 3                              : 4
        1 1 1 1 3      2 1 1 3, 1 1 2 3, 1 2 1 3, 2 2 3, 1 3 3, 3 1 3     : 7
        1 1 1 1 1 3    ...                                                : 13
        ...
        tribonacci numbers!
    """
    count = 1
    permuts = 1
    for (i, v) in enumerate(dm)
        if v == 1
            count += 1
        else
            permuts *= tribonacci(count)
            count = 0
        end 
    end
    permuts * tribonacci(count)
end

@btime part2!(diffmap!($input))