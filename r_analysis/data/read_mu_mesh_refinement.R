dpath <- file.path('data', 'multiscale', 'control', 'mesh_refinement')
files <- list.files(dpath, pattern = "*.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = TRUE)
  d <- d %>% dplyr::mutate('mesh' = factor(unlist(str_split(file, '_'))[1]),
                           'threshold' = as.numeric(threshold))
  data <- rbind(data, d)
}
mu_control_mesh_refinement <- data %>% dplyr::select(c(mesh, threshold))
rm(data, d, file, dpath, files)