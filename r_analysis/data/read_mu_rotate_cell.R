dpath <- file.path('data', 'multiscale', 'main','rotate_cell')
files <- list.files(dpath,  pattern = "*.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = TRUE)
  d <- d %>% dplyr::mutate('mesh' = factor(unlist(str_split(file, '_'))[1]), 
                           'coil_angle' = unlist(str_split(file, '_'))[3],
                           'y_angle' = unlist(str_split(file, '_'))[12] %>% as.numeric(),
                           'neuronal_model' =  factor(unlist(str_split(file, '_'))[5]),
                           'activation_threshold' = threshold)
  data <- rbind(data, d)
}
mu_rotate_cell <- data %>% dplyr::select(c(mesh, coil_angle, y_angle, neuronal_model, activation_threshold))
rm(data, d, file, dpath, files)