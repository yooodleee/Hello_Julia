# Aotumatically run notebooks and generate rst table for results

include("badges.jl")

"""rst file parser to find title, author and factcheck status."""
function parse_rst(filename)
    res = Dict("author" => "unknown", "status" => 0, "title" => "", "abstract" => "")
    title_found = false
    open(filename) do fid
        data = readlines(fid)
        for line in data
            line = strip(line)
            if line == ""
                continue
            end
            if !title_found
                res["title"] = line 
                title_found = true
            end
            if startswith(line, "Author(s):")
                auth = split(line[12:end], ' ')
                auth = filter(s -> !('@' in s), auth)
                auth = join(auth, ' ')
                res["author"] = auth
            end
            if startswith(line, "Abstract:")    # not working, todo, fixme, ...
                res["abstract"] = line[11:end]
            end
            if startswith(line, "Failed:")
                res["status"] = 1
            end
            if startswith(line, "Failure:")
                res["status"] = 1
            end
            m = matchall(r"[-0-9.]+", line)
        end
    end
    return res 
end


function run_notebooks()
    k = 0
    results = Dict[]
    cd(dirname(@__FILE__)) do 
        for ipynb in readir("tutorials")
            tic()
            if !endswith(ipynb, "ipynb")
                continue
            end
            runtime = 0
            status = 1
            println("Running notebook tutorials/$ipynb")
            # port = 34211+k # you're having some weird port issue with zmq
            # k += 1
            try
                run(`timeout 180 runipy -0 tutorials/$ipynb --kernel=julia-0.4`)
                status = 0
            catch error
                warn("running notebook failed")
                Base.showerror(Base.STDOUT, error)
            end
            runtime = toc()
            bn = "tutorials/$(ipynb[1:end-6])"
            # try
            #     run(`ipython nbconvert tutorials/$ipynb --to rst --output=$bn`)
            # catch error
            #     warn("unable to convert notebook to rst format")
            #     Base.showerror(Base.STDOUT, error)
            # end
    end
end