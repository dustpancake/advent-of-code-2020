import Base: in, convert

using BenchmarkTools: @btime
using Test

function getinput(path::AbstractString)
    content = collect(eachline(path))
    (s1, s2) = findall(==(""), content) # split indices
    (content[begin:s1-1], content[s1+2], content[s2+2:end])
end 

function parsetickets(tickets::AbstractArray{<:AbstractString}, numfields::Int)::Array{Int, 2}
    numtickets = length(tickets)
    tsa = zeros(Int, (numtickets, numfields))
    for j in 1:numtickets
        foreach(i -> tsa[j, i[1]] = parse(Int, i[2]), enumerate(split(tickets[j], ",")))
    end
    tsa
end

struct TicketField 
    name::SubString
    r1::UnitRange{Int}
    r2::UnitRange{Int}
end

function check(val::Int, tf::TicketField)::Bool
    val in tf.r1 || val in tf.r2
end
function check(val::Int, tfa::AbstractArray{TicketField, 1})::Int
    all(tf->!check(val, tf), tfa) ? val : 0
end

# overload conversion functions
function convert(::Type{UnitRange{T}}, s::AbstractString)::UnitRange{T} where T <: Int
    s1, s2 = split(s, "-")
    parse(Int, s1):parse(Int, s2)
end
function convert(::Type{T}, field::AbstractString)::TicketField where T <: TicketField
    name, data = split(field, ":")
    TicketField(name, split(data, "or")...)
end

# use overloaded conversions for implicit
function parsefields(fields::AbstractArray{<:AbstractString})::AbstractArray{TicketField, 1}
    fields
end

# convenience function: parse all
function parsedata(tickets::AbstractArray{<:AbstractString}, fields::AbstractArray{<:AbstractString})
    parsetickets(tickets, length(fields)), parsefields(fields)
end

function errorrate(ticket::AbstractArray{Int, 1}, fields::AbstractArray{TicketField, 1})::Int
    sum(map(v->check(v, fields), ticket))
end
function errorrate(tickets::AbstractArray{Int, 2}, fields::AbstractArray{TicketField, 1})::Int
    sum(ticket -> errorrate(ticket, fields), eachrow(tickets))
end

# part 1
function part1(fields, personal, others)
    tickets, fields = parsedata(others, fields)
    errorrate(tickets, fields)
end
@testset "Part 1" begin
    fields, personal, others = getinput("day16/test.txt")
    @test part1(fields, personal, others) == 71
end


# part 2
@views function validtickets(tickets::AbstractArray{Int, 2}, fields::AbstractArray{TicketField, 1})::Array{Int, 2}
    indices = findall(==(0), map(ticket -> errorrate(ticket, fields), eachrow(tickets)))
    tickets[indices, :]
end

function validforfield(col::AbstractArray{Int, 1}, field::TicketField)::Bool
    all(map(v -> check(v, field), col))
end

function associatedfields(col::AbstractArray{Int, 1}, fields::AbstractArray{TicketField, 1})::Array{Int, 1}
    findall(field -> validforfield(col, field), fields)
end

@views function associatefields(tickets::AbstractArray{Int, 2}, fields::AbstractArray{TicketField, 1})::Dict{SubString, Int}
    remaining = collect(1:length(fields))
    candidates = Dict{Int, Array{Int, 1}}(nᵢ=>associatedfields(col, fields) for (nᵢ, col) in enumerate(eachcol(tickets)))
    fieldmap = Dict{SubString, Int}()

    associate! = (nᵢ, i) -> begin
        fieldmap[fields[i].name] = nᵢ
        delete!(candidates, nᵢ)
        remaining[i] = 0
    end

    # associate trivial
    for (nᵢ, findices) in candidates
        if length(findices) == 1
            associate!(nᵢ, findices[1])
        end
    end

    # associate others
    while any(!=(0), remaining)
        for (nᵢ, findices) in candidates
            int = findices ∩ remaining
            if length(int) == 1
                associate!(nᵢ, int[1])
            end
        end 
    end

    fieldmap
end

function part2(fields, personal, others)
    push!(others, personal)
    tickets, fields = parsedata(others, fields)
    tickets = validtickets(tickets, fields)

    fieldmap = associatefields(tickets, fields)
    
    indexes = [v for (k, v) in fieldmap if occursin(r"^departure", k)]
    prod(tickets[end, indexes])
end

fields, personal, others = getinput("day16/input.txt")
@btime part1(fields, personal, others)
@btime part2(fields, personal, others)


