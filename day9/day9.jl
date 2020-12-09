getinput(path::AbstractString="day9/test.txt") = map(x->parse(Int, x), eachline(path))

function part1(input::AbstractArray{Int64}, mask::Int)::Tuple{Int, Int}
    for (i, v) in enumerate(input[mask + 1: end])
        subarr = @view input[i:i + mask - 1]
        if !any(i -> v - i in subarr, subarr)
            return (i + mask, v)
        end
    end
    warn("No solution found.")
    return (-1, -1)
end

function testcase1()
    input = getinput()
    @show part1(input, 5)

    @assert(part1(input, 5) == (15, 127))
end

testcase1()

# part 1
input = getinput("day9/input.txt")
index, key = part1(input, 25)
println("Part 1: key=$key, index=$index")

@inline function consecutive(input::AbstractArray{Int64}, goal::Int)
    partial_sum = 0
    for i in 1:length(input)
        partial_sum += input[i] # partial sum
        if partial_sum > goal # break if bigger than goal
            break
        elseif partial_sum == goal
            return i - 1
        end
    end
    return nothing
end

function part2(input::AbstractArray{Int64}, mask::Int, key::Int)
    consecutive_range = nothing
    for i in 1:length(input)-mask
        cindex = consecutive(view(input, i:i+mask), key)
        if !(isnothing(cindex))
            consecutive_range = i:i+cindex
            break
        end
    end
    
    selection = input[consecutive_range]
    maximum(selection) + minimum(selection)
end

function part2b(input::AbstractArray{Int64}, key::Int)
    """ inspired by Tom Kwong's solution """
    i=1
    j=2
    partial_sum = input[i] + input[j]
    while j < length(input)
        if partial_sum < key
            j += 1
            partial_sum += input[j]
        elseif partial_sum > key
            partial_sum -= input[i]
            i += 1
        else
            return i, j, sum(extrema(input[i:j]))
        end
    end
    return -1
end

function testcase2()
    input = getinput("day9/test.txt")
    @assert(part2(input, 5, 127) == 62)
end

testcase2()

# part 2 
solution = part2(input, 25, key)
println("Part 2: sol=$solution")

using BenchmarkTools
#@btime part2($input, 25, $key)
#@btime part2b($input, $key)

@btime part1b($input, 25)