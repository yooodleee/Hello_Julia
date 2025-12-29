xtuple = 3, 2, 2
# (3, 2, 2)

xarray = [3, 2, 2]
# 3-element Vector{Int64}:
#  3
#  2
#  2

typeof(xtuple)
# Tuple{Int64, Int64, Int64}

typeof(xarray)
# Vector{Int64} (alias for Array{Int64, 1})

2 * xtuple 
# ERROR: MethodError: no method matching *(::Int64, ::Tuple{Int64, Int64, Int64})

sort(xtuple)
# ERROR: MethodError: no method matching sort(::Tuple{Int64, Int64, Int64})

sort(xarray)
# 3-element Vector{Int64}:
#  2
#  2
#  3

sort(collect(xtuple))
# 3-element Vector{Int64}:
#  2
#  2
#  3

typeof((1))
# Int64

typeof((1,))
# Tuple{Int64}