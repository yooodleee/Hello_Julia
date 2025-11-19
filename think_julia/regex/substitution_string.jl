regsample = "Korean ^^ English :)"
# "Korean ^^ English :)"

replace(regsample, r"\^" => "-", r"\)" => "(")
# "Korean -- English :("

regsample2 = "P implies Q"
# "P implies Q"

replace(regsample2, r"(.+) (.+)s (.+)" => s"\3 is \2d by \1")
# "Q is implied by P"