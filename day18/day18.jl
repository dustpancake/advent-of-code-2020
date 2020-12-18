using Test
using BenchmarkTools: @btime
using Distributed


const TokenStream = Base.Iterators.Stateful{String,Union{Nothing, Tuple{Char,Int64}}}

oplookup = Dict{Char, Function}(
    '+' => (partialsum::Int, x::Int) -> partialsum + x,
    '*' => (partialsum::Int, x::Int) -> partialsum * x
)

function parseeval!(ts::TokenStream)::Int
    partialsum::Int = 0
    operator::Function = (ps, x) -> x

    while !isempty(ts)
        token = popfirst!(ts)
        
        if token == ' ' continue end
        if token == ')' break end
        if token == '('
            
            midres = parseeval!(ts)
            partialsum = operator(partialsum, midres)
        
        elseif haskey(oplookup, token)  # operator lookup
            operator = oplookup[token]
        else                            # number
            value = parse(Int, token)
            partialsum = operator(partialsum, value)
        end
    end
    partialsum
end

function parseeval(string::AbstractString)::Int
    ts::TokenStream = Iterators.Stateful(string)
    parseeval!(ts)
end

function parseeval(strings::Array{String,1})
    map(parseeval, strings)
end

@testset "Part 1" begin
    sample = collect(eachline("day18/test.txt"))
    @test parseeval(sample[1]) == 71
    @test parseeval(sample[2]) == 51
    @test parseeval(sample[3]) == 26    
    @test parseeval(sample[4]) == 437
    @test parseeval(sample[5]) == 12240
    @test parseeval(sample[6]) == 13632
end

# i am super tired; julia parses ^ before * so gonna use that 

function parser(expression::Expr)::Expr
    for (i, token) in enumerate(expression.args)
        if token isa Expr
            expression.args[i] = parser(token)
        elseif token == :^
            expression.args[i] = :+
        end
    end
    expression
end

function part2(string::AbstractString)::Int
    expression = Base.parse_input_line(replace(string, "+" => "^"))
    eval(parser(expression))
end

# sum(map(part2, eachline("day18/input.txt")))