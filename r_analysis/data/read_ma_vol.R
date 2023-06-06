dpath <- file.path('data', 'macroscopic')
meshes <- list.files(dpath)
data <- NULL
for (mesh in meshes){
  files <- list.files(file.path(dpath, mesh, 'volume'), pattern = "*.xlsx")
  for(file in files){
    d <- NULL
    d <- readxl::read_excel(file.path(dpath, mesh, 'volume', file), col_names = TRUE)
    d <- d %>% dplyr::mutate('mesh' = unlist(str_split(file, '_'))[1],
                             'shape' = unlist(str_split(file, '_'))[3],
                             'height' = unlist(str_split(file, '_'))[5],
                             'thickness' = unlist(str_split(file, '_'))[7],
                             'coil_angle' = unlist(str_split(file, '_'))[9])
    data <- rbind(data, d)
  }
}
ma_vol <- data
rm(data, d, file, dpath, files, mesh, meshes)