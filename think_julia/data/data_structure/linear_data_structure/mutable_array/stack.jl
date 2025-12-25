pi_ = [3, 1]
# 2-element Vector{Int64}:
#  3
#  1

push!(pi_, 4)
# 3-element Vector{Int64}:
#  3
#  1
#  4

push!(pi_, 5)
# 4-element Vector{Int64}:
#  3
#  1
#  4
#  5

five = pop!(pi_)
# 5

pi_
# 3-element Vector{Int64}:
#  3
#  1
#  4

five
# 5