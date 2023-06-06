library(ProjectTemplate)
load.project()


# Fraction of activated cells ----
str(mu_control_synaptic_weight)
min(mu_control_synaptic_weight$activation_threshold)
d <- mu_control_synaptic_weight %>% dplyr::count(syn_weight)
d$activated_cells <- mu_control_synaptic_weight %>% dplyr::filter(activation_threshold < 101) %>% dplyr::count(syn_weight) %>% dplyr::pull(n)
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d
ggplot(data = d, aes(x = syn_weight, y = percent, fill = syn_weight)) + 
  geom_col() +
  scale_fill_steps(n.breaks = 9, trans = 'reverse') +
  labs(x = "Synaptic weight (a.u.)", y = "Activated cells (%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 70, by = 10)) +
  scale_x_continuous(breaks = seq(from = 0.1, to = 0.9, by = 0.1)) +
  coord_cartesian(ylim = c(0, 70)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/s2/A.", format, sep = ""), plot = last_plot(), 
       width = 100, height = 65, units = "mm", dpi = 300)

# GLM with binomial distribution
data <- mu_control_synaptic_weight %>% dplyr::mutate(syn_weight = factor(syn_weight),
                                                     activated = case_when(activation_threshold < 101 ~ 1,
                                                                           activation_threshold == 101 ~ 0,
                                                                           TRUE ~ NA_real_))
data <- within(data, 
               syn_weight <- relevel(syn_weight, ref = "0.1"))
mod0 <- glm(activated ~ 1, family = binomial, data = data) 
mod1 <- glm(activated ~ syn_weight, family = binomial, data = data) 
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# Activation threshold
ggplot(data =  mu_control_synaptic_weight %>% dplyr::filter(activation_threshold < 101), aes(x = syn_weight, y = activation_threshold, color = syn_weight)) + 
  geom_jitter(alpha = 0.25) +
  scale_color_steps(n.breaks = 9, trans = 'reverse') +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.5) +
  labs(x = "Synaptic weight (a.u.)", y = "Intensity (MSO%)") +
  scale_x_continuous(breaks = seq(from = 0.1, to = 0.9, by = 0.1)) +
  scale_y_continuous(breaks = seq(from = 40, to = 100, by = 20)) +
  coord_cartesian(ylim = c(40, 110)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/s2/B.", format, sep = ""), plot = last_plot(), 
       width = 100, height = 65, units = "mm", dpi = 300)
mu_control_synaptic_weight %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(coil_angle) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
data <- mu_control_synaptic_weight %>% dplyr::filter(activation_threshold < 101)
data <- within(data, 
               syn_weight <- relevel(syn_weight, ref = "0.9"))
mod0 <- glm(activation_threshold ~ 1, family = poisson(link = "log"), data = data) 
mod1 <- glm(activation_threshold ~ factor(syn_weight), family = poisson(link = "log"), data = data) 
anova(mod0, mod1)
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)
