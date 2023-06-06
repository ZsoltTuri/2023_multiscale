dpath <- file.path('data', 'multiscale', 'control', 'synaptic_weight')
files <- list.files(dpath,  pattern = "*.xlsx")
data <- NULL
for(file in files){
  d <- NULL
  d <- readxl::read_excel(file.path(dpath, file), col_names = TRUE)
  d <- d %>% dplyr::mutate('neuronal_model' = factor(unlist(str_split(file, '_'))[5]),
                           'syn_weight' = as.numeric(unlist(str_split(file, '_'))[10]),
                           'activation_threshold' = as.numeric(threshold))
  data <- rbind(data, d)
}
mu_control_synaptic_weight <- data
rm(data, d, file, dpath, files)