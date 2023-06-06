function init_local(workspace)
    addpath(genpath(fullfile(workspace, 'fun')));
    addpath(genpath(fullfile('C:', 'Prg-Win', 'SimNIBS-3.2', 'matlab')));
    addpath('C:\Prg-Win\2022_cortical_folding_hpc\nemo\Model_Generation\TMS_package\E-Field_Coupling');
    cd(workspace);
end