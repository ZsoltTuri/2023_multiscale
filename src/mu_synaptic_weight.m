function mu_synaptic_weight(index)
    %% Info
    % Run multi-scale modeling on HPC.
    % Aim: Study effect of synaptic weights (control analysis).
    
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
    params.neuronal_model = 'Aberra_L5_model'; 
    params.neuronal_depth = 1.25;
    params.syn_threshold = load(fullfile(params.workspace, 'data', 'thresholds', strcat(params.neuronal_model, '_synaptic_threshold', '.mat')));
    params.syn_threshold = cell2mat(struct2cell(params.syn_threshold));
    params.syn_input_weights = transpose(0.1:0.1:0.9); % scalar for synaptic threshold
    params.mso_max = 101; % maximum TMS intensity 
    params.folder_flag = 'spTMS';
    params.sim_id = strcat(params.folder_flag, '_synaptic_weight');
    params.folder = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);
    
    %% Run modeling
    % Prepare multi-scale modeling
    if not(isfolder(params.folder))
        [~, ~] = mkdir(params.folder);
    end
    sim_params = load(fullfile(params.workspace, 'data', 'mu_sim', 'spTMS_neuronal_model', strcat(params.neuronal_model, '_loop_params.mat')));
    sim_params = cell2mat(struct2cell(sim_params));
    sim_params.syn_input_weight = params.syn_input_weights(index, 1);
    sim_params.syn_weight_sync = params.syn_threshold * sim_params.syn_input_weight;
    sim_params.label = strcat('synweight_', num2str(sim_params.syn_input_weight)); 
    save(fullfile(params.folder, strcat(sim_params.label, '_sim_params.mat')), 'sim_params');
    if index == 1
        copy_mesh(params, sim_params);
    end
    % Run multi-scale modeling
    [tholds, hist] = estimate_spTMS_threshold(params, sim_params); % this fun uses parfor loop
    thresholds = zeros(size(sim_params.nrn_locations, 1), 1);
    thresholds_history = cell(1, 1);
    thresholds(:, 1) = tholds;
    thresholds_history{1, 1} = hist;
    save_spTMS_threshold_data(params, sim_params, thresholds, thresholds_history); 
end