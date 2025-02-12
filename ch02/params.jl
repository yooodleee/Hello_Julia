# 변수명


"""
줄리아 REPL에서는 유니코드 문자를 레이텍(LaTeX)과 비슷한 약어를 써서 탭 완성(tab completion)으로 
    입력할 수 있다. 밑줄 문자 _(under score)는 변수명에 쓸 수 있다. your_name이나 airspeed_of_unladen_swallow
    처럼 일반적으로 여러 단어로 된 변수명에 쓴다. 변수명을 잘못 쓰면 구문 오류(syntax error)가 발생한다.
"""
# 76trombondes = "big parade"

# ERROR: LoadError: syntax: "76" is not a valid function argument name 

# @more = 10000000

# struct = "Advanced Theoretical Zymurgy"

"""
76trombondes는 숫자로 시작하기 때문에 잘못되었다.
more@는 사용하면 안되는 문자 @가 포함되어서 오류가 발생했다.

struct는 줄리아의 예약어(keyword)이다. 예약어는 프로그램의 구조를 해석하는 데 사용되므로 변수명으로 
    사용할 수 없다. 줄리아의 예약어는 다음과 같다.

    abstract type       baremodule      begin       break       catch
    const               continue        do          else        elseif
    end                 export          finally     for         false
    function            global          if          import      in
    let                 local           macro       module      mutable struct
    primitive type      quote           return      true        try
    using               struct          where       while
"""