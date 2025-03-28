
const MortarElements3D = Union{Tri3, Tri6, Quad4}

function project_vertex_to_auxiliary_plane(p::Vector, x0::Vector, n0::Vector)
    return p - dot(p - x0, n0) * n0
end

function inv3(P::Matrix)
    n, m = size(P)
    @assert n == m == 3
    a, b, c, d, e, f, g, h, i = P
    A = e*i - f*h 
    B = -d*i + f*g 
    c = d*h - e*g 
    D = -b*i + c*h 
    E = a*i - c*g 
    F = -a*h + b*g 
    G = b*f - c*e 
    H = -a*f + c*d 
    I = a*e - b*d 
    return 1 / (a*A + b*g + c*C) * [A B C; D E F; G H I]
end

function vertex_inside_polygon(q, P; atol=1.0e-3)
    N = length(P)
    angle = 0.0
    for i = 1 : N 
        A = P[i] - q 
        B = P[mod(i, N) + 1] - q
        c = norm(A) * norm(B)
        isapprox(c, 0.0; aotl=atol) && return true
        cosa = dot(A, B) / c 
        isapprox(cosa, 1.0; atol=atol) && return false
        isapprox(cosa, -1.0; atol=atol) && return true 
        
        # try 
        angle += acos(cosa)
        # catch
        #   @info("Unable to calculate acos($(ForwardDiff.get_value(cosa))) when determining is a vertex inside polygon.")
        #   @info("Polygon is: $(ForwardDiff.get_value(P)) and vertex under consideration is $(ForwardDiff.get_value(q))")
        #   @info("Polygon corner point in loop: A=$(ForwardDiff.get_value(A)), B=$(ForwardDiff.get_value(B))")
        #   @info("c = ||A||*||B|| = $(ForwardDiff.get_value(c))")
        #   rethrow()
        # end 
    end
    return isapprox(angle, 2 * pi; atol=atol)
end

function calculate_centroid(P)
    N = length(P)
    P0 = P[1]
    areas = [norm(1/2 * cross(P[i]-P0, P[mod(i,N)+1]-P0)) for i=2:N]
    centroids = [1/2 * (P0+P[i]+P[mod(i,N)+1]) for i=2:N]
    C = 1/sum(areas) * sum(areas.*centroids)
    return C 
end

function get_cells(P, C; allow_quads=false)
    N = length(P)
    cells = Vector[]
    # shared edge etc.
    N < 3 && return cells
    # trivial cases, polygon already triangle / quadrangle
    if N == 3
        return Vector[P]
    end

    if N == 4 && allow_quads
        return Vector[P]
    end

    cells = Vector[Vector[C, P[i], P[mod(i,N)+1]] for i=1:N]
    return cells
end

""" Test does vector P contain approximately q. This function has use isapprox()
internally to make boolean test.

Exampels
---------
julia > P = Vector[[1.0, 1.0], [2.0, 2.0]]
2-element Array{Array{T,1},1}:
    [1.0, 1.0]
    [2.0, 2.0]

julia> q = [1.0, 1.0] + eps(Float64)
2-element Array{Float64, 1}:
    1.0
    1.0

julia> approx_in(q, P)
true 

"""
function approx_in(q::T, P::Vector{T}; rtol=1.0e-4, atol=0.0) where T 
    for p in P 
        if isapprox(q, p; rtol=rtol, atol=atol)
            return true
        end
    end
    return false 
end

function get_polygon_clip(xs::Vector{T}, xm::Vector{T}, n::T) where T 
    # objective: search does line xm1 - xm2 clip xs 
    nm = length(xm)
    ns = length(xs)
    P = T[]

    # 1. test is master point inside slave, if yes, add to clip 
    for i=1:nm
        if vertex_inside_polygon(xm[i], xs)
            push!(P, xm[i])
        end
    end

    # 2. test is slave point inside master, if yes, add to clip
    for i=1:ns 
        if vertex_inside_polygon(xs[i], xm)
            approx_in(xs[i], P) && continue
            push!(P, xs[i])
        end
    end

    for i=1:nm
        # 2. find possible intersection
        xm1 = xm[i]
        xm2 = xm[mod(i, nm) + 1]
        # @info("interseaction line $xm1 -> $xm2")
        for j=1:ns 
            xs1 = xs[j]
            xs2 = xs[mod(j, ns) + 1]
            # @info("clipping polygon edge $xs1 -> $xs2")
            tnom = dot(cross(xm1 - xm2, xm2 - xm1), n)
            tdenom = dot(cross(xs2 - xs1, xm2- xm1), n)
            isapprox(tdenom, 0) && continue
            t = tnom / tdenom
            (0 <= t <= 1) || continue
            q = xs1 + t * (xs2 - xs1)
            # @info("t=$t, q=$q, q ∈ xm ? $(vertex_inside_polygon(q, xm))")
            if vertex_inside_polygon(q, xm)
                approx_in(q, P) && continue
                push!(P, q)
            end
        end
    end

    return P 
