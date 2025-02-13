# 새로운 함수 만들기

# 지금까지 줄리아에서 제공하는 함수만 사용했다. 물론 새로운 함수를 추가하는 것도 가능하다. 이를 함수 정의
# (function definition)라고 한다. 새로운 함수의 이름과 함수가 호출되었을 때 실행할 문장의 나열을 지정하면 된다.

function printlyrics()
    println("I'm a lumberjack, and I'm Okay.")
    println("I sleep all night and I work all day.")
end

""" 
function은 함수 정의가 시작됨을 알려주는 예약어다. 이 예제에서 함수의 이름, 즉 함수명은 printlyrics이다. 함수명을 
정하는 규칙은 같다. 거의 모든 유니코드 문자를 쓸 수 있다. 단 첫 번째 문자가 숫자일 수는 없다. 예약어를 함수명으로 
쓰는 것도 안 된다. 변수와 함수를 같은 이름으로 정하는 것도 피해야 한다.

함수명 뒤에 괄호 안에 아무것도 없으면, 이 함수는 아무런 인자도 받지 않는다는 뜻이다. 함수 정의의 첫 줄을 헤더(header)
라고 하고, 나머지는 본문(body)라고 한다. 본문은 end 예약어로 끝나고, 문장은 몇 개든지 포함할 수 있다. 가독성을 위해 
함수의 본문은 들여쓰기(indent)해야 한다.

따옴표는 반드시 "곧은 따옴표"를 쓴다. 인쇄물 등에서 쓰는 "둥근 따옴표"는 (문자열 안에 포함시키는 것을 제외하면) 줄리아에서
쓸 수 없다. 대화형 모드에서 함수 정의를 하게 되면 REPL이 함수 정의가 아직 완료되지 않았음을 보여주기 위해 자동으로 들여쓰기를
해준다.
"""
function printlyrics()
    println("I'm a lumberjack, and I'm okay.")
end

"""
함수 정의를 마치려면, 예약어인 end를 입력한다. 새로운 함수를 호출하는 것은 내장 함수(built-in function)와 다를 바 없다.
"""

printlyrics()

"""
함수를 일단 정의했다면, 다른 함수 안에서 사용할 수도 있다. 예컨대 앞의 후렴을 반복려면 repeatlyris라는 함수를 또 만들 수 있을
것이다.
"""
function repeatlyris()
    printlyrics()
    printlyrics()
end

repeatlyris()