# part 2 
import Base: copy

struct Player
    name::String
    cards::Vector{Int}
end

function copy(p::Player)::Player
    Player(p.name, copy(p.cards))
end

function parseplayer(player::AbstractString)::Player
    (name, cardstring) = split(player, ":")
    cards = [parse(Int, i[1]) for i in eachmatch(r"(\d+)", cardstring)]
    Player(name, cards)
end

function getplayers(path="day22/test.txt")::Vector{Player}
    (players) = split(read(path, String), "\n\n")
    map(parseplayer, players)
end

struct Round
    p1::Player
    p2::Player
    p1cache::Vector{Vector{Int}}
    p2cache::Vector{Vector{Int}}
end

function Round(p1::Player, p2::Player)::Round
    Round(copy(p1), copy(p2), Vector{Vector{Int}}(), Vector{Vector{Int}}())
end

function Round(n1::String, n2::String, c1::Vector{Int}, c2::Vector{Int})::Round
    Round(Player(n1, copy(c1)), Player(n2, copy(c2)))
end

function getwinner(round::Round)::Player
    p1length = length(round.p1.cards)
    p2length = length(round.p2.cards)
    p1length > p2length ? round.p1 : round.p2
end

function hascards(player::Player)::Bool
    length(player.cards) > 0
end

function updatecache!(round::Round)
    push!(round.p1cache, copy(round.p1.cards))
    push!(round.p2cache, copy(round.p2.cards))
end

@views function incache(round::Round)::Bool
    p1incache = round.p1.cards in round.p1cache
    p2incache = round.p2.cards in round.p2cache
    if p1incache && p2incache
        return true
    else
        return false
    end
end

function needrecurse(round::Round, topcards::Vector{Int})::Bool
    (p1val, p2val) = topcards

    p1recurse = length(round.p1.cards) ≥ p1val # add one to account for topcard
    p2recurse = length(round.p2.cards) ≥ p2val

    if (p1recurse && p2recurse)
        return true
    else
        return false
    end
end

function makesubround(round::Round, topcards::Vector{Int})::Round
    # really inefficient function; misread about how many cards to take with, so botched a copy op
    p1copy = Player(round.p1.name, copy(round.p1.cards[1:topcards[1]]))
    p2copy = Player(round.p2.name, copy(round.p2.cards[1:topcards[2]]))
    Round(p1copy, p2copy)
end

function play!(round::Round)::Player
    count = 0
    while (hascards(round.p1) && hascards(round.p2))
        count += 1

        if incache(round)
            return round.p1 # player one win 
        else
            updatecache!(round)
        end 

        topcards = map(popfirst!, [round.p1.cards, round.p2.cards])

        if needrecurse(round, topcards)
            subround = makesubround(round, topcards)
            if play!(subround).name == round.p1.name
                @show topcards
                push!(round.p1.cards, topcards...)
            else
                push!(round.p2.cards, reverse(topcards)...)
            end
        else
            roundwinner = argmax(topcards) == 1 ? round.p1 : round.p2
            push!(roundwinner.cards, sort(topcards; rev=true)...)
        end

    end
    getwinner(round)
end

function getscore(player::Player)#::Int
    @show player
    mult = reverse(collect(Int, 1:length(player.cards)))
    sum(mult .* player.cards)
end

players = getplayers("day22/input.txt")
game1 = Round(players...)
winner = play!(game1)
getscore(winner)
