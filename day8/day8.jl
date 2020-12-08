
const Instruction = Pair{SubString, Int}
const Program = Array{Instruction}

mutable struct Computer
    rip::Int
    accumulator::Int
    # constructors
    Computer(;acc=0) = new(1, acc)
end

function reset!(c::Computer) 
    c.rip=1
    c.accumulator=0 
end

operations = Dict{SubString, Function}(
    "nop" => (c::Computer, val::Int) -> nothing,
    "acc" => (c::Computer, val::Int) -> c.accumulator += val,
    "jmp" => (c::Computer, val::Int) -> c.rip += val - 1 # since will inc +1 per cycle
)

function run!(c::Computer, i::Instruction)
    operations[i.first](c, i.second)
end

function run!(c::Computer, p::Program)
    prog_length = length(p)
    imask = zeros(Bool, prog_length)
    while !(imask[c.rip])
        imask[c.rip] = true
        run!(c, p[c.rip])
        c.rip += 1 # increment instruction pointer
        if (c.rip > prog_length) break end
    end
    c.rip > prog_length
end

function parse_line(line::AbstractString)::Instruction
    groups = match(r"(\w+) ([+-]\d+)", line)
    groups[1] => parse(Int, groups[2])
end

function load_program(path::AbstractString="day8/test.txt")::Program
    map(parse_line, eachline(path))
end

function testcase1()
    prog = load_program()
    comp = Computer()
    run!(comp, prog)
    @assert(comp.accumulator == 5)
end

function part1()
    prog = load_program("day8/input.txt")
    comp = Computer()
    run!(comp, prog)
    comp.accumulator
end

testcase1()
#@assert(part1() == 1262)

function testcase2()
    # ensure exit condition works 
    prog = load_program("day8/test2.txt")
    comp = Computer()
    run!(comp, prog)
    @assert(comp.accumulator == 8)
end

testcase2()

function switchnopjmp(i::Instruction)
    newi = i.first == "jmp" ? "nop" : "jmp"
    return Instruction(newi, i.second)
end

function ittprog(p::Program, i::Int) # itterate the next change of program
    index = findnext(x->occursin(r"(jmp|nop)",x.first), p, i)
    modified = copy(p)
    modified[index] = switchnopjmp(modified[index])
    index, modified
end

function bruteforce!(comp::Computer, p::Program)
    modind = 0
    newprog = copy(p)
    modind = 1
    count = 0
    while !(run!(comp, newprog))
        count += 1
        println("Run no $count :: tried switch at $modind")
        modind, newprog = ittprog(p, modind + 1)
        # reset
        reset!(comp)
    end
end

function testcase3()
    prog = load_program()
    comp = Computer() 
    bruteforce!(comp, prog)
    @assert(comp.accumulator == 8)
end

testcase3()

function part2()
    prog = load_program("day8/input.txt")
    comp = Computer()
    bruteforce!(comp, prog)
    comp.accumulator
end

part2()