
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
                
end