function extract_readme_info(params, loop_params)
    
    % broadcast loop_params variables     
    mesh_model = loop_params.mesh_model;  
    
    % import readme file
    stl_path = fullfile(params.workspace, 'data', 'stl_init', mesh_model); 
    stl_name = 'README.txt'; 
    fid = fopen(fullfile(stl_path, stl_name));
    tline = fgetl(fid);
    lines = cell(0, 0);
    i = 1;
    while ischar(tline)  
        lines{i, 1} = tline;
        if ischar(lines{i, 1})
            lines{i, 2} = contains(lines{i, 1}, 'Skin');
            lines{i, 3} = contains(lines{i, 1}, 'Bone');
            lines{i, 4} = contains(lines{i, 1}, 'Fluid');
            lines{i, 5} = contains(lines{i, 1}, 'Gray');
            lines{i, 6} = contains(lines{i, 1}, 'White');
            lines{i, 7} = contains(lines{i, 1}, 'Height');
            lines{i, 8} = contains(lines{i, 1}, 'Thickness');
            lines{i, 9} = contains(lines{i, 1}, 'Shape');
        end
        i = i + 1;
        tline = fgetl(fid);
    end
      
    % skin
    info = struct();
    skin = {lines{1:end-1, 2}};
    skin = cell2mat(skin);
    skin_idx = find(skin, true);
    info.skin_radius = str2double(cell2mat(regexp(lines{skin_idx, 1}, '[+-]?\d+\.?\d*', 'match')));
    
    % bone
    bone = {lines{1:end-1, 3}};
    bone = cell2mat(bone);
    bone_idx = find(bone, true);
    info.bone_radius = str2double(cell2mat(regexp(lines{bone_idx, 1}, '[+-]?\d+\.?\d*', 'match')));
    
    % fluid
    fluid = {lines{1:end-1, 4}};
    fluid = cell2mat(fluid);
    fluid_idx = find(fluid, true);
    info.fluid_radius = str2double(cell2mat(regexp(lines{fluid_idx, 1}, '[+-]?\d+\.?\d*', 'match')));

    % gray matter
    gm = {lines{1:end-1, 5}};
    gm = cell2mat(gm);
    gm_idx = find(gm, true);
    info.gm_radius = str2double(cell2mat(regexp(lines{gm_idx, 1}, '[+-]?\d+\.?\d*', 'match')));

    % white matter
    wm = {lines{1:end-1, 6}};
    wm = cell2mat(wm);
    wm_idx = find(wm, true);
    info.wm_radius = str2double(cell2mat(regexp(lines{wm_idx, 1}, '[+-]?\d+\.?\d*', 'match')));

    % height
    height = {lines{1:end-1, 7}};
    height = cell2mat(height);
    height_idx = find(height, true);
    info.height = str2double(cell2mat(regexp(lines{height_idx, 1}, '[+-]?\d+\.?\d*', 'match')));

    % thickness
    thickness = {lines{1:end-1, 8}};
    thickness = cell2mat(thickness);
    thickness_idx = find(thickness, true);
    info.thickness = str2double(cell2mat(regexp(lines{thickness_idx, 1}, '[+-]?\d+\.?\d*', 'match')));

    % shape
    shape = {lines{1:end-1, 9}};
    shape = cell2mat(shape);
    shape_idx = find(shape, true);
    info.shape = cell2mat(regexp(lines{shape_idx, 1}, 'Sinusoid|Mushroom', 'match'));

    % save
    info_path = fullfile(params.workspace, 'data', 'stl_init', mesh_model);
    info_name = strcat(mesh_model, '_info.mat');
    save(fullfile(info_path, info_name), 'info')
end