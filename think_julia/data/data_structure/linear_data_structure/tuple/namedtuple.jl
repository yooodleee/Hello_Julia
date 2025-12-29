point = (x=5, y=3, z=2)
# (x = 5, y = 3, z = 2)

typeof(point)
# @NamedTuple{x::Int64, y::Int64, z::Int64}

propertynames(point)
# (:x, :y, :z)

point.x
# 5

point[end]
# 2

dims = 2
# 2

rev = true 
# true 

sortargs = (; dims, rev)
# (dims = 2, rev = true)

M = [3 7 4; 1 5 8; 9 2 6]
# 3×3 Matrix{Int64}:
#  3  7  4
#  1  5  8
#  9  2  6

sort(M; sortargs...)
# 3×3 Matrix{Int64}:
#  7  4  3
#  8  5  1
#  9  6  2

sort(M; dims = 2, rev = true)
# 3×3 Matrix{Int64}:
#  7  4  3
#  8  5  1
#  9  6  2