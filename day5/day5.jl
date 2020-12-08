
function decode(seat::AbstractString)::Int
    seat = replace(replace(seat, r"[FL]" => "0"), r"[BR]" => "1")
    parse(Int, seat, base=2) 
end

function test()
    @assert( decode("FBFBBFFRLR")==357 )
    @assert( decode("BFFFBBFRRR")==567 )
    @assert( decode("FFFBBBFRRR")==119 )
    @assert( decode("BBFFBBFRLL")==820 )
end

test()


# read in input
input = open("day5/input.txt", "r") do io
    [i for i in split(read(io, String), "\n") if i != ""]
end

# part 1
println("Part 1")
@show input .|> decode |> findmax

# part 2

function findseat(sids::AbstractArray{<:Int})::Int
    index = first(findall( >(1), sids[2:end] - sids[1:end-1] ))
    return sids[index] + 1
end

println("Part 2")
@show input .|> decode |> sort! |> findseat


# for shits and giggles 
# part 1
map(x->parse(Int,replace(replace(x,r"[FL]"=>"0"),r"[BR]"=>"1"),base=2),eachline("day5/input.txt"))|>findmax
# part 2
map(x->parse(Int,replace(replace(x,r"[FL]"=>"0"),r"[BR]"=>"1"),base=2),eachline("day5/input.txt"))|>sort!|>x->x[findall(>(1),x[2:end]-x[1:end-1])[1]]+1


# both
println(map(x->parse(Int,replace(replace(x,r"[FL]"=>"0"),r"[BR]"=>"1"),base=2),eachline("day5/input.txt"))
    |>sort|>x->(findmax(x)[1],x[findall(>(1),x[2:end]-x[1:end-1])[1]]+1))