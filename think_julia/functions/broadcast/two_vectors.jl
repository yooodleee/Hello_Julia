x = [3, 7, 1];
y = [0, 6, 2];

x' * y  # inner product
# 44

x * y
# ERROR: MethodError: no method matching *(::Vector{Int64}, ::Vector{Int64})
# The function `*` exists, but no method is defined for this combination of argument types.

x .* y 
# 3-element Vector{Int64}:
#   0
#  42
#   2