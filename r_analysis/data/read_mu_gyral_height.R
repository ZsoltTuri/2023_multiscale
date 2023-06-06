dpath <- file.path('data', 'multiscale', 'main', 'gyral_height')
files <- list.files(dpath,  pattern = "*.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = TRUE)
  d <- d %>% dplyr::mutate('mesh' = factor(unlist(str_split(file, '_'))[1]), 
                           'neuronal_model' = unlist(str_split(file, '_'))[5],
                           'activation_threshold' = threshold)
  data <- rbind(data, d)
}
mu_gyral_height <- data %>% dplyr::select(c(mesh, neuronal_model, activation_threshold))
rm(data, d, file, dpath, files)