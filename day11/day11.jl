using BenchmarkTools

getinput() = collect(eachline("day11/input.txt"))

const Field = UInt8

function tomatrix(input)
    dims = (length(input)+2, length(input[begin])+2) # +2 for padding
    output = zeros(Field, dims)
    for (j, row) in enumerate(input)
        for (i, col) in enumerate(row)
            output[j+1, i+1] = col == 'L' ? 1 : 0     
        end
    end
    output
end

@inline function mapper(f::Function, bounds)
    for row in 1:bounds[1]
        for col in 1:bounds[2]
            f(row, col)
        end
    end
end

using Crayons
const RESET = Crayon(foreground=:white)
const RED = Crayon(foreground=:red)
function visualise(input)
    bounds = size(input)
    mapper((row, col) -> begin
            seat = input[row, col]
            if seat != 0
                seat = seat == 1 ? 'L' : '#'
                print(RED, seat, RESET)
            else
                print('.')
            end
            if col == bounds[2]
                println()
            end
        end,
        bounds
    )
end

const stencil = Field[1 1 1 ; 1 0 1 ; 1 1 1]
@inline function convolve(input::AbstractArray; minseats=40) # must both be 3x3
    numocc = sum(input .* stencil)
    curr = input[2, 2]
    if curr == 1 && numocc < 10
        return 10
    elseif curr == 10 && numocc ≥ minseats
        return 1
    else
        return curr
    end
end

function adjacent!(input::AbstractArray, output::AbstractArray)
    bounds = size(input) .- 1
    mapper((row, col) -> begin
            if input[row, col] != 0
                section = @view input[row-1:row+1, col-1:col+1]
                output[row, col] = convolve(section)
            end
        end, 
        bounds
    )
    return output
end

@inline function numseats(frame::AbstractArray)
    count(==(10), frame)
end

function fullevolve(input::AbstractArray, evolvefunc!::Function)
    output = zeros(Field, size(input))
    seats = numseats(input)
    δseats = 1
    ittcount = 0
    while δseats != 0
        # inc ittcount
        ittcount += 1
        #println("ittcount=$ittcount")

        # evolve; switch depending on ittcount
        if ittcount % 2 == 1
            curr_seats = numseats(evolvefunc!(input, output))
            #visualise(output)
        else
            curr_seats = numseats(evolvefunc!(output, input))
            #visualise(input)
        end

        # update break logic
        δseats = seats - curr_seats
        seats = curr_seats
        #ittcount != 3 || break
    end
    if ittcount % 2 != 1 # not even
        input = output
    end
    return input
end

function traceline(input, j, i, Δj, Δi)
    j += Δj
    i += Δi
    bounds = size(input)
    while input[j, i] == 0
        j += Δj
        i += Δi
        if j ≤ 0 || i ≤ 0 || j ≥ bounds[1] || i ≥ bounds[2]
            return 0
        end
    end
    return input[j, i]
end

function nearestneighbours!(input::AbstractArray, row::Int, col::Int, section::AbstractArray)
    for Δj in [-1, 0, 1]
        for Δi in [-1, 0, 1]
            if Δj == Δi == 0; continue end
            section[Δj + 2, Δi + 2] = traceline(input, row, col, Δj, Δi)
        end
    end
    section[2, 2] = input[row, col]
    section
end

section = zeros(Field, 3, 3) # storage for nearest neighbours
function lineofsight!(input::AbstractArray, output::AbstractArray)
    global section
    bounds = size(input) .- 1
    mapper((row, col) -> begin
            if input[row, col] != 0
                section = nearestneighbours!(input, row, col, section)
                #visualise(section)
                #println()
                output[row, col] = convolve(section, minseats=50)
            end
        end, 
        bounds
    )
    return output 
end


function part1()
    input = tomatrix(getinput())
    input = @btime fullevolve($input, adjacent!)
    numseats(input)
end


function part2()
    input = tomatrix(getinput())
    input = @btime fullevolve($input, lineofsight!)
    
    numseats(input)
end


part1()
part2()