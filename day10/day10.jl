using BenchmarkTools

function diffmap!(input::AbstractArray)::Array{Int, 1}
    sort!(input)
    p1 = @view input[2:end]
    p2 = @view input[1:end-1]
    p1 - p2
end

function part1!(dm::AbstractArray)
    (count(==(1), dm) + 1) * (count(==(3), dm) + 1)
end

function tribonacci(n)::Int
    """ bare bones implementation """
    if n <= 1
        return 1
    elseif n == 2
        return 2
    elseif n == 3 
        return 4
    else
        return tribonacci(n-1) + tribonacci(n-2) + tribonacci(n-3)  
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
        looks like tribonacci numbers 
    """
    count = 1
    permuts = 1
    for v in dm
        if v == 1
            count += 1
        else
            permuts *= tribonacci(count)
            count = 0
        end 
    end
    permuts * tribonacci(count)
end

# read in file
input1 = map(x->parse(Int, x), eachline("day10/input.txt"))

@btime part1!(diffmap!($input))

@btime part2!(diffmap!($input))

println("Part 1 ", part1!(diffmap!(input)))
println("Part 2 ", part2!(diffmap!(input)))
