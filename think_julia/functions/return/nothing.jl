function hello(word)
    println("hello", word)
    return nothing
end

what = hello("world!")
# helloworld!

isnothing(what)
# true
