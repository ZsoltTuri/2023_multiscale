function create_spheres(params, loop_params)

    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;

    % load info
    info_path = fullfile(params.workspace, 'data', 'stl_init', mesh_model); 
    info_name = strcat(mesh_model, '_info.mat');
    info = load(fullfile(info_path, info_name));
    info = cell2mat(struct2cell(info));
    radii = zeros(3, 1) * inf;       
    radii(1, 1) = info.skin_radius;
    radii(2, 1) = info.bone_radius;
    radii(3, 1) = info.fluid_radius;
    
    % create spheres
    compartments = {'skin'; 'bone'; 'fluid'};
	geo_path = fullfile(params.workspace, 'data', 'geo', mesh_model);

    space = 32;
    for ii = 1:length(compartments)
        compartment = compartments{ii, 1};
        radius = radii(ii, 1);
        geo_file = strcat(compartment, '.geo');
        % save file
        fname = fullfile(geo_path, geo_file);
        fid = fopen(fname, 'wt');
        fprintf(fid, 'SetFactory("OpenCASCADE"); \n');
        fprintf(fid, strcat('r =', space, num2str(radius), '; \n'));
        fprintf(fid, 'Sphere(1) = {0, 0, 0, r, -Pi/2, Pi/2, 2*Pi}; \n');
        fprintf(fid, 'Surface Loop(2) = {1}; \n');
        fprintf(fid, 'Volume(1) = {1}; \n');
        fprintf(fid, 'Characteristic Length{ PointsOf{ Volume{1}; } } = 0.01; \n'); % this value defines mesh resolution     
        fprintf(fid, ' \n');
        fclose(fid);
    end
 
end