# 주석

""" 
프로그램이 커지고 복잡해지면, 읽기가 점점 더 어려워진다. 형식 언어는 밀도가 높아서, 코드를 봤을 때,
    어떤 동작을 하는지, 왜 이런 동작을 하는지 알기가 어려울 때가 있다. 이런 이유로 프로그램의 동작을
    에 대해서 자연 언어로 메모를 다는 것은 좋은 생각이다. 이런 메모를 주석(comment)이라고 부른다. 
    주석은 # 기호로 시작한다.
"""

# 분 단위의 시간(time)을 시간(hour)의 백분율로 계산함.
minute = 60
percentage = (minute * 100) / 60

""" 
이렇게 # 기호로 시작하면 줄 전체가 주석이 된다. 다음과 같이 코드 뒤쪽에 주석을 넣을 수 있다.
"""

percentage = (minute * 100) / 60    # 시간(hour)의 백분율

""" 
# 부터 그 줄의 끝까지 프로그램의 실행에 아무런 영향을 주지 않고 무시된다. 주석은 해당 코드의 당연하지 않은
    사항을 기록하는 데 유용하다. 코드를 읽는 사람이 그 코드가 무엇을 하는지는 알아낼 수 있다고 가정하고, 왜
    그렇게 하는지를 설명하는 편이 좋다. 다음과 같은 주석은 중복되는 내용이므로 불편하다는 것을 알 수 있다.
"""

v = 5   # v에 5를 할당함

"""다음 주석은 코드 자체에서는 제공하지 않는 유용한 정보를 제공한다."""

v = 5   # 속도의 단위는 초당 미터(m/s)