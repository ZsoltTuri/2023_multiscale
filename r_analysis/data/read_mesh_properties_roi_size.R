dpath <- file.path('data', 'mesh_properties', 'roi_sizes')
meshes <- list.files(dpath)
data <- NULL
for (mesh in meshes){
  files <- list.files(file.path(dpath, mesh), pattern = "*.mat")
  for(file in files){
    d <- NULL
    d <- readMat(file.path(dpath, mesh, file))
    d <- matrix(unlist(d), nrow = length(d), byrow = TRUE) %>% as.data.frame(.)
    d <- data.frame('mesh' = unlist(str_split(file, '_'))[1],
                    'coil_angle' = unlist(str_split(file, '_'))[3],
                    'roi_size' = matrix(unlist(d), nrow = length(d), byrow = TRUE))
    data <- rbind(data, d)
  }
}
mesh_roi_size <- data
rm(data, d, file, dpath, files, mesh, meshes)