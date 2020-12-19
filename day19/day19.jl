
Rules = Dict{SubString, SubString}


function getinput(path="day19/test.txt")
    (rules, messages) = split(read(path, String), "\n\n")

    ruledict = Rules()
    for group in eachmatch(r"(\d+): (.*)", rules)
        ruledict[group[1]] = group[2]
    end

    return ruledict, split(messages)
end


function parserule(ruledict::Rules, target::AbstractString)::String
    targetrules::SubString = ruledict[target]
    if occursin(r"[ab]", targetrules)
        return strip(targetrules, '\"')
    end

    for rule in eachmatch(r"(\d+)", targetrules)
        targetrules = replace(
            targetrules, 
            rule[1]=>parserule(ruledict, rule[1]);
            count=1 # prevent e.g. 3 from replacing in 13
        )
    end

    if occursin("|", targetrules)
        return "($targetrules)"
    else
        return targetrules
    end
end

function makeregex(rules::Rules, target::AbstractString)::Regex
    rule = replace(parserule(rules, target), " "=>"") # get rid of whitespace
    Regex("^$rule\$") # fix to string length
end

(rules, messages) = getinput("day19/input.txt")
rule = makeregex(rules, "0")
count(i->!isnothing(match(rule, i)), messages)


# part 2 

rules["8"] = "42 | 42 8"
rules["11"] = "42 31 | 42 11 31"


function repeat(ruledict::Rules, target::AbstractString)
    rule = ruledict[target]
    template = rule
    for i in 1:2 # arbitrary depth, so that is longer than longest string
        rule = replace(rule, target => "($rule)")
    end
    replace(rule, "($template)"=>split(template, "|")[1])
end

rules["8"] = "42 | 42 (42)+" # by hand
rules["11"] = repeat(rules, "11")

rule = makeregex(rules, "0")
count(i->!isnothing(match(rule, i)), messages)