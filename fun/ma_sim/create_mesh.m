function create_mesh(params, loop_params)
    
    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;
    
    geo_path = fullfile(params.workspace, 'data', 'geo', mesh_model);
    mesh_path = fullfile(params.workspace, 'data', 'mesh');
    stl_path_init = fullfile(params.workspace, 'data', 'stl_init', mesh_model);
    stl_path = fullfile(params.workspace, 'data', 'stl', mesh_model);
	geo_file = strcat(mesh_model, '.geo');  
    mesh_file = strcat(mesh_model, '.msh');
	space = 32;
    
    % create meshfix and gmsh commands
    command = struct();
    command.wm = strcat('meshfix', space, fullfile(stl_path_init, 'wm.stl'), space, '-a 2 -u 5 --smooth 1 --remove-handles --stl -o', space, fullfile(stl_path, 'wm.stl')); 
    command.gm = strcat('meshfix', space, fullfile(stl_path_init, 'gm.stl'), space, '-a 2 -u 5 --smooth 1 --remove-handles --stl -o', space, fullfile(stl_path, 'gm.stl')); % --vertices 90000
    command.fluid = strcat('gmsh', space, fullfile(geo_path, 'fluid.geo'), space, '-2 -o', space, fullfile(stl_path, 'fluid.stl'));   
    command.bone = strcat('gmsh', space, fullfile(geo_path, 'bone.geo'), space, '-2 -o', space, fullfile(stl_path, 'bone.stl')); 
    command.skin = strcat('gmsh', space, fullfile(geo_path, 'skin.geo'), space, '-2 -o', space, fullfile(stl_path, 'skin.stl')); 
    command.mesh = strcat('gmsh -3', space, '-setnumber Mesh.ToleranceInitialDelaunay 1e-12 -format msh2 -o', space, fullfile(mesh_path, mesh_file), space, fullfile(geo_path, geo_file));

    % run meshfix and gmsh commands
    system(command.wm)
    system(command.gm)
    system(command.fluid)
    system(command.bone)
    system(command.skin)
    system(command.mesh)

end