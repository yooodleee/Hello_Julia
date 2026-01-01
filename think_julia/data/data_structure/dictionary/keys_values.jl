height = Dict([("Alice", 167), ("Bob", 174), ("Eve", 155)])
# Dict{String, Int64} with 3 entries:
#   "Alice" => 167
#   "Bob"   => 174
#   "Eve"   => 155

height["Alice"]
# 167

height[1]
# ERROR: KeyError: key 1 not found

keys(height)
# KeySet for a Dict{String, Int64} with 3 entries. Keys:
# "Alice"
# "Bob"
# "Eve"

values(height)
# ValueIterator for a Dict{String, Int64} with 3 entries. Values:
#     167
#     174
#     155