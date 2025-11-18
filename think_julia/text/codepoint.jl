codepoint('a')
# 0x00000061

codepoint('b')
# 0x00000062

codepoint('가')
# 0x0000ac00

Int('a')
# 97

'a' + 2
# 'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)

'a' * 2
# ERROR: MethodError: no method matching *(::Char, ::Int64)
