reshape(1:12, 3, 4)
# 3×4 reshape(::UnitRange{Int64}, 3, 4) with eltype Int64:
#  1  4  7  10
#  2  5  8  11
#  3  6  9  12

reshape(1:12, 2, :, 3)
# 2×2×3 reshape(::UnitRange{Int64}, 2, 2, 3) with eltype Int64:
# [:, :, 1] =
#  1  3
#  2  4

# [:, :, 2] =
#  5  7
#  6  8

# [:, :, 3] =
#   9  11
#  10  12
