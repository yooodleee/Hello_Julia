# 변수와 매개변수의 지역성

"""
어떤 변수를 함수 내부에서 만들면, 그 변수는 함수 내부에서만 유효하게 존재한다. 이런 성질을 지역성(locality)이라고
하고, 이렇게 지역성이 있는 변수를 지역 변수(local variable)라고 한다.
"""

function printtwice(bruce)
    println(bruce)
    print(bruce)
end


function cattwice(part1, part2)
    concat = part1 * part2
    printtwice(concat)
end

line1 = "Bing tiddle"
line2 = "tiddle bang"

cattwice(line1, line2)

"""
cattwice 함수의 실행이 끝나면, 변수 concat은 파괴된다. 이 변수를 출력하려고 한다면, 이런 오류를 만나게 된다.
"""

println(concat) # Bing tiddletiddle bangERROR: LoadError: UndefVarError: `concat` not defined in `Main`
