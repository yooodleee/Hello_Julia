julia = "hello"
# "hello"

julia[end] = 'a'
# ERROR: MethodError: no method matching setindex!(::String, ::Char, ::Int64)
