function run_multi_scale_modeling(input)
params = struct();
params.workspace = input.workspace;
params.model = input.models{input.mid, 1};
params.neuronal_model = {'Aberra_L23_model', 'Aberra_L5_model'};
% Initialize neuronal model -----------------------------------------------
if strcmp(input.initialize_neuronal_model, 'yes')
    initialize_neuronal_model(params)
end
% Generate neuronal model -------------------------------------------------
if strcmp(input.generate_neuronal_model, 'yes')
    generate_neuronal_model(params)
end
% Select neuronal locations -----------------------------------------------
params.angle = 0;
params.mesh_path = fullfile(input.workspace, 'data', 'sim_stat', strcat(params.model, '_angle_', num2str(params.angle))); 
params.mesh_name = strcat(params.model, '_GM.msh');
params.n = 1; % select every nth element
if strcmp(input.select_neuronal_locations, 'yes')
    select_neuronal_locations(params);
end
% Estimate synaptic threshold ---------------------------------------------
params.folder_flag = 'syn';
params.syn_weight_max = 0.2;
params.tms_amp = 0;
if strcmp(input.estimate_synaptic_threshold, 'yes')
    prepare_folder(params);
    estimate_synaptic_threshold(params);
end

%% Estimate single-pulse TMS thresholds 
params.folder_flag = 'spTMS';
params.mso_max = 101;
params.syn_threshold = load(fullfile(input.workspace, 'data', 'thresholds', strcat(params.neuronal_model, '_synaptic_threshold.mat')));
params.syn_threshold = cell2mat(struct2cell(params.syn_threshold));

params.nrn_locations = load(fullfile(input.workspace, 'data', 'nrn_locs', strcat(params.model, '.mat')));
params.nrn_locations = cell2mat(struct2cell(params.nrn_locations));
params.roi_mask = load(fullfile(input.workspace, 'data', 'nrn_locs', strcat(params.model, '_mask.mat')));
params.roi_mask = cell2mat(struct2cell(params.roi_mask));
% using both neuronal models ----------
params.syn_input_weight = 0;
if strcmp(input.estimate_spTMS_threshold, 'yes')
    prepare_folder(params);
    estimate_spTMS_threshold(params);
    append_spTMS_threshold_to_mesh(params);
end
end


% Estimate single-pulse TMS threshold using different portion of synaptic
% inputs ------------------------------------------------------------------
params.folder_flag = 'spTMS';
params.mso_max = 101;
params.syn_threshold = load(fullfile(input.workspace, 'data', 'thresholds', strcat(params.neuronal_model, '_synaptic_threshold.mat')));
params.syn_threshold = cell2mat(struct2cell(params.syn_threshold));
params.syn_input_weight = 0:0.1:0.9;
params.nrn_locations = load(fullfile(input.workspace, 'data', 'nrn_locs', strcat(params.model, '.mat')));
params.nrn_locations = cell2mat(struct2cell(params.nrn_locations));
params.roi_mask = load(fullfile(input.workspace, 'data', 'nrn_locs', strcat(params.model, '_mask.mat')));
params.roi_mask = cell2mat(struct2cell(params.roi_mask));
if strcmp(input.estimate_spTMS_threshold, 'yes')
    prepare_folder(params);
    estimate_spTMS_threshold(params);
    append_spTMS_threshold_to_mesh(params);
end
end