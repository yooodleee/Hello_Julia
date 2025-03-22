using HDF5
using LightXML

mutable struct Xdmf <: AbstractResultsWriter 
    name :: String
    xml :: XMLElement
    hdf :: HDF5File
    hdf_counter :: Int
    format :: String
end


function  Xdmf()
    return Xdmf(tempname())
end

function h5_file(xdmf::Xdmf)
    return xdmf.name * ".h5"
end

function xmffile(xdmf::Xdmf)
    return xdmf.name * ".xmf"
end

"""
    Xdmf(name, version="3.0", overwrite=false)

Initialize a new Xdmf obj.
"""
function Xdmf(name::String, version="3.0", overwrite=false)
    xdmf = new_element("Xdmf")
    h5file = "$name.h5"
    xmlfile = "$name.xmf"

    if isfile(h5file)
        if overwrite
            @debug("Result file $h5file exists, use Xdmf($name; overwrite=true) to rewrite results")
        end
    end

    if isfile(xmlfile)
        if overwrite
            @debug("Result file $xmlfile exists, removing old file.")
            rm(xmffile)
        else
            error("Result file $xmlfile exists, use Xdmf($name; overwrite=true) to rewrite results")
        end
    end

    set_attribute(xdmf, "xmlns:xi", "http://www.w3.org/2001/XInclude")
    set_attribute(xdmf, "Version", version)
    flag = isfile(h5file) ? "r+" : "w"
    hdf = h5open(h5file, flag)
    return Xdmf(name, xdmf, hdf, 1, "HDF")
end