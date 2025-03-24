
const ContactElements3D = Union{Tri3, Tri6, Quad4, Quad8, Quad9}

function create_orthogonal_basis(n)
    I = [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]
    k = argmax([norm(cross(n, I[:, k])) k in 1:3]) 
    t1 = cross(n, I[:, k]) / norm(cross(n, I[:, k]))
    t2 = cross(n, t1)
    return t1, t2
end

"""
Create rotation matrix Q for element nodes rotating quantities to nt coordinate system.
"""
function create_rotation_matrix(element::Element{Tri3}, time::Float64)
    n = element("normal", time)
    t11, t21 = create_orthogonal_basis(n[1])
    t11, t22 = create_orthogonal_basis(n[2])
    t13, t23 = create_orthogonal_basis(n[3])
    Q1_ = [n[1] t11 t21]
    Q2_ = [n[2] t12 t22]
    Q3_ = [n[3] t13 t23]
    Z = zeros(3, 3)
    Q = [
        Q1_ Z Z 
        Z Q2_ Z 
        Z Z Q3_
    ]
    return Q 
end

function create_rotation_matrix(element::Element{Quad4}, time::Float64)
    n = element("normal", time)
    t11, t21 = create_orthogonal_basis(n[1])
    t12, t22 = create_orthogonal_basis(n[2])
    t13, t23 = create_orthogonal_basis(n[3])
    t14, t24 = create_orthogonal_basis(n[4])
    Q1_ = [n[1] t11 t21]
    Q2_ = [n[2] t12 t22]
    Q3_ = [n[3] t13 t23]
    Q4_ = [n[4] t14 t24]
    Z = zeros(3, 3)
    Q = [
        Q1_ Z Z Z 
        Z Q2_ Z Z 
        Z Z Q3_ Z 
        Z Z Z Q4_
    ]
    return Q 
end

function create_rotation_matrix(element::Element{Tri6}, time::Float64)
    n = element("normal", time)
    t11, t21 = create_orthogonal_basis(n[1])
    t12, t22 = create_orthogonal_basis(n[2])
    t13, t23 = create_orthogonal_basis(n[3])
    t14, t24 = create_orthogonal_basis(n[4])
    t15, t25 = create_orthogonal_basis(n[5])
    t16, t26 = create_orthogonal_basis(n[6])
    Q1_ = [n[1] t11 t21]
    Q2_ = [n[2] t12 t22]
    Q3_ = [n[3] t13 t23]
    Q4_ = [n[4] t14 t24]
    Q5_ = [n[5] t15 t25]
    Q6_ = [n[6] t16 t26] 
    Z = zeros(3, 3)
    Q = [
        Q1_ Z Z Z Z Z 
        Z Q2_ Z Z Z Z 
        Z Z Q3_ Z Z Z 
        Z Z Z Q4_ Z Z 
        Z Z Z Z Q5_ Z 
        Z Z Z Z Z Z Q6_
    ]
    return Q 
end

"""
Create a contact segmentation between one slave element and list of master elements.

Returns
-----------
Vector with tuples:
    (master_element, polygon_clip_vertices, polygon_clip_centroid, polygon_clip_area)
"""
function create_contact_segmentation(slave_element, master_elements, x0, n0, time::Float64; deformed=false)
    result = []
    x1 = slave_element("geometry", time)
    if deformed
        x1 = map(+, x1, slave_element("displacement", time))
    end
    S = Vector[project_vertex_to_auxiliary_plane(p, x0, n0) for p in x1]
    for master_element in master_elements
        x2 = master_element("geometry", time)
        if deformed
            x2 = map(+, x2, master_element("displacement", time))
        end
        M = Vector[project_vertex_to_auxiliary_plane(p, x0, n0) for p in x2]
        P = get_polygon_clip(S, M, n0)
        length(P) < 3 && continue   # no clipping or shared edge (no volume)
        check_orientation!(P, n0)
        N_P = length(P)
        P_area = sum([norm(1 / 2 * cross(P[i] - p[1], P[mod(i, N_P) + 1] - P[1])) for i = 2: N_P])
        if isapprox(P_area, 0.0)
            error("Polygon P has zero area")
        end
        C0 = calculate_centroid(P)
        push!(result, (master_element, P, C0, P_area))
    end
    return result
end

