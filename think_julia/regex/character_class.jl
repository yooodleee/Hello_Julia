regsample1 = "Dave in cave gives 2 sharp knives to shave 36 sheep with eve";

collect(eachmatch(r"[aeiou]ve", regsample1))
# 6-element Vector{RegexMatch}:
#  RegexMatch("ave")
#  RegexMatch("ave")
#  RegexMatch("ive")
#  RegexMatch("ive")
#  RegexMatch("ave")
#  RegexMatch("eve")

collect(eachmatch(r"[0-9]", regsample1))
# 3-element Vector{RegexMatch}:
#  RegexMatch("2")
#  RegexMatch("3")
#  RegexMatch("6")

collect(eachmatch(r"[^0-9]", regsample1))
# 57-element Vector{RegexMatch}:
#  RegexMatch("D")
#  RegexMatch("a")
#  RegexMatch("v")
#  ⋮
#  RegexMatch("e")
#  RegexMatch("v")
#  RegexMatch("e")

collect(eachmatch(r"..ve", regsample1))
# 6-element Vector{RegexMatch}:
#  RegexMatch("Dave")
#  RegexMatch("cave")
#  RegexMatch("give")
#  RegexMatch("nive")
#  RegexMatch("have")
#  RegexMatch(" eve")

collect(eachmatch(r"\w\wve", regsample1))
# 5-element Vector{RegexMatch}:
#  RegexMatch("Dave")
#  RegexMatch("cave")
#  RegexMatch("give")
#  RegexMatch("nive")
#  RegexMatch("have")

collect(eachmatch(r"[^Dc].ve", regsample1))
# 4-element Vector{RegexMatch}:
#  RegexMatch("give")
#  RegexMatch("nive")
#  RegexMatch("have")
#  RegexMatch(" eve")

regsample2 = """
Name, Age, PhoneNumber
Dave, 22, 010-1234-5678
Steve, 23, 010-2345-6789
Rob, 32, 010-3456-7890
John, 47, 010-4567-8901
""";

collect(eachmatch(r"\d\d\d-\d\d\d\d-\d\d\d\d", regsample2))
# 4-element Vector{RegexMatch}:
#  RegexMatch("010-1234-5678")
#  RegexMatch("010-2345-6789")
#  RegexMatch("010-3456-7890")
#  RegexMatch("010-4567-8901")

println(replace(regsample2, r"-\d\d\d\d-" => "-****-"))
# Name, Age, PhoneNumber
# Dave, 22, 010-****-5678
# Steve, 23, 010-****-6789
# Rob, 32, 010-****-7890
# John, 47, 010-****-8901
