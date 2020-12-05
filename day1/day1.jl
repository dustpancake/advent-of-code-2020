# from textfile of numbers, find the two that add to 2020, and multiply for the key

const GOAL = Int64(2020)

# empty array
numbers = Int64[]

# read in numbers and parse to Int64
for num in eachline("day1/numbers.txt")
    try
        push!(numbers, tryparse(
            Int64, num
            )
        )
    catch err
        if isa(err, MethodError)
            println("Failed to parse " * num)
        else
            error("Unexpected error parsing " * num)
        end
    end
end

# check if any are null (as tryparse returns null if bad)
if any(ismissing.(numbers))
    index = findfirst(ismissing.(numbers)) # finds first instance of "true"
    error("Bad number conversion @ " * string(index))
end

# sort numbers
sort!(numbers)

function find_two()
    for i in numbers
        diff = GOAL - i
        # check if diff in numbers
        index = findall(x->x==diff, numbers)
        if !isempty(index)
            if length(index) != 1
                warn("multiple indexes found for " * string(i) * ", only showing first")
            end
            othernum = numbers[index[1]]
            println("$i matches with $othernum for product $(i * othernum)")
        end
    end
end


function find_three()
    for first in numbers
        for second in numbers
            diff = GOAL - (first + second)

            index = findall(x->x==diff, numbers)
            if !isempty(index)
                if length(index) != 1
                    warn("multiple indexes found for $first, $second only showing first")
                end
                othernum = numbers[index[1]]
                println("$first, $second, $othernum for product $(first * second * othernum)")
            end
        end
    end
end


find_two()
find_three()