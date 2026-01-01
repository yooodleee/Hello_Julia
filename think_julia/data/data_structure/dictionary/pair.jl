p = 'i' => identity
# 'i' => identity

propertynames(p)
# (:first, :second)

p.first
# 'i': ASCII/Unicode U+0069 (category Ll: Letter, lowercase)

p.second
# identity (generic function with 1 method)

f = Dict('c' => cos, 's' => sin, 't' => tan)
# Dict{Char, Function} with 3 entries:
#   'c' => cos
#   's' => sin
#   't' => tan

typeof(f)
# Dict{Char, Function}

x = ['c', 'o', 's', 'm', 'i', 'c', 'g', 'i', 'r', 'l', 's'];

replace(x, 's' => 'x')
# 11-element Vector{Char}:
#  'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)
#  'o': ASCII/Unicode U+006F (category Ll: Letter, lowercase)
#  'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
#  ⋮
#  'r': ASCII/Unicode U+0072 (category Ll: Letter, lowercase)
#  'l': ASCII/Unicode U+006C (category Ll: Letter, lowercase)
#  'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)

replace(x, 's' => 'x', 'i' => 'e')
# 11-element Vector{Char}:
#  'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)
#  'o': ASCII/Unicode U+006F (category Ll: Letter, lowercase)
#  'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
#  ⋮
#  'r': ASCII/Unicode U+0072 (category Ll: Letter, lowercase)
#  'l': ASCII/Unicode U+006C (category Ll: Letter, lowercase)
#  'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)