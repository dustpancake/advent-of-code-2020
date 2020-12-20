using DataStructures: DefaultDict
# assume throughout edges are unique up to a reversal 

struct Tile
    matrix::Matrix{Int}
    edgevalues::Vector{Tuple{Int, Int}}
    Tile() = new(zeros(Int, (1, 1)), Vector{Tuple{Int, Int}}())
    Tile(m::Matrix{Int}, ev::Vector{Tuple{Int, Int}}) = new(m, ev)
end

function tovalue(edge::AbstractArray)::Tuple{Int, Int}
    fwrd = parse(Int, join(edge); base=2)
    revd = parse(Int, join(reverse(edge)); base=2)
    (fwrd, revd)
end

@views function Tile(mat::Matrix{Int})::Tile
    edges = tovalue.([ mat[1, :], mat[:, end], mat[end, :], mat[:, 1] ])
    Tile(mat, edges)
end

TileSet = Dict{Int, Tile}
EdgeMapping = Dict{Tuple{Int, Int}, Vector{Int}}

function parsetile(tilestring::AbstractString)::Tuple{Int, Tile}
    lines = split(tilestring, "\n")
    tileid = parse(Int, match(r"(\d+)", lines[1]).match)
    tile = zeros(Int, (length(lines[2:end]), length(lines[1])))
    for (j, line) in enumerate(lines[2:end])
        for (i, char) in enumerate(line)
            tile[j,i] = char == '#' ? 1 : 0
        end
    end
    (tileid, Tile(tile))
end

function readtileset(path::AbstractString="day20/test.txt")::TileSet
    TileSet(i[1] => i[2] for i in map(parsetile, split(read(path, String), "\n\n")))
end
function rotate(t::Tile, k::Int=1)::Tile
    Tile(rotr90(t.matrix, k))
