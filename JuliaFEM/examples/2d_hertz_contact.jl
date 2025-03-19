# # 2D Hertz contact problem

# ![](2d_hertz_contact/model.png)

# In the example, a cylinder is pressed agains block with a force of 35 kN.
# A similar example can be found from NAFMS report FENET D3613 (advanced
# finite element contact benchmarks).
#
# Solution for maximum pressure ``p_0`` and contact radius ``a`` is
# ```math
#   p_{0} = \sqrt{\frac{FE}{2\pi R}}, \\
#   a     = \sqrt{\frac{BFR}{\pi E}},
# ```
# where
# ```math
#   E = \frac{2E_{1}E_{2}}{E_{2}\left(1-\nu_{1}^{2}\right)+E_{1}\left(1-\nu_{2}^{2}\right)}.
# ```
# 
# Substituting values, one gets accurate solution to be ``p_0 = 3585 \;\mathrm{MPa}`` and 
# ``a = 6.21 \;\mathrm{mm}``.

using JuliaFEM, LinearAlgebra

# simulation starts by reading the mesh. Model is constructed and meshed using
# SALOME, thus mesh format is .med. Mesh type is quite simple structure,
# containing things `mesh.nodes`, `mesh.elements` and so on. Keep on mind,
# that Mesh contains only standard Julia types and you think it as a structure
# helping you to construct elements needed in simulation. In principle, you don't
# need to use `Mesh` in simulation anyway if you figure some other way to define
# the geometry for elements.

datadir = abspath(joinpath(pathof(JuliaFEM), "..", "..", "examples", "2d_hertz_contact"))
meshfile = joinpath(datadir, "hertz_2d_full.med")
mesh = aster_read_mesh(meshfile)

for (elset_name, element_ids) in mesh.element_sets
    nel = length(element_ids)
    println("Element set $elset_name contains $nel elements.")
end

for (nset_name, node_ids) in mesh.node_sets
    nno = length(node_ids)
    println("Node set $nset_name contains $nno nodes.")
end

nnodes = length(mesh.nodes)
println("Total number of nodes in mesh: $nnodes")
nelements = length(mesh.elements)
println("Total number of elements in mesh: $nelements")


# Next, define two bodies. Technically, you could have only one problem and add
# elements from both bodies to the same problem, but defining two different
# problems is recommended for clarity. Plain strain assumption is used.

# To make clear what is happening here: you first create a set of elements
# (elements are in vector called `upper_elements`), then you define new
# problem which type is `Elasticity`, give it some meaningful name (this time
# `cylinder`), and last value 2 means that problems does have two degrees of
# freedom per node.

upper_elements = create_elements(mesh, "CYLINDER")
update!(upper_elements, "youngs modulus", 70.0e3)
update!(upper_elements, "poissons ratio", 0.3)
upper = Problem(Elasticity, "cylinder", 2)
upper.properties.formulation = :plane_strain
add_elements!(upper, upper_elements)

lower_elements = create_elements(mesh, "BLOCK")
update!(lower_elements, "youngs modulus", 210.0e3)
update!(lower_elements, "poissons ratio", 0.3)
lower = Problem(Elasticity, "block", 2)
lower.properties.formulation = :plane_strain
add_elements!(lower, lower_elements)


# Next you define same boundary conditions: creating "boundary" problems goes
# in the same way than "field" problems, the only difference is that 
# you add extra argument giving what field are you tring to fix. This time, 
# you have 2 dofs / node and you fix displacement in direction 2.

bc_fixed_elements = create_elements(mesh, "FIXED")
update!(bc_fixed_elements, "displacement 2", 0.0)
bc_fixed = Problem(Dirichlet, "fixed", 2, "displacement")
add_elements!(bc_fixed, bc_fixed_elements)

# Defining symmetry boundary condition goes with the same idea

bc_sym_23_elements = create_elements(mesh, "SYM23")
update!(bc_sym_23_elements, "displacement 1", 0.0)
bc_sym_23 = Problem(Dirichlet, "symmetry line 23", 2, "displacement")
add_elements!(bc_sym_23, bc_sym_23_elements)


# Next you define point load. To define that, you first need to find some node 
# near the top of cylinder, using function `find_nearest_node`.
# Then you create a new problem, agian of type Elasticity. 
# Like told already, you don't need to use `Mesh` if you have some other procedure
# to define the geometry of the element (and it's connectivity, of course). 
# So you can directly create an element of type `Poi1`, meaning 1-node point 
# element, update it's geometry and apply 35.0e3 kN load in negative y-direction:

