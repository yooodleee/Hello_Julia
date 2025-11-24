fibnc = [1, 1, 2, 3, 5, 8, 13, 21];

for (f, p) ∈ zip(prime, fibnc)
    println("$f - $p")
end
# 2 - 1
# 3 - 1
# 5 - 2
# 7 - 3
# 11 - 5
# 13 - 8
# 17 - 13
# 19 - 21
