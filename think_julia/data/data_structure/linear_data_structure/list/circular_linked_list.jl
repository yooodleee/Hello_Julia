p = [2, 3, 5, 7, 11, 13];

@show circshift(p, 2);
# circshift(p, 2) = [11, 13, 2, 3, 5, 7]

@show circshift(p, -1);
# circshift(p, -1) = [3, 5, 7, 11, 13, 2]

M = [3 4 7; 1 5 8; 9 6 2]
# 3×3 Matrix{Int64}:
#  3  4  7
#  1  5  8
#  9  6  2

circshift(M, [0, -1])
# 3×3 Matrix{Int64}:
#  4  7  3
#  5  8  1
#  6  2  9

circshift(M, [1, 1])
# 3×3 Matrix{Int64}:
#  2  9  6
#  7  3  4
#  8  1  5