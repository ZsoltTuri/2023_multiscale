# Gyral shape
mu_gyral_shape <- rbind(mu_gyral_shape, mu_neuronal_model %>% dplyr::filter(neuronal_model == 'L5')) %>% dplyr::mutate('shape' = case_when(mesh == 'm-031' ~ 'Sine',
                                                                                                                                           mesh == 'm-038' ~ 'Mushroom',
                                                                                                                                           TRUE ~ as.character(NA)))
temp <- mu_neuronal_model_actefield %>% dplyr::filter(neuronal_model == 'L5') %>% dplyr::mutate('shape' = 'Sine') %>% dplyr::select(shape, activation_efield, activated)
mu_gyral_shape_actefield <- rbind(mu_gyral_shape_actefield, temp)
rm(temp)

# Gyral height
mu_gyral_height <- mu_gyral_height %>% dplyr::mutate('height' = case_when(mesh == 'm-003' ~ 14,
                                                                          mesh == 'm-017' ~ 15,
                                                                          mesh == 'm-031' ~ 16,
                                                                          mesh == 'm-045' ~ 17,
                                                                          mesh == 'm-059' ~ 18,
                                                                          TRUE ~ NA_real_))

# Coil angle
temp <- mu_neuronal_model %>% dplyr::mutate('coil_angle' = '0') %>% dplyr::select(mesh, coil_angle, neuronal_model, activation_threshold)
mu_control_coil_angle <- rbind(temp, mu_control_coil_angle) %>% dplyr::mutate(coil_angle = dplyr::recode_factor(coil_angle, `0` = "90", `15` = "+15", `30` = "+30", `45` = "+45", `60` = "+60", `75` = "+75", `90` = "+90", `180` = "+180"),
                                                                              neuronal_model = factor(neuronal_model))
rm(temp)


# Neuronal morphology
mu_control_neuronal_morphology <- within(mu_control_neuronal_morphology, 
                                         neuronal_model <- relevel(neuronal_model, ref = "L5b"))
mu_control_neuronal_morphology_actefield <- within(mu_control_neuronal_morphology_actefield, 
                                                   neuronal_model <- relevel(neuronal_model, ref = "L5b"))