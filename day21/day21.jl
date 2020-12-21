import Base: show
using DataStructures: DefaultDict
using BenchmarkTools: @btime

struct FoodItem
    ingredients::Vector{SubString}
    alergens::Vector{SubString}
end

FoodIndex = Dict{SubString, Vector{FoodItem}}

function show(io::IO, fi::FoodItem)
    write(io, "FoodItem: with $(length(fi.ingredients)) ingredients.")
end

function foodparser(line::AbstractString)::FoodItem
    (ingredients, alergens) = split(line, "contains")
    FoodItem(
        map(i->i[1], eachmatch(r"(\w+)", ingredients)),
        map(i->i[1], eachmatch(r"(\w+)", alergens))
    )
end
function getinput(path="day21/test.txt")::Vector{FoodItem}
    map(foodparser, eachline(path))
end

function makeindexes(farr::Vector{FoodItem})::FoodIndex
    alergens = DefaultDict{SubString, Vector{FoodItem}}(Vector{FoodItem})
    for f in farr
        for a in f.alergens
            push!(alergens[a], f)
        end
    end
    alergens
end


function compare(f::FoodItem, o::Vector{FoodItem})::Tuple{Vector{SubString}, Vector{SubString}}
    (f.ingredients ∩ mapreduce(i->i.ingredients, ∩, o), f.alergens ∩ mapreduce(i->i.alergens, ∩, o))
    #reduce((sets, i) -> (i.ingredients ∩ sets[1], i.ingredients ∩ sets[2]), o; init=(f.ingredients, f.alergens))
end

function removeknown!(diffs::Tuple{Vector{SubString}, Vector{SubString}}, amap::Dict{SubString, SubString})::Tuple{Vector{SubString}, Vector{SubString}}
    ingredients = values(amap)
    alergens = keys(amap)
    (filter!(i->!(i in ingredients), diffs[1]), filter!(i->!(i in alergens), diffs[2]))
end

function associate(farr::Vector{FoodItem}, aindex::FoodIndex)::Dict{SubString, SubString}
    numalergens = length(keys(aindex))
    alergenmap = Dict{SubString, SubString}()

    ittcount = 0
    for f in Iterators.cycle(farr)
        for a in f.alergens
            (idiff, adiff) = removeknown!(compare(f, aindex[a]), alergenmap)

            if length(idiff) == length(adiff) == 1 # known match
                alergenmap[adiff[1]] = idiff[1]
            end

        end
        ittcount += 1
        if length(keys(alergenmap)) == numalergens
            break
        end
        if ittcount > 20
            println("No exhaustive solution found")
            @show length(keys(alergenmap)), numalergens
            break
        end

    end
    alergenmap
end

function findoddfoods(farr::Vector{FoodItem}, amap::Dict{SubString, SubString})::Int
    allfoods = collect(Iterators.flatten(map(i -> i.ingredients, farr)))
    noalergens = setdiff(allfoods, values(amap))
    count(i-> i in noalergens, allfoods)
end

function dangerouslist(amap::Dict{SubString, SubString})::String
    ingredients = SubString[]
    for i in sort!(collect(keys(amap)))
        push!(ingredients, amap[i])
    end
    join(ingredients, ",")
end


function part1(farr)
    aindex = makeindexes(farr)
    amap = associate(farr, aindex) 
    findoddfoods(farr, amap)
    dangerouslist(amap)
end


farr = getinput("day21/input.txt")
@btime part1($farr)