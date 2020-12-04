


const Passport = Dict{SubString, SubString} # type alias

function make_passport(entry::AbstractString)::Passport
    passport = Passport()
    for match in eachmatch(r"(\S+):(\S+)", entry)
        passport[match[1]] = match[2]
    end
    passport
end

function validate(passport::Passport)
    if length(passport) == 8 || ( length(passport) == 7 && !( "cid" in keys(passport) ) ) 
        return true
    else
        return false
    end
end

function read_passport_file(p::AbstractString)
    input = SubString[]
    open(p, "r") do io 
        input = split(read(io, String), "\n\n")
    end
    make_passport.(input)
end

# part 1
println("Part 1")
passports = read_passport_file("day4/input.txt")
@show count(validate.(passports))


# part 2

const rules = Dict{SubString, Function}(
    "byr" => (byr) -> length(byr) == 4 && 1920 ≤ parse(Int64, byr) ≤ 2002,
    "iyr" => (iyr) -> length(iyr) == 4 && 2010 ≤ parse(Int64, iyr) ≤ 2020,
    "eyr" => (eyr) -> length(eyr) == 4 && 2020 ≤ parse(Int64, eyr) ≤ 2030,
    "hgt" => (hgt) -> begin
        height = match(r"^(\d+)(cm|in)$", hgt)
        if isnothing(height)
            return false
        elseif height[2] == "cm"
            return 150 ≤ parse(Int64, height[1]) ≤ 193
        elseif height[2] == "in"
            return 59 ≤ parse(Int64, height[1]) ≤ 76
        else
            warn("Unknown height measurement $(height[2])")
            return false
        end
    end,
    "hcl" => (hcl) -> !isnothing(match(r"^#[0-9a-f]{6}$", hcl)),
    "ecl" => (ecl) -> !isnothing(match(r"^(amb|blu|brn|gry|grn|hzl|oth)$", ecl)),
    "pid" => (pid) -> !isnothing(match(r"^(\d{9})$", pid)),
    "cid" => (cid) -> true # ignore 
)

function validfields(passport::Passport)
    for (key, value) in passport
        valid_function = rules[key]
        if !valid_function(value)
            return false
        end 
    end
    return true
end

function validate(passport::Passport)
    if length(passport) == 8 || ( length(passport) == 7 && !( "cid" in keys(passport) ) ) 
        return validfields(passport)
    else
        return false
    end
end

passports = read_passport_file("day4/test_invalid.txt")
if !(count(validate.(passports)) == 0); error("Invalid failed."); end
passports = read_passport_file("day4/test_valid.txt")
if !(count(validate.(passports)) == 4); error("Valid failed."); end

println("Part 2")
passports = read_passport_file("day4/input.txt")
@show count(validate.(passports))
