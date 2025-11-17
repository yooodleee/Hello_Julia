T = zeros(2, 2, 2)
# 2×2×2 Array{Float64, 3}:
# [:, :, 1] =
#  0.0  0.0
#  0.0  0.0

# [:, :, 2] =
#  0.0  0.0
#  0.0  0.0

vec(T)
# 8-element Vector{Float64}:
#  0.0
#  0.0
#  0.0
#  ⋮
#  0.0
#  0.0
#  0.0

reshape(T, :)
# 8-element Vector{Float64}:
#  0.0
#  0.0
#  0.0
#  ⋮
#  0.0
#  0.0
#  0.0
