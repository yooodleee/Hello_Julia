function var4(a,b,c,d)
    m = (a + b + c + d) / 4
    v = ((a-m)^2 + (b-m)^2 + (c-m)^2 + (d-m)^2) / (4-1)
    return v 
end

var4(0,1,2,3)
# 1.6666666666666667