function force_add(x, y)
    n = max(length(x), length(y))
    z = zeros(n)

    for k = 1:n
        try
            z[k] = x[k] + y[k]
        catch err
            if isa(err, BoundsError)
                println("different length vectors!")
            end
            try z[k] = x[k] catch end 
            try z[k] = y[k] catch end 
        end
    end
    return z
end

u = [1, 8, 0, 4, 2];

v = [3, 6, 9];


force_add(u, v)
# different length vectors!
# different length vectors!
# 5-element Vector{Float64}:
#   4.0
#  14.0
#   9.0
#   4.0
#   2.0
