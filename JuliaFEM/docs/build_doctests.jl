using JuliaFEM
using Lexicon

include("badges.jl")

"""Searches recursively all the modules from packages. As documentation grows, it's a bit
troublesome to add all the new modules manually, so this function searches all the modules
automatically.

Params
--------
    module_a: Module 
        Module where you want to search modules inside
    append_list: Array{Module, 1}
        Array, where you append Modules as you find them

Returns
--------
    None, Void function, which manipulates the append_list
"""
function search_modules!(module_::Module, append_list::Array{Module, 1})
    all_names = names(module_, true)
    for each in all_names
        inner_module = module_.(each)
        if (typeof(inner_module) == Module) && !(inner_module in append_list)
            push!(append_list, inner_module)
            search_modules!(inner_module, append_list)
        end
    end
end

append_list = Array(Module, 0)
search_modules!(JuliaFEM, append_list)

const modules = append_list

cd(dirname(@__FILE__)) do 
    npassed = 0
    nfailed = 0
    nskipped = 0

    for m in modules
        s = doctest(m)
        lnpassed, lnfailed, lnskipped = map(length, (passed(s), failed(s), skipped(s)))
        npassed += lnpassed
        nfailed += lnfailed
        nskipped += lnskipped
    end
    println("""DOCTEST: {"failed": $nfailed, "skipped": $nskipped, "passed": $nskipped""")
    make_badge("doctests", npassed, (npassed + nfailed + nskipped), "badges/doctests-status.svg")
end