function surface_based_efield_analysis_roi(params, loop_params)

    % broadcast loop_params variables
    mesh_model = loop_params.mesh_model;
    radian = loop_params.radian;

    % load info file
    info_path = fullfile(params.workspace, 'data', 'stl_init', mesh_model); 
    info_name = strcat(mesh_model, '_info.mat');
    info = load(fullfile(info_path, info_name));
    info = cell2mat(struct2cell(info));
    
    % define parameters
    compartments = {'GM'}; % {'WM'; 'GM'};
    region_idxs  = 1002; % [1001; 1002]; % 1001: WM; 1002: GM
    roi_types    = {'roi_full'}; % {'roi_full'; 'roi_crown'; 'roi_wall'};
    field_types  = {'normE', 'E_tan_norm', 'E_perp_norm'}; 
    element      = 'surface';
    datatype     = 'tridata';  
    
    % set output
    out = struct();
    out.path = fullfile(params.workspace, 'data', 'sim_stat', mesh_model, 'surface');
    if not(isfolder(out.path))
        mkdir(out.path)
    end 
    out.weighted_mean = [];
    out.mean = [];
    out.roi_type = [];
    out.compartment = [];
    out.field_type = [];
    
    % load mesh
    mesh_path = fullfile(params.workspace, 'data', 'sim', strcat(mesh_model, '_angle_', num2str(rad2deg(radian))));
    mesh_file = strcat(mesh_model, '_TMS_1-0001_MagVenture_MC_B70_scalar.msh');
    mesh = mesh_load_gmsh4(fullfile(mesh_path, mesh_file));
    mesh = mesh_append_normal_and_tangential_efield_simnibs21(mesh);
    
    % ROI masks path
    mask_path = fullfile(params.workspace, 'data', 'mesh_mask', mesh_model);
  
    for ii = 1:length(region_idxs)
        region_idx = region_idxs(ii, 1);
        compartment = compartments{ii, 1};      
        m = mesh_extract_regions(mesh, 'region_idx', region_idx); 
        [tri_areas, ~] = mesh_get_triangle_sizes(m);
        % load roi mask
        mask_name = strcat(mesh_model, '_', element, '_', compartment, '.mat');
        roi_mask = load(fullfile(mask_path, mask_name));
        roi_mask = cell2mat(struct2cell(roi_mask));
        for jj = 1:length(roi_types)
            roi_type = roi_types{jj, 1};
            switch roi_type
                case {'roi_full'}
                    roi_idx = roi_mask.inside;
                case {'roi_crown'}
                    roi_idx = roi_mask.crown;
                case {'roi_wall'}
                    roi_idx = roi_mask.wall;     
            end
            m.element_data{end + 1, 1} = m.element_data{5, 1};
            m.element_data{end, 1}.name = roi_type;
            m.element_data{end, 1}.tridata(:) = 0;
            m.element_data{end, 1}.tridata(roi_idx) = 1;
            for kk = 1:length(field_types)
                field_type = field_types{kk};
                switch field_type
                    case {'normE'}
                        field_str = 'E_tot';
                    case {'E_tan_norm'}
                        field_str = 'E_tan';
                    case {'E_perp_norm'}
                        field_str = 'E_per';
                end
                field_idx = get_field_idx(m, field_type, 'elements');
                field = m.element_data{field_idx}.(datatype);
                out.weighted_mean(end+1, 1) = sum(field(roi_idx, 1) .* tri_areas(roi_idx, 1)) / sum(tri_areas(roi_idx, 1));
                out.mean(end+1, 1) = mean(field(roi_idx, 1));
                out.roi_type{end+1, 1} = roi_type;
                out.field_type{end+1, 1} = field_str;
                out.compartment{end+1, 1} = compartment;              
            end
        end
        gm_path = fullfile(params.workspace, 'data', 'sim_surface_mesh', mesh_model);
        if not(isfolder(gm_path))
            mkdir(gm_path)
        end
        gm_file = strcat(mesh_model, '_angle_', num2str(rad2deg(radian)), '_', compartment, '.msh');
        mesh_save_gmsh4(m, fullfile(gm_path, gm_file));
    end

    % save output
    out.n = length(out.weighted_mean);
    out.mesh = repmat({mesh_model}, out.n, 1);
    out.coil_angle = repmat({rad2deg(radian)}, out.n, 1);
    out.element = repmat({element}, out.n, 1);      
    T = table(out.mesh, out.coil_angle, out.element, out.field_type, out.compartment, out.roi_type, out.weighted_mean, out.mean);
    T.Properties.VariableNames = {'mesh', 'coil_angle', 'element', 'field_type', 'compartment', 'roi_type', 'weighted_mean', 'mean'}; 
    out.file = strcat(mesh_model, '_shape_', info.shape, '_height_', num2str(info.height * params.scaling_factor), '_thickness_', num2str(info.thickness * params.scaling_factor), '_angle_', num2str(rad2deg(radian)), '_', compartment, '_', element, '.xlsx');
    writetable(T, fullfile(out.path, out.file)); 
end