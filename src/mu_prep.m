%% Info
% Prepare multi-scale modeling on HPC.
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
clear; close; clc;
params = struct();
params.repository = '2022_cortical_folding_hpc';
params.workspace = fullfile('', params.repository); % please set
run(fullfile(params.workspace, 'src', 'init(params.workspace).m'))
params.idx = transpose(1:70);
params.mesh_models = create_head_model_names(params);
params.mesh_model = params.mesh_models{29, 1};
params.neuronal_models = {'Aberra_L23_model'; 'Aberra_L5_model'; 'Aberra_L23b_model'; 'Aberra_L5b_model'};
params.neuronal_depths = [0.45; 1.25; 1.25; 0.45];
params.axon_type = 4; % myelinated axon
params.syn_distance = 10; % distance from soma on apical dendrite in µm 
params.folder_flag = 'syn';
params.syn_weight_max = 0.2; % maximum synaptic weight used in threshold estimation in a.u.
params.tms_amp = 0; % TMS intensity in MSO%; 0 = no TMS applied
% here, I only select one macroscopic E-field simulation, because synaptic threshold is not specific to the mesh or TMS parameters
params.angles = 0;   % coil angles 
params.radians = deg2rad(params.angles);
params.sim = strcat(params.mesh_model, '_angle_', num2str(params.angles(1, 1))); 
params.mesh_path = fullfile(params.workspace, 'data', 'sim_stat', params.sim);  
params.mesh_name = strcat(params.mesh_model, '_GM.msh');

%% Run simulations
for i = 1:length(params.neuronal_models)
    % prepare simulation parameters
    sim_params                = struct();
    sim_params.neuronal_model = params.neuronal_models{i, 1}; 
    sim_params.neuronal_dept  = params.neuronal_depths(i, 1);    
    sim_params.mesh_model     = params.mesh_model;
    sim_params.nrn_locations  = load(fullfile(params.workspace, 'data', 'nrn_locs', params.mesh_model, strcat(sim_params.mesh_model, '_locations.mat')));
    sim_params.nrn_locations  = cell2mat(struct2cell(sim_params.nrn_locations));
    % prepare multi-scale modeling
    generate_neuronal_model(params, sim_params);
    prepare_folder(params, sim_params);
    estimate_synaptic_threshold(params, sim_params);
end