library(ProjectTemplate)
load.project()

d <- mu_control_coil_angle %>% dplyr::group_by(neuronal_model) %>% dplyr::count(coil_angle)  
d$activated_cells <- mu_control_coil_angle %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(neuronal_model) %>% dplyr::count(coil_angle) %>% dplyr::pull(n) 
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d
ggplot(data = d, aes(x = coil_angle, y = percent, fill = coil_angle)) + 
  facet_grid(rows = vars(neuronal_model)) +
  geom_col(color = 'black') +
  scale_fill_brewer("Blues") +
  labs(x = "Coil angle", y = "Activated cells (%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 50, by = 10)) +
  coord_cartesian(ylim = c(0, 50)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S4/A.", format, sep = ""), plot = last_plot(), 
       width = 100, height = 85, units = "mm", dpi = 300)
# GLM with binomial distribution
data <- mu_control_coil_angle %>% dplyr::mutate(activated = case_when(activation_threshold < 101 ~ 1,
                                                                      activation_threshold == 101 ~ 0,
                                                                      TRUE ~ NA_real_),
                                                neuronal_model = as.numeric(neuronal_model))

# L23
mod0 <- glm(activated ~ 1, family = binomial, data = data %>% dplyr::filter(neuronal_model == "1")) 
mod1 <- glm(activated ~ coil_angle, family = binomial,data %>% dplyr::filter(neuronal_model == "1")) 
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# L5
mod0 <- glm(activated ~ 1, family = binomial, data = data %>% dplyr::filter(neuronal_model == "2")) 
mod1 <- glm(activated ~ coil_angle, family = binomial,data %>% dplyr::filter(neuronal_model == "2")) 
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# Activated cells: Activation threshold 
ggplot(data =  mu_control_coil_angle %>% dplyr::filter(activation_threshold < 101), aes(x = coil_angle, y = activation_threshold, color = as.numeric(coil_angle))) + 
  facet_grid(rows = vars(neuronal_model)) +
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.5) +
  labs(x = "", y = "Intensity (MSO%)") +
  scale_color_steps(n.breaks = 9, trans = 'reverse') +
  scale_y_continuous(breaks = seq(from = 40, to = 100, by = 20)) +
  coord_cartesian(ylim = c(40, 110)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S4/B.", format, sep = ""), plot = last_plot(), 
       width = 100, height = 85, units = "mm", dpi = 300)
mu_control_coil_angle %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(coil_angle) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()

data <- mu_control_coil_angle %>% dplyr::filter(activation_threshold < 101) %>% dplyr::mutate(neuronal_model = as.numeric(neuronal_model))
data <- within(data, 
               coil_angle <- relevel(coil_angle, ref = "90"))

# L23
mod0 <- glm(activation_threshold ~ 1, family = poisson(link = "log"), data = data %>% dplyr::filter(neuronal_model == "1")) 
mod1 <- glm(activation_threshold ~ factor(coil_angle), family = poisson(link = "log"), data = data %>% dplyr::filter(neuronal_model == "1")) 
anova(mod0, mod1)
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# L5
mod0 <- glm(activation_threshold ~ 1, family = poisson(link = "log"), data = data %>% dplyr::filter(neuronal_model == "2")) 
mod1 <- glm(activation_threshold ~ factor(coil_angle), family = poisson(link = "log"), data = data %>% dplyr::filter(neuronal_model == "2")) 
anova(mod0, mod1)
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)
