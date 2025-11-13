using ProgressMeter

function accumulate_randoms(n_iters::Int)
    x = zeros(100)
    @showprogress for i ∈ 1:n_iters
        x .+= rand(100)     # broadcast
    end
    return x
end

@time result = accumulate_randoms(10_000_000)