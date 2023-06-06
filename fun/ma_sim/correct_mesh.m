function correct_mesh(params, loop_params)

    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;

    mesh_file = strcat(mesh_model, '.msh');
    mesh_path = fullfile(params.workspace, 'data', 'mesh');
    
    m = mesh_load_gmsh4(fullfile(mesh_path, mesh_file));
    m.triangle_regions(m.triangle_regions == 1) = 1001;    
    m.triangle_regions(m.triangle_regions == 2) = 1002; 
    m.triangle_regions(m.triangle_regions == 3) = 1003;
    m.triangle_regions(m.triangle_regions == 4) = 1004;
    m.triangle_regions(m.triangle_regions == 5) = 1005;
    m.nodes = m.nodes * params.scaling_factor;
    mesh_save_gmsh4(m, fullfile(mesh_path, mesh_file));
end