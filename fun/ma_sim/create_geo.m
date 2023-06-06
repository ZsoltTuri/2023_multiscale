function create_geo(params, loop_params)

    % broadcast loop_params variables 
    mesh_model = loop_params.mesh_model;
    
    geo_file = strcat(mesh_model, '.geo');
    geo_path = fullfile(params.workspace, 'data', 'geo', mesh_model);
    stl_path = fullfile(params.workspace, 'data', 'stl', mesh_model); 

    fname = fullfile(geo_path, geo_file);
    fid = fopen(fname, 'wt');
    fprintf(fid, strcat('Mesh.Algorithm3D = 1; \n'));
    fprintf(fid, strcat('Mesh.Optimize = 1; \n'));
    fprintf(fid, strcat('Mesh.OptimizeNetgen = 1; \n'));
    
    fprintf(fid, strcat('Merge "', stl_path, '/wm.stl"; \n'));
    fprintf(fid, strcat('Merge "', stl_path, '/gm.stl"; \n'));
    fprintf(fid, strcat('Merge "', stl_path, '/fluid.stl"; \n'));
    fprintf(fid, strcat('Merge "', stl_path, '/bone.stl"; \n'));
    fprintf(fid, strcat('Merge "', stl_path, '/skin.stl"; \n'));
    
    fprintf(fid, strcat('Surface Loop(1) = {1}; \n'));
    fprintf(fid, strcat('Surface Loop(2) = {2}; \n'));
    fprintf(fid, strcat('Surface Loop(3) = {3}; \n'));
    fprintf(fid, strcat('Surface Loop(4) = {4}; \n'));
    fprintf(fid, strcat('Surface Loop(5) = {5}; \n'));
    
    fprintf(fid, strcat('Volume(1) = {1}; \n'));
    fprintf(fid, strcat('Volume(2) = {2, 1}; \n'));
    fprintf(fid, strcat('Volume(3) = {3, 2}; \n'));
    fprintf(fid, strcat('Volume(4) = {4, 3}; \n'));
    fprintf(fid, strcat('Volume(5) = {5, 4}; \n'));
    
    fprintf(fid, strcat('Physical Surface(1) = {1}; \n'));
    fprintf(fid, strcat('Physical Surface(2) = {2}; \n'));
    fprintf(fid, strcat('Physical Surface(3) = {3}; \n'));
    fprintf(fid, strcat('Physical Surface(4) = {4}; \n'));
    fprintf(fid, strcat('Physical Surface(5) = {5}; \n'));
    
    fprintf(fid, strcat('Physical Volume(1) = {1}; \n'));
    fprintf(fid, strcat('Physical Volume(2) = {2}; \n'));
    fprintf(fid, strcat('Physical Volume(3) = {3}; \n'));
    fprintf(fid, strcat('Physical Volume(4) = {4}; \n'));
    fprintf(fid, strcat('Physical Volume(5) = {5}; \n'));
    fclose(fid);
end