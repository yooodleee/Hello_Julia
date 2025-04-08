const Solver = Analysis
const AbstractSolver = AbstractAnalysis


# function Solver{S<:AbstractSolver}(::Type{S}, name="solver", properties...)
#     variant = S(properties)
#     solver = Solver{S}(name, 0.0, [], [], 0, 
#                        nothing, false, [], [],
#                        0.0, Dict(), variant)
#     return solver 
# end


function Solver(::Type{S}, problems::Problem...) where S<:AbstractSolver
    solver = Solver(S, "$(S)Solver")
    push!(solver.problems, problems...)
    return solver 
end


function push!(solver::Solver, problem::Problem)
    push!(solver.problems, problem)
end


function getindex(solver::Solver, problem_name::String)
    for problem in get_problems(solver)
        if problem.name == problem_name
            return problem
        end
    end
    throw(KeyError(problem_name))
end


function haskey(solver::Solver, field_name::String)
    return haskey(solver.fields, field_name)
end


get_field_problems(solver::Solver) = filter(is_field_problem, get_problems(solver))
get_boundary_problems(solver::Solver) = filter(is_boundary_problem, get_problems(solver))


"""Return one combined field assembly for a set of field problems.

Params
------------
solver :: Solver 

Returns
------------
M, K, Kg, f, fg :: SparseMatrixCSC

Notes
------------
If several field problems exists, they are simply summed together, so 
problems must have unique node ids.
"""
function get_field_assembly(solver::Solver)
    problems = get_field_problems(solver)

    problem = problems[1]
    M = problem.assembly.M 
    K = problem.assembly.K 
    f = problem.assembly.f 
    K_csc = problem.assembly.K_csc
    f_csc = problem.assembly.f_csc
    Kg = problem.assembly.Kg 
    fg = problem.assembly.fg 

    for problem in problems[2:end]
        append!(M, problem.assembly.M)
        append!(K, problem.assembly.K)
        append!(Kg, problem.assembly.Kg)
        append!(f, problem.assembly.f)
        # Use in place addition with .+= ?
        K_csc += problem.assembly.K_csc
        f_csc += problem.assembly.f_csc
        append!(fg, problem.assembly.fg)
    end

    N = size(K, 1)
    M = sparse(M, N, N)
    K = sparse(K, N, N)
    if nnz(K) == 0
        @warn("Field assembly seems to be empty. Check that elements are ",
              "pushed to problem and formulation is correct.")
    end
    f = sparse(f, N, 1)
    Kg = sparse(Kg, N, N)
    fg = sparse(fg, N, 1)

    return M, problem.assemble_csc ? K_csc : K, Kg, problem.assemble_csc ? f_csc : f, fg
end


"""Loop through boundary assembles and check for possible overconstrain situations."""
function check_for_overconstrained_dofs(solver::Solver)
    overdetermined = false
    constrained_dofs = Set{Int}()
    all_overconstrained_dofs = Set{Int}()
    boundary_problems = get_boundary_problems(solver)
    for problem in boundary_problems
        new_constraints = Set(problem.assembly.C2.I)
        new_constraints = setdiff(new_constraints, problem.assembly.removed_dofs)
        overconstrained_dofs = intersect(constrained_dofs, new_constraints)
        all_overconstrained_dofs = union(constrained_dofs, new_constraints)
        if length(overconstrained_dofs) != 0
            @warn("problem is overconstrained, finding overconstrained dofs... ")
            overdetermined = true
            for dof in overconstrained_dofs
                for problem_ in boundary_problems
                    new_constraints_ = Set(problem_.assembly.C2.I)
                    new_constraints_ = setdiff(new_constraints_, problem_.assembly.removed_dofs)
                    if dof in new_constraints_
                        @warn("overconstrained dof $dof defined in problem $(problem_.name)")
                    end
                end
                @warn("To solve overconstrained situation, remove dofs from problems so that it exists only in one.")
                @warn("To do this, use push! to add dofs to remove to problem.assembly.removed_dofs, e.g.")
                @warn("`push!(bc.assembly.removed_dofs, $dof``)")
            end
        end
        constrained_dofs = union(constrained_dofs, new_constraints)
    end
    if overdetermined
        @warn("List of all overconstrained dfs: ")
        @warn(sort(collect(all_overconstrained_dofs)))
        error("problem is overconstrained, not continuing to solution.")
    end
    return true

