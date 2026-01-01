X = Set([3, 1, 4]);

Y = Set([5, 6, 1]);

X ∪ Y
# Set{Int64} with 5 elements:
#   5
#   4
#   6
#   3
#   1

X ∩ Y
# Set{Int64} with 1 element:
#   1

setdiff(X, Y)
# Set{Int64} with 2 elements:
#   4
#   3

symdiff(X, Y)
# Set{Int64} with 4 elements:
#   5
#   4
#   6
#   3

isempty([3, 0] ∩ [1, 3])
# false

isdisjoint([2, 0], [1, 3])
# true 