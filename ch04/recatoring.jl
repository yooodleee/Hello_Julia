# 리팩터링

"""
circle 함수를 작성할 때는 polygon 함수를 재활용할 수 있었다.
많은 변을 가진 정다각형은 원에 잘 근사하기 때문이다.
하지만 원호는 그렇게 협조적이지가 않아서 arc 함수를 작성할 때는 polygon이나 circle 함수를 활용할 수 없었다.

대안은 polygon 함수를 복사해서 arc 함수로 바꾸는 것이다. 이렇게 한 결과는 아마 다음과 같을 것이다.
"""

function arc(t, r, angle)
    arc_len = 2 * π * r * angle / 360
    n = trunc(arc_len / 3) + 1
    step_len = arc_len / n
    step_angle = angle / n

    for i in 1:n
        forward(t, step_len)
        trun(t, -step_angle)
    end
end

"""
이렇게 작성하고 보니 아래쪽 절반이 polygon 함수와 비슷하다.
그렇지만 인터페이스를 변경하지 않고는 polygon 함수를 활용할 수 없다.
세 번째 인수로 angle 을 받도록 일반화할 수도 있을 텐데, 이렇게 하면 더 이상 polygon 이라는 이름이 적절하지 않다.
그 대신 이렇게 일반화된 함수를 polygon 이라고 하기로 한다.
"""

function polyline(t, n, len, angle)
    for i in 1:n
        forward(t, len)
        turn(t, -angle)
    end
end

"""
이제 polygon 과 arc 함수가 polyline을 사용하도록 재작성한다.
"""

function polygon(t, n, len)
    angle = 360 / n
    polyline(t, n, len, angle)
end

function arc(t, r, angle)
    arc_len = 2 * π * r * angle / 360
    n = trunc(arc_len / 3) + 1
    step_len = arc_len / n
    step_angle = angle / n
    polyline(t, n, step_len, step_angle)
end

"""
마지막으로 circle 함수가 arc 를 사용하도록 재작성해본다.
"""

function circle(t, r)
    arc(t, r, 360)
end

"""
이렇게 인터페이스를 개선하고 코드 재활용을 더 하는 방향으로 프로그래밍을 재정리하는 과정을 리팩터링이라고 부른다.
우리 경우를 보면 arc 함수와 polygon 함수에 비슷한 코드가 있음을 확인한 후, 그 부분을 polyline 으로 생성했다.

미리 이런 프로그램을 만들기로 계획했더라면, polyline 을 먼저 작성함으로써 리팩터링을 피할 수 있었을 것이다.
그렇지만 보통 프로젝트 초입에는 모든 인터페이스를 디자인할 수 있을 정도로 충분히 알고 있기가 어렵다.
코딩을 시작한 이후에야, 비로소 문제를 더 잘 이해하게 된다.
그러므로 종종 리펙터링은 뭔가 더 알게 되었다는 신호일 수도 있겠다.
"""