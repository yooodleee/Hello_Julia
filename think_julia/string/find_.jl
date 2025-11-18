findall("in", "Definition of Infinity in Linear Algebra")
# 4-element Vector{UnitRange{Int64}}:
#  4:5
#  18:19
#  24:25
#  28:29

findall(isspace, "Definition of Infinity in Linear Algebra")
# 5-element Vector{Int64}:
#  11
#  14
#  23
#  26
#  33

findfirst("in", "Definition of Infinity in Linear Algebra")
# 4:5

findlast("in", "Definition of Infinity in Linear Algebra")
# 28:29

findnext("in", "Definition of Infinity in Linear Algebra", 16)
# 18:19

findprev("in", "Definition of Infinity in Linear Algebra", 16)
# 4:5
