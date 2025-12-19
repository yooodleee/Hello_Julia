half = 2 // 4
# 1//2

typeof(half)
# Rational{Int64}

fieldnames(Rational)
# (:num, :den)

getfield(half, :num)
# 1

getfield(half, :den)
# 2

propertynames(half)
# (:num, :den)

getproperty(half, :num)
# 1

getproperty(half, :den)
# 2

half.num
# 1

half.den
# 2

Q = [k // 12 for k in 1:12]
# 12-element Vector{Rational{Int64}}:
#   1//12
#   1//6
#   1//4
#    ⋮
#   5//6
#  11//12
#    1

@show getproperty.(Q, :num);
# getproperty.(Q, :num) = [1, 1, 1, 1, 5, 1, 7, 2, 3, 5, 11, 1]