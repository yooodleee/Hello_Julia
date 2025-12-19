length("Dynamics")
# 8

length([0, 1, 3])
# 3

length
# length (generic function with 89 methods)

length(arrow)
# ERROR: MethodError: no method matching length(::Stick)

Base.length(x::Stick) = x.length 

length(arrow)
# 12

length.(["Dynamics", [0, 1, 3], arrow])
# 3-element Vector{Int64}:
#   8
#   3
#  12

arrow
# Stick(12, ">")

function Base.show(io::IO, data::Stick)
    print(io, ("-" ^ data.length) * data.tip)
end

arrow
# ------------>

Stick(2, "O")
# --O

Stick(4, "I")
# ----I

Stick(8, "E")
# --------E 