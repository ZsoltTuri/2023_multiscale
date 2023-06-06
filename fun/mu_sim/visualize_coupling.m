function visualize_coupling(params, loop_params)
    
    % broadcast loop_params variables 
    neuronal_model  = loop_params.neuronal_model;
    neuronal_dept   = loop_params.neuronal_dept;
    mesh_model      = loop_params.mesh_model;
    syn_weight_sync = loop_params.syn_weight_sync;
    efield_sim      = loop_params.efield_sim;
    loc_idx         = loop_params.loc_idx;
    nrnloc          = loop_params.nrn_locations(loc_idx, :);

    if strcmp(neuronal_model, 'Aberra_L23_model')
        model_name = strcat('Aberra_L23_human', '_', params.folder_flag);
    else
        model_name = strcat('Aberra_L5_human', '_', params.folder_flag);
    end 
    
    sim = strcat(model_name, '_', mesh_model, '_loc_', num2str(loc_idx));    
    mso = 70;
    meshfile = strcat(mesh_model, '_TMS_1-0001_MagVenture_MC_B70_scalar.msh'); 
    meshpath = fullfile(params.workspace, 'data', 'sim', strcat(efield_sim, filesep));

    % E-field coupling to neuronal model 
    cd(fullfile(params.workspace, 'nemo', 'Models', sim, 'Code', 'NEURON'))
    var = struct();
    var.meshfile = meshfile;
    var.meshpath = meshpath; 
    var.nrnloc = nrnloc;   
    var.nrndpth = neuronal_dept;
    var.nrnfile = 'locs_all_seg.txt';
    var.nrnpath = fullfile('..', '..', 'Results', 'NEURON', 'locs', filesep); 
    var.nrnaxs = [0  1  0];
    var.nrnori = []; 
    var.scale_E = mso;
    var.respath = fullfile('..', '..', 'Results', 'E-field_Coupling');
    var.parameters_file = 'parameters.txt';
    create_parameter_file(var);
    cd(fullfile(params.workspace, 'nemo', 'Models', sim, 'Code', 'E-Field_Coupling'))
    couple_script_visualize(fullfile(params.workspace, 'nemo', 'Models', sim, 'Results', 'E-field_Coupling', 'parameters.txt'));
end