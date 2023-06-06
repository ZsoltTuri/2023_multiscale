%% Info
% Prepare macroscopic E-field simulations on HPC. 

%% Define preliminaries and parameters
params = struct();
params.repository = '2022_cortical_folding_hpc';
params.workspace = % please  set
run(fullfile(params.workspace, 'src', 'init(params.workspace).m'));
params.idx = transpose(1:70);
params.mesh_models = create_head_model_names(params);
params.scaling_factor = 100;  % controls the final mesh size [in mm]

%% Create parallel pool
pp = parcluster('local');
num_workers = str2num(getenv('SLURM_NTASKS_PER_NODE'));
parpool_tmpdir = [getenv('TMP'), '/.matlab/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')];
mkdir(parpool_tmpdir);
pp.JobStorageLocation = parpool_tmpdir;
parpool(pp, num_workers);
poolobj = gcp('nocreate');

%% Run simulations
parfor i = 1:14    
    loop_params = struct();
    loop_params.mesh_model = params.mesh_models{i, 1};
    create_folders(params, loop_params);
    extract_readme_info(params, loop_params);
    create_geo(params, loop_params);
    create_spheres(params, loop_params);
    create_mesh(params, loop_params); 
    correct_mesh(params, loop_params);  
    extract_save_mesh_dimension(params, loop_params);   
end
delete(poolobj);