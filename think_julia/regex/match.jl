regsample1 = "Dave in cave gives 2 sharp knives to shave 36 sheep with eve";

match(r"a", regsample1)
# RegexMatch("a")

match(r"z", regsample1)

collect(eachmatch(r"ave", regsample1))
# 3-element Vector{RegexMatch}:
#  RegexMatch("ave")
#  RegexMatch("ave")
#  RegexMatch("ave")

collect(eachmatch(r"(a|i)ve", regsample1))
# 5-element Vector{RegexMatch}:
#  RegexMatch("ave", 1="a")
#  RegexMatch("ave", 1="a")
#  RegexMatch("ive", 1="i")
#  RegexMatch("ive", 1="i")
#  RegexMatch("ave", 1="a")

collect(eachmatch(r"(a|e|i)ve", regsample1))
# 6-element Vector{RegexMatch}:
#  RegexMatch("ave", 1="a")
#  RegexMatch("ave", 1="a")
#  RegexMatch("ive", 1="i")
#  RegexMatch("ive", 1="i")
#  RegexMatch("ave", 1="a")
#  RegexMatch("eve", 1="e")
