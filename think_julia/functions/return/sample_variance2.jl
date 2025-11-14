function var4(a,b,c,d)
    m = (a+b+c+d) / 4
    v = ((a-m)^2 + (b-m)^2 + (c-m)^3 + (d-m)^4) / (4-1)
    return m, v 
end

mean1, var1 = var4(0,1,2,3)
# (1.5, 1.6666666666666667)

mean1
# 1.5

var1
# 1.6666666666666667

_, var2 = var4(0,2,4,8)
# (3.5, 141.5625)

var2
# 141.5625