using Base.Threads

Threads.nthreads()

A_ = [rand(1000, 1000) for _ in 1:1000];

@time for A ∈ A_
    sin.(A)
end
#   5.781559 seconds (422.98 k allocations: 7.470 GiB, 5.27% gc time, 1.72% compilation time)

@time @threads for A ∈ A_
    sin.(A)
end
#   0.846451 seconds (59.78 k allocations: 7.453 GiB, 27.24% gc time, 18.40% compilation time)