using LinearAlgebra: norm

const e₁, e₂ = Vector{Int}([1, 0]), Vector{Int}([0, 1])
vectormap = Dict{SubString, Vector{Int}}(
    "se" => (e₂ - e₁),
    "sw" => (-e₂ - e₁),
    "nw" => (-e₂ + e₁),
    "ne" => (e₂ + e₁),
    "e" => 2*e₂,
    "w" => -2*e₂
)

function parseline(line::AbstractString)
    sum(
        i->vectormap[i[1]],
        eachmatch(
            r"(se|sw|nw|ne|e|w)",
            line
        )
    )
end

function readinput(path="day24/test.txt")::Vector{Vector{Int}}
    map(parseline, eachline(path))
end

function part1(input)
    # simple
    length(input) - (2 * (length(input) - length(unique(input)))) 
end



# part 2

function nestedminmax(i::AbstractArray)::Tuple{Int, Int}
    minimum(map(minimum, i)), maximum(map(maximum, i))
end

@views function togrid(input::Vector{Vector{Int}})::Matrix{Int}
    (offset, maxima) = nestedminmax(input)
    @show offset, maxima
    offset -= 1 # index start 1
    dim = maxima + 1 - offset
    rep = zeros(Int, (dim, dim))
    for i in input
        i .-= offset
        rep[i...] = rep[i...] == 0 ? 1 : 0
    end
    rep
end

const stencil = Int[
    0 1 0 1 0 ;
    1 0 0 0 1 ;
    0 1 0 1 0
]
@views function convolve(mat::AbstractArray)::Int
    sum(mat .* stencil)
end

function mapper(f::Function, grid::Matrix{Int})
    (rows, cols) = size(grid) .- (2, 4)
    for row in 1:rows
        # only walk diagonals
        start = row % 2 == 1 ? 2 : 1
        for col in start:2:cols
            f(row+1, col+2) # accounts for padding
        end
    end
end

function applyrules(curr::Int, conv::Int)::Int
    if curr == 1 # black 
        if conv == 0 || conv > 2
            return 0 # flip
        else
            return 1 # stay the same
        end
    else # white
        if conv == 2
            return 1 # flip
        else
            return 0
        end
    end
end

@views function evolve!(ref::Matrix{Int}, dest::Matrix{Int})
    mapper((row, col) -> begin
            section = ref[row-1:row+1, col-2:col+2]
            curr = ref[row, col]
            conv = convolve(section)
            dest[row, col] = applyrules(curr, conv)
        end,
        ref
    )
end

function addpadding(grid::Matrix{Int})
    dims = size(grid) .+ (4, 8)
    blank = zeros(Int, (dims))
    for loc in findall(==(1), grid)
        blank[loc[1] + 2, loc[2] + 4] = 1
    end
    blank
end

function evolve(grid::Matrix{Int})
    # bump 8 in x, 4 in y, else miss edges in convolution
    grid = addpadding(grid)
    output = copy(grid)
    evolve!(grid, output)
    output
end

function run!(grid::Matrix{Int}, times::Int)
    for _ in 1:times
        grid = evolve(grid)
    end
    grid 
end

function visualise(grid::Matrix{Int})
    (rows, cols) = size(grid)
    for row in 1:rows
        for col in 1:cols
            print(grid[row, col] == 1 ? '#' : '.')
        end
        println()
    end
end

input = readinput("day24/input.txt")
grid = togrid(input)
visualise(grid)
grid = run!(grid, 100)
@show count(==(1), grid)
#visualise(grid)