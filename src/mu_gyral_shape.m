%% Info
% Run multi-scale modeling on HPC.
% Aim: Study effect of gyral shape.

%% Define preliminaries and parameters
params = struct();
params.repository = '2022_cortical_folding_hpc';
params.workspace = fullfile('', params.repository); % please set
run(fullfile(params.workspace, 'src', 'init(params.workspace).m'))
params.idx = transpose(1:70);
params.mesh_models = create_head_model_names(params);
% Here, I select one mesh file and one E-field simulation 
params.mesh_model = params.mesh_models{38, 1};
params.angles = 0;  % coil angles 
params.efield_sim = strcat(params.mesh_model, '_angle_', num2str(params.angles(1, 1))); % macroscopic E-field simulation
params.neuronal_model = 'Aberra_L5_model'; 
params.neuronal_depth = 1.25;
params.syn_threshold = load(fullfile(params.workspace, 'data', 'thresholds', strcat(params.neuronal_model, '_synaptic_threshold', '.mat')));
params.syn_threshold = cell2mat(struct2cell(params.syn_threshold));
params.syn_input_weight = 0;
params.syn_weight_sync = params.syn_threshold * params.syn_input_weight; % 0 = no synaptic input 
params.mso_max = 101; % maximum TMS intensity 
params.folder_flag = 'spTMS';
params.sim_id = strcat(params.folder_flag, '_gyral_shape');
params.folder = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);

%% Run modeling
% Prepare multi-scale modeling
if not(isfolder(params.folder))
    [~, ~] = mkdir(params.folder);
end
sim_params = struct();
sim_params.mesh_model = params.mesh_model;
sim_params.efield_sim = params.efield_sim;
sim_params.syn_input_weight = params.syn_input_weight;
sim_params.syn_weight_sync = params.syn_weight_sync;
sim_params.neuronal_model = params.neuronal_model; 
sim_params.neuronal_dept = params.neuronal_depth;
sim_params.nrn_locations_all = load(fullfile(params.workspace, 'data', 'nrn_locs', params.mesh_model, strcat(sim_params.mesh_model, '_locations.mat')));
sim_params.nrn_locations_all = cell2mat(struct2cell(sim_params.nrn_locations_all));
sim_params.nrn_percent = 0.2;
sim_params.nrn_number = ceil(sim_params.nrn_percent * length(sim_params.nrn_locations_all));
copy_mesh(params, sim_params);
sim_params.index = randsample(1:length(sim_params.nrn_locations_all), sim_params.nrn_number);
sim_params.nrn_locations = sim_params.nrn_locations_all(sim_params.index, :);       
sim_params.label = params.sim_id;
save(fullfile(params.folder, strcat(sim_params.label, '_sim_params.mat')), 'sim_params');

% Run multi-scale modeling
[tholds, hist] = estimate_spTMS_threshold(params, sim_params); % this fun uses parfor loop
thresholds = zeros(size(sim_params.nrn_locations, 1), 1);
thresholds_history = cell(1, 1);
thresholds(:, 1) = tholds;
thresholds_history{1, 1} = hist;
save_spTMS_threshold_data(params, sim_params, thresholds, thresholds_history); 