function create_color_table_for_gmsh(cmap)
    fid = fopen(fullfile(cmap.path, cmap.name), 'w');
    fprintf(fid, 'View[1].ColorTable = { \n');
    for i = 1:length(cmap.gmsh) - 1
        fprintf(fid, strcat('{', num2str(cmap.gmsh(i, 1)), ',', num2str(cmap.gmsh(i, 2)), ',', num2str(cmap.gmsh(i, 3)), '}, \n'));
    end
    fprintf(fid, strcat('{', num2str(cmap.gmsh(end, 1)), ',', num2str(cmap.gmsh(end, 2)), ',', num2str(cmap.gmsh(end, 3)), '} \n'));
    fprintf(fid, '};');

    fprintf(fid, 'View[2].ColorTable = { \n');
    for i = 1:length(cmap.gmsh) - 1
        fprintf(fid, strcat('{', num2str(cmap.gmsh(i, 1)), ',', num2str(cmap.gmsh(i, 2)), ',', num2str(cmap.gmsh(i, 3)), '}, \n'));
    end
    fprintf(fid, strcat('{', num2str(cmap.gmsh(end, 1)), ',', num2str(cmap.gmsh(end, 2)), ',', num2str(cmap.gmsh(end, 3)), '} \n'));
    fprintf(fid, '};');
    fclose(fid);
end