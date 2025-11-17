aa = []
# Any[]

ia = Int64[]
# Int64[]

push!(aa, π)
# 1-element Vector{Any}:
#  π = 3.1415926535897...

push!(ia, π)
# ERROR: MethodError: no method matching Int64(::Irrational{:π})
