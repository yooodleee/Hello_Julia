
"""
Elasticity equation.

Field equation is:

    m∂²u/∂t² = ∇⋅σ - b

Wask from is: find u∈U such that ∀v in V

    δW := ∫ρ₀∂²u/∂t²⋅δu dV₀ + ∫S:δE dV₀ - ∫b₀⋅δu dV₀ - ∫t₀⋅δu dA₀ = 0

where:

    ρ₀ = density
    b₀ = displacement load
    t₀ = displacement traction

Formulations
---------------
plane stress, plane strain, 3D

References
---------------

https://en.wikipedia.org/wiki/Linear_elasticity
https://en.wikipedia.org/wiki/Finite_strain_theory
https://en.wikipedia.org/wiki/Stress_measures
https://en.wikipedia.org/wiki/Mooney%E2%80%93Rivlin_solid
https://en.wikipedia.org/wiki/Strain_energy_density_function
https://en.wikipedia.org/wiki/Plane_stress
https://en.wikipedia.org/wiki/Hooke's_law

"""
mutable struct Elasticity <: FieldProblem
    # these are found from problem.properties for type Problem{Elasticity}
    formulation :: Symbol
    finite_strain :: Bool
    geometric_stiffness :: Bool
    store_fields :: Vector{Symbol}
end

function Elasticity()
    # formulation Plane_stress, plane_strain, continuum
    return Elasticity(:continuum, false, false, [])
end

function get_unknown_field_name(problem::Problem{Elasticity})
    return "displacement"
end

function get_formulation_type(problem::Problem{Elasticity})
    return :incremental
end

"""
    assemble!(assembly::Assembly, problem::Problem{Elasticity}, elements, time)

Start finite element assembly procedure for Elasticity problem.

Function groups elements to arrays by their type and assembles one element type 
at time. This makes it possible to pre-allocate matrices common to same type
of elements.
"""
function assemble!(assembly::Assembly, problem::Problem{Elasticity}, elements::Vector{Element}, time)
    formulation = Val{problem.properties.formulation}
    for (element_type, elements_subset) in group_by_element_type(elements)
        assemble!(assembly, problem, elements_subset, time, formulation)
    end
end

function assemble!(assembly::Assembly, problem::Problem{Elasticity}, 
    elements::Vector{T}, time, formulation) where {T <: Element}
    
    if problem.assemble_parallel
        @assert problem.assemble_csc
        # Thread assembly
        assemblers = [FEMBase.start_assemble(assembly * K_csc, assembly.f_csc) for i in 1:Threads.nthreads()]
        local_buffers = [allocate_buffer(problem, elements) for i in 1:Threads.nthreads()]
        for (color, elements) in FEMBase.get_color_ranges(elements)
            Threads.@threads for i in 1 : length(elements)
                element = elements[i]
                tid = Threads.threadid()
                assemble_element!(assembly, assemblers[tid], problem, element, local_buffers[tid], time, formulation, true)
            end
        end
    else

        # Normal assembly
        local_buffer = allocate_buffer(problem, elements)
        assembler = FEMBase.start_assemble(assembly.K_csc, assembly.f_csc)
        for i in 1 : length(elements)
            assemble_element!(
                assembly,
                assembler,
                problem,
                elements[i],
                local_buffer,
                time,
                formulation,
                problem.assemble_csc
            )
        end
    end
end

include("problems_elasticity_2d.jl")

const Elasticity3DSurfaceElements = Union{Poi1, Tri3, Tri6, Quad4, Quad8, Quad9}
const Elasticity3DVolumeElements = Union{Tet4, Pyr5, Wedge6, Wedge15, Hex8, Tet10, Hex20, Hex27}

