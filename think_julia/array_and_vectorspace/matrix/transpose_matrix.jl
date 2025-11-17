A = [1 0 1 1 
     2 0 1 0 
    -2 3 4 0 
    -5 5 6 0];

A'
# 4×4 adjoint(::Matrix{Int64}) with eltype Int64:
#  1  2  -2  -5
#  0  0   3   5
#  1  1   4   6
#  1  0   0   0

[2im 1+3im 
   4     5]'
# 2×2 adjoint(::Matrix{Complex{Int64}}) with eltype Complex{Int64}:
#  0-2im  4+0im
#  1-3im  5+0im
