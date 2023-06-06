function action_potential = get_neuronal_response(var)
    cd(var.code_path);
    system('nrniv -nogui -NSTACK 100000 -NFRAME 20000 -Py_NoSiteFlag TMS_script.hoc');
    file = fullfile(var.sim_path, 'fired.txt');
    wait_for_saving_file(file)
    action_potential = load(file);
    delete(file); 
    wait_for_deleting_file(file);
end