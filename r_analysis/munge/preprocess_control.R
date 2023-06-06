# ROI size -------
mesh_roi_size <- mesh_roi_size %>% dplyr::mutate('mesh' = as.factor(mesh),
                                                 'coil_angle' = as.integer(coil_angle),
                                                 'coil_angle_corrected' = case_when(coil_angle <= 255 ~ coil_angle + 90,
                                                                                    coil_angle >= 270 ~ abs(270 - coil_angle),
                                                                                    TRUE ~ NA_real_))
mesh_roi_size$coil_angle_corrected <- factor(mesh_roi_size$coil_angle_corrected,
                                             levels = c(90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, 255, 270, 285, 300, 315, 330, 345, 0, 15, 30, 45, 60, 75))