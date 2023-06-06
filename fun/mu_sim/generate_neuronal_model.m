function generate_neuronal_model(params, sim_params)
    % broadcast sim_params variables 
    neuronal_model  = sim_params.neuronal_model;
    
    % set folders
    folder = fullfile(params.workspace, 'nemo', 'Models');
    if not(isfolder(folder))
        mkdir(folder)
    end
    clearvars folder
    if strcmp(neuronal_model, 'Aberra_L23_model')
        script = 'Aberra_L23_model_script(params).m'; 
        folder = 'Aberra_L23_human'; 
    elseif strcmp(neuronal_model, 'Aberra_L5_model')
        script = 'Aberra_L5_model_script(params).m';
        folder = 'Aberra_L5_human';
    elseif strcmp(neuronal_model, 'Aberra_L23b_model')
        script = 'Aberra_L23b_model_script(params).m';
        folder = 'Aberra_L23b_human';
    elseif strcmp(neuronal_model, 'Aberra_L5b_model')
        script = 'Aberra_L5b_model_script(params).m';
        folder = 'Aberra_L5b_human';
    else
        disp('Unknown neuronal model.');
    end
    
    % generate model
    run(fullfile(params.workspace, 'nemo', 'Model_Generation', script))
    
    % export neuron segment location
    cd(fullfile(params.workspace, 'nemo', 'Models', folder, 'Code', 'NEURON'));
    system('nrniv -nogui -NSTACK 100000 -NFRAME 20000 -Py_NoSiteFlag save_locations.hoc');
end