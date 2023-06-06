function prepare_folder(params, sim_params)
    
    neuronal_model = sim_params.neuronal_model;

    if strcmp(neuronal_model, 'Aberra_L23_model')
        fld = 'Aberra_L23_human'; 
    elseif strcmp(neuronal_model, 'Aberra_L5_model')
        fld = 'Aberra_L5_human';
    elseif strcmp(neuronal_model, 'Aberra_L23b_model')
        fld = 'Aberra_L23b_human';
    elseif strcmp(neuronal_model, 'Aberra_L5b_model')
        fld = 'Aberra_L5b_human';
    else
        disp('Unknown neuronal model.');
    end
    folder = strcat(fld, '_', params.folder_flag);

    % Copy neuronal model folder
    source_folder = fullfile(params.workspace, 'nemo', 'Models', fld);
    target_folder = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', folder);
    if not(isfolder(target_folder))
        mkdir(target_folder);
    end
    status = copyfile(source_folder, target_folder, 'f');
    if status == 1
        disp('Copying source folder successfully!');
    else
        disp('Error copying source folder!');
    end
    clearvars source_folder target_folder

    % Copy modified hoc files
    source_folder = fullfile(params.workspace, 'nemo', 'adjusted_nemo_codes', params.folder_flag, 'hoc_codes');
    target_folder = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', folder, 'Code', 'NEURON');
    status = copyfile(source_folder, target_folder, 'f');
    if status == 1
        disp('Copying hoc files successfully!');
    else
        disp('Error copying hoc files!');
    end
    clearvars source_folder target_folder
    % Copy waveform files
    source_folder = fullfile(params.workspace, 'nemo', 'adjusted_nemo_codes', params.folder_flag, 'TMS_Waveform');
    target_folder = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', folder, 'Results', 'TMS_Waveform');
    if not(isfolder(target_folder))
        mkdir(target_folder)
    end
    status = copyfile(source_folder, target_folder, 'f');
    if status == 1
        disp('Copying TMS waveforms successfully!');
    else
        disp('Error copying TMS waveforms!');
    end
    clearvars source_folder target_folder

    % Copy couple script
    source_folder = fullfile(params.workspace, 'nemo', 'adjusted_nemo_codes', params.folder_flag, 'couple_script');
    target_folder = fullfile([getenv('TMP'),'/.models/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')], 'nemo', 'Models', folder, 'Code', 'E-Field_Coupling');
    if not(isfolder(target_folder))
        mkdir(target_folder)
    end
    status = copyfile(source_folder, target_folder, 'f');
    if status == 1
        disp('Copying E-field coupling script successfully!');
    else
        disp('Error copying E-field coupling script!');
    end
    clearvars source_folder target_folder

end