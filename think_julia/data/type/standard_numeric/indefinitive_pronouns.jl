nothing

missing
# missing 

nothing isa Nothing
# true

missing isa Missing
# true 

something(nothing, 2, 3)
# 2

for k in skipmissing([missing, 2, 3])
    println(k)
end
# 2
# 3