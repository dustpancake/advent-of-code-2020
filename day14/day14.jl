using BenchmarkTools
using Combinatorics

const CommandArray = Array{Tuple{String, Int, Int}, 1}
function getinput(path="day14/test.txt")
    commands = CommandArray()
    for line in eachline(path)
        if occursin("mask", line)
            strmask = match(r"mask = ([\w\d]+)", line)[1]
            mask = parse(Int, replace(replace(strmask, "1"=>0), "X"=>1), base=2)
            value = parse(Int, replace(strmask, "X"=>0), base=2)
            push!(commands, ("mask", mask, value))
        else
            g = match(r"mem\[(\d+)\] = (\d+)", line)
            index = parse(Int, g[1])
            value = parse(Int, g[2])
            push!(commands, ("mem", index, value))
        end
    end
    commands
end

mutable struct Memory
    memory::Dict{Int, Int}
    mask::Int
    maskval::Int
    Memory() = new(Dict(), 0, 0)
end

function makeexec(m::Memory, lookup::Dict{String, Function})
    (cmd) -> lookup[cmd[1]](m, cmd[2], cmd[3])
end

function runall(input::CommandArray, lookup::Dict{String, Function})
    m = Memory()
    exec = makeexec(m, lookup)
    foreach(exec, input)
    sum(values(m.memory))
end

fpart1 = Dict{String, Function}(
    "mask" => (mem, mask, value) -> begin
        mem.mask = mask
        mem.maskval = value
    end,
    "mem" => (mem, index, value) -> mem.memory[index] = (value & mem.mask) + mem.maskval
)
function part1(input)
    runall(input, fpart1) 
end

input = getinput("day14/input.txt")
#@btime part1(input)

function unwrap(val::Int)
    digits = []
    for i in 0:38
        digit = val & (1 << i)
        if digit != 0
            push!(digits, digit)
        end
    end
    digits
end

fpart2 = Dict{String, Function}(
    "mask" => (mem, mask, value) -> begin
        mem.mask = mask
        mem.maskval = value
    end,
    "mem" => (mem, index, value) -> begin
        root = ( index | mem.maskval ) & ~mem.mask
        digits = unwrap(mem.mask)
        for comb in combinations(digits)
            i = root + sum(comb)
            mem.memory[i] = value
        end
        mem.memory[root] = value
    end
)

@btime runall(input, fpart2)