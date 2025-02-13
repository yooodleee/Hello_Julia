# 수학 함수

"
줄리아에서는 대부분의 친숙한 수학 함수들을 바로 사용할 수 있다. 다음의 예에서는 상용로그를 구하는 log10 함수를 사용해
(신호 강도 signal_power와 노이즈 강도 noise_power가 이미 정의되어 있다고 가정하고) 신호 대 노이즈 비율을 데시벨로 계
산한다. 물론 자연로그를 계산하는 함수 log도 있다.
"
signal_power = 20
noise_power = 30
ratio = signal_power / noise_power
decibels = 10 * log10(ratio)


"
다음의 에시에서는 라디안(radian) 값의 사인(sine)을 구한다. 변수의 이름(radians)를 보면, sin 함수와 cos, tan 등 삼각함수가
인수를 라디안으로 받는다는 것을 알 수 있다.
"
radians = 0.7
height = sin(radians)

"
도degree로 표시된 각도를 라디안으로 바꾸려면, 180으로 나누고 π를 곱하면 된다.
"
degrees = 45
radians = degrees / 180 * π
sin(radians)

"
변수 π의 값은 부동소수점 수로 표시된 원주율 π의 근사값이다. 줄리아 안에 내장되어 있고, 유효숫자는 16자리다. 줄리아에서 pi는 π
의 또 다른 표현이다. 삼각함수를 알고 있다면 위 예시의 결과에를 root(2)/2와 비교해볼 수 있다는 걸 알 것이다.
"
sqrt(2) / 2