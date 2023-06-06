%% Info
% Run multi-scale modeling on HPC.
% Aim: Study the effect of local mesh refinement on neuronal activation.
% Analysis type: Control. 

%% Define preliminaries and parameters
clear; close; clc;
params                 = struct();
params.repository      = '2022_cortical_folding_hpc';
params.workspace       = fullfile('', params.repository); % please set
run(fullfile(params.workspace, 'src', 'init(params.workspace).m'))
params.idx             = transpose(1:2);
params.mesh_models     = create_head_model_names(params);
params.angles          = 0;   % coil angles 
params.neuronal_model  = 'Aberra_L23_model'; 
params.neuronal_depth  = 0.45;
params.syn_weight_sync = 0;   % 0 = no synaptic input 
params.mso_max         = 101; % maximum TMS intensity 
params.folder_flag     = 'spTMS';
params.sim_id          = strcat(params.folder_flag, '_mesh_refinement');
params.folder = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);
if not(isfolder(params.folder))
    mkdir(params.folder)
end

%% Run modeling
% % Prepare multi-scale modeling parameters
% for i = 1:2
%     loop_params = struct();
%     loop_params.mesh_model        = params.mesh_models{i, 1};
%     if i == 1
%         nrn_locations_all = load(fullfile(params.workspace, 'data', 'nrn_locs', loop_params.mesh_model, strcat(loop_params.mesh_model, '_locations.mat')));
%         nrn_locations_all = cell2mat(struct2cell(nrn_locations_all));
%         index = randsample(1:length(nrn_locations_all), 500); % randomly select 500 neuronal locations
%     end
%     loop_params.index             = index;
%     loop_params.nrn_locations     = nrn_locations_all(loop_params.index, :);
%     loop_params.efield_sim        = strcat(loop_params.mesh_model, '_angle_', num2str(params.angles(1, 1)));
%     loop_params.syn_weight_sync   = params.syn_weight_sync;
%     loop_params.neuronal_model    = params.neuronal_model; 
%     loop_params.neuronal_dept     = params.neuronal_depth;    
%     loop_params.label             = loop_params.neuronal_model; 
%     save(fullfile(params.folder, strcat(loop_params.mesh_model, '_loop_params.mat')), 'loop_params');
% end

% Run multi-scale modeling
for i = 2 
    loop_params = load(fullfile(params.folder, strcat(params.mesh_models{i, 1}, '_loop_params.mat')));
    loop_params = cell2mat(struct2cell(loop_params));
    copy_mesh(params, loop_params);
    prepare_folder(params, loop_params);
    [tholds, hist] = estimate_spTMS_threshold(params, loop_params); % this fun uses parfor loop
    thresholds = zeros(size(loop_params.nrn_locations, 1), 1);
    thresholds_history = cell(1, 1);
    thresholds(:, 1) = tholds;
    thresholds_history{1, 1} = hist;
    save_spTMS_threshold_data(params, loop_params, thresholds, thresholds_history); 
end