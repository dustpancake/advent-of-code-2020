# toboggan run

using Crayons: Crayon
const RESET = Crayon(foreground=:white)
const RED = Crayon(foreground=:red)



const TREE_SYMB = Char('#')

abstract type AbstractTileMap end 

struct Map <: AbstractTileMap
    tile::AbstractArray{<:AbstractString}
    width::Int64
    rows::Int64
    Map(a::AbstractArray{<:AbstractString}) = new(a, length(a[1]), length(a))
end

function load_tile(p::AbstractString)
    data = SubString[]
    for line in eachline(p)
        push!(data, line)
    end
    data
end

@inline function check_tree(row::AbstractString, i)::Int64
    return Int64(row[i] == TREE_SYMB)
end

@inline function pprow(row::AbstractString, i)
    """ string for pretty print with colours where we are """
    print("(row, i) = \"")
    println(row[1:i-1], RED, row[i], RESET, row[i+1:end], "\", $i")
end

function descend(m::AbstractTileMap, x_step::Int64, y_step::Int64=1)
    """ moves over x_step to the right per row """
    x = (collect(1:m.rows) * x_step).% m.width .+ 1 # all of the x values, mod x + 1 for julia offset

    reduced_tilemap = m.tile[y_step+1:y_step:end]
    
    trees = count(
        (it) -> begin
            (row, i) = it
            # pprow(row, i)
            row[i] == TREE_SYMB
        end,
        (row, i) for (row, i) in zip(reduced_tilemap, x) # we skip the first row, since move right THEN down
    )
    trees
end

map = Map(load_tile("day3/input.txt"))
trees = descend(map, 3)
println("Trees on 3 right = $trees")

# part 2
prod = descend(map, 1) * descend(map, 3) * descend(map, 5) * descend(map, 7) * descend(map, 1, 2)
println("Product = $prod")