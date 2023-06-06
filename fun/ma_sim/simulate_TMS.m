function simulate_TMS(params, loop_params)

    % broadcast loop_params variables
    mesh_model = loop_params.mesh_model;
    radian = loop_params.radian;    

    % Define parameters
    mesh_path = fullfile(params.workspace, 'data', 'mesh');
    pathfem = fullfile(params.workspace, 'data', 'sim', strcat(mesh_model, '_angle_', num2str(rad2deg(radian))));
    if not(isfolder(pathfem))
        mkdir(pathfem)
    end
    mesh_file = strcat(mesh_model, '.msh');    
    fnamehead = fullfile(mesh_path, mesh_file);
    mesh = mesh_load_gmsh4(fnamehead);      
    
    % Prepare and save matsimnibs file
    center = max(mesh.nodes(:, 3));
    offset = center + params.distance;
    matsimnibs = create_matsimnibs(radian, offset); 
    matsimnibs_folder = fullfile(params.workspace, 'data', 'matsimnibs', mesh_model);
    if not(isfolder(matsimnibs_folder))
        mkdir(matsimnibs_folder)
    end
    save(fullfile(matsimnibs_folder, strcat(mesh_model, '_angle_', num2str(rad2deg(radian)), '.mat')), 'matsimnibs')
    
    % Run SimNIBS
    S                              = sim_struct('SESSION'); % start simulation session 
    S.fnamehead                    = fnamehead;             % define I/O
    S.pathfem                      = pathfem;               
    S.fields                       = 'eE';                  % simulation output fields
    S.poslist{1}                   = sim_struct('TMSLIST'); % select simulation mode
    S.poslist{1}.fnamecoil         = params.fnamecoil;      % coil path
    S.poslist{1}.pos(1).matsimnibs = matsimnibs;            % coil's affine transformation matrix                                  
    S.poslist{1}.pos(1).didt       = params.mso * params.ccr * 1000000; % stimulation intensity
    run_simnibs(S)
end