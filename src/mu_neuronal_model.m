function mu_neuronal_model(index)
    %% Info
    % Run multi-scale modeling on HPC.
    % Aim: Study effect of different neuronal models (and morphology).
    % Notes: 
    % Aberra_L23_model: model and morphology are congruent
    %   - neuronal model:      layer II/III pyramidal neuron
    %   - neuronal morphology: layer II/III pyramidal neuron
    % Aberra_L23b_model: model and morphology are incongruent
    %   - neuronal model:      layer II/III pyramidal neuron
    %   - neuronal morphology: layer V pyramidal neuron (!)
    % Aberra_L5_model: model and morphology are congruent
    %   - neuronal model:      layer V pyramidal neuron
    %   - neuronal morphology: layer V pyramidal neuron
    % Aberra_L5b_model: model and morphology are incongruent
    %   - neuronal model:      layer V pyramidal neuron
    %   - neuronal morphology: layer II/III pyramidal neuron (!)

    %% Define preliminaries and parameters
    params = struct();
    params.repository = '2022_cortical_folding_hpc';
    params.workspace = fullfile('', params.repository); % please set
    run(fullfile(params.workspace, 'src', 'init(params.workspace).m'))
    params.idx = transpose(1:70);
    params.mesh_models = create_head_model_names(params);
    % Here, I select one mesh file and one E-field simulation 
    params.mesh_model = params.mesh_models{31, 1};
    params.angles = 0;   % coil angles 
    params.efield_sim = strcat(params.mesh_model, '_angle_', num2str(params.angles(1, 1))); % macroscopic E-field simulation
    params.neuronal_models = {'Aberra_L23_model'; 'Aberra_L5_model'; 'Aberra_L23b_model'; 'Aberra_L5b_model'};
    params.neuronal_depths = [0.45; 1.25; 1.25; 0.45];
    params.syn_input_weight = 0;
    params.syn_weight_sync = 0; % 0 = no synaptic input 
    params.mso_max = 101; % maximum TMS intensity 
    params.folder_flag = 'spTMS';
    params.sim_id = strcat(params.folder_flag, '_neuronal_model');
    params.folder = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);

    %% Prepare multi-scale modeling
    if not(isfolder(params.folder))
        [~, ~] = mkdir(params.folder);
    end
    sim_params = struct();
    sim_params.mesh_model = params.mesh_model;
    sim_params.efield_sim = params.efield_sim;  
    sim_params.syn_input_weight = params.syn_input_weight;
    sim_params.syn_weight_sync = params.syn_weight_sync;
    sim_params.neuronal_model = params.neuronal_models{index, 1}; 
    sim_params.neuronal_dept = params.neuronal_depths(index, 1);
    sim_params.nrn_locations_all = load(fullfile(params.workspace, 'data', 'nrn_locs', params.mesh_model, strcat(sim_params.mesh_model, '_locations.mat')));
    sim_params.nrn_locations_all = cell2mat(struct2cell(sim_params.nrn_locations_all));
    sim_params.nrn_percent = 0.2;
    sim_params.nrn_number = ceil(sim_params.nrn_percent * length(sim_params.nrn_locations_all));
    if index == 1
        loc_index = randsample(1:length(sim_params.nrn_locations_all), sim_params.nrn_number);
        sim_params.index = loc_idx;
        copy_mesh(params, sim_params);
        save(fullfile(params.folder, 'index.mat'), 'loc_index');
    else
        sim_params.index = load(fullfile(params.folder, 'index.mat'));
        sim_params.index = cell2mat(struct2cell(sim_params.index));
    end    
    sim_params.nrn_locations = sim_params.nrn_locations_all(sim_params.index, :);        
    sim_params.label = sim_params.neuronal_model; 
    save(fullfile(params.folder, strcat(sim_params.neuronal_model, '_sim_params.mat')), 'sim_params');

    %% Run multi-scale modeling
    prepare_folder(params, sim_params);
    [tholds, hist] = estimate_spTMS_threshold(params, sim_params); % this fun uses parfor loop
    thresholds = zeros(size(sim_params.nrn_locations, 1), 1);
    thresholds_history = cell(1, 1);
    thresholds(:, 1) = tholds;
    thresholds_history{1, 1} = hist;
    save_spTMS_threshold_data(params, sim_params, thresholds, thresholds_history); 
end