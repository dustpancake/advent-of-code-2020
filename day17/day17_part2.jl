using BenchmarkTools


function getinput(path="day17/test.txt")::Array{Int, 4}
    content = split(read(path, String))
    dims = (length(content), length(content[1]), 1, 1)
    output = zeros(Int, dims)
    for j in 1:dims[1]
        for i in 1:dims[2]
            output[j, i] = content[j][i] == '#' ? 1 : 0
        end
    end 
    output
end

@views function addpadding(cube::Array{Int, 4})::Array{Int, 4}
    dims = size(cube)
    padded = zeros(Int, dims .+ 2)
    padded[2:dims[1]+1, 2:dims[2]+1, 2:dims[3]+1, 2:dims[4]+1] = cube[:, :, :, :]
    padded
end

@inline function mapper(f::Function, dimensions::Tuple{Int, Int, Int, Int})
    for w in 2:dimensions[4]-1
        for z in 2:dimensions[3]-1
            for y in 2:dimensions[2]-1
                for x in 2:dimensions[1]-1
                    f(y, x, z, w)
                end
            end
        end
    end
end

@views function adjacent(section::AbstractArray, stencil::Array{Int, 4})::Int
    sum(section .* stencil)
end

stencil = ones(Int, (3, 3, 3, 3))
stencil[2, 2, 2, 2] = 0
@views function convolve(cube::Array{Int, 4}, f::Function)::Array{Int, 4}
    output = zeros(Int, size(cube))
    mapper(
        (y, x, z, w) -> begin
            val = adjacent(
                cube[y-1:y+1, x-1:x+1, z-1:z+1, w-1:w+1],
                stencil
            )
            output[y, x, z, w] = f(cube[y, x, z, w], val) # i need to subtract 1 but i don't know why ??
        end,
        size(cube)
    )
    output
end

@inline function evolutionlogic(current::Int, val::Int)::Int
    if current == 1 && 2 ≤ val ≤ 3
        return 1
    elseif current == 0 && val == 3
        return 1
    end
    return 0
end

function convolve(cube::Array{Int, 4})::Array{Int, 4}
    convolve(cube, evolutionlogic)
end

@views function visualize(cube::Array{Int, 4})
    dims = size(cube)
    offsets = (dims .÷ 2) .+ 1
    for z in 2:dims[3]-1
        println(" Z = $(z-offsets[3])")
        for y in 2:dims[2]-1
            for x in 2:dims[1]-1
                print(cube[y, x, z], " ")
            end
            println()
        end
    end
end

function cycle!(cube::Array{Int, 4})::Array{Int, 4}
    convolve(addpadding(cube))
end

function part1(cube)
    cube = addpadding(cube)
    for i in 1:6
        cube = cycle!(cube)
    end
    #visualize(cube)
    count(==(1), cube)
end

cube = getinput("day17/input.txt")
@btime part1(cube)
