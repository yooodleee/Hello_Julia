regsample = """
Name, Age, PhoneNumber
Dave, 22, 010-1234-5678
Steve, 23, 010-2345-6789
Rob, 32, 010-3456-7890
John, 47, 010-4567-8901
""";

collect(eachmatch(r"\d{3}-\d{4}-\d{4}", regsample))
# 4-element Vector{RegexMatch}:
#  RegexMatch("010-1234-5678")
#  RegexMatch("010-2345-6789")
#  RegexMatch("010-3456-7890")
#  RegexMatch("010-4567-8901")

collect(eachmatch(r"\d{2,4}", regsample))
# 16-element Vector{RegexMatch}:
#  RegexMatch("22")
#  RegexMatch("010")
#  RegexMatch("1234")
#  ⋮
#  RegexMatch("010")
#  RegexMatch("4567")
#  RegexMatch("8901")

collect(eachmatch(r"\d{3,4}", regsample))
# 12-element Vector{RegexMatch}:
#  RegexMatch("010")
#  RegexMatch("1234")
#  RegexMatch("5678")
#  ⋮
#  RegexMatch("010")
#  RegexMatch("4567")
#  RegexMatch("8901")

collect(eachmatch(r"\w{5,}", regsample))
# 2-element Vector{RegexMatch}:
#  RegexMatch("PhoneNumber")
#  RegexMatch("Steve")

println(replace(regsample, r"m\w?e" => "-"))
# Na-, Age, PhoneNu-r
# Dave, 22, 010-1234-5678
# Steve, 23, 010-2345-6789
# Rob, 32, 010-3456-7890
# John, 47, 010-4567-8901

collect(eachmatch(r"\w*[aA]\w*", regsample))
# 3-element Vector{RegexMatch}:
#  RegexMatch("Name")
#  RegexMatch("Age")
#  RegexMatch("Dave")

collect(eachmatch(r"\w+[aA]\w+", regsample))
# 2-element Vector{RegexMatch}:
#  RegexMatch("Name")
#  RegexMatch("Dave")
