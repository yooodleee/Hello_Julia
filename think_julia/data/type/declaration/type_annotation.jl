f(x::Real)::Real = 4x*(1-x)

f(0.5)
# 1.0

f(0.5 + 0im)
# Error: MethodError: no method matching f(::ComplexF64)