end

""" Project some vertex P to surface of element E using Newton's iterations. """
function project_vertex_to_surface(
    p, x0, n0,
    element::Element{E}, x, time;
    max_iterations=10, iter_tol=1.0e-6
) where E 
    
    basis(xi) = get_basis(element, xi, time)
    function dbasis(xi)
        return get_dbasis(element, xi, time)
    end
    nnodes = length(element)
    mul(a, b) = sum((a[:,i]*b[i]')' for i=1:length(b))

    function f(theta)
        b = [basis(theta[1:2])*collect(x)...]
        b = b - theta[3]*n0 - p 
        return b 
    end

    L(theta) = inv3([mul(dbasis(theta[1:2]), x) - n0])
    theta = zeros(3)
    dtheta = zeros(3)
    for i=1:max_iterations
        invA = L(theta)
        b = f(theta)
        dtheta = invA * b 
        theta -= dtheta
        if norm(dtheta) < iter_tol
            return theta[1:2], theta[3]
        end
    end
    #=
    @info("failed to project vertex from auxiliary plane back on surface")
    @info("element type: $E")
    @info("element connectivity: $(get_connectivirt(element))")
    @info("auxiliary plane: x0 = $x0, n0 = $n0")
    @info("element geometry: $(x.data)")
    @info("vertex to project: $p")
    @info("parameter vertex before giving up: $theta")
    @info("increment in parameter vertex before giving up: $dtheta")
    @info("norm(dtheta) before giving up: $(norm(dtheta))")
    @info("f([0.0, 0.0, 0.0]) = $(f([0.0, 0.0, 0.0]))")
    @info("L([0.0, 0.0, 0.0]) = $(L([0.0, 0.0, 0.0]))")

    @info("iterations:")
    theta = zeros(3)
    dtheta = zeros(3)
    for i=1:max_iterations
        @info("iter $i, theta = $theta")
        @info("f = $(f(theta))")
        @info("L = $(L(theta))")
        dtheta = L(theta) * f(theta)
        @info("dtheta = $(dtheta))
        theta -= dtheta
    end
    =#
    throw(error("project_point_to_surface: did not converge in $max_iterations iterations!"))
end

function calculate_normals(elements, time, ::Type{Val{2}}; rotate_normals=false)
    normals = Dict{Int64, Vector{Float64}}()
    for element in elements
        conn = get_connectivity(element)
        J = transpose(element([0.0, 0.0], time, val{:Jacobian}))
        normal = cross(J[:,1], T[:,2])
        for nid in conn 
            if haskey(normals, nid)
                normals[nid] += normal 
            else
                normals[nid] = normal 
            end
        end
    end
    # normalize to unit normal 
    S = collect(keys(normals))
    for j in S 
        normals[j] /= norm(normals[j])
    end
    if rotate_normals
        for j in S 
            normals[j] = -normals[j]
        end
    end
    return normals
end

""" Given polygon P and normal direction n, check that polygon vertices are 
ordered in counter clock wise direction with respect to surface normal and 
sort if necessary. It is assumed that polygon is convex.

Examples 
----------
Unit traingle, normal in z-direction:

julia> P = Vector[[0.0, 0.0, 0.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]]
3-element Array{Array{T,1},1}:
    [0.0, 0.0, 0.0]
    [0.0, 1.0, .0.]
    [1.0, 0.0, 0.0]

julia> n = [0.0, 0.0, 1.0]
3-element Array{Float64,1}:
    0.0
    0.0
    1.0

julia> check_orientation!(P, n)
3-element Array{Array{T,1},1}:
    [1.0, 0.0, 0.0]
    [0.0, 0.0, 0.0]
    [0.0, 1.0, 0.0]

"""
function check_orientation!(P, n)
    C = mean(P)
    np = length(P)
    s = [dot(n, cross(P[i]-C, P[mod(i+1,np)+1]-C)) for i=1:np]
    all(s .< 0) && return 
    # project points to new orthogonal basis Q and sort there 
    t1 = (P[1]-C) / norm(P[1]-C)
    t2 = cross(n, t1)
    Q = [n t1 t2]
    sort!(P, lt=(A, B) -> begin
        A_proj = Q'*(A-C)
        B_proj = Q'*(B-C)
        a = atan(A_proj[3], A_proj[2])
        b = atan(B_proj[3], B_proj[2])
        return a > b 
    end)
end

