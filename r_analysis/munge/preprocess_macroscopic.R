preprocess_df <- function(df){
  df <- df %>% dplyr::select(-roi_type)
  df <- df %>% dplyr::mutate('mesh' = as.factor(mesh),
                             'shape' = as.factor(shape),
                             'height' = as.numeric(height),
                             'thickness' = as.numeric(thickness),
                             'element' = as.factor(element),
                             'field_type' = factor(field_type, levels = c("E_tot", "E_tan", "E_per")),
                             'compartment' = as.factor(compartment),
                             'coil_angle' = as.integer(coil_angle),
                             'coil_angle_corrected' = case_when(coil_angle <= 255 ~ coil_angle + 90,
                                                                coil_angle >= 270 ~ abs(270 - coil_angle),
                                                                TRUE ~ NA_real_))
  df$coil_angle_corrected <- factor(df$coil_angle_corrected,
                                    levels = c(90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, 255, 270, 285, 300, 315, 330, 345, 0, 15, 30, 45, 60, 75))
  df <- df %>% dplyr::select(mesh, shape, height, thickness, coil_angle, coil_angle_corrected, element, field_type, compartment, weighted_mean, mean)
  return(df)
}
ma_sur <- preprocess_df(ma_sur)
ma_vol <- preprocess_df(ma_vol)