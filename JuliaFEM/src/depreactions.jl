function assemble!(problem::Problem, time, ::Type{Val{:mass_matrix}})
    assemble_mass_matrix!(problem, time)
end

function assemble!(problem::Problem, element::Element, time=0.0)
    assemble!(problem.assembly, problem, element, time)
end

module Abaqus 
using JuliaFEM: create_surface_elements
end