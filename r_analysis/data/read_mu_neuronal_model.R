# Read in multiscale-modleing data
dpath <- file.path('data', 'multiscale', 'main', 'neuronal_model')
files <- list.files(dpath,  pattern = "^m")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = TRUE)
  d <- d %>% dplyr::mutate('mesh' = factor(unlist(str_split(file, '_'))[1]),
                           'neuronal_model' = unlist(str_split(file, '_'))[5],
                           'activation_threshold' = threshold)
  data <- rbind(data, d)
}
mu_neuronal_model <- data %>% dplyr::select(c(mesh, neuronal_model, activation_threshold))
rm(data, d, file, dpath, files)

# Read in activation E-field data
dpath <- file.path('data', 'multiscale', 'main', 'neuronal_model')
files <- list.files(dpath,  pattern = "*scaled_efields.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = FALSE)
  colnames(d) <- 'activation_efield'
  d <- d %>% dplyr::mutate('neuronal_model' = unlist(str_split(file, '_'))[2])
  data <- rbind(data, d)
}
mu_neuronal_model_actefield <- data %>% dplyr::select(c(neuronal_model, activation_efield))
rm(data, d, file, dpath, files)

# Read in Boolean variable (fired/not fired) related to activation E-field data
dpath <- file.path('data', 'multiscale', 'main', 'neuronal_model')
files <- list.files(dpath,  pattern = "*scaled_efields_fired.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = FALSE)
  colnames(d) <- 'activated'
  data <- rbind(data, d)
}
mu_neuronal_model_actefield <- mu_neuronal_model_actefield %>% dplyr::mutate('activated' = data$activated)
rm(data, d, file, dpath, files)