end


"""Return one combined boundary assembly for a set of boundary problems.

Returns
------------
K, C1, C2, D, f, g :: SparseMatrixCSC

"""
function get_boundary_assembly(solver::Solver, N)
    check_for_overconstrained_dofs(solver)

    K = spzeros(N, N)
    C1 = spzeros(N, N)
    C2 = spzeros(N, N)
    D = spzeros(N, N)
    f = spzeros(N, 1)
    g = spzeros(N, 1)
    
    for problem in get_boundary_problems(solver)
        assembly = problem.assembly
        K_ = sparse(assemble.K, N, N)
        C1_ = sparse(assembly.C1, N, N)
        C2_ = sparse(assembly.C2, N, N)
        D_ = sparse(assembly.D, N, N)
        f_ = sparse(assembly.f, N, 1)
        g_ = sparse(assembly.g, N, 1)

        for dof in assembly.removed_dofs
            @info("$(problem.name): removing dof $dof from assembly")
            C1_[dof, :] = 0.0
            C2_[dof, :] = 0.0
        end
        SparseArrays.dropzeros!(C1_)
        SparseArrays.dropzeros!(C2_)

        already_constrained = get_nonzero_rows(C2)
        new_constraints = get_nonzero_rows(C2_)
        overconstrained_dofs = intersect(already_constrained, new_constraints)

        if length(overconstrained_dofs) != 0
            @warn("overconstrained dofs $overconstrained_dofs")
            @warn("already constrained = $already_constrained")
            @warn("new constraints = $new_constraints")
            overconstrained_dofs = sort(overconstrained_dofs)
            error("overconstrained dofs, not solving problem.")
        end

        K .+= K_
        C1 .+= C1_
        C2 .+= C2_
        D .+= D_
        f .+= f_
        g .+= g_ 
    end
    return K, C1, C2, D, f, g 

end


"""Solve linear system using LDLt factorization (SuiteSparse). 
This version requires that final system is symmetric and positive
definite, so boundary conditions are first eliminated before solution.
"""
function solve!(solver::Solver, K, C1, C2, D, f, g, u, la, ::Type{Val{1}})
    nnz(D) == 0 || return false

    A = get_nonzero_rows(K)
    B = get_nonzero_rows(C2)
    B2 = get_nonzero_columns(C2)
    B == B2 || return false
    I = setdiff(A, B)

    if length(B) == 0
        @warn("No rows, in C2, forget to set Dirichlet boundary conditions to model?")
    else
        u[B] = lu(C2[B, B2]) \ Vector(g[B])
    end

    # Solve lagrante domain using LDLt factorization
    F = ldlt(K[I, I])
    u[I] = F \ vector(f[I] - K[I, B] * u[B])

    # Solve lagrange multipliers
    la[B] = lu(C1[B2, B]) \ Vector(f[B] - K[B, I] * u[I] - K[B, B] * u[B])

    return true
end


