supertype(supertype(typeof([1, 2, 3])))
# AbstractVector{Int64} (alias for AbstractArray{Int64, 1})

supertype(supertype(typeof(zeros(2, 2))))
# AbstractMatrix{Float64} (alias for AbstractArray{Float64, 2})
