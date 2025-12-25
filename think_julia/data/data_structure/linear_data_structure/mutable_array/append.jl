odd = [1, 3, 5];

even = [0, 2, 4];

@show append!(odd, even)
# append!(odd, even) = [1, 3, 5, 0, 2, 4]
# 6-element Vector{Int64}:
#  1
#  3
#  5
#  0
#  2
#  4

odd
# 6-element Vector{Int64}:
#  1
#  3
#  5
#  0
#  2
#  4

even
# 3-element Vector{Int64}:
#  0
#  2
#  4