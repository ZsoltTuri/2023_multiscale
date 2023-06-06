dpath <- file.path('data', 'auxiliary', 'mesh_dimensions')
files <- list.files(dpath, pattern = "*.mat")
data <- NULL
for(file in files){
  d <- NULL
  d <- readMat(file.path(dpath, file))
  df <- data.frame('mesh' = factor(unlist(str_split(file, '_'))[1]),
                   'compartment' = unlist(c(d$dimension[1], d$dimension[6])),
                   'gyrus_height' = unlist(c(d$dimension[5], d$dimension[10])))
  data <- rbind(data, df)
}
aux_gyrus_height <- data
rm(data, df, d, file, dpath, files)