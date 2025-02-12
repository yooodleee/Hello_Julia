# 값과 자료형(value's type)

"""
자료형(type)
    * 정수형(integer):
        2, 42, 0, ...
    * 부동소수점 수(floating point number):
        42.0, 0.0001, ...
    * 문자열(string):
        "Hello World!", ...
    * 자료형 확인은 typeof()
"""

typeof(2)   # Int64

typeof(42.0)    # Float64

typeof("Hello World")   # String

typeof("2") # String

1,000,000   # (1, 0, 0) 세 자리마다 쉼표를 넣음. 단, 자료형은 정수가 아님.
1_000_000   # underscore를 써서 세 자리마다 쉼표를 넣어야 원하는 결과를 얻을 수 있음.