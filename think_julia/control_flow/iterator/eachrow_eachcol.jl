M = [4 8 9 
     7 1 3
     2 5 6];

for mat ∈ eachrow(M)
    println(mat)
end
# [4, 8, 9]
# [7, 1, 3]
# [2, 5, 6]

for rix ∈ eachcol(M)
    println(rix)
end
# [4, 7, 2]
# [8, 1, 5]
# [9, 3, 6]