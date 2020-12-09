getinput(path::AbstractString="day9/test.txt") = map(x->parse(Int, x), eachline(path))

@inline function checknum(subarr::AbstractArray{Int64}, num::Int)::Bool
    for (i,v) in enumerate(subarr)
        if any(findall(==(num-v), subarr) .!= i)
            return true
        end
    end 
    return false 
end

function part1(input::AbstractArray{Int64}, mask::Int)::Tuple{Int,Int}
    for (i, v) in enumerate(view(input, mask+1:length(input))) # using raw for loop over algorithm guaruntees short circuit
        if !(checknum(view(input, i:i+mask), v)) # views to save memory 
            return (i+mask, v)
        end
    end
    warn("No solution found for part 1.")
    return (-1, -1)
end

function testcase1()
    input = getinput()
    @assert(part1(input, 5) == (15, 127))
end

testcase1()

# part 1
input = getinput("day9/input.txt")
index, key = part1(input, 25)
println("Part 1: key=$key, index=$index")

function consecutive(input::AbstractArray{Int64}, goal::Int)
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

function testcase2()
    input = getinput("day9/test.txt")
    @assert(part2(input, 5, 127) == 62)
end

testcase2()

# part 2 
solution = part2(input, 25, key)
println("Part 2: sol=$solution")