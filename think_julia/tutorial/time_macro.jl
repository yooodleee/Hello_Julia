function test_sum()
        x = zeros(3)
        for i  ∈ 1:100_000
                x += rand(3)
        end
        return x
end

@time result = test_sum()