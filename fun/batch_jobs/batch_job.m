function batch_job(batch) 
linux_sep = '/';
space = 32;
fname = strcat(batch.pc_path, '\\', batch.name);
fid = fopen(fname, 'wt');
fprintf(fid, '#!/bin/bash \n');
fprintf(fid, '########## Begin Slurm header ########## \n');
fprintf(fid, '# Job name \n');
fprintf(fid, strcat('#SBATCH --job-name=', batch.job_name, '\n'));
fprintf(fid, '# Requested number of nodes \n');
fprintf(fid, strcat('#SBATCH --nodes=', batch.nodes, '\n'));
fprintf(fid, '# Requested number of tasks \n');
%fprintf(fid, strcat('#SBATCH --ntasks=', batch.tasks, '\n'));
%fprintf(fid, '# Requested number of task per node \n');
fprintf(fid, strcat('#SBATCH --ntasks-per-node=', batch.tasks_nodes, '\n'));
fprintf(fid, '# Requested memory \n');
fprintf(fid, strcat('#SBATCH --mem=', batch.memory, 'gb \n'));
fprintf(fid, '# Estimated wallclock time for job \n');
fprintf(fid, strcat('#SBATCH --time=', batch.wallclock, '\n'));
if sum(strcmp(fieldnames(batch), 'array')) == 1
    fprintf(fid, '# Define arrayjobs \n');
    fprintf(fid, strcat('#SBATCH --array=', batch.array, '\n'));
end
fprintf(fid, '# Specify queue class \n');
fprintf(fid, '#SBATCH --partition=single \n');
fprintf(fid, '# Send mail when job begins, aborts and ends \n');
fprintf(fid, '#SBATCH --mail-type=ALL \n');
fprintf(fid, '########### End Slurm header ########## \n');

fprintf(fid, strcat('echo "Submit Directory:', space, '$SLURM_SUBMIT_DIR" \n'));
fprintf(fid, strcat('echo "Working Directory:', space,  '$PWD" \n'));
fprintf(fid, strcat('echo "Running on host:', space, '$HOSTNAME" \n'));
fprintf(fid, strcat('echo "Job id:',  space, '$SLURM_JOB_ID" \n'));
fprintf(fid, strcat('echo "Job name:', space, '$SLURM_JOB_NAME" \n'));
fprintf(fid, strcat('echo "Number of nodes dedicated to the job:', space, '$SLURM_JOB_NUM_NODES" \n'));
fprintf(fid, strcat('echo "Memory per node dedicated to the job:', space, '$SLURM_MEM_PER_NODE" \n'));
fprintf(fid, strcat('echo "Total number of processes dedicated to the job:', space, '$SLURM_NPROCS" \n'));
fprintf(fid, strcat('echo "The total number of tasks available for the job:', space, '$SLURM_NTASKS" \n'));
fprintf(fid, strcat('echo "Number of requested tasks per node:', space, '$SLURM_NTASKS_PER_NODE" \n'));
fprintf(fid, strcat('echo "Number of processes per node dedicated to the job:', space, '$SLURM_JOB_CPUS_PER_NODE" \n'));

fprintf(fid, strcat('cd', space, batch.hpc_path, linux_sep, 'src', space, '\n')); 
fprintf(fid, strcat('ml', space, strcat('math', linux_sep, 'matlab', linux_sep, 'R2020b \n')));
if sum(strcmp(fieldnames(batch), 'array')) == 1
    fprintf(fid, strcat('matlab –nodesktop -nodisplay -batch', space, '"', batch.job_name, '(${SLURM_ARRAY_TASK_ID})"', '\n'));
else
    fprintf(fid, strcat('matlab –nodesktop -nodisplay -batch', space, '"', batch.job_name, '"', '\n'));
end
fclose(fid);
end 