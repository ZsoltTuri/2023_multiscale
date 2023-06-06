function create_folders(params, loop_params)
    mesh_model = loop_params.mesh_model;
    main_folder = fullfile(params.workspace, 'data');
    if not(isfolder(main_folder))
        [~, ~] = mkdir(main_folder);
    end
    subfolders = {'geo', 'matsimnibs', 'mesh_mask', 'mesh_stat', 'nrn_locs', 'roi_sizes', 'sim_stat', 'sim_surface_mesh', 'stl', 'thresholds'};
    for i = 1:length(subfolders)
        subfolder = fullfile(main_folder, subfolders{i}, mesh_model);
        if not(isfolder(subfolder))
            [~, ~] = mkdir(subfolder);
        end
    end

    subfolders = {'mesh', 'sim'};
    for i = 1:length(subfolders)
        subfolder = fullfile(main_folder, subfolders{i});
        if not(isfolder(subfolder))
            [~, ~] = mkdir(subfolder);
        end
    end

end