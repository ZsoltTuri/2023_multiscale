%% Info
% Create batch job scripts for HPC.
% Run this script on your local PC and upload its output (shell files) to HPC via git.

%% Set preliminaries
clear; close; clc;
repository = '2022_cortical_folding_hpc';
addpath(genpath(fullfile('', repository, 'fun'))) % please set
cd(fullfile('', repository)) % please set

%% Define paths 
path     = struct();
path.pc  = fullfile('', repository, 'batch_jobs'); % please set
path.pc  = strrep(path.pc, '\', '\\'); % for Windows
path.hpc = fullfile('', repository); % please set
path.hpc = strrep(path.hpc, '\', '/'); % for Linux

%% Define jobs
jobs   = struct();
jobs.a = 'ma_prep'; % prepare macroscopic E-field simulations
jobs.b = 'ma_sim'; % run macroscopic E-field simulations
jobs.c = 'mu_prep'; % prepare multi-scale simulations
jobs.d = 'mu_neuronal_model'; % multi-scale simulations: neuronal model
jobs.e = 'mu_neuronal_model_visualize'; % visualize neuronal model
jobs.f = 'mu_synaptic_weight'; % multi-scale simulations: synaptic weight
jobs.g = 'mu_gyral_shape'; % multi-scale simulations: gyral shape
jobs.h = 'mu_neuronal_depth'; % multi-scale simulations: neuronal depth
jobs.i = 'mu_gyral_height'; % multi-scale simulations: gyral height
jobs.j = 'mu_coil_angle'; % multi-scale simulations: coil angle
jobs.k = 'mu_coil_angle_rot_cells'; % multi-scale simulations: coil angle and rotate cells
jobs.l = 'mu_coil_angle_rot_cells_z'; % multi-scale simulations: coil angle and rotate cells around z axis
jobs.m = 'mu_rotate_cell_y_axis'; % multi-scale simulations: rotate cells around y axis

%% Create batch jobs
% prepare macroscopic E-field simulations
batch             = struct();
batch.job_name    = jobs.a;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
%batch.tasks       = '1';
batch.tasks_nodes = '7'; 
batch.memory      = '64'; 
batch.wallclock   = '02:45:00';  
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% run macroscopic E-field simulations
batch             = struct();
batch.job_name    = jobs.b;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '6'; 
batch.memory      = '64'; 
batch.wallclock   = '15:00:00'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% prepare multi-scale simulations
batch             = struct();
batch.job_name    = jobs.c;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '1';
batch.memory      = '32'; 
batch.wallclock   = '01:00:00'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% multi-scale simulations: neuronal model
batch             = struct();
batch.job_name    = jobs.d;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '10'; 
batch.memory      = '80'; 
batch.wallclock   = '72:00:00';
batch.array       = '3'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% multi-scale simulations: visualize neuronal model coupling
batch             = struct();
batch.job_name    = jobs.e;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '1'; 
batch.memory      = '10'; 
batch.wallclock   = '00:20:00';
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch) 

% multi-scale simulations: synaptic weight
batch             = struct();
batch.job_name    = jobs.f;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '8'; 
batch.memory      = '64'; 
batch.wallclock   = '72:00:00';
batch.array       = '1-9';
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% multi-scale simulations: gyral shape
batch             = struct();
batch.job_name    = jobs.g;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '8';
batch.memory      = '64'; 
batch.wallclock   = '72:00:00'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% multi-scale simulations: neuronal depth
batch             = struct();
batch.job_name    = jobs.h;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks       = '1';
batch.tasks_nodes = '10';
batch.memory      = '80'; 
batch.wallclock   = '72:00:00';
batch.array       = '1-3';
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)  

% multi-scale simulations: gyral height
batch             = struct();
batch.job_name    = jobs.i;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks       = '1';
batch.tasks_nodes = '10';
batch.memory      = '80'; 
batch.wallclock   = '72:00:00';
batch.array       = '4-5';
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch) 

% multi-scale simulations: coil angle
batch             = struct();
batch.job_name    = jobs.j;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '10';
batch.memory      = '80'; 
batch.wallclock   = '72:00:00';
batch.array       = '1-7'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch) 

% multi-scale simulations: coil angle and rotate cells
batch             = struct();
batch.job_name    = jobs.k;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '10';
batch.memory      = '90'; 
batch.wallclock   = '65:00:00';
batch.array       = '1-2'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch) 

% multi-scale simulations: coil angle and rotate cells around z axis
batch             = struct();
batch.job_name    = jobs.l;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '10';
batch.memory      = '90'; 
batch.wallclock   = '65:00:00';
batch.array       = '1-2'; 
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch)

% multi-scale simulations: rotate cells around y axis
batch             = struct();
batch.job_name    = jobs.m;
batch.name        = strcat(batch.job_name, '.sh');
batch.nodes       = '1';
batch.tasks_nodes = '10';
batch.memory      = '110'; 
batch.wallclock   = '65:00:00';
batch.array       = '4'; % '1-12'
batch.pc_path     = path.pc;
batch.hpc_path    = path.hpc;
batch_job(batch) 

%% Initialization
batch          = struct();
batch.name     = 'initialize.sh';
batch.jobs     = struct2cell(jobs);
batch.pc_path  = path.pc;
batch.hpc_path = path.hpc;
batch_job_init(batch);