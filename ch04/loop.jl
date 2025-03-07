# 단순 반복
using Thinkjulia

🐢 = Turtle()
@svg begin
    forward(🐢, 100)
    turn(🐢, -90)
    forward(🐢, 100)
    turn(🐢, -90)
    forward(🐢, 100)
    turn(🐢, -90)
    forward(🐢, 100)
end

"""
for 명령문을 사용하면 더 간결하게 할 수 있다.
"""

for i in 1:4
    println("Hello!")
end

"""
이것은 for 명령문의 가장 간단한 사용례이다. 더 자세한 내용은 나중에 보겠지만, 이 정도만 알아도 프로그램을 다시
작성하기에 충분하다. 더 읽기 전에 꼭 직접 프로그램을 작성해보도록 한다.

다음은 정사각형을 그리는 for 문이다.
"""

🐢 = Turtle()
@svg begin
    for i in 1:4
        forward(🐢, 100)
        turn(🐢, -90)
    end
end

"""
for 명령문의 구문 규칙은 함수 정의와 유사하다. 헤더가 있고 end 예약어로 긑나는 본문이 있다.
본문은 문장을 몇 개든 포함할 수 있다.

for 명령문은 루프(loop)라고도 부른다. 그 실행 흐름을 보면, 본문을 끝까지 실행한 후, 고리처럼
다시 본문의 맨 처음으로 돌아가기 때문이다. 이 예제에서는 본문을 네 번 실행한다.

엄밀히 봤을 때, for 명령문을 써서 작성한 프로그램은 그 전 프로그램과 다르다. 왜냐하면 정사각형의 마지막 변을 그린 후
90도 회전을 추가로 하기 때문이다. 이 추가 회전 때문에 실행 시간이 조금 더 걸릴 수 있지만, 루프를 돌 때마다 같은 동작을 
하기 때문에 코드가 더 간단해졌다. 추가적으로 실행이 끝났을 때, 거북이가 시작 지점과 동일한 위치에서 동일한 방향을 
바라보도록 하는 효과도 생겼다.
"""