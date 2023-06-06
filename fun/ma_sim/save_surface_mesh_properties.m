function save_surface_mesh_properties(params, loop_params)

    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;

    % define parameters
    compartments = {'WM'; 'GM'};
    region_idxs  = [1001; 1002]; % 1001: WM; 1002: GM
    roi_types    = {'in'; 'out'};
    idx_row      = [1, 3; 2, 4]; % I use this in the nested for loop to get the right row in 'mesh_property'
    element      = 'surface';

    % load mesh
    mesh_path = fullfile(params.workspace, 'data', 'mesh');
    mesh_name = strcat(mesh_model, '.msh');
    mesh = mesh_load_gmsh4(fullfile(mesh_path, mesh_name));

    % prepare output
    out_path = fullfile(params.workspace, 'data', 'mesh_stat', mesh_model);
    out_name = strcat(mesh_model, '_', element, '_properties.mat');
    
    % get mesh properties
    mask_path = fullfile(params.workspace, 'data', 'mesh_mask', mesh_model);
    for ii = 1:length(region_idxs)
        region_idx = region_idxs(ii, 1);
        compartment = compartments{ii, 1};      
        m = mesh_extract_regions(mesh, 'region_idx', region_idx);           
        mask_name = strcat(mesh_model, '_', element, '_', compartment, '.mat'); 
        roi_mask = load(fullfile(mask_path, mask_name));
        roi_mask = cell2mat(struct2cell(roi_mask));
        [tri_areas, tri_edge_length] = mesh_get_triangle_sizes(m);
        for jj = 1:length(roi_types)
            roi_type = roi_types{jj, 1};
            mesh_property(idx_row(ii, jj)).compartment = compartment;
            mesh_property(idx_row(ii, jj)).region_idx = region_idx;
            mesh_property(idx_row(ii, jj)).element = element;
            mesh_property(idx_row(ii, jj)).roi_type = roi_type;
            % inside ROI
            if strcmp(roi_type, 'in')
                mesh_property(idx_row(ii, jj)).tri_areas       = mean(tri_areas(roi_mask.inside, 1));
                mesh_property(idx_row(ii, jj)).tri_edge_length = mean(tri_edge_length(roi_mask.inside, 1));
            % outside ROI
            else
                mesh_property(idx_row(ii, jj)).tri_areas       = mean(tri_areas(roi_mask.outside, 1));
                mesh_property(idx_row(ii, jj)).tri_edge_length = mean(tri_edge_length(roi_mask.outside, 1));
            end
        end
    end
    save(fullfile(out_path, out_name), 'mesh_property');
end