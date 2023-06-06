#################
# GYRAL HEIGHT #
################

library(ProjectTemplate)
load.project()

# Fraction of activated cells ----
d <- mu_gyral_height %>% dplyr::count(height)
d$activated_cells <- mu_gyral_height %>% dplyr::filter(activation_threshold < 101) %>% dplyr::count(height) %>% dplyr::pull(n)
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d

# Figure
ggplot(data = d, aes(x = height, y = percent, fill = height)) + 
  geom_segment(aes(x = height, xend = height, y = 0, yend = percent)) +
  geom_point(shape = 21, size = 3, stroke = 1) +
  scale_fill_steps(n.breaks = 5) + #scale_fill_viridis_c(option = "G", direction = -1) +
  labs(x = "Gyral height (mm)", y = "Activated cells (%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 50, by = 10)) +
  coord_cartesian(ylim = c(0, 50)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_5/A.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 55, units = "mm", dpi = 300)

# GLM with binomial distribution
data <- mu_gyral_height %>% dplyr::mutate(height = factor(height),
                                          activated = case_when(activation_threshold < 101 ~ 1,
                                                                activation_threshold == 101 ~ 0,
                                                                TRUE ~ NA_real_))
data <- within(data, 
               height <- relevel(height, ref = "14"))
mod0 <- glm(activated ~ 1, family = binomial, data = data) 
mod1 <- glm(activated ~ height, family = binomial, data = data)
summary(mod0)
summary(mod1)
summary(mod1)$coefficients
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# Activation threshold (of activated cells)  ----
mu_gyral_height %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(height) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
ggplot(data = mu_gyral_height %>% dplyr::filter(activation_threshold < 101), aes(x = height, y = activation_threshold, color = height)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.05) +
  labs(x = "Gyral height (mm)", y = "Intensity (MSO%)") +
  scale_y_continuous(breaks = seq(from = 40, to = 100, by = 20)) +
  coord_cartesian(ylim = c(40, 110)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_5/B.", format, sep = ""), plot = last_plot(), 
       width = 70, height = 55, units = "mm", dpi = 300)
# GLM with Poisson 
data <- mu_gyral_height %>% dplyr::filter(activation_threshold < 101) %>% dplyr::mutate(height = factor(height))
data <- within(data, 
               height <- relevel(height, ref = "14"))
mod0 <- glm(activation_threshold ~ 1, family = poisson(link = "log"), data = data) 
mod1 <- glm(activation_threshold ~ factor(height), family = poisson(link = "log"), data = data) 
summary(mod0) # <- winning model
summary(mod1)# AIC no difference!!
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)


