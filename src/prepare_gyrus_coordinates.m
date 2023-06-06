clear; close; clc;
params              = struct();
params.repository   = '2022_cortical_folding_hpc';
params.workspace    = fullfile('', params.repository); % please set
run(fullfile(params.workspace, 'src', 'init_local(params.workspace).m'));

svg = 'mushroom_18mm.svg';
filename = fullfile(params.workspace, 'inkscape', 'dots_only', svg);
coordinates = extract_svg_coordinates(filename);
save(fullfile(params.workspace, 'inkscape', 'coordinates', strcat(svg(1:end-4), '.mat')), 'coordinates');
writematrix(coordinates, fullfile(params.workspace, 'inkscape', 'coordinates', strcat(svg(1:end-4), '.txt')));