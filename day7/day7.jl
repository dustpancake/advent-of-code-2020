import Base: *

re_subbag = r"(\d) (\w+ \w+)"
re_rootbag = r"^(\w+ \w+)"

const SubBag = Pair{SubString, Int}
const BagIndex = Dict{SubString, Array{SubBag}}

function getinput(path="day7/input.txt")::BagIndex
    bags = BagIndex()
    for line ∈ eachline(path)
        root = match(re_rootbag, line)[1]
        bags[root] = map(
            m -> m[2] => parse(Int, m[1]), # map name to number
            eachmatch(re_subbag, line)
        )
    end
    bags
end

function hasgold(barr::Array{SubBag})
    return any(map(first, barr).=="shiny gold")
end

function hasgold(bi::BagIndex, barr::Array{SubBag})
    return any(hasgold(barr)) ? true : any(map(
        b -> hasgold(bi, bi[b.first]), 
        barr
    ))
end

function cascade(bi::BagIndex, barr::Array{SubBag})::Int
    length(barr) == 0 ? 0 : mapreduce(
        b->begin
            (cascade(bi, bi[b.first]) + 1) * b.second
        end,
        +,
        barr
    )
end

function testcase1()
    input = getinput("day7/test.txt")
    @assert count(map(b->hasgold(input, b), values(input))) == 4
end

function testcase2()
    input = getinput("day7/test.txt")
    @assert(cascade(input, input["shiny gold"]) == 32)
end

function testcase3()
    input = getinput("day7/test2.txt")
    @assert(cascade(input, input["shiny gold"]) == 126)
end

function part1(input)
    count(map(b->hasgold(input, b), values(input)))
end

function part2(input)
    cascade(input, input["shiny gold"])
end 

testcase1()

input = getinput("day7/input.txt")

testcase2()
testcase3()

part2(input)