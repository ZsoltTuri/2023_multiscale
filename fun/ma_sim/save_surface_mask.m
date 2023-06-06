function save_surface_mask(params, loop_params)

    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;
    radian = loop_params.radian;

    % define paramterers
    compartments = {'WM'; 'GM'};
    region_idxs = [1001; 1002]; 
    element = 'surface';
    center = [0, 0, 0]; 

    % load roi size
    cyl_height = load(fullfile(params.workspace, 'data', 'roi_sizes', mesh_model, strcat(mesh_model, '_angle_', num2str(rad2deg(radian)), '_roi_size.mat')));
    cyl_height = cell2mat(struct2cell(cyl_height));
    cyl_height = ceil(2 * cyl_height) / params.scaling_factor;

    % load mesh
    mesh_path = fullfile(params.workspace, 'data', 'mesh');
    mesh_name = strcat(mesh_model, '.msh');
    mesh = mesh_load_gmsh4(fullfile(mesh_path, mesh_name));

    % load info file
    info_path = fullfile(params.workspace, 'data', 'stl_init', mesh_model); 
    info_name = strcat(mesh_model, '_info.mat');
    info = load(fullfile(info_path, info_name));
    info = cell2mat(struct2cell(info));
  
    % load cylinder
    cylinder = struct();
	cylinder.zcenter = 0.845; % we can hard code this value, because we fixed the gyral crown position for all mesh files at the same value
    cylinder.radius = 0.35; % we can hard code this value, because we fixed the global width of the gyri
    cylinder.center = [0, 0, cylinder.zcenter] * params.scaling_factor;
    cylinder.radius = cylinder.radius * params.scaling_factor;
    u_vec  = [1, 0, 0];

    % prepare outputs
    mask_path = fullfile(params.workspace, 'data', 'mesh_mask', mesh_model);
    locs_path = fullfile(params.workspace, 'data', 'nrn_locs', mesh_model);
    
    % get masks
    for ii = 1:length(region_idxs)
        region_idx = region_idxs(ii, 1);
        compartment = compartments{ii, 1};      
        m = mesh_extract_regions(mesh, 'region_idx', region_idx);           
        matrix = mesh_get_triangle_centers(m); 
        distance = get_distance(matrix, center);
        if strcmp(compartment, 'WM')
            threshold = (info.wm_radius +  (info.wm_radius * params.wall_offset)) * params.scaling_factor;    
        else
            threshold = (info.gm_radius +  (info.gm_radius * params.wall_offset)) * params.scaling_factor;
        end
        idx_gyr = distance >  threshold;
        height = (cyl_height / 2) * params.scaling_factor;
        cylinder.base = cylinder.center - (u_vec * height);
        cylinder.top = cylinder.center + (u_vec * height);
        idx_cyl = get_cylindrical_roi(matrix, cylinder);
        idx_in = idx_gyr & idx_cyl; % inside ROI
        idx_out = not(idx_in);      % outside ROI           
        % output
        roi_mask         = struct();
        roi_mask.inside  = idx_in;
        roi_mask.outside = idx_out;
        mask_name = strcat(mesh_model, '_', element, '_', compartment, '.mat');
        save(fullfile(mask_path, mask_name), 'roi_mask');
        % save neuronal locations    
        if strcmp(compartment, 'GM')
            nrnlocs = matrix(roi_mask.inside, :);
            locs_name = strcat(mesh_model, '_locations.mat');
            save(fullfile(locs_path, locs_name), 'nrnlocs');
        end
    end    
end