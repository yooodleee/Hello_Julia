using DataFrames

df1 = DataFrame(letter = ['A', 'B', 'C'], number = [1, 2, 3])
# 3×2 DataFrame
#  Row │ letter  number 
#      │ Char    Int64
# ─────┼────────────────
#    1 │ A            1
#    2 │ B            2
#    3 │ C            3

charactor = ["adam", "eve"]
# 2-element Vector{String}:
#  "adam"
#  "eve"

page = [19, 77]
# 2-element Vector{Int64}:
#  19
#  77

df2 = DataFrame(; charactor, page)
# 2×2 DataFrame
#  Row │ charactor  page  
#      │ String     Int64
# ─────┼──────────────────
#    1 │ adam          19
#    2 │ eve           77

_df3 = [1 0 9; 8 5 2]
# 2×3 Matrix{Int64}:
#  1  0  9
#  8  5  2

df3 = DataFrame(_df3, ["x", "y", "z"])
# 2×3 DataFrame
#  Row │ x      y      z     
#      │ Int64  Int64  Int64
# ─────┼─────────────────────
#    1 │     1      0      9
#    2 │     8      5      2

df3 = DataFrame(_df3, :auto)
# 2×3 DataFrame
#  Row │ x1     x2     x3    
#      │ Int64  Int64  Int64
# ─────┼─────────────────────
#    1 │     1      0      9
#    2 │     8      5      2

Matrix(df3)
# 2×3 Matrix{Int64}:
#  1  0  9
#  8  5  2

ef = DataFrame(a = [], p = Int[], k = String[])
# 0×3 DataFrame
#  Row │ a    p      k      
#      │ Any  Int64  String
# ─────┴────────────────────

df4 = DataFrame(x = [3, 1, 7, 1, ], y = [5, 9, 2, 1])
# 4×2 DataFrame
#  Row │ x      y     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      5
#    2 │     1      9
#    3 │     7      2
#    4 │     1      1

rename(df4, [:a, :b])
# 4×2 DataFrame
#  Row │ a      b     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      5
#    2 │     1      9
#    3 │     7      2
#    4 │     1      1

rename(df4, :y => :z)
# 4×2 DataFrame
#  Row │ x      z     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      5
#    2 │     1      9
#    3 │     7      2
#    4 │     1      1

df4[1, :]
# DataFrameRow
#  Row │ x      y     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      5

df4
# 4×2 DataFrame
#  Row │ x      y     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      5
#    2 │     1      9
#    3 │     7      2
#    4 │     1      1

sort(df4, :x)
# 4×2 DataFrame
#  Row │ x      y     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     1      9
#    2 │     1      1
#    3 │     3      5
#    4 │     7      2

sort(df4, :y)
# 4×2 DataFrame
#  Row │ x      y     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     1      1
#    2 │     7      2
#    3 │     3      5
#    4 │     1      9

push!(df4, [0, -1])
# 5×2 DataFrame
#  Row │ x      y     
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      5
#   ⋮  │   ⋮      ⋮
#    5 │     0     -1
#       3 rows omitted

df4[!, :z] = [missing, -1, 0, missing, 0]; df4
# 5×3 DataFrame
#  Row │ x      y      z       
#      │ Int64  Int64  Int64?
# ─────┼───────────────────────
#    1 │     3      5  missing
#   ⋮  │   ⋮      ⋮       ⋮
#    5 │     0     -1        0
#                3 rows omitted

dropmissing(df4)
# 3×3 DataFrame
#  Row │ x      y      z     
#      │ Int64  Int64  Int64
# ─────┼─────────────────────
#    1 │     1      9     -1
#    2 │     7      2      0
#    3 │     0     -1      0

unique(df4, :z)
# 3×3 DataFrame
#  Row │ x      y      z       
#      │ Int64  Int64  Int64?
# ─────┼───────────────────────
#    1 │     3      5  missing
#    2 │     1      9       -1
#    3 │     7      2        0

select(df4, [:x, :z])
# 5×2 DataFrame
#  Row │ x      z       
#      │ Int64  Int64?
# ─────┼────────────────
#    1 │     3  missing
#   ⋮  │   ⋮       ⋮
#    5 │     0        0
#         3 rows omitted

select(df4, Not(:x))
# 5×2 DataFrame
#  Row │ y      z       
#      │ Int64  Int64?
# ─────┼────────────────
#    1 │     5  missing
#   ⋮  │   ⋮       ⋮
#    5 │    -1        0
#         3 rows omitted