end
function flip(mat::Matrix{Int})::Matrix{Int}
    rotr90(mat')
end
function flip(t::Tile)::Tile
    Tile(flip(t.matrix))
end

function assemble(ts::TileSet)::EdgeMapping
    # find pairs of tiles, combine, find more pairs, etc
    mapping = EdgeMapping()
    for (id, tile) in ts
        for v in tile.edgevalues
            if haskey(mapping, v)
                push!(mapping[v], id)
            elseif haskey(mapping, reverse(v))
                push!(mapping[reverse(v)], id)
            else
                mapping[v] = Int[id]
            end
        end
    end
    mapping
end

function blankmap(ts::TileSet)::Tuple{Matrix{Int}, Int}
    dim = convert(Int, sqrt(length(ts)))
    (zeros(Int, (dim, dim)), dim)
end

function getcorners(em::EdgeMapping)::Vector{Int}
    singles = DefaultDict{Int, Int}(0)
    for (k, vec) in em
        if length(vec) == 1
            singles[vec[1]] += 1
        end
    end
    # (corners, edges)
    [k for (k, v) in filter(i->i[2]==2, singles)]
end

function orientcorner(tile::Tile, em::EdgeMapping)
    # top and left need to be disconnected
    orientation = map(i->haskey(em, i) && length(em[i]) == 1, tile.edgevalues)
    println("BEFORE")
    visualise(tile.matrix)
    @show orientation
    if orientation == [1, 1, 0, 0]  # tr
        return flip(tile)
    elseif orientation == [0, 1, 1, 0] # rb
        return rotate(tile, 2)
    elseif orientation == [0, 0, 1, 1] # bl
        return rotate(tile)
    else # tl
        return tile
    end
end

function tilematch(edgeval::Tuple{Int, Int}, em::EdgeMapping)
    if haskey(em, edgeval) return em[edgeval]
    else return em[reverse(edgeval)]
    end
end

const adjlookup = Dict{Int, Tuple{Int, Tuple{Int, Int}}}(2=>(4, (0, 1)), 3=>(1, (1, 0)))
function orientation(c::Tile, t::Tile, edge::Tuple{Int, Int})::Tuple{Tuple{Int, Int}, Tile}
    j = 0
    for (ji, e) in enumerate(c.edgevalues)
        if e == edge
            j = ji
            break
        end
    end
    adjedge, offset = adjlookup[j] # adjecent edge lookup
    for _ in 1:4 # rotations
        if t.edgevalues[adjedge] == edge
            # correct orientation 
            break
        elseif reverse(t.edgevalues[adjedge]) == edge
            # flip required
            t = flip(t)
            if adjedge == 4
                t = rotate(t, 2)
            end
            break
        end
        t = rotate(t)
    end
    (offset, t)
end

function maketilemap!(ts::TileSet)::Matrix{Int}
    em = assemble(ts)
    (tilemap, sqsize) = blankmap(ts)

    corners = getcorners(em)

    tilemap[1, 1] = corners[1]
    @show corners[1]
    # orient first corner
    ts[corners[1]] = orientcorner(ts[corners[1]], em)
    # fill the rest

    for (j, i) in Iterators.product(1:sqsize, 1:sqsize)
        current = ts[tilemap[j, i]]
        for edge in current.edgevalues[2:3]
            for tile in tilematch(edge, em)
                if tile in tilemap continue end # skip already assigned
                (offset, updated) = orientation(current, ts[tile], edge)
                ts[tile] = updated
                tilemap[((j, i) .+ offset)...] = tile
            end
        end
    end
    tilemap
end

@views function render(tilemap::Matrix{Int}, ts::TileSet)::Matrix{Int}
    mfactor = size(ts[tilemap[1, 1]].matrix)[1]
    sqsize = size(tilemap)[1]
    rendered = zeros(Int, (1, 1) .* (sqsize * mfactor))
    for (j, i) in Iterators.product(1:sqsize, 1:sqsize)
        jr = (j-1)*mfactor+1
        ir = (i-1)*mfactor+1
        rendered[jr:jr+mfactor-1, ir:ir+mfactor-1] = ts[tilemap[j, i]].matrix
    end
    rendered
end

function visualise(m::Matrix{Int})
    s = size(m)[1]
    for j in 1:s
        for i in 1:s
            char = m[j, i] == 1 ? '#' : '.'
            print(char)
        end 
        println()
    end
end

function part1()
    tileset = readtileset("day20/input.txt")
    tm = maketilemap!(tileset)
    corners = getcorners(assemble(tileset))
end

using BenchmarkTools: @btime
#@btime 
@show prod(part1())

function trimsquares(rendermap::Matrix{Int}; tilesize::Int=10)#::Matrix{Int}
    # want to trim 1 10,11 20,21 30
    mapsize = size(rendermap)[1]
    exclusion = vcat([i for i in 1:10:mapsize], [i for i in 10:10:mapsize])
    selection = setdiff(1:mapsize, exclusion)
    rendermap[selection, selection]
end

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


@views function convolve(rendermap::Matrix{Int}, stencil::Matrix{Int})::Int
    # returns count
    stencilsize = size(stencil)
    limits = size(rendermap) .- stencilsize
    target::Int = sum(stencil)
    count = 0
    for (j, i) in Iterators.product(1:limits[1], 1:limits[2])
        value = sum(rendermap[j:j+stencilsize[1]-1, i:i+stencilsize[2]-1] .* stencil)
        if value == target
            count += 1
        end
    end
    count
end

@views function maxmonster!(rendermap::Matrix{Int})::Int
    stencil = tokernel(monster)
    counts = Int[]
    for _ in 1:4 # rotations
        for _ in 1:2 # flips
            count = convolve(rendermap, stencil)
            push!(counts, count)
            rendermap = flip(rendermap)
        end
        rendermap = rotate(rendermap)
    end
    maximum(counts)
end

function part2()
    tileset = readtileset("day20/test.txt")
    rendermap = render(maketilemap!(tileset), tileset)
    rendermap = trimsquares(rendermap)
    #visualise(rendermap)
end

part2()