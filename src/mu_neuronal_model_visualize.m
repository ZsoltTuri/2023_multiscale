%% Info
% Run multi-scale modeling on HPC.
% Aim: Visualize neuronal models.

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
params.neuronal_models = {'Aberra_L23_model'; 'Aberra_L5_model'}; 
params.neuronal_depths = [0.45; 1.25];
params.syn_weight_sync = 0;   % 0 = no synaptic input 
params.mso_max = 101; % maximum TMS intensity 
params.folder_flag = 'spTMS';
params.sim_id = strcat(params.folder_flag, '_neuronal_model');
params.folder = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);

% Visualize E.-field coupling
for i = 1:length(params.neuronal_models)
    loop_params = load(fullfile(params.folder, strcat(params.neuronal_models{i, 1}, '_loop_params.mat')));
    loop_params = cell2mat(struct2cell(loop_params));
    loop_params.loc_idx = 5318; % details: mu_neuronal_model_local.m
    visualize_coupling(params, loop_params)
end