function initialize_internal_params!(params, ip, type_) # ::Type{Val{:type_2d}}
    param_keys = keys(params)
    all_keys = ip.fields.keys
    ip_fields = filter(x->isassigned(all_keys, x), collect(1 : length(all_keys)))

    if !("params_initialized" in ip_fields)
        for key in param_keys
            update!(ip, key, 0.0 => params[key])
        end
        if type_ == Val{:type_2d}
            update!(ip, "stress", 0.0 => [0.0, 0.0, 0.0])
            update!(ip, "strain", 0.0 => [0.0, 0.0, 0.0])
        elseif type_ == Val{:type_3d}
            update!(ip, "stress", 0.0 => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
            update!(ip, "strain", 0.0 => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        else
            error("daa")
        end
        update!(ip, "prev_time", 0.0 => 0.0)
        update!(ip, "params_initialized", 0.0 => true)
    end
end

Parameters.@with_kw struct Elasticity3DLocalBuffers{B, T}
    ndofs           :: Int
    dim             :: Int
    bi              :: BasisInfo{B, T}
    BL              :: Matrix{T} = zeros(6, ndofs)
    BNL             :: Matrix{T} = zeros(9, ndofs)
    Km              :: Matrix{T} = zeros(ndofs, ndofs)
    Kg              :: Matrix{T} = zeros(ndofs, ndofs)
    f_int           :: Vector{T} = zeros(ndofs)
    f_ext           :: Vector{T} = zeros(ndofs)
    f_buffer        :: Vector{T} = zeros(ndofs)
    f_buffer_dim    :: Vector{T} = zeros(div(ndofs, dim))
    gdofs           :: Vector{Int} = zeros(Int, ndofs)
    gradu           :: Matrix{T} = zeros(dim, dim)
    strain          :: Matrix{T} = zeros(dim, dim)
    strain_vec      :: Vector{T} = zeros(6)
    stress_vec      :: Vector{T} = zeros(6)
    F               :: Matrix{T} = zeros(dim, dim)
    D               :: Matrix{T} = zeros(6, 6)
    Dtan            :: Matrix{T} = zeros(6, 6)
    Bt_mul_D        :: Matrix{T} = zeros(ndofs, 6)
    Bt_mul_D_mul_B  :: Matrix{T} = zeros(ndofs, ndofs)
    Bt_mul_S        :: Vector{T} = zeros(ndofs)
end

function allocate_buffer(
    problem::Problem{Elasticity}, ::Vector{Element{El}}
    ) where EL<:Elasticity3DVolumeElements

    dim = get_unknown_field_dimension(problem)

    nnodes = length(El)
    ndofs = dim * nnodes

<<<<<<< HEAD
    return Elasticity3DLocalBuffers(ndofs=ndofs, dim=dim, bi = BasisInfo(El))
end

=======
    for element in elements

        u = element("displacement", time)
        X = element("geometry", time)

        fill!(Km, 0.0)
        fill!(Kg, 0.0)
        fill!(f_int, 0.0)
        fill!(f_ext, 0.0)

        for ip in get_integration_points(element)
            eval_basis!(bi, X, ip)
            w = ip.weight * bi.detJ
            N = bi.N 
            dN = bi.grad  # deriatives of basis functions w.r.t. X, i.e.  ∂N/∂X
            grad!(bi, gradu, u) # displacement gradient ∇u

            # calculate strain tensor and deformation gradient
            fill!(strain, 0.0)
            fill!(F, 0.0)
            F[:,:] += I
            if props.finite_strain
                strain[:,:] = 1/2 * (gradu + gradu' + gradu' * gradu)
                F[:,:] += gradu
            else
                strain[:,:] = 1/2 * (gradu + gradu')
            end
>>>>>>> master


function reset_element!(buf::Elasticity3DLocalBuffers)
    fill!(buf.Km, 0.0)
    fill!(buf.Kg, 0.0)
    fill!(buf.f_int, 0.0)
    fill!(buf.f_ext, 0.0)
    return
end

function reset_integration_point!(buf::Elasticity3DLocalBuffers)
    fill!(buf.F, 0.0)
    fill!(buf.strain, 0.0)
    fill!(buf.D, 0.0)
    fill!(buf.BL, 0.0)
    fill!(buf.BNL, 0.0)
    return
end

<<<<<<< HEAD
function to_voigt!(strain_vec, strain)
    strain_vec[1] = strain[1, 1]
    strain_vec[2] = strain[2, 2]
    strain_vec[3] = strain[3, 3]
    strain_vec[4] = 2.0 * strain[1, 2]
    strain_vec[5] = 2.0 * strain[2, 3]
    strain_vec[6] = 2.0 * strain[1, 3]
    return
end
=======
            fill(D, 0.0)
            E = element("youngs modulus", ip, time)::Float64
            nu = element("poissons ratio", ip, time)::Float64
            la = E * nu / ((1.0 * nu) * (1.0 - 2.0 * nu))
            mu = E / (2.0 * (1.0 + nu))
            D[1, 1] = D[2, 2] = D[3, 3] = 2 * mu + la
            D[4, 4] = D[5, 5] = D[6, 6] = mu 
            D[1, 2] = D[2, 1] = D[2, 3] = D[3, 2] = D[1, 3] = D[3, 1] = la 
>>>>>>> master


const u = (
    [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], 
    [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]
)

const X = (
    [-93.7197, -93.7197, 150.883], [-91.657, -85.8251, 157.885], [-100.523, -88.8309, 157.883], 
    [-91.6593, -88.8309, 157.883], [-92.6883, -89.7724, 154.384], [-96.0902, -87.328, 157.883], 
    [-97.1216, -91.2753, 154.383], [-92.6895, -91.2753, 154.383], [-91.6581, -87.328, 157.883], 
    [-96.0914, -88.8309, 157.883]
)

const displacement_load_string = [string("displacement load", i) for i in 1:3]
""" Assembly 3d continuum elements in general solid mechanics problem. """
function assemble_element!(
    assembly::Assembly,
    assembler::FEMBase.AssemblerSparsityPattern,
    problem::Problem{Elasticity},
    element::Element{El},
    local_buffer::Elasticity3DLocalBuffers,
    time, ::Type{Val{:continuum}},
    use_csc = false
) where El<:Elasticity3DLocalBuffers
    
    cheating = false
    props = problem.properties
    dim = get_unknown_field_dimension(problem)

    nnodes = length(El)
    ndofs = dim * nnodes

    Parameters.@unpack bi, BL, BNL, Km Kg, f_int, f_ext, f_buffer, f_buffer_dim, gdofs, gradu, strain,
            strain_vec, stress_vec, F, D, Dtan, Bt_mul_D, Bt_mul_D_mul_B, Bt_mul_S = local_buffer
    
    if !cheating
        u = element("displacement", time)
        X = element("geometry", time)
    end
    reset_element!(local_buffer)

    for ip in get_integration_points(element)
        reset_integration_point!(local_buffer)
        eval_basis!(bi, X, ip)
        w = ip.weight * bi.detJ
        N = bi.N 
        dN = bi.grad    # deriatives of basis functions w.r.t. X, i.e. ∂N/∂X
        grad!(bi, gradu, u) # displacement gradient ∇u

        # calculate strain tensor and deformation gradient
        # F[:,:] += I 
        for i in 1:dim 
            F[i, i] += 1.0
        end

        if props.finite_strain
            strain[:, :] = 1/2 * (gradu + gradu' + gradu' * gradu)
            F[:, :] += gradu
        else
            strain[:, :] .= 1/2 .* (gradu .+ gradu')
        end

        to_voigt!(strain_vec, strain)

        # material stiffness start 
        if props.finite_strain
            for i = 1 : nnodes
                BL[1, 3*(i-1)+1] = F[1, 1] * DN[1, i]
                BL[1, 3*(i-1)+2] = F[2, 1] * DN[1, i]
                BL[1, 3*(i-1)+3] = F[3, 1] * DN[1, i]
                BL[2, 3*(i-1)+1] = F[1, 2] * dN[2, i]
                BL[2, 3*(i-1)+2] = F[2, 2] * dN[2, i]
                BL[2, 3*(i-1)+3] = F[3, 2] * dN[2, i]
                BL[3, 3*(i-1)+1] = F[1, 3] * dN[3, i]
                BL[3, 3*(i-1)+2] = F[2, 3] * dN[3, i]
                BL[3, 3*(i-1)+3] = F[3, 3] * dN[3, i]
                BL[4, 3*(i-1)+1] = F[1, 1] * dN[2, i] + F[1, 2] * dN[1, i]
                BL[4, 3*(i-1)+2] = F[2, 1] * dN[2, i] + F[2, 2] * dN[1, i]
                BL[4, 3*(i-1)+3] = F[3, 1] * dN[2, i] + F[3, 2] * dN[1, i]
                BL[5, 3*(i-1)+1] = F[1, 2] * dN[3, i] + F[1, 3] * dN[2, i]
                BL[5, 3*(i-1)+2] = F[2, 2] * dN[3, i] + F[2, 3] * dN[2, i]
                BL[5, 3*(i-1)+3] = F[3, 2] * dN[3, i] + F[3, 3] * dN[2, i]
                BL[6, 3*(i-1)+1] = F[1, 3] * dN[1, i] + F[1, 1] * dN[3, i]
                BL[6, 3*(i-1)+2] = F[2, 3] * dN[1, i] + F[2, 1] * dN[3, i]
                BL[6, 3*(i-1)+3] = F[3, 3] * dN[1, i] + F[3, 1] * dN[3, i]
            end
        else
            for i = 1 : nnodes
                BL[1, 3 * (i - 1) + 1] = dN[1, i]
                BL[2, 3 * (i - 1) + 2] = dN[2, i]
                BL[3, 3 * (i - 1) + 3] = dN[3, i]
                BL[4, 3 * (i - 1) + 1] = dN[2, i]
                BL[4, 3 * (i - 1) + 2] = dN[1, i]
                BL[5, 3 * (i - 1) + 2] = dN[3, i]
                BL[5, 3 * (i - 1) + 3] = dN[2, i]
                BL[6, 3 * (i - 1) + 1] = dN[3, i]
                BL[6, 3 * (i - 1) + 3] = dN[1, i]
            end
        end

        # calculate stress

        if cheating
            E = 200e3
            nu = 0.3
        else
            E = element("youngs modulus", ip, time)::Float64
            nu = element("poissons ratio", ip, time)::Float64
        end
        
        la = E * nu / ((1.0 + nu) * (1.0 - 2.0 * nu))
        mu = E / (2.0 * (1.0 + nu))
        D[1, 1] = D[2, 2] = D[3, 3] = 2 * mu + la 
        D[4, 4] = D[5, 5] = D[6, 6] = mu 
        D[1, 2] = D[2, 1] = D[2, 3] = D[3, 2] = D[1, 3] = D[3, 1] = la 

        # determine material model

        material_model = :Linear_elasticity
        if haskey(element, "plasticity")
            material_model = :ideal_plasticity!
        end

        # calculate stress vector based on material model 

        if material_model == :Linear_elasticity
            copyto!(Dtan, D)
            mul!(stress_vec, Dtan, strain_vec)
        end

        if material_model == :ideal_plasticity!
            plastic_def = element("plasticity")[ip.id]

            calculate_stress! = plastic_def["type"]
            yield_surface = plastic_def["yield_surface"]
            params = plastic_def["params"]
            initialize_internal_params!(params, ip, Val{:type_3d})

            if time == 0.0
                error("Given step time = $(time). Please select time > 0.0")
            end

            t_last = ip("prev_time", time)
            update!(ip, "prev_time", time => t_last)
            dt = time - t_last
            stress_last = ip("stress", t_last)
            strain_last = ip("strain", t_last)
            dstrain_vec = strain_vec - strain_last
            fill!(stress_vec, 0.0)
            fill!(Dtan, 0.0)
            plastic_strain = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            calculate_stress!(
                stress_vec,
                stress_last,
                dstrain_vec,
                plastic_strain,
                D,
                params,
                Dtan,
                yield_surface_,
                time,
                dt,
                Val{:type_3d}
            )
        end

        :strain in props.store_fields && update!(ip, "strain", time => strain_vec)
        :stress in props.store_fields && update!(ip, "stress", time => stress_vec)
        :stress11 in props.store_fields && update!(ip, "stress11", time => stress_vec[1])
        :stress22 in props.store_fields && update!(ip, "stress22", time => stress_vec[2])
        :stress33 in props.store_fields && update!(ip, "stress33", time => stress_vec[3])
        :stress12 in props.store_fields && update!(ip, "stress12", time => stress_vec[4])
        :stress23 in props.store_fields && update!(ip, "stress23", time => stress_vec[5])
        :stress13 in props.store_fields && update!(ip, "stress13", time => stress_vec[6])
        :plastic_strain in props.store_fields && update!(ip, "plastic_strain", time => plastic_strain)

        # Km += w * BL' * Dtan * BL
        mul!(Bt_mul_D, transpose(BL), Dtan)
        mul!(Bt_mul_D_mul_B, Bt_mul_D, BL)
        mul!(Bt_mul_D_mul_B, w)
        for i = 1 : ndofs ^ 2
            @inbounds Km[i] += Bt_mul_D_mul_B[i]
        end

        # material stiffness end
        if props.geometric_stiffness
            # take geometric stiffness into account

            for i = 1 : size(dN, 2)
                BNL[1, 3 * (i - 1) + 1] = dN[1, i]
                BNL[2, 3 * (i - 1) + 1] = dN[2, i]
                BNL[3, 3 * (i - 1) + 1] = dN[3, i]
                BNL[4, 3 * (i - 1) + 2] = dN[1, i]
                BNL[5, 3 * (i - 1) + 2] = dN[2, i]
                BNL[6, 3 * (i - 1) + 2] = dN[3, i]
                BNL[7, 3 * (i - 1) + 3] = dN[1, i]
                BNL[8, 3 * (i - 1) + 3] = dN[2, i]
                BNL[9, 3 * (i - 1) + 3] = dN[3, i]
            end

            S3 = zeros(3 * dim, 3 * dim)
            S3[1, 1] = stress_vec[1]
            S3[2, 2] = stress_vec[2]
            S3[3, 3] = stress_vec[3]
            S3[1, 2] = S3[2, 1] = stress_vec[4]
            S3[2, 3] = S3[3, 2] = stress_vec[5]
            S3[1, 3] = S3[3, 1] = stress_vec[6]
            S3[4 : 6, 4 : 6] = S3[7 : 9, 7 : 9] = S3[1 : 3, 1 : 3]

            Kg += w * BNL' * S3 * BNL 
        
        end

        # internal load
        mul!(Bt_mul_S, transpose(BL), stress_vec)
        rmul!(Bt_mul_S, w)
        f_int .+= Bt_mul_S

        # external load start
        if haskey(element, "displacement load")
            T = element("displacement load", ip, time)::Vector{Float64}
            mul!(f_buffer, w, vec(T * N))
            f_ext .+= f_buffer
        end

        for i = 1 : dim 
            if haskey(element, displacement_load_string[i])
                b = element(displacement_load_string[i], ip, time)::Float64
                mul!(f_buffer_dim, w, N)
                for (i, j) in enumerate(1 : dim : length(f_ext))
                    f_ext[j] = b * f_buffer_dim[i]
                end
            end
        end
        # external load end
    end

    FEMBase.get_gdofs!(gdofs, problem, element)

    # Update f_ext in place to be f_ext - f_int
    f_ext .-= f_int

    if use_csc
        # add contribution to K, Kg, f
        @inbounds FEMBase.assemble_local!(assembler, gdofs, Km, f_ext)

        if props.geometric_stiffness
            @inbounds FEMBase.assemble_local_matrix!(assembler, gdofs, Kg)
        end
    else
        add!(assembly.f, gdofs, f_ext)
        add!(assembly.K, gdofs, gdofs, Km)
        if props.geometric_stiffness
            add!(assembly.Kg, gdofs, gdofs, Kg)
        end
    end

    return nothing
end

""" Elasticity equations, surface traction for continuum formulation. """
function assemble!(
    assembly::Assembly,
    problem::Problem{Elasticity},
    elements::Vector{Element{El}},
    time, ::Type{Val{:continuum}}
) where El<:Elasticity3DSurfaceElements
    
    props = problem.properties
    dim = get_unknown_field_dimension(problem)

    for element in elements
        nnodes = size(element, 2)
        f = zeros(dim * nnodes)

        has_concentrated_forces = false
        for ip in get_integration_points(element)
            detJ = element(ip, time, Val{:detJ})
            w = ip.weight * detJ
            N = element(ip, time)
            if haskey(element, "displacement traction force")
                T = element("displacement traction force", ip, time)
                f += w * vec(T * N)
            end
            for i in 1 : dim 
                if haskey(element, "displacement traction force $i")
                    T = element("displacement traction force $i", ip, time)
                    f[i : dim : end] += w * vec(T * N)
                end
                if haskey(element, "concentrated force $i")
                    has_concentrated_forces = true
                    T = element("concentrated force $i", ip, time)
                    f[i : dim : end] += w * vec(T * N)
                end
            end
            if haskey(element, "surface pressure")
                J = element(ip, time, Val{:Jacobian})'
                n = cross(J[:, 1], J[:, 2])
                n /= norm(n)
                # sign convention, positive pressure is towards surface
                p = -element("surface pressure", ip, time)
                f += w * p * vec(n * N)
            end
        end
        if has_concentrated_forces
            update!(element, "concentrated force", time => Any[f])
        end

        gdofs = get_gdofs(problem, element)
        add!(assembly.f, gdofs, f)
    end
end

"""
    assemble!(assmebly, problem, elements, time, ::Type{Val{:continuum}})

Assemble all other elements for continuum Elasticity problems. Basically, 
throw an exception telling to filter invalid elements out from the element 
set.
"""
function assemble!(
    assembly::Assembly,
    problem::Problem{Elasticity},
    elements::Vector{Elasticity{El}},
    time, ::Type{Val{:continuum}} 
) where El 
    
    @info(
        "It looks that you are trying to assemble of type $El to 3d continuum "*
        "problem. However, they are not supported yet. To filter out elements form a "*
        "element set, try `filter(element->!isa(element, Element{$El}), elements)`"
    )
    error(
        "Tried to assemble unsupported elements of type $El to 3d continuum problem."
    )
end

""" Return strain tensor. """
function get_strain_tensor(problem, element, ip, time)
    gradu = element("displacement", ip, time, Val{:Grad})
    eps = 0.5 * (gradu' + gradu)
    return eps
end

""" Return stress tensor. """
function get_stress_tensor(problem, element, ip, time)
    eps = get_strain_tensor(problem, element, ip, time)
    E = element("youngs modulus", ip, time)
    nu = element("poissons ratio", ip, time)
    mu = E / (2.0 * (1.0 + nu))
    la = E * nu / ((1.0 + nu) * (1.0 - 2.0 * nu))
    S = la * tr(eps) * I + 2.0 * mu * eps
    return S 
end

""" Return strain vector in "ABAQUS" order 11, 22, 33, 12, 23, 13. """
function get_strain_vector(problem, element, ip, time)
    eps = get_strain_tensor(problem, element, ip, time)
    return [eps[1, 1], eps[2, 2], eps[3, 3], eps[1, 2], eps[2, 3], eps[1, 3]]
end

""" Return stress vector in "ABAQUS" order 11, 22, 33, 12, 23, 13. """
function get_stress_vector(problem, element, ip, time)
    S = get_stress_tensor(problem, element, ip, time)
    return [S[1, 1], S[2, 2], S[3, 3], S[1, 2], S[2, 3], S[1, 3]]
end

""" Make least squares fit for some field to nodes. """
function lsq_fit(problem, elements, field, time)
    A = SparseMatrixCOO()
    b = SparseMatrixCOO()
    volume = 0.0
    for element in elements
        gdofs = get_connectivity(element)
        for ip in get_integration_points(element)
            detJ = element(ip, time, Val{:detJ})
            w = ip.weight * detJ
            N = element(ip, time)
            f = field(problem, element, ip, time)
            add!(A, gdofs, gdofs, w * kron(N', N))
            for i = 1 : length(f)
                add!(b, gdofs, w * f[i] * N, i)
            end
            volume += w 
        end
    end
    A = sparse(A)
    b = sparse(b)
    A = 1 / 2 * (A + A')

    nz = get_nonzero_rows(A)
    F = ldlt(A[nz, nz])

    x = F \ b[nz, :]

    nodal_values = Dict(node_id => Vector(x[idx, :]) for (idx, node_id) in enumerate(nz))
    return nodal_values
end

""" Postprocessing, extrapolate strain to nodes using least-squares fit. """
function postprocess!(problem::Problem{Elasticity}, time::Float64, ::Type{Val{:strain}})
    elements = get_elements(problem)
    strain = lsq_fit(problem, elements, get_strain_vector, time)
    update!(elements, "strain", time => strain)
end

function postprocess!(problem::Problem{Elasticity}, time::Float64, ::Type{Val{:stress}})
    elements = get_elements(problem)
    stress = lsq_fit(problem, elements, get_stress_vector, time)
    update!(elements, "stress", time => stress)
end