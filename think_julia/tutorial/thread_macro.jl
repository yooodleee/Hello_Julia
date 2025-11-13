using Base.Threads

Threads.nthreads()

for i ∈ 1:9
    print(i, " ")
end
# 1 2 3 4 5 6 7 8 9 

@threads for i ∈ 1:9
    print(i, " ")
end
# 1 5 7 4 9 6 3 2 8 