nid = find_nearest_node(mesh, [0.0, 100.0])
load = problem(Elasticity, "point load", 2)
load.properties.formulation = :plane_strain
load.elements = [Element(Poi1, [nid])]
update!(load.elements, "geometry", mesh.nodes)
update!(load.elements, "displacement traction force 2", -35.0e3)


# Next, you define another boundary problem, this time the type of problem is 
# Contact2D, which is a mortar contact formulation for two dimensions.
# Elements are added using `add_slave_elemtns!` and `add_master_elements!`.
# Problems, in general, can have some properties defined, like the formulation
# in `Elasticity` (you also have `:plane_strain`). 
# For contact, you need to swap normal direction for meshes created by 
# ABAQUS, and in JuliaFEM in general you follow the same conventions what are 
# used in ABAQUS.

contact = Problem(Contact2D, "contact", 2, "displacement")
contact.properties.rotate_normals = true
contact_slave_elements = create_elements(mesh, "BLOCK_TO_CYLINDER")
contact_master_elements = create_elements(mesh, "CYLINDER_TO_BLOCK")
add_master_elements(contact, contact_master_elements)
add_slave_elemtns(contact, contact_slave_elements)


# After all problems are defined, you defined some `Analysis`, which can be e.g.
# static analysis, dynamic analysis, modal analysis, linear perturbation
# analysis and so on.
# Here, the analysis type is `Nonlinear`, which is nonlinear quasistatic analysis.
# In the same manner as you do `add_elements!` to add elements to `Problem`, you 
# use `add_problem!` to add problems to analysis.
# Because you are not restricted to some particular input nd output formats, you 
# "connect" a `ResultsWriter` to your analysis, this time you want to visualize
# results using ParaView, thus you write your results to Xdmf format, which 
# uses well defined standards XML and HDF to store model data. 

analysis = Analysis(Nonlinear)
add_problems!(analysis, upper, lower, bc_fixed, bc_sym_23, load, contact)
xdmf = Xdmf("2d_hertz_results"; overwrite=true)
add_results_writer!(analysis, xdmf)

# In last part, you run the analysis.

run!(analysis)
close(xdmf)

# # Results 

# Results are stored in `2d_hertz_results.xmf` and `2d_hertz_results.h5` for 
# visual inspection. You can also postprocess results programmatically 
# because you are inside a real scripting / programming environment all the 
# time. For example, you can integrate the resultant force in normal and 
# tangential direction in contact surface to validate our result.

Rn = 0.0
Rt = 0.0
time = 0.0
for sel in contact_slave_elements
    for ip in get_integration_points(sel)
        global Rn, Rt
        w = ip.weight*sel(ip, time, Val[:detJ])
        n = sel("normal", ip, time)
        t = sel("tangent", ip, time)
        la = sel("lambda", ip, time)
        Rn += w*dot(n, la)
        Rt += w*dot(t, la)
    end
end


println("2d hertz contact resultant forces: Rn = $Rn, Rt = $Rt")

using Test
@test isapprox(Rn, 35.0e3)
@test isapprox(Rt, 0.0)


# Visualization of the results can be done using ParaView
# ![](2d_hertz_contact/results_displacement.png)

# For optimization loops, you want to programmatically find, for example, maximum
# contact pressure. You can, for example, get all the values in nodes:

lambda = contact("lambda", time)
normal = contact("normal", time)
p0 = 0.0
p0_acc = 3585.0
for (nid, n) in normal
    lan = dot(n, lambda[nid])
    println("$nid => $lan")
    global p0
    p0 = max(p0, lan)
end

p0 = round(p0, digits=2)
rtol = round(norm(p0 - p0_acc) / max(p0, p0_acc) * 100, digits=2)
println("Maximum contact pressure p0 = $p0, p0_acc = $p0_acc, rtol = $rtol %")

# To get rough approximation where does the contact open, you can find the element
# from slave contact surface, where contact pressure is zero in the other node 
# and something nonzero in the other node. 

a_rad = 0.0
for element in contact_slave_elements
    la1, la2 = element("lambda", time)
    p1, p2 = norm(la1), norm(la2)
    a, b = isapprox(p1, 0.0), isapprox(p2, 0.0)
    if (a && !b) || (b && !a)
        X1, X2 = element("geometry", time)
        println("Contact opening element geometry: X1 = $X1, X2 = $X2")
        println("Contact opening element lambda: la1 = $la1, la2 = $la2")
        xl1, yl1 = X1
        xl2, yl2 = X2
        global a_rad
        a_rad = 1 / 2 * abs(xl1 * xl2)
        break
    end
end
println("Contact radius: $a_rad")


# This example briefly described some of the core features of JuliaFEM.