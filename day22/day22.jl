# part 1


struct Player
    name::String
    cards::Vector{Int}
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

function getwinner(players::Vector{Player})::Player
    players[
        argmax(
            map(i -> length(i.cards), players)
        )
    ]
end

function play!(players::Vector{Player})::Player
    count = 0
    while !(any(i->length(i.cards) == 0, players))
        topcards = map(i->popfirst!(i.cards), players)
        roundwinner = players[argmax(topcards)]
        push!(
            roundwinner.cards, 
            sort(topcards; rev=true)...
        )
        count += 1 
    end
    getwinner(players)
end

function getscore(player::Player)#::Int
    mult = reverse(collect(Int, 1:length(player.cards)))
    sum(mult .* player.cards)
end

players = getplayers("day22/test2.txt")
winner = play!(players)
getscore(winner)