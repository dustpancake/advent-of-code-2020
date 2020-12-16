import Base: in
using BenchmarkTools: @btime
using Test

function getinput(path="day16/test.txt")
    (predicates, personal, others) = open(path, "r") do io
        pr, pe, ot = map(i->[j for j in split(i, "\n") if j != ""], split(read(io, String), "\n\n"))
        pr, pe[2], ot[2:end]
    end
end

struct TicketField
    name::SubString
    r1::UnitRange{Int64}
    r2::UnitRange{Int64}
    TicketField(name::AbstractString, r1::AbstractString, r2::AbstractString) = begin 
        r1 = split(r1, "-")
        r1 = map(i->parse(Int, i), r1)
        r2 = split(r2, "-")
        r2 = map(i->parse(Int, i), r2)
        new(name, r1[1]:r1[2], r2[1]:r2[2])
    end 
end

function in(val::Int, tf::TicketField)
    val in tf.r1 || val in tf.r2
end

function ticketfields(checks::AbstractArray{<:AbstractString})::Array{TicketField,1}
    map((check) -> begin
            (class, preds) = split(check, ":")
            (p1, _, p2) = split(preds)
            TicketField(class, p1, p2)
        end, 
        checks
    )
end

function parseticket(ts::AbstractString)::Array{Int, 1}
    map(i->parse(Int, i), split(ts, ",")) 
end
function parsetickets(tsa::AbstractArray{<:AbstractString})::Array{Int, 2}
    hcat(map(parseticket, tsa)...)'
end

function errorfunc(tfa::Array{TicketField,1})
    (ticket::Array{Int, 1}) -> begin
        sum(map(val -> any(map(field -> val ∈ field, tfa)) ? 0 : val, ticket))
    end
end

function errorrate(tickets::Array{Int, 2}, fields::Array{TicketField,1})
    checker = errorfunc(fields)
    sum(map(checker, tickets))
end

function part1(file::AbstractString)
    pr, pe, ot = getinput(file)
    tickets = parsetickets(ot)
    @show tickets[:]
    tfa = ticketfields(pr)
    errorrate(tickets, tfa)
end

@testset "Part 1" begin
    @test part1("day16/test.txt") == 71
end
# @btime part1("day16/input.txt")

function validtickets(tickets::Array{Int, 2}, fields::Array{TicketField,1})::Array{Array{Int, 1}}
    checker = errorfunc(fields)
    filter(ticket -> checker(ticket) == 0, tickets)
end

function part2(file::AbstractString)
    pr, pe, ot = getinput(file) 
    tickets = map(parseticket, push!(ot, pe))
    tfa = ticketfields(pr)
    validtickets(tickets, tfa)
end

part2("day16/test.txt")