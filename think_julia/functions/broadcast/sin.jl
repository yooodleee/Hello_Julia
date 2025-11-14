sin([1., 2., 3., 4.])
# ERROR: MethodError: no method matching sin(::Vector{Float64})


sin.([1., 2., 3., 4.])
# 4-element Vector{Float64}:
#   0.8414709848078965
#   0.9092974268256817
#   0.1411200080598672
#  -0.7568024953079282
