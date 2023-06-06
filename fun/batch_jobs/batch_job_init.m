function batch_job_init(batch)
    linux_sep = '/';
    space = 32;
    fname = strcat(batch.pc_path, '\\', batch.name);
    fid = fopen(fname, 'wt');
    fprintf(fid, '#!/bin/bash \n');
    fprintf(fid, strcat('cd', space, batch.hpc_path, ' \n')); 
    % fprintf(fid, 'rm *.out \n');
    fprintf(fid, 'git stash \n');
    fprintf(fid, 'git pull origin main \n');
    for ii = 1:length(batch.jobs)
        job = batch.jobs{ii, 1};
        fprintf(fid, strcat('dos2unix batch_jobs/', job, '.sh \n'));
        fprintf(fid, strcat('chmod +x batch_jobs/', job, '.sh \n'));
    end
    fprintf(fid, strcat('cd', space, batch.hpc_path, linux_sep, 'nemo', linux_sep, 'Model_Generation', linux_sep, 'Aberra_files', linux_sep, 'lib_mech', linux_sep, '\n'));
    fprintf(fid, strcat('nrnivmodl', '\n'));
    fprintf(fid, strcat('cd', space, batch.hpc_path, ' \n'));
    fclose(fid);
end 