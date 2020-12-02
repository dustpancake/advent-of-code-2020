# password validation

const LINE_REGEX = r"(\d+)-(\d+) (\w): (\w+)"

abstract type Policy end
is_valid(::AbstractString, ::Policy) = error("Not Implemented")

struct CountPolicy <: Policy
    range::AbstractRange
    char::AbstractChar

    CountPolicy(min_r, max_r, char) = new(min_r:max_r, char)
end

mutable struct Password
    pw::AbstractString
    policy::Policy

    # constructor
    Password(pw::AbstractString, min_r::T, max_r::T, char::AbstractChar) where T <: Int64 = begin
        # default for task1
        policy = CountPolicy(min_r, max_r, char)
        new(pw, policy)
    end
end

# parse data
passwords = Password[]
for line in eachline("day2/input.txt")
    groups = match(LINE_REGEX, line)

    # if there is data
    if !isnothing(groups)
        min_r = parse(Int64, groups[1])
        max_r = parse(Int64, groups[2])
        char = first(groups[3])
        push!(passwords,
            # populate 
            Password(groups[4], min_r, max_r, char)
        )
    end
end


Base.show(io::IO, p::Password) = print(io, "$(p.policy) in $(p.pw)")

function is_valid(s::AbstractString, p::CountPolicy)
    char_count = count(i -> i==p.char, s)
    return char_count in p.range
end

function validate(p::Password)
    return is_valid(p.pw, p.policy)
end


function validate_all()
    valids = validate.(passwords)
    correct = count(i -> i==1, valids)

    println("Processed $(length(valids)) passwords with $(typeof(passwords[1].policy)), of which $(correct) were correct.")
end
validate_all()


# part 2

struct PositionPolicy <: Policy
    pos1::Int64
    pos2::Int64
    char::AbstractChar

    PositionPolicy(p::CountPolicy) = new(p.range[1], p.range[end], p.char)
end

function is_valid(s::AbstractString, p::PositionPolicy)
    first = s[p.pos1] == p.char
    second = length(s) >= p.pos2 ? s[p.pos2] == p.char : false
    return first ⊻ second # xor
end

function migrate_policy!(p::Password, new_policy::Type{T}) where T <: Policy
    p.policy = new_policy(p.policy)
end

migrate_policy!.(passwords, PositionPolicy)

valids = validate.(passwords)
correct = count(i -> i==1, valids)

validate_all()