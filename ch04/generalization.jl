# 일반화

"""
다음은 매개변수 len을 square 함수에 추가하는 것이다.
"""

function square(t, len)
    for i in 1:4
        forward(t, len)
        turn(t, -90)
    end
end

🐢 = Turtle()
@svg begin
    square(🐢, 100)
end

"""
함수에 매개변수를 추가하는 것을 일반화(generalization)이라고 한다. 매개변수를 추가하면 함수를 더 
일반적인 상황에 사용할 수 있다. 이전 버전에서는 정사각형이 항상 같은 크기였는데, 이 버전에서는 다양한
길이로 만들 수 있게 되었다.

다음 단계도 일반화다. polygon 함수는 정사각형을 그리는 대신, 임의 개수의 변을 갖는 정다각형을 그린다.
"""

function polygon(t, n, len)
    angle = 360 / n
    for i in 1:n
        forward(t, len)
        turn(t, -angle)
    end
end

🐢 = Turtle()
@svg begin
    polygon(🐢, 7, 70)
end

"""
위는 변의 길이가 70인 정칠각형을 그리게 된다.
"""