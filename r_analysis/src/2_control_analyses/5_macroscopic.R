library(ProjectTemplate)
load.project()

max <- 1.6 
min <- 1.2

# Figures -----

# Shape 
d <- ma_vol %>% dplyr::group_by(shape) %>% dplyr::summarise_at(vars(weighted_mean), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
ggplot(data = d, aes(x = shape, y = mean, fill = shape)) + 
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2, position = position_dodge(0.9)) +
  geom_point(shape = 21, size = 2, stroke = 1) +
  labs(x = "Gyral shape", y = "E-field (V/m)") +
  scale_y_continuous(breaks = seq(from = min, to = max, by = 0.1)) +
  scale_fill_manual(values = c(c1, c2)) +
  coord_cartesian(ylim = c(min, max)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S5/C.", format, sep = ""), plot = last_plot(), 
       width = 45, height = 55, units = "mm", dpi = 300)

# Thickness
d <- ma_vol %>% dplyr::group_by(thickness) %>% dplyr::summarise_at(vars(weighted_mean), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
ggplot(data = d, aes(x = thickness, y = mean, fill = thickness)) + 
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2, position = position_dodge(0.9)) +
  geom_point(shape = 21, size = 2, stroke = 1) +
  labs(x = "Cortical thickness (mm)", y = "E-field (V/m)")+
  scale_x_continuous(breaks = seq(from = 1.5, to = 4.5, by = 0.5)) +
  scale_y_continuous(breaks = seq(from = min, to = max, by = 0.1)) +
  scale_fill_viridis_c(option = "D", direction = -1) +
  coord_cartesian(ylim = c(min, max)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S5/D.", format, sep = ""), plot = last_plot(), 
       width = 85, height = 55, units = "mm", dpi = 300)

# Height
d <- ma_vol %>% dplyr::group_by(height) %>% dplyr::summarise_at(vars(weighted_mean), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
ggplot(data = d, aes(x = height, y = mean, fill = height)) + 
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2, position = position_dodge(0.9)) +
  geom_point(shape = 21, size = 2, stroke = 1) +
  labs(x = "Gyral height (mm)", y = "E-field (V/m)")+
  scale_y_continuous(breaks = seq(from = min, to = max, by = 0.1)) +
  scale_fill_viridis_c(option = "G", direction = -1) +
  coord_cartesian(ylim = c(min, max)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S5/E.", format, sep = ""), plot = last_plot(), 
      width = 65, height = 55, units = "mm", dpi = 300)

# Coil angles
d <- ma_vol %>% dplyr::group_by(coil_angle_corrected) %>% dplyr::summarise_at(vars(weighted_mean), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
ggplot(data = d, aes(x = factor(coil_angle_corrected), y = mean, fill = coil_angle_corrected)) + 
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2, position = position_dodge(0.9)) +
  geom_point(shape = 21, size = 2, stroke = 1) + 
  scale_fill_viridis_d(option = "C") +
  labs(x = "Coil angles (degree)", y = "E-field (V/m)") +
  scale_y_continuous(breaks = seq(from = min, to = max, by = 0.1)) +
  coord_cartesian(ylim = c(min, max)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12),
        axis.text.x = element_text(angle = 30, hjust = 1),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S5/F.", format, sep = ""), plot = last_plot(), 
       width = 205, height = 65, units = "mm", dpi = 300)


# Statistical analysis --------------------------------------------------------------------------------------------------------------------------------------------
data <- ma_vol
data <- within(data, 
               coil_angle_corrected <- relevel(coil_angle_corrected, ref = "0"))

# Generalized linear model
mod0 <- lmerTest::lmer(weighted_mean ~ (1|mesh), data = data) 
mod1 <- lmerTest::lmer(weighted_mean ~ (1|mesh) + thickness, data = data) 
mod2 <- lmerTest::lmer(weighted_mean ~ (1|mesh) + height, data = data) 
mod3 <- lmerTest::lmer(weighted_mean ~ (1|mesh) + shape, data = data) 
mod4 <- lmerTest::lmer(weighted_mean ~ (1|mesh) + coil_angle_corrected, data = data) 
anova(mod0, mod1)
anova(mod0, mod2)
anova(mod0, mod3)
anova(mod0, mod4)
#anova(mod1) #n.s.
anova(mod1)
anova(mod2)
anova(mod3)
anova(mod4)

# Alternative statistical analysis -------
# Linear model 
mod0 <- lm(weighted_mean ~ 1, data = data) 
mod1 <- lm(weighted_mean ~ thickness, data = data) 
mod2 <- lm(weighted_mean ~ height, data = data) 
mod3 <- lm(weighted_mean ~ shape, data = data) 
mod4 <- lm(weighted_mean ~ coil_angle_corrected, data = data) 
anova(mod0, mod1, mod2, mod3, mod4)
anova(mod1)