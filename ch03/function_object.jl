# 정의와 사용

"""
앞 절에 나온 코드 조각을 모아보면, 전체 프로그램은 다음과 같다.
"""

function printlyris()
    println("I'm a lumberjack, and I'm okay.")
    println("I sleep all night and I work all day.")
end

function repeatlyrics()
    printlyris()
    printlyris()
end

repeatlyrics()

"""
이 프로그램은 두 개의 함수 정의printlyrics와 repeatlyrics를 가지고 있다. 함수 정의는 다른 문장처럼 실행되며,
그 결과로 함수 객체(function object)가 만들어진다. 함수의 내부에 있는 문장들은 함수가 호출될 때까지 실행되지 
않는다. 그래서 함수 정의 자체는 아무런 출력을 하지 않는다.

예상하겠지만, 함수를 실행하기 전에 먼저 함수를 만들어야 한다. 다른 말로 하면 함수 정의가 함수 호출 전에 실행되어야 한다.
"""