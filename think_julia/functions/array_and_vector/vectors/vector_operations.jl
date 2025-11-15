e = exp(1);     # 2.718281828459045
u = [4, π, 1, -2];
v = [0, -9, 0, e];


# Vector Addition
u + v
# 4-element Vector{Float64}:
#   4.0
#  -5.858407346410207
#   1.0
#   0.7182818284590451

# Vector Substraction
u - v
# 4-element Vector{Float64}:
#   4.0
#  12.141592653589793
#   1.0
#  -4.718281828459045

# Scalar Multiplication
e * u 
# 4-element Vector{Float64}:
#  10.87312731383618
#   8.539734222673566
#   2.718281828459045
#  -5.43656365691809

# Scalar Division
u / π
# 4-element Vector{Float64}:
#   1.2732395447351628
#   1.0
#   0.3183098861837907
#  -0.6366197723675814
