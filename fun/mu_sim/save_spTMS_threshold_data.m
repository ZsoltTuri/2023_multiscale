function save_spTMS_threshold_data(params, sim_params, thresholds, thresholds_history)

    % broadcast loop_params variables 
    neuronal_model  = sim_params.neuronal_model;
    neuronal_dept   = sim_params.neuronal_dept;
    mesh_model      = sim_params.mesh_model;
    syn_input_weight = sim_params.syn_input_weight;
    efield_sim      = sim_params.efield_sim;
    label           = sim_params.label;
    index           = sim_params.index;
    yangle           = sim_params.yangle;

    roi_mask        = load(fullfile(params.workspace, 'data', 'mesh_mask', mesh_model, strcat(mesh_model, '_surface_GM.mat')));
    roi_mask        = cell2mat(struct2cell(roi_mask));

    % save .mat 
    out_path = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);
    out_name_t = strcat(efield_sim, '_', neuronal_model, '_nrndepth_', num2str(neuronal_dept), '_synweight_',  num2str(syn_input_weight), '_cellYangle_', num2str(yangle), '_thresholds.mat');
    out_name_th = strcat(efield_sim, '_', neuronal_model, '_nrndepth_', num2str(neuronal_dept), '_synweight_',  num2str(syn_input_weight), '_cellYangle_', num2str(yangle), '_thresholds_history.mat');
    save(fullfile(out_path, out_name_t), 'thresholds');
    save(fullfile(out_path, out_name_th), 'thresholds_history');
    
    % save .xlsx
    T = array2table(thresholds);
    T.Properties.VariableNames = {'threshold'};
    out_name_t = strcat(efield_sim, '_', neuronal_model, '_nrndepth_', num2str(neuronal_dept), '_synweight_',  num2str(syn_input_weight), '_cellYangle_', num2str(yangle), '_thresholds.xlsx');
    writetable(T, fullfile(out_path, out_name_t));

%     % load mesh
%     mesh_path = fullfile(params.workspace, 'data', 'mu_sim', params.sim_id);
%     mesh_name = strcat(efield_sim, '_GM.msh');
%     mesh = mesh_load_gmsh4(fullfile(mesh_path, mesh_name));
%     idx = length(mesh.element_data);
%         
%     % append simulation results
%     mask_inside = find(roi_mask.inside == true); % first get inside mask
%     mask_mu = mask_inside(index); % create mask for multi-scale modeling
%     mesh.element_data{idx + 1, 1} = mesh.element_data{idx, 1};
%     mesh.element_data{idx + 1, 1}.tridata(:, 1) = 0;
%     % mesh.element_data{idx + 1, 1}.tridata(roi_mask.inside, 1) = thresholds(:, 1);
%     mesh.element_data{idx + 1, 1}.tridata(mask_mu, 1) = thresholds(:, 1);
%     mesh.element_data{idx + 1, 1}.name = label;
%     mesh.element_data{idx + 1, 1}.tetdata = mesh.element_data{2, 1}.tetdata;
%     
%     % save mesh
%     mesh_save_gmsh4(mesh, fullfile(mesh_path, mesh_name))    

end