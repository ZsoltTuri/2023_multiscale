%% Info
% Run macroscopic E-field simulations on HPC.

%% Define preliminaries and parameters
params = struct();
params.repository = '2022_cortical_folding_hpc';
params.workspace = fullfile('', params.repository); % please set
run(fullfile(params.workspace, 'src', 'init(params.workspace).m'))
params.idx = transpose(1:70);
params.mesh_models = create_head_model_names(params);
params.fnamecoil = fullfile('', 'conda', 'envs', 'simnibs_env', 'lib', 'python3.7', 'site-packages', 'simnibs', 'ccd-files', 'MagVenture_MC_B70.ccd'); % please set
params.ccr = 1.49; % coil current rate of change at 1 percent maximum stimulator output (MSO) [A/us]
params.mso = 1; % run simulations at 1 percent MSO
params.angles = transpose(0:15:345); % coil angles [in degree]
params.radians = deg2rad(params.angles);
params.distance = 4; % coil to skin distance [in mm]
params.scaling_factor = 100;  % controls the final mesh size [in mm]
% ROI size: Compute the mean Euclidean distance for those mesh elements that have at least 25% of the robust max. of the absolute E-field
params.field = 'normE';
params.robust_max = 99.9;   
params.threshold = 25;  
params.stat = 'mean'; 
params.wall_offset = 0.025; % offset the ROI's wall from the sphere with a given percentage

%% Create parallel pool
pp = parcluster('local');
num_workers = str2num(getenv('SLURM_NTASKS_PER_NODE'));
parpool_tmpdir = [getenv('TMP'), '/.matlab/local_cluster_jobs/slurm_jobID_', getenv('SLURM_JOB_ID')];
mkdir(parpool_tmpdir);
pp.JobStorageLocation = parpool_tmpdir;
parpool(pp, num_workers);
poolobj = gcp('nocreate');

%% Run E-field simulations
n_rad = length(params.radians);
parfor i = 1:14
    loop_params = struct();
    loop_params.mesh_model = params.mesh_models{i, 1};
    for j = 1:n_rad        
        loop_params.radian = params.radians(j, 1);
        simulate_TMS(params, loop_params);
        determine_roi_size(params, loop_params); 
        if j == 1
            save_surface_mask(params, loop_params);
            save_volume_mask(params, loop_params);
            save_surface_mesh_properties(params, loop_params);
            save_volume_mesh_properties(params, loop_params);
        end
        surface_based_efield_analysis_roi(params, loop_params);
        volume_based_efield_analysis_roi(params, loop_params);        
    end
end
delete(poolobj);