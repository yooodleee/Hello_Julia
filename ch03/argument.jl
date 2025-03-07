# 함수 호출

""" 
수학과 다르게, 프로그래밍에서 함수(function)란 어떤 계산을 수행하는 문장의 나열을 말하며,
함수에는 이름이 붙어 있다. 함수를 정의할 때, 이름을 지정하고, 문장을 나열하게 된다. 나중에 함수는
그 이름을 사용해 호출(call)할 수 있다.
"""

# 함수 호출
println("Hello, World!")

""" 
이 함수의 이름은 println이다. 괄호 안의 표현식은 함수의 인수(argument)라고 부른다.
보통 함수는 인수를 받아서, 결과를 돌려준다(return)고들 말한다. 그 결과를 결괏값(반환값)return value이라고 부른다.

줄리아에는 어떤 자료형의 값을 다른 자료형으로 변환하는 함수들이 있다. parse 함수는 문자열을 받아서, 가능한 경우는
지정된 숫자형으로 변환하고, 그렇지 않으면 오류를 낸다.
"""

# parse 함수
parse(Int64, "32")

parse(Float64, "3.14159")

parse(Int64, "Hello")
# ERROR: ArgumentError: invalid base 10 digit 'H' in "Hello"

"""
trunc 함수는 부동 소수점 수를 정수로 변환하는데, 반올림을 하지는 않고, 소수점 아래를 잘라낸다.
"""

trunc(Int64, 3.99999)

trunc(Int64, -2.3)

"""
float 함수는 정수를 부동소수점 수로 변환한다.
"""

float(32)

"""
마지막으로 string 함수는 인수를 문자열로 변환한다.
"""

string(32)

string(3.14567)