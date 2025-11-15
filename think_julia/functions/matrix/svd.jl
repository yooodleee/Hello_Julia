using LinearAlgebra

R = [1 1; 0 2]
# 2×2 Matrix{Int64}:
#  1  1
#  0  2

E = eigen(R)
# Eigen{Float64, Float64, Matrix{Float64}, Vector{Float64}}
# values:
# 2-element Vector{Float64}:
#  1.0
#  2.0
# vectors:
# 2×2 Matrix{Float64}:
#  1.0  0.707107
#  0.0  0.707107

E.values
# 2-element Vector{Float64}:
#  1.0
#  2.0

E.vectors
# 2×2 Matrix{Float64}:
#  1.0  0.707107
#  0.0  0.707107

S = svd(R)
# SVD{Float64, Float64, Matrix{Float64}, Vector{Float64}}
# U factor:
# 2×2 Matrix{Float64}:
#  0.525731  -0.850651
#  0.850651   0.525731
# singular values:
# 2-element Vector{Float64}:
#  2.2882456112707374
#  0.8740320488976421
# Vt factor:
# 2×2 Matrix{Float64}:
#   0.229753  0.973249
#  -0.973249  0.229753

R + I
# 2×2 Matrix{Int64}:
#  2  1
#  0  3

rand(3,3) + I 
# 3×3 Matrix{Float64}:
#  1.04206   0.822428  0.0831435
#  0.181798  1.64256   0.0291304
#  0.934592  0.062779  1.63784

I3 = I(3)
# 3×3 Diagonal{Bool, Vector{Bool}}:
#  1  ⋅  ⋅
#  ⋅  1  ⋅
#  ⋅  ⋅  1