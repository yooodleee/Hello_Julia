# Case 1:
u + π
# ERROR: MethodError: no method matching +(::Vector{Float64}, ::Irrational{:π})
# For element-wise addition, use broadcasting with dot syntax: array .+ scalar


# Case 2:
u .+ π
# 4-element Vector{Float64}:
#  7.141592653589793
#  6.283185307179586
#  4.141592653589793
#  1.1415926535897931
