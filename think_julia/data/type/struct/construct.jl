struct Stick 
    length::Integer
    tip::String
end

arrow = Stick(12, ">")
# Stick(12, ">")

arrow.length
# 12

arrow.tip
# ">"