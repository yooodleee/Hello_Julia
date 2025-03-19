using  Pkg, Documenter, Literate, JuliaFEM

# really?
juliafem_dir = abspath(joinpath(dirname(JuliaFEM)), "..")

"""
    copy_docs(pkg_name)

Copy documentation of some package `pkg_name` to `docs/src/pkg_name`,
where `pkg_name` is the name of package. Return true if success, false
otherwise.

If package is undocumented, i.e. directory `docs/src` is missing,
but there will exists `README.md`, copy that file to
`docs/src/pkg_name/index.md`.
"""
function copy_docs(pkg_name)
    
    local pkg_path
    try
        pkg = getfield(JuliaFEM, Symbol(pkg_name))
        pkg_path = abspath(joinpath(pathof(pkg), "..", ".."))
    catch
        @info("Could not find package $pkg_name from JuliaFEM namespace, pkg_path unknown.")
        return false

    end

    src_dir = joinpath(pkg_path, "docs", "src")
    dst_dir = joinpath(juliafem_dir, "docs", "src", "packages", pkg_name)
    pkg_dir = joinpath(juliafem_dir, "docs", "src", "packages")
    isdir(pkg_dir) || mkpath(pkg_dir)

    # if can find pkg_name/docs/src =>
    # copy that to docs/src/packages/pkg_name
    if isdir(src_dir)
        isdir(dst_dir) || cp(src_dir, dst_dir)
        @info("Copied documentation of package $pkg_name from $src_dir successfully.")
        return true
    end
    
    # if can find pkg_name/README.md =>
    # copy that to docs/src/packages/pkg_name/index.md
    readme_file = joinpath(pkg_path, "README.md")
    if isfile(readme_file) 
        isdir(dst_dir) || mkpath(dst_dir)
        dst_file = joinpath(dst_dir, "index.md")
        isfile(dst_file) || cp(readme_file, dst_file)
        @info("Copied REAMD.md of package $pkg_name from $readme_file successfully.")
        return true
    end

    @warn(
        "Cannot copy documentation of package $pkg_name from $src_dir: " *
        "No such directory exists. (Is the package in REQUIRE of JuliaFEM?)"
    )

    return false

end


"""
    add_page!(part, page)

Add new page to documentation. Part can be USER_GUIDE, DEVELOPER_GUIDE or
PACKAGES. `page` is a string containing path to the page, or `Pair` where
key is the name of the page and value is the path to the page. 

# Examples

If page starts with `#`, i.e. having title, page is automatically included
to documentation with that name:

```Julia 
add_page!(PACKAGES, "MyPackage/index.md")
```

Title can be changed using `Pair`, i.e.

```Julia
add_page!(PACKAGES, "Theory" => "MyPackage/theory.md")
```

"""
function add_page!(dst, src)
    file = isa(src, Pair) ? src.second : src
    src_dir = joinpath(juliafem_dir, "docs", "src")
    if isfile(joinpath(src_dir, file))
        push!(dst, src)
        return true
    end
    if isfile(joinpath(src_dir, "packages", file))
        push!(dst, joinpath("packages", src))
        return true
    end
    @warn("Cannot add page $file: no such file")
    return false
end


"""
    generate_developers_guide()

Generate Developer's guide.
"""
function generate_developers_guide()
    DEVELOPER_GUIDE = []
    if copy_docs("FEMBase")
        add_page!(DEVELOPER_GUIDE, "FEMBase/mesh.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/fields.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/basis.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/integeration.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/elements.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/problems.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/solvers.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/postprocessing.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/results.md")
        add_page!(DEVELOPER_GUIDE, "FEMBase/materails.md")
    end
    return DEVELOPER_GUIDE
end


"""
    generate_packages()

Generate single page description for packages by fetching the REAMD.md, index.md
or similar from the package documentation. Returns a vector containing pages for
a documentation.
"""
function generate_packages()
    PACKAGES = []
    copy_docs("FEMBase")                && add_page!(PACKAGES, "FEMBase/index.md")
    copy_docs("FEMBasis")               && add_page!(PACKAGES, "FEMBasis/index.md")
    copy_docs("FEMQuad")                && add_page!(PACKAGES, "FEMQuad/index.md")
    copy_docs("FEMSparse")              && add_page!(PACKAGES, "FEMSparse/index.md")
    copy_docs("Materials")              && add_page!(PACKAGES, "Materials/index.md")
    copy_docs("AsterReader")            && add_page!(PACKAGES, "AsterReader/index.md")
    copy_docs("AbaqusReader")           && add_page(PACKAGES, "AbaqusReader/index.md")
    copy_docs("LinearImplicitDynamics") && add_page!(PACKAGES, "LinearImplicitDynamics/index.md")
    copy_docs("HeatTransfer")           && add_page!(PACKAGES, "HeatTransfer/index.md")
    copy_docs("PlaneElasticity")        && add_page!(PACKAGES, "PlaneElasticity/index.md")
    copy_docs("FEMCoupling")            && add_page!(PACKAGES, "FEMCoupling/index.md")
    copy_docs("FEMTruss")               && add_page!(PACKAGES, "FEMTruss/index.md")
    copy_docs("Mortar2D")               && add_page!(PACKAGES, "Mortar2D/index.md")
    copy_docs("Mortar3D")               && add_page!(PACKAGES, "Mortar3D/index.md")
    copy_docs("MortarContact2D")        && add_page!(PACKAGES, "MortarContact2D/index.md")
    copy_docs("MortarContact2DAD")      && add_page!(PACKAGES, "MortarContact2DAD/index.md")
    copy_docs("OptoMechanics")          && add_page!(PACKAGES, "OptoMechanics/index.md")
    copy_docs("Miniball")               && add_page!(PACKAGES, "Miniball/index.md")
    copy_docs("ModelReduction")         && add_page!(PACKAGES, "ModelReduction/index.md")
    copy_docs("NodeNumbering")          && add_page!(PACKAGES, "NodeNumbering/index.md")
    # copy_docs("Xdmf")                 && add_page!(PACKAGES, "Xdmf/index.md")
    copy_docs("UMAT")                   && add_page!(PACKAGES, "UMAT/index.md")
    return PACKAGES
end