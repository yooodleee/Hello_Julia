# 실행 흐름

"""
함수가 처음 사용되기 전에 함수 정의가 나오도록 보장하려면, 문장이 실행되는 순서를 알아야 한다. 이것을
실행 흐름(flow of execution)이라고 한다.

프로그램의 실행은 언제나 첫 문장부터 시작한다. 문장은 위에서 아래로 하나씩 차례대로 실행된다.

함수 정의는 실행 흐름을 바꾸지 않는다. 함수 내부에 있는 문장들은 함수가 호출되기 전까지는 실행되지 않는다는
점을 기억해두자.

함수 호출은 실행 흐름에서 우회한다고 생각하면 쉽다. 함수 호출을 만나면 다음 문장으로 가기 전에 호출된 함수의 본문으로 
점프한다. 거기서 본문의 끝까지 문장들을 실행하고 나서, 점프를 시작헀던 지점으로 돌아간다. 이것은 꽤 간단해 보이지만, 
함수는 또 다른 함수를 호출할 수 있다는 것을 알 수 있었다. 한 함수의 내부에서 한참 문장들을 따라가던 도중, 다른 함수 
호출을 만나 그 다른 함수의 문장들을 또 실행하게 될 수도 있다. 그러다가 거기서 또 다른 함수 호출을 만나면 또 그 함수의
문장을 실행하고...

다행히 줄리아는 이런 점프들을 잘 기록하고 있다가, 함수가 완료되면 그 함수가 호출되었던 곳으로 돌아가서 실행을 게속한다.
이런 식으로 프로그램의 끝까지 가면, 종료되는 것이다. 요약하자면 프로그램을 읽을 때 위에서 아래로 읽는 것이 항상 최선은 
아니라는 것이다. 종종 실행 흐름을 따라가면서 읽는 것이 합리적일 때가 있다.
"""