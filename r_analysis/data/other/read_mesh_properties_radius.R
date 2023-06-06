dpath <- file.path('data', 'auxiliary', 'mesh_dimensions')
files <- list.files(dpath, pattern = "*.mat")
data <- NULL
for(file in files){
  d <- NULL
  d <- readMat(file.path(dpath, file))
  df <- data.frame('mesh' = factor(unlist(str_split(file, '_'))[1]),
                   'compartment' = unlist(c(d$dimension[1], d$dimension[6], d$dimension[11], d$dimension[16], d$dimension[21])),
                   'radius' = unlist(c(d$dimension[3], d$dimension[8], d$dimension[13], d$dimension[18], d$dimension[23])))
  data <- rbind(data, df)
}
aux_mesh_radius <- data
rm(data, df, d, file, dpath, files)