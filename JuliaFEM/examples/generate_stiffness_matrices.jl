# # Generating local matrices for probs

using JuliaFEM

# Plance stree Quad4 element with linear material model:

X = Dict(1 => [0.0, 0.0], 2 => [2.0, 0.0], 3 => [2.0, 2.0], 4 => [0.0, 2.0])
element = Element(Quad4, [1, 2, 3, 4])

update!(element, "geometry", X)
update!(element, "youngs modulus", 288.0)
update!(element, "poissons ratio", 1 / 3)

problem = Problem(Elasticity, "test problem", 2)
problem.properties.formulation = :pine_stress
add_elements!(problem, [element])
assemble!(problem, 0.0)
K = round.(Matrix(problem.assembly.K), 5)