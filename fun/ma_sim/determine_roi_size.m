function roi_size = determine_roi_size(params, loop_params)
% This function determines ROI size based on E-field modeling results.

    % broadcast loop_params variables
    mesh_model = loop_params.mesh_model;
    radian = loop_params.radian;

    % load mesh
    mesh_path = fullfile(params.workspace, 'data', 'sim', strcat(mesh_model, '_angle_', num2str(rad2deg(radian))));
    mesh_file = strcat(mesh_model, '_TMS_1-0001_MagVenture_MC_B70_scalar.msh');
    mesh = mesh_load_gmsh4(fullfile(mesh_path, mesh_file));
    m = mesh_extract_regions(mesh, 'region_idx', [2 1002]);
    
    % load matsimnibs
    matsimnibs_path = fullfile(params.workspace, 'data', 'matsimnibs', mesh_model);
    matsimnibs_file = strcat(mesh_model, '_angle_', num2str(rad2deg(radian)), '.mat');
    matsimnibs = load(fullfile(matsimnibs_path, matsimnibs_file));
    matsimnibs = cell2mat(struct2cell(matsimnibs));   

     % load readme info file
    info_path = fullfile(params.workspace, 'data', 'stl_init', mesh_model); 
    info_name = strcat(mesh_model, '_info.mat');
    info = load(fullfile(info_path, info_name));
    info = cell2mat(struct2cell(info));

    % get closes point to the coil center in GM
    tri = mesh_get_triangle_centers(m);
    idx = mesh_get_closest_triangle_from_point2(m, matsimnibs(1:3, 4)', 1002);
    point = tri(idx, :);  

    % get E-fields
    field_idx = get_field_idx(m, 'normE', 'elements');
    field = m.element_data{field_idx}.tetdata;
    robust_max = prctile(field, params.robust_max);
    threshold = robust_max * (params.threshold / 100);
    
    % get mask based on threshold intensity
    mask_int = field > threshold; 
    
    % get mask for the gyrus (for tetrahedra)
    tet = mesh_get_tetrahedron_centers(m);
    center = [0, 0, 0];
    distance = get_distance(tet, center);
    height = (info.gm_radius +  (info.gm_radius * params.wall_offset)) * params.scaling_factor;
    mask_gyr = distance >  height;
        
    % get distances    
    matrix = tet(mask_int & mask_gyr, :);
    distances = get_distance(matrix, point);
    switch (params.stat)
        case {'mean'}
            roi_size = mean(distances);
        case {'median'}
            roi_size = median(distances);
    end
    save(fullfile(params.workspace, 'data', 'roi_sizes', mesh_model, strcat(mesh_model, '_angle_', num2str(rad2deg(radian)), '_roi_size.mat')), 'roi_size');
end