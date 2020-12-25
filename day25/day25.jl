

function test()::Tuple{Int, Int}
    (5764801, 17807724)
end

function input()::Tuple{Int, Int}
    (8458505, 16050997)
end

function generate(loopsize::Int, subjectnum::Int=7)::Int
    key = 1 
    for i in 1:loopsize
        key = (key * subjectnum) % 20201227
    end
    key
end

function crack(target::Int)
    key = 1
    loops = 0
    while key != target
        loops += 1
        key = (key * 7) % 20201227
    end
    loops
end

(card, door) = input()

loopcard, loopdoor = (crack(card), crack(door))
generate(loopcard, door), generate(loopdoor, card)