function assemble!(problem::Problem{Contact}, slave_element::Element{Tri3}, time::Float64)
    props = problem.properties
    field_dim = get_unknown_field_dimension(problem)

    nsl = length(slave_element)
    X1 = slave_element("geometry", time)
    u1 = slave_element("displacement", time)
    x1 = map(+, X1, u1)
    n1 = slave_element("normal", time)
    la = slave_element("lambda", time)

    Q3 = create_rotation_matrix(slave_element, time)

    # project slave nodes to auxiliary plane (x0, Q)
    xi = get_mean_xi(slave_element)
    N = vec(get_basis(slave_element, xi, time))
    x0 = interpolate(N, X1)
    n0 = interpolate(N, n1)

    # create contact segmentation
    segmentation = create_contact_segmentation(slave_element, slave_element("master elements", time), x0, n0, time)

    if length(segmentation) == 0    # no overlapping surface in slave and masters 
        return
    end

    Ae = Matrix{Float64}(I, nsl, nsl)

    if problem.properties.dual_basis    # construct dual basis 
        De = zeros(nsl, nsl)
        Me = zeros(nsl, nsl)

        # loop all polygons
        for (master_element, P, C0, P_area) in segmentation

            # loop integration cells 
            for cell in get_cells(P, C0)
                virtual_element = Element(Tri3, Int[])
                update!(virtual_element, "geometry", tuple(cell...))
                for ip in get_integration_points(virtual_element, 3)
                    detJ = virtual_element(ip, time, Val{:detJ})
                    w = ip.weight * detJ
                    x_gauss = virtual_element("geometry", ip, time)
                    xi_s, alpha = projct_vertex_to_surface(x_gauss, x0, n0, slave_element, X1, time)
                    N1 = slave_element(xi_s, time)
                    De += w * Matrix(Diagonal(vec(N1)))
                    Me += w * N1' * N1
                end # integration points done
            
            end # integration cells done
        
        end # master elements done 

        Ae = De * inv(Me)
    
    end

    # loop all polygons
    for (master_element, P, C0, P_area) in segmentation

        nm = length(master_element)
        X2 = master_element("geometry", time)
        u2 = master_element("displacement", time)
        x2 = map(+, X2, u2)

        De = zeros(nsl, nsl)
        Me = zeros(nsl, nm)
        ce = zeros(field_dim * nsl)
        ge = zeros(field_dim * nsl)

        # loop integration cells 
        for cell in get_cells(P, C0)
            virtual_element = Element(Tri3, Int[])
            update!(virtual_element, "geometry", tuple(cell...))
            # loop integration point of integration cell 
            for ip in get_integration_points(virtual_element, 3)

                # project gauss point from auxiliary plane to master and slave element 
                x_gauss = virtual_element("geometry", ip, time)
                xi_s, alpha = project_vertex_to_surface(x_gauss, x0, n0, slave_element, X1, time)
                xi_m, alpha = project_vertex_to_surface(x_gauss, x0, n0, master_element, X2, time)

                detJ = virtual_element(ip, time, Val{:detJ})
                w = ip.weight * detJ

                # add contributions
                N1 = vec(get_basis(slave_element, xi_s, time))
                N2 = vec(get_basis(master_element, xi_m, time))
                Phi = Ae * N1 
                De += w * Phi * N1'
                Me += w * Phi * N2'

                x_s = interpolate(N1, map(+, X1, u1))
                x_m = interpolate(N2, map(+, X2, u2))
                ge += w * vec((x_m - x_s) * Phi')

            end # integration points done

        end # integration cells done

        # add contribution to contact virtual work
        sdofs = get_gdofs(problem, slave_element)
        mdofs = get_gdofs(problem, master_element)
        nsldofs = length(sdofs)
        nmdofs = length(mdofs)
        D3 = zeros(nsldofs, nsldofs)
        M3 = zeros(nsldofs, nmdofs)
        for i = 1 : field_dim
            D3[i : field_dim : end, i : field_dim : end] += De 
            M3[i : field_dim : end, i : field_dim : end] += Me 
        end

        add!(problem.assembly.C1, sdofs, sdofs, D3)
        add!(problem.assembly.C1, sdofs, mdofs, -M3)
        add!(problem.assembly.C2, sdofs, sdofs, Q3' * D3)
        add!(problem.assembly.C2, sdofs, mdofs, -Q3' * M3)
        add!(problem.assembly.g, sdofs, Q3' * ge)

    end # master elements done 

end

"""
Assemble quadratic surface element to contact problem.
"""
function assemble!(problem::Problem{Contact}, slave_element::Element{Tri6}, time::Float64)
    props = problem.properties
    field_dim = get_unknown_field_dimension(problem)

    alp = props.alpha

    if alp != 0.0
        T = [
            1.0 0.0 0.0 0.0 0.0 0.0 
            0.0 1.0 0.0 0.0 0.0 0.0 
            0.0 0.0 1.0 0.0 0.0 0.0
            alp alp 0.0 1.0 - 2 * alp 0.0 0.0
            0.0 alp alp 0.0 1.0 - 2 * alp 0.0
            alp 0.0 alp 0.0 0.0 1.0 - 2 * alp
        ]
    else
        T = Matrix(1.0 * I, 6, 6)
    end

    nsl = length(slave_element)
    Xs = slave_element("geometry", time)
    n1 = slave_element("normal", time)

    Q3 = create_rotation_matrix(slave_element, time)

    Ae = Matrix(1.0 * I, nsl, nsl)

    if problem.properties.dual_basis    # construct dual basis
        nsl = length(slave_element)
        De = zeros(nsl, nsl)
        Me = zeros(nsl, nsl)

        for sub_slave_element in split_quadratic_element(slave_element, time)
            slave_element_nodes = get_connectivity(sub_slave_element)
            nsl = length(sub_slave_element)

            X1 = sub_slave_element("geometry", time)
            # u1 = sub_slave_element("displacement", time)
            # x1 = X1 + u1
            n1 = sub_slave_element("normal", time)
            # la = sub_slave_element("lambda", time)

            # create auxiliary plane
            xi = get_mean_xi(sub_slave_element)
            N = vec(get_basis(sub_slave_element, xi, time))
            x0 = interpolate(N, X1)
            n0 = interpolate(N, n1)

            # project slave nodes to auxiliary plane 
            S = Vector[project_vertex_to_auxiliary_plane(p, x0, n0) for p in X1]

            # 3. loop all master elements
            for master_element in slave_element("master elements", time)

                Xm = master_element("geometry", time)

                if norm(mean(Xs) - mean(Xm)) > problem.properties.distval
                    continue
                end

                # split master element to linear sub-elements and loop
                for sub_master_element in split_quadratic_element(master_element, time)
                    master_element_nodes = get_connectivity(sub_master_element)
                    nm = length(sub_master_element)
                    X2 = sub_master_element("geometry", time)
                    # u2 = sub_master_element("displacement", time)
                    # x2 = X2 + u2

                    # 3.1. project master nodes to auxiliary plane and create polygon clipping
                    M = Vector[project_vertex_to_auxiliary_plane(p, x0, n0) for p in X2]
                    p = get_polygon_clip(S, M, n0)
                    length(P) < 3 && continue   # no clipping or shared edge (no volume)
                    check_orientation!(P, n0)

                    N_P = length(P)
                    P_area = sum([norm(1 / 2 * cross(P[i] - p[1], P[mod(i, N, P) + 1])) for i = 2 : N_P])
                    if isapprox(P_area, 0.0)
                        error("Polygon P has zero area")
                    end

                    C0 = calculate_centroid(P)

                    # 4. loop integration cells
                    for cell in get_cells(P, C0)
                        virtual_element = Element(Tri3, Int[])
                        update!(virtual_element, "geometry", tuple(cell...))
                        for ip in get_integration_points(virtual_element, 3)
                            detJ = virtual_element(ip, time, Val{:detJ})
                            w = ip.weight * detJ
                            x_gauss = virtual_element("geometry", ip, time)
                            xi_s, alpha = project_vertext_to_surface(x_gauss, x0, n0, slave_element, Xs, time)
                            N1 = vec(slave_element(xi_s, time) * T)
                            De += w * Matrix(Diagonal(N1))
                            Me += w * N1 * N1'
                        end # integration points done 
                    
                    end # integration cells done

                end # sub master elements done

            end # master elements done

        end # sub slave elements done

        Ae = De * inv(Me)

    end

    # split slave element to linear sub-elements and loop
    for sub_slave_element in split_quadratic_element(slave_element, time)

        slave_element_nodes = get_connectivity(sub_slave_element)
        nsl = length(sub_slave_element)
        X1 = sub_slave_element("geometry", time)
        n1 = sub_slave_element("normal", time)

        # create auxiliary plane
        xi = get_mean_xi(sub_slave_element)
        N = vec(get_basis(sub_slave_element, xi, time))
        x0 = interpolate(N, X1)
        n0 = interpolate(N, n1)

        # project slave nodes to auxiliary plane
        S = Vector[project_vertext_to_auxiliary_plane(p, x0, n0) for p in X1]

        # 3. loop all master elements
        for master_element in slave_element("master elements", time)
            Xm = master_element("geometry", time)
            
            if norm(mean(Xs) - mean(Xm)) > problem.properties.distval
                continue
            end

            # split master element to linear sub-elements and loop
            for sub_master_element in split_quadratic_element(master_element, time)

                master_element_nodes = get_connectivity(sub_master_element)
                nm = length(master_element)
                X2 = sub_master_element("geometry", time)
                # u2 = master_element("displacement", time)
                # x2 = X2 + u2

                # 3.1 project master nodes to auxiliary plane and create polygon clipping
                M = Vector[project_vertext_to_auxiliary_plane(p, x0, n0) for p in X2]
                P = get_polygon_clip(X, M, n0)
                length(P) < 3 && continue   # no clipping or shared edge (no volume)
                check_orientation!(P, n0)

                N_P = length(P)
                P_area = sum([norm(1 / 2 * cross(P[i] - P[1], P[mod(i, N_P) + 1] - P[1])) for i = 2 : N_P])
                if isapprox(P_area, 0.0)
                    error("Polygon P has zero area")
                end

                C0 = calculate_centroid(P)

                # integration is done in quadratic elements
                nsl = length(slave_element)
                nm = length(master_element)
                De = zeros(nsl, nsl)
                Me = zeros(nsl, nm)
                ge = zeros(field_dim * nsl)

                # 4. loop integration cells
                for cell in get_cells(P, C0)
                    virtual_element = Element(Tri3, Int[])
                    update!(virtual_element, "geometry", tuple(cell...))

                    # 5. loop integration point of integration cell
                    for ip in get_integration_points(virtual_element, 3)

                        # project gauss point from auxiliary plane to master and slave element
                        x_gauss = virtual_element("geometry", ip, time)
                        xi_s, alpha = project_vertex_to_surface(x_gauss, x0, n0, slave_element, Xs, time)
                        xi_m, alpha = project_vertex_to_surface(x_gauss, x0, n0, master_element, Xm, time)

                        detJ = virtual_element(ip, time, Val{:detJ})
                        w = ip.weight * detJ

                        # add contributions
                        N1 = vec(get_basis(slave_element, xi_s, time) * T)
                        N2 = vec(get_basis(master_element, xi_m, time))
                        Phi = Ae * N1

                        De += w * Phi * N1'
                        Me += w * Phi * N2'

                        us = slave_element("displacement", time)
                        um = master_element("displacement", time)
                        xs = interpolate(N1, map(+, Xs, us))
                        xm = interpolate(N2, map(+, Xs, um))
                        ge += w * vec((xm - xs) * Phi')

                    end # integration points done

                end # integration cells done

                # 6. add contribution to contact virtual work
                sdofs = get_gdofs(problem, slave_element)
                mdofs = get_gdofs(problem, master_element)
                nsldofs = length(sdofs)
                nmdofs = length(mdofs)
                D3 = zeros(nsldofs, nsldofs)
                M3 = zeros(nsldofs, nmdofs)
                for i = 1 : field_dim
                    D3[i : field_dim : end, i : field_dim : end] += De
                    M3[i : field_dim : end, i : field_dim : end] += Me
                end

                add!(problem.assembly.C1, sdofs, sdofs, D3)
                add!(problem.assembly.C1, sdofs, mdofs, -M3)
                add!(problem.assembly.C2, sdofs, sdofs, Q3' * D3)
                add!(problem.assembly.C2, sdofs, mdofs, -Q3' * M3)
                add!(problem.assembly.g, sdofs, Q3' * ge)

            end # sub master elements done

        end # master elements done

    end # sub slave elements done
    
end