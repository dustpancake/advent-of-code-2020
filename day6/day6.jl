
groups = open("day6/input.txt") do io
    split(read(io, String), "\n\n")
end

# part 1
count = mapreduce(
    x->length(Set(replace(x, "\n"=>""))), 
    +, groups
)
@show count


# part 2
count = mapreduce(
    x->length(intersect(split(x)...)),
    +,
    groups
)
@show count