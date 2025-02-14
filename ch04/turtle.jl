# 사례 연구 " 인터페이스 디자인

"""
함께 동작하는 함수들을 어떻게 설계하는지, 그 과정을 사례 연구를 통해 알아볼 것이다.

먼저 프로그램으로 도형을 그릴 수 있는 거북이 그래픽을 소개한다. 거북이 그래픽은 표준 라이브러리에 포함되어 있지
않기 때문에, ThinkJulia 모듈을 사용하도록 줄리아 설치본에 추가해야 할 것이다.
"""

"""
모듈(module)은 관련 있는 함수 모음이 들어 있는 파일을 말한다. 어떤 모듈들은 줄리아 표준 라이브러리에 포함되어 
제공된다. 그 외 추가 기능을 하는 모듈은 패키지(package) 모음집 사이트에서 가져올 수 있다(http://juliaobserver.com)
패키지는 REPL에서 ]를 눌러 Pkg REPL 모드에 들어간 후 add 명령을 사용해 추가한다.
"""

# (v1.0) pkg> add https://github.com/BenLauwens/ThinkJulia.jl

"""
모듈에 있는 함수를 사용하기 위해서는 using 명령문으로 모듈을 먼저 가져와야 한다.
"""

using ThinkJulia

a = Turtle()

"""
ThinkJulia 모듈은 a.Turtle 객체를 만들어주는 Turtle 함수를 제공한다. 여기서 우리는 그 객체를 변수 a에 할당한다.
"""

🐢 = Turtle()
# Luxor.Turtle()

"""
거북이(turtle)가 만들어졌다면, 함수를 호출해 거북이를 움직일 수 있다. 예컨대 거북이를 전진시키려면 다음과 같이 한다.
"""

@svg begin
    forward(🐢, 100)
end