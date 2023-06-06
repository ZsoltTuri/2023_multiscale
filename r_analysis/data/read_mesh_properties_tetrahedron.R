dpath <- file.path('data', 'mesh_properties', 'tetrahedron')
folders <- list.files(dpath)
data <- NULL
for (folder in folders){
  file <- list.files(file.path(dpath, folder), pattern = "*volume_properties.mat")
  d <- NULL
  d <- readMat(file.path(dpath, folder, file))
  df <- data.frame('mesh' = factor(unlist(str_split(file, '_'))[1]),
                   'compartment' = factor(c('WM', 'GM', 'WM', 'GM')),
                   'type' = factor(c('ROI', 'ROI', 'NON-ROI', 'NON-ROI')),
                   'tet_vol' = unlist(c(d$mesh.property[5], d$mesh.property[11], d$mesh.property[17], d$mesh.property[23])),
                   'tet_edge_len' = unlist(c(d$mesh.property[6], d$mesh.property[12], d$mesh.property[18], d$mesh.property[24])))
  data <- rbind(data, df)
}
mesh_tetrahedron <- data %>% dplyr::filter(type == 'ROI' & compartment == 'GM')
rm(data, df, d, file, dpath, folder, folders)
