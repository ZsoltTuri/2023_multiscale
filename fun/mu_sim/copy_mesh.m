function copy_mesh(params, loop_params)
    
    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;
    efield_sim = loop_params.efield_sim;
    
    % define source and target 
    source_path = fullfile(params.workspace, 'data', 'sim_surface_mesh', mesh_model);
    source_name = strcat(efield_sim, '_GM.msh');
    source_file = fullfile(source_path, source_name);
    target_path = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);
    target_name = strcat(efield_sim, '_GM.msh');
    target_file = fullfile(target_path, target_name);
    if not(isfolder(target_path))
        mkdir(target_path)
    end

    % copy file    
    status = copyfile(source_file, target_file, 'f');
    if status == 1
        disp('Copying source folder successfully!');
    else
        disp('Error copying source folder!');
    end

    % delete fields except normE and save mesh
    mesh = mesh_load_gmsh4(target_file);
    field_idx = get_field_idx(mesh, 'normE', 'elements');
    m = mesh.element_data{field_idx, 1};
    mesh.element_data = [];
    mesh.element_data{1, 1} = m;
    mesh_save_gmsh4(mesh, target_file);
end

