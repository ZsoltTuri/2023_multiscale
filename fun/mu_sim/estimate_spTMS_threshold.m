function [tholds, hist] = estimate_spTMS_threshold(params, sim_params)
    
    % broadcast sim_params variables 
    neuronal_model   = sim_params.neuronal_model;
    neuronal_dept    = sim_params.neuronal_dept;
    mesh_model       = sim_params.mesh_model;
    syn_input_weight = sim_params.syn_input_weight;
    syn_weight_sync  = sim_params.syn_weight_sync;
    nrn_locations    = sim_params.nrn_locations;
    efield_sim       = sim_params.efield_sim;
    rot_cells        = sim_params.rot_cells;
    yangle           = sim_params.yangle;
   
    if strcmp(neuronal_model, 'Aberra_L23_model')
        model_name = strcat('Aberra_L23_human', '_', params.folder_flag);
    elseif strcmp(neuronal_model, 'Aberra_L5_model')
        model_name = strcat('Aberra_L5_human', '_', params.folder_flag);
    elseif strcmp(neuronal_model, 'Aberra_L23b_model')
        model_name = strcat('Aberra_L23b_human', '_', params.folder_flag);
    elseif strcmp(neuronal_model, 'Aberra_L5b_model')
        model_name = strcat('Aberra_L5b_human', '_', params.folder_flag);
    else
        disp('Unknown neuronal model.');
    end
        
    % Create parallel pool
    pp = parcluster('local');
    num_workers = str2num(getenv('SLURM_NTASKS_PER_NODE'));
    parpool_tmpdir = [getenv('TMP'),'/.matlab/local_cluster_jobs/slurm_jobID_',getenv('SLURM_JOB_ID')];
    mkdir(parpool_tmpdir);
    pp.JobStorageLocation = parpool_tmpdir;
    parpool(pp, num_workers);
    poolobj = gcp('nocreate');

    % Create a separate folder for each simulation 
    nlocs = size(nrn_locations, 1); % number of rows
    source_folder = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', model_name);
    parfor ll = 1:nlocs 
        target_folder =  strcat(source_folder, '_', efield_sim, '_loc_', num2str(ll), '_syn_', num2str(syn_input_weight), '_depth_', num2str(neuronal_dept));
        mkdir(target_folder);
        copyfile(source_folder, target_folder, 'f');
    end

    % Threshold hunting
    meshfile = strcat(mesh_model, '_TMS_1-0001_MagVenture_MC_B70_scalar.msh'); 
    meshpath = fullfile(params.workspace, 'data', 'sim', strcat(efield_sim, filesep));
    tholds = zeros(nlocs, 1);
    hist = cell(nlocs, 1);
    mkdir(fullfile(params.workspace, 'data', 'thresholds'));
    
    parfor jj = 1:nlocs 
        sim =  strcat(model_name, '_', efield_sim, '_loc_', num2str(jj), '_syn_', num2str(syn_input_weight), '_depth_', num2str(neuronal_dept));
        nrnloc = nrn_locations(jj, :);
        % Create params.txt  
        cd(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Code', 'NEURON'))
        var = struct();
        var.params_path = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Results', 'NEURON'); 
        var.params_path = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Results', 'NEURON');   
        var.params_file = 'params.txt';
        var.tms_amp = '1'; % initially run it at 1% MSO
        var.syn_freq = '3.000000';
        var.syn_noise = '0.500000';
        var.syn_weight = '0.000000';
        var.syn_weight_sync  = sprintf('%.7f', syn_weight_sync);
        var.tms_offset = '2.000000';
        var.quasipotentials_file = 'quasipotentials.txt';
        create_paramstxt_file(var);
        % E-field coupling to neuronal model 
        mkdir(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Results', 'E-field_Coupling'));
        var = struct();
        var.meshfile = meshfile;
        var.meshpath = meshpath; 
        var.nrnloc = nrnloc;   
        var.nrndpth = neuronal_dept;
        var.nrnfile = 'locs_all_seg.txt';
        var.nrnpath = fullfile('..', '..', 'Results', 'NEURON', 'locs', filesep); 
        var.nrnaxs = [0  1  0];
        var.nrnori = []; 
        var.scale_E = 1;
        var.respath = fullfile('..', '..', 'Results', 'E-field_Coupling');
        var.yangle = yangle;
        var.parameters_file = 'parameters.txt';
        create_parameter_file(var);
        cd(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Code', 'E-Field_Coupling'))
        
        if strcmp(rot_cells, 'no') 
            couple_script(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Results', 'E-field_Coupling', 'parameters.txt'));
        else
            couple_script_rot_cells(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Results', 'E-field_Coupling', 'parameters.txt'));
        end

        % Estimate spTMS threshold iteratively
        mkdir(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models',  sim, 'Results', 'thresholds'));
        neuron_threshold_determined = false;
        start_intensity = params.mso_max;
        tested_intensities = start_intensity;
        action_potential_history = [];
        while ~neuron_threshold_determined  
            current_intensity = tested_intensities(end);
            disp(['current MSO is: ', sprintf('%.7f', current_intensity)])
            % update params.txt iteratively
            cd(fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Code', 'NEURON'))
            var = struct();
            var.params_path = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Results', 'NEURON');   
            var.params_file = 'params.txt';
            var.tms_amp = current_intensity;
            var.syn_freq = '3.000000';
            var.syn_noise = '0.500000';
            var.syn_weight = '0.000000';
            var.syn_weight_sync  = sprintf('%.7f', syn_weight_sync);
            var.tms_offset = '2.000000';
            var.quasipotentials_file = 'quasipotentials.txt';
            create_paramstxt_file(var); 
            var = struct();
            var.code_path = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', sim, 'Code', 'NEURON');
            var.sim_path = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models',  sim, 'Results', 'thresholds'); 
            action_potential = get_neuronal_response(var); 
            if action_potential
                if length(tested_intensities) == 1  
                    action_potential_history = 1;
                else
                    action_potential_history(end + 1) = 1;
                end
            else
                if length(tested_intensities) == 1 
                    action_potential_history = 0;
                else
                    action_potential_history(end + 1) = 0;
                end
            end
            % determine next intensity and decide if threshold was determined
            next_intensity = update_intensity('tested_intensities', tested_intensities, 'action_potential_history', action_potential_history); 
            if ismember(next_intensity, tested_intensities)
                if next_intensity == start_intensity
                    tholds(jj, 1) = start_intensity;
                    neuron_threshold_determined = true;
                else
                    ids = find(action_potential_history == 1);
                    tholds(jj, 1) = min(tested_intensities(ids));  
                    neuron_threshold_determined = true;
                end
            else
                neuron_threshold_determined = false;
                tested_intensities(end + 1) = next_intensity;
            end    
        end
        h = zeros(length(tested_intensities), 2);
        h(:, 1) = tested_intensities';
        h(:, 2) = action_potential_history';
        hist{jj, 1} = h;
    end
    delete(poolobj);
end
