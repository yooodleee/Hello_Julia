S = Set([3, 1, 4, 1, 5])
# Set{Int64} with 4 elements:
#   5
#   4
#   3
#   1

sort(S)
# ERROR: MethodError: no method matching sort(::Set{Int64})

P = Set()
# Set{Any}()

push!(P, 4)
# Set{Any} with 1 element:

push!(P, 7)
# Set{Any} with 2 elements:
#   4
#   7

pop!(P)
# 4