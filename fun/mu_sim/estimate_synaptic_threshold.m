function estimate_synaptic_threshold(params, sim_params)

    % broadcast sim_params variables 
    neuronal_model  = sim_params.neuronal_model;
    neuronal_dept   = sim_params.neuronal_dept;
    mesh_model      = sim_params.mesh_model;
    nrn_locations   = sim_params.nrn_locations;
    
    % select cell location
    location_idx = 1;
    nrnloc = nrn_locations(location_idx, :);
    
    % correct model name
    if strcmp(neuronal_model, 'Aberra_L23_model')
        model_name =  strcat('Aberra_L23_human', '_syn');
    elseif strcmp(neuronal_model, 'Aberra_L5_model')
        model_name = strcat('Aberra_L5_human', '_syn');
    elseif strcmp(neuronal_model, 'Aberra_L23b_model')
        model_name = strcat('Aberra_L23b_human', '_syn');
    elseif strcmp(neuronal_model, 'Aberra_L5b_model')
        model_name = strcat('Aberra_L5b_human', '_syn');
    else
        disp('Unknown neuronal model.');
    end

    % Create params.txt
    cd(fullfile(params.workspace, 'nemo', 'Models', model_name, 'Code', 'NEURON'))
    var = struct();
    var.params_path = fullfile(params.workspace, 'nemo', 'Models', model_name, 'Results', 'NEURON');   
    var.params_file = 'params.txt';
    var.tms_amp = params.tms_amp;
    var.syn_freq = '3.000000';
    var.syn_noise = '0.500000';
    var.syn_weight = '0.000000';
    var.syn_weight_sync  = sprintf('%.7f', params.syn_weight_max);
    var.tms_offset = '2.000000';
    var.quasipotentials_file = 'quasipotentials.txt';
    create_paramstxt_file(var);
    
    % E-field coupling to neuronal model 
    mkdir(fullfile(params.workspace, 'nemo', 'Models', model_name, 'Results', 'E-field_Coupling'));
    var = struct();
    var.meshfile = strcat(mesh_model, '_TMS_1-0001_MagVenture_MC_B70_scalar.msh'); 
    var.meshpath = fullfile(params.workspace, 'data', 'sim', strcat(params.sim, filesep)); 
    var.nrnloc = nrnloc;  
    var.nrndpth = neuronal_dept;
    var.nrnfile = 'locs_all_seg.txt';
    var.nrnpath = fullfile('..', '..', 'Results', 'NEURON', 'locs', filesep); 
    var.nrnaxs = [0  1  0];
    var.nrnori = []; 
    var.scale_E = 1;
    var.respath = fullfile('..', '..', 'Results', 'E-field_Coupling');
    var.parameters_file = 'parameters.txt';
    create_parameter_file(var);
    cd(fullfile(params.workspace, 'nemo', 'Models', model_name, 'Code', 'E-Field_Coupling'))
    couple_script(fullfile(params.workspace, 'nemo', 'Models', model_name, 'Results', 'E-field_Coupling', 'parameters.txt'));
    
    % Estimate synaptic threshold iteratively
    neuron_threshold_determined = false;
    start_weight = params.syn_weight_max; 
    tested_weights = start_weight;
    sim_path = fullfile(params.workspace, 'nemo', 'Models',  model_name, 'Results', 'thresholds');
    mkdir(sim_path)
    
    while ~neuron_threshold_determined  
        current_weight = round(tested_weights(end), 7);
        disp(['current weight: ', sprintf('%.7f', current_weight)])
        % update params.txt
        cd(fullfile(params.workspace, 'nemo', 'Models', model_name, 'Code', 'NEURON'))
        var = struct();
        var.params_path = fullfile(params.workspace, 'nemo', 'Models', model_name, 'Results', 'NEURON');   
        var.params_file = 'params.txt';
        var.tms_amp = params.tms_amp;
        var.syn_freq = '3.000000';
        var.syn_noise = '0.500000';
        var.syn_weight = '0.000000';
        var.syn_weight_sync  = sprintf('%.7f', current_weight);
        var.tms_offset = '2.000000';
        var.quasipotentials_file = 'quasipotentials.txt';
        create_paramstxt_file(var); 
        var = struct();
        var.code_path = fullfile(params.workspace, 'nemo', 'Models', model_name, 'Code', 'NEURON');
        var.sim_path = sim_path; 
        action_potential = get_neuronal_response(var); 
        if action_potential
            if length(tested_weights) == 1  
                action_potential_history = 1;
            else
                action_potential_history(end + 1) = 1;
            end
        else
            if length(tested_weights) == 1 
                action_potential_history = 0;
            else
                action_potential_history(end + 1) = 0;
            end
        end
        % determine next weight
        next_weight = update_weight('tested_weights', tested_weights, 'action_potential_history', action_potential_history);
        % decide if threshold was determined
        if ismember(next_weight, tested_weights)
            if next_weight == start_weight
                threshold(1, 1) = start_weight;
                neuron_threshold_determined = true;
            else
                ids = find(action_potential_history == 1);
                threshold(1, 1) = min(tested_weights(ids));  
                neuron_threshold_determined = true;
            end
        else
            neuron_threshold_determined = false;
            tested_weights(end + 1) = next_weight;
        end    
    end
    % Save output
    history = zeros(length(tested_weights), 2);
    history(:, 1) = tested_weights';
    history(:, 2) = action_potential_history';
    folder = fullfile(params.workspace, 'data', 'thresholds');
    if not(isfolder(folder))
        mkdir(folder);
    end
    save(fullfile(folder, strcat(neuronal_model, '_synaptic_threshold.mat')), 'threshold');
    save(fullfile(folder, strcat(neuronal_model, '_synaptic_threshold_history.mat')), 'history');
end