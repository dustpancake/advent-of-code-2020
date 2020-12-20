using BenchmarkTools: @btime
# assume throughout edges are unique up to a reversal 

struct Tile
    id::Int
    body::Array{Int, 2}
    connections::Array{Int, 1} # top, right, bottom, left in that order always
    Tile(id::Int, body::Array{Int, 2}) = new(id, body, zeros(Int, 4))
end

TileSet = Array{Tile, 1}

@views function getedges(t::Tile)::Array{Array{Int, 1}}
    [ t.body[1, :], t.body[:, end], t.body[end, :], t.body[:, 1] ] # top, right, bottom, left 
end

function parsetile(tilestring::AbstractString)
    lines = split(tilestring, "\n")
    tileid = parse(Int, match(r"(\d+)", lines[1]).match)

    tile = zeros(Int, (length(lines[2:end]), length(lines[1])))
    for (j, line) in enumerate(lines[2:end])
        for (i, char) in enumerate(line)
            tile[j,i] = char == '#' ? 1 : 0
        end
    end
    Tile(tileid, tile)
end

function readtileset(path::AbstractString="day20/test.txt")::TileSet
    map(parsetile, split(read(path, String), "\n\n"))
end

function edgematch(t1::Tile, t2::Tile)
    if t1.id == t2.id; return 0; end
    e1 = getedges(t1)
    e2 = getedges(t2)
    e2 = [e2; reverse.(e2)]
    sum(i->count(==(i), e2), e1)
end

function edgematches(ts::TileSet)
    map(tile->tile.id=>sum(i->edgematch(tile, i), ts), ts)
end 

function findcorners(ts::TileSet)
    edgepairs = edgematches(ts)
    map(first, edgepairs[findall(i->i.second==2, edgepairs)])
end

# part 1

#tileset = readtileset("day20/test.txt")
#prod(findcorners(tileset))

# part 2

monster = """                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """
function tokernel(monster::AbstractString)
    lines = split(monster, "\n")
    m = zeros(Int, (length(lines), length(lines[1])))
    for (j, line) in enumerate(lines)
        for (i, char) in enumerate(line)
            m[j, i] = char == '#' ? 1 : 0
        end
    end
    m
end

function rotate(t::Tile; k::Int=1)::Tile
    Tile(t.id, rotr90(t.body, k))
end

function findedges(ts::TileSet)
    edgepairs = edgematches(ts)
    map(first, edgepairs[findall(i->i.second==3, edgepairs)])
end

function assembleframe!(tiles::Dict, cornertiles, edgetiles)
    # select random corner
    frame = Tile[]
    corner = tiles[cornertiles[1]]
    delete!(tiles, cornertiles[1])

    for edgetile in edgetiles
        for i in 1:4 # rotation int

        end
    end
end

function assemblemap(ts::TileSet)

end

tileset = readtileset("day20/test.txt")
count(i->i.second == 3, edgematches(tileset))

tokernel(monster)
assemblemap(tileset)