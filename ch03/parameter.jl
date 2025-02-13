# 매개변수와 인수

"""
어떤 함수들은 인수를 받는다. 예를 들어 sin 함수를 호출할 때는 인수로 수치를 넘겨야 한다. 어떤 함수들은 인수를 두 개 이상
받는다. parse 함수는 숫자 한 개와 문자열 한개, 도합 두 개의 인수를 받는다. 함수 내부에서 인수는 매개변수(parameter)라고 
부르는 변수에 할당된다. 인수가 한 개인 함수 정의를 살펴보자.
"""
function printtwice(bruce)
    println(bruce)
    println(bruce)
end

"""
위 함수에는 인수가 bruce라는 이름의 매개변수로 할당된다. 이 함수가 호출되면, 매개변수의 값을 두 번 출력할 것이다. 이 함수는
출력할 수 있는 어떤 값을 받아도 잘 동작한다.
"""

printtwice("Spam")

printtwice(42)

printtwice(π)

"""
합성의 규칙은 내장 함수와 마찬가지로 우리가 정의한 함수에도 적용된다.
그러니까, printtwice 함수의 인수로 어떤 표현식이든 넣을 수 있다.
"""

printtwice("Spam "^4)

"""
인수는 함수가 호출되기 전에 먼저 평가된다. 그러니까 위 예제에서는 "Spam "4와 cos()는 각각
한 번씩만 평가된다. 물론 변수도 표현식이므로 인수로 쓸 수 있다.
"""

michael = "Eric, the half a bee."
printtwice(michael)

"""
여기서 함수의 인수로 전달하는 변수의 이름(michael)은 매개변수의 이름(bruce)과 아무런 상관이 없다.
함수를 호출할 때 어떤 값을 인수로 전달했든 간에, printtwice 함수 내에서 변수 명은 bruce가 된다.
"""