using BenchmarkTools
# can grow at least one cube in each dimension per cycle
# six cycles means init dim + 6

function getinput(path="day17/test.txt")::Array{Int, 3}
    content = split(read(path, String))
    dims = (length(content), length(content[1]), 1)
    output = zeros(Int, dims)
    for j in 1:dims[1]
        for i in 1:dims[2]
            output[j, i] = content[j][i] == '#' ? 1 : 0
        end
    end 
    output
end

@views function addpadding(cube::Array{Int, 3})::Array{Int, 3}
    dims = size(cube)
    padded = zeros(Int, dims .+ 2)
    padded[2:dims[1]+1, 2:dims[2]+1, 2:dims[3]+1] = cube[:, :, :]
    padded
end

@inline function mapper(f::Function, dimensions::Tuple{Int, Int, Int})
    for z in 2:dimensions[3]-1
        for y in 2:dimensions[2]-1
            for x in 2:dimensions[1]-1
                f(y, x, z)
            end
        end
    end
end

@views function adjacent(section::AbstractArray, stencil::Array{Int, 3})::Int
    sum(section .* stencil)
end

prestencil = ones(Int, (3, 3, 3))
prestencil[2, 2, 2] = 0
stencil = copy(prestencil)
@views function convolve(cube::Array{Int, 3}, f::Function)::Array{Int, 3}
    output = zeros(Int, size(cube))
    mapper(
        (y, x, z) -> begin
            val = adjacent(
                cube[y-1:y+1, x-1:x+1, z-1:z+1],
                stencil
            )
            output[y, x, z] = f(cube[y, x, z], val) # i need to subtract 1 but i don't know why ??
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

function convolve(cube::Array{Int, 3})::Array{Int, 3}
    convolve(cube, evolutionlogic)
end

@views function visualize(cube::Array{Int, 3})
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

function cycle!(cube::Array{Int, 3})::Array{Int, 3}
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

cube = @btime getinput("day17/input.txt")
#@btime part1(cube)
