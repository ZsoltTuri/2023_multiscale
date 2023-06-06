function extract_save_mesh_dimension(params, loop_params)
    
    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;

	mesh_path = fullfile(params.workspace, 'data', 'mesh');
	mesh_file = strcat(mesh_model, '.msh');
	mesh = mesh_load_gmsh4(fullfile(mesh_path, mesh_file));
	region_idxs = [1001; 1002; 1003; 1004; 1005];
	labels = {'WM'; 'GM'; 'CSF'; 'BONE'; 'SKIN'};
	dimension = struct();
	for ii = 1:length(region_idxs)
		region_idx = region_idxs(ii, 1);
		label = labels{ii, 1};
		m = mesh_extract_regions(mesh, 'region_idx', region_idx);
		tri = mesh_get_triangle_centers(m);
		center = [0, 0, 0];
		distance = get_distance(tri, center);
		dimension(ii).label = label;
		dimension(ii).code = region_idx;
        if region_idx < 1003
            d = sort(distance);
            dimension(ii).diameter = round(mean(d(1:10000, 1)), 2);
        else
            dimension(ii).diameter = round(mode(distance), 2);
        end
	end     
	out_path = fullfile(params.workspace, 'data', 'mesh_stat', mesh_model); 
	out_file = strcat(mesh_model, '_dimension.mat');
	save(fullfile(out_path, out_file), 'dimension');
end