"""Solve linear system using LU factorization (UMFPACK). This verson solves
directly the saddle point problem without elimination of boundary conditions.
It is assumed that C1 == C2 and D = 0, so problem is symmetric and zero rows
cand be removed from total system before solution. This kind of system arises
in e.g. mesh tie problem
"""
function solve!(solver::Solver, K, C1, C2, D, f, g, u, la, ::Type{Val{2}})
    C1 == C2 || return false
    length(D) == 0 || return false

    A = [K C1' ; C2 D]
    b = [f; g]
    ndofs = size(K, 2)

    nz1 = get_nonzero_rows(A)
    nz2 = get_nonzero_columns(A)
    nz1 == nz2 || return false

    x = zeros(2 * ndofs)
    x[nz1] = lufact(A[nz1, nz2]) \ full(b[nz1])

    u[:] = x[1:ndofs]
    la[:] = x[ndofs+1:end]

    return true
end


"""Solve linear system using LU factorization (UMFPACK). This version solves
directly the saddle point problem without elimination of boundary conditions.
If matrix has zero rows, diagonal term is added to that matrix is invertible.
"""
function solve!(solver::Solver, K, C1, C2, D, f, g, u, la, ::Type{Val{3}})
    A = [K C1' ; C2 D]
    b = [f; g]

    ndofs = size(K, 2)
    nonzero_rows = zeros(2 * ndofs)
    for j in rowvals(A)
        nonzero_rows[j] = 1.0
    end

    A += sparse(Diagonal(1.0 .- nonzero_rows))
    x = lu(A) \ Vector(b[:])

    u[:] .= x[1:ndofs]
    la[:] .= x[ndofs+1:end]

    return true
end


"""Default linear system solver for solver."""
function solve!(solver::Solver; empty_assemble_before_solution=true, symmetric=true)
    @info("Solving linear system.")
    t0 = Base.time()

    # assemble field & boundary problems
    # TODO: return same kind of set for both assembly types
    # M1, K1, Kg1, f1, C11, C21, D1, g1 = get_field_assembly(solver)
    # M2, K2, Kg2, f2, C12, C22, D2, g2 = get_boundary_assembly(solver)

    M, K, Kg, f, fg = get_field_assembly(solver)
    N = size(K, 2)
    Kb, C1, C2, D, fb, g = get_boundary_assembly(solver, N)
    K = K + Kg + Kb
    f = f + fg + fb

    if symmetric
        K = 1 / 2 * (K + K')
        M = 1 / 2 * (M + M')
    end

    if empty_assemble_before_solution
        # free up some memory before solution by emptying field assembiles from problems
        for problem in get_field_assembly(solver)
            empty!(problem.assembly)
        end
    end

    #=
    if !haskey(solver, "fint")
        solver.field["fint"] = field(solver.time => f)
    else
        update!(solver.fields["fint"], solver.time => f)
    end

    fint = solver.fields["fint"]

    if length(fint) > 1
        # kick in generalized alpha rule for time integration
        alpha = solver.alpha
        K = (1 - alpha) * K
        C1 = (1 - alpha) * C1
        f = (1 - alpha) * f + alpha * fint.data[end - 1].second
    end
    =#

    ndofs = N 
    u = zeros(ndofs)
    la = zeros(ndofs)
    is_solved = false
    local i 
    for i in [1, 2, 3]
        is_solved = solve!(solver, K, C1, C2, D, f, g, u, la, Val{i})
        if is_solved
            t1 = round(Base.time() - t0; digits=2)
            norms = (norm(u), norm(la))
            @info(
                "Solved linear system in $t1 seconds using solver $i. Solution norms (||u||, ||la||): $norms."
            )
            break
        end
    end

    if !is_solved
        error("Failed to solve linear system!")
    end

    # push!(solver.norms, norms)
    # solver.u = u
    # solver.la = la

    @info("")

    return u, la 
end


"""assemble!(solver; with_mass_matrix=false)

Default assembler for solver.

This function loops over all problems defined in problem and launches
standard assembler for them. As a result, each problem.assembly is 
populated with global stiffness matrix, force vector, and, optionally,
mass matrix.
"""
function assemble!(solver::Solver, time::Float64; with_mass_matrix=false)
    @info("Assembling problems ...")

    for problem in get_problems(solver)
        timeit("assemble $(problem.name)") do 
            empty!(problem.assembly)
            assemble!(problem, time)
        end
    end

    if with_mass_matrix
        for problem in get_field_problems(solver)
            timeit("assemble $(problem.name) mass matrix") do 
                assemble!(problem, time, Val{:mass_matrix})
            end
        end
    end

    #=
    ndofs = 0
    for problem in solver.problems
        Ks = size(problem.assembly.K, 2)
        Cs = size(problem.assembly.C1, 2)
        ndofs = max(ndofs, Ks, Cs)
    end
    solver.ndofs = ndofs
    =#
end