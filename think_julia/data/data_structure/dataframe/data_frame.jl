import Pkg;
Pkg.add("RDatasets")

using RDatasets

iris = dataset("datasets", "iris")
# 150×5 DataFrame
#  Row │ SepalLength  SepalWidth  PetalLength  PetalWidth  Species   
#      │ Float64      Float64     Float64      Float64     Cat…
# ─────┼─────────────────────────────────────────────────────────────
#    1 │         5.1         3.5          1.4         0.2  setosa
#   ⋮  │      ⋮           ⋮            ⋮           ⋮           ⋮
#  150 │         5.9         3.0          5.1         1.8  virginica
#                                                    148 rows omitted

size(iris)
# (150, 5)

propertynames(iris)
# 5-element Vector{Symbol}:
#  :SepalLength
#  :SepalWidth
#  :PetalLength
#  :PetalWidth
#  :Species

iris[1, 1]
# 5.1

iris.Species[1]
# CategoricalArrays.CategoricalValue{String, UInt8} "setosa"