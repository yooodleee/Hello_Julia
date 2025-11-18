fib(n) = n > 1 ? fib(n-1) + fib(n-2) : n 
# fib (generic function with 1 method)

println("fib(10) = ", fib(10))
# fib(10) = 55

println("fib(10) = $(fib(10))")
# fib(10) = 55


# # no interpolated case:
for n = 5:14
    if n >= 10
        println(lpad("fib(", 4), n, ") = ", lpad(fib(n), 3))
    else
        println(lpad("fib(", 5), n, ") = ", lpad(fib(n), 3))
    end
end

# fib(5) =   5
# fib(6) =   8
# fib(7) =  13
# fib(8) =  21
# fib(9) =  34
# fib(10) =  55
# fib(11) =  89
# fib(12) = 144
# fib(13) = 233
# fib(14) = 377


# # interpolated case:
for n = 5:14
    println("$(lpad("fib($n)", 7)) = $(lpad(fib(n), 3))")
end

# fib(5) =   5
#  fib(6) =   8
#  fib(7) =  13
#  fib(8) =  21
#  fib(9) =  34
# fib(10) =  55
# fib(11) =  89
# fib(12) = 144
# fib(13) = 233
# fib(14) = 377
