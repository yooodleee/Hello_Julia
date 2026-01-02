using DataFrames

winner = DataFrame(
    num = [2, 14, 35, 37, 49, 81],
    win = ["B", "A", "B", "B", "B", "A"]
)
# 6×2 DataFrame
#  Row │ num    win    
#      │ Int64  String
# ─────┼───────────────
#    1 │     2  B
#   ⋮  │   ⋮      ⋮
#    6 │    81  A
#        4 rows omitted

score = DataFrame(
    num = [3, 7, 14, 49, 81, 37],
    scr = [7, 3, 1, 5, 9, 2]
)
# 6×2 DataFrame
#  Row │ num    scr   
#      │ Int64  Int64
# ─────┼──────────────
#    1 │     3      7
#   ⋮  │   ⋮      ⋮
#    6 │    37      2
#       4 rows omitted

outerjoin(winner, score, on = :num)
# 8×3 DataFrame
#  Row │ num    win      scr     
#      │ Int64  String?  Int64?
# ─────┼─────────────────────────
#    1 │    14  A              1
#   ⋮  │   ⋮       ⋮        ⋮
#    8 │     7  missing        3
#                  6 rows omitted

innerjoin(winner, score, on = :num)
# 4×3 DataFrame
#  Row │ num    win     scr   
#      │ Int64  String  Int64
# ─────┼──────────────────────
#    1 │    14  A           1
#    2 │    49  B           5
#    3 │    81  A           9
#    4 │    37  B           2

gdf = groupby(winner, :win)
# GroupedDataFrame with 2 groups based on key: win
# First Group (4 rows): win = "B"
#  Row │ num    win    
#      │ Int64  String
#   ⋮  │   ⋮      ⋮
#        4 rows omitted
# ⋮
# Last Group (2 rows): win = "A"
#  Row │ num    win    
#      │ Int64  String
#   ⋮  │   ⋮      ⋮
#        2 rows omitted

combine(gdf, :win => length => :cnt)
# 2×2 DataFrame
#  Row │ win     cnt   
#      │ String  Int64
# ─────┼───────────────
#    1 │ B           4
#    2 │ A           2