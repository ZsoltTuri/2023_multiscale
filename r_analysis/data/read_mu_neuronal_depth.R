dpath <- file.path('data', 'multiscale', 'main','neuronal_depth')
files <- list.files(dpath,  pattern = "*.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = TRUE)
  d <- d %>% dplyr::mutate('mesh' = factor(unlist(str_split(file, '_'))[1]), 
                           'neuronal_model' = unlist(str_split(file, '_'))[5],
                           'neuronal_depth' = unlist(str_split(file, '_'))[8],
                           'activation_threshold' = threshold)
  data <- rbind(data, d)
}
mu_neuronal_depth <- data %>% dplyr::select(c(mesh, neuronal_model, neuronal_depth, activation_threshold))
rm(data, d, file, dpath, files)