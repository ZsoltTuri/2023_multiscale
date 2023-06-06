##################
# NEURONAL DEPTH #
#################

library(ProjectTemplate)
load.project()

# Fraction of activated cells ----
str(mu_neuronal_depth)
min(mu_neuronal_depth$activation_threshold)
d <- mu_neuronal_depth %>% dplyr::count(neuronal_depth)  
d$activated_cells <- mu_neuronal_depth %>% dplyr::filter(activation_threshold < 101) %>% dplyr::count(neuronal_depth) %>% dplyr::pull(n)
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d
ggplot(data = d, aes(x = neuronal_depth, y = percent, fill = neuronal_depth)) + 
  geom_segment(aes(x = neuronal_depth, xend = neuronal_depth, y = 0, yend = percent)) +
  geom_point(shape = 21, size = 3, stroke = 1) +
  labs(x = "Neuronal depth (mm)", y = "Activated cells (%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 50, by = 10)) +
  coord_cartesian(ylim = c(0, 50)) +
  scale_fill_brewer(palette = "Blues", direction = -1) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_5/D.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 55, units = "mm", dpi = 300)

# GLM with binomial distribution
data <- mu_neuronal_depth %>% dplyr::mutate(neuronal_depth = factor(neuronal_depth),
                                                    activated = case_when(activation_threshold < 101 ~ 1,
                                                                          activation_threshold == 101 ~ 0,
                                                                          TRUE ~ NA_real_))
data <- within(data, 
               neuronal_depth <- relevel(neuronal_depth, ref = "3.25"))
mod0 <- glm(activated ~ 1, family = binomial, data = data) 
mod1 <- glm(activated ~ neuronal_depth, family = binomial, data = data) 
summary(mod0)
summary(mod1)
summary(mod1)$coefficients
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# Activation threshold (of activated cells) ----
ggplot(data =  mu_neuronal_depth %>% dplyr::filter(activation_threshold < 101), aes(x = neuronal_depth, y = activation_threshold, color = neuronal_depth)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.05) +
  labs(x = "Neuronal depth (mm)", y = "Intensity (MSO%)") +
  scale_y_continuous(breaks = seq(from = 40, to = 100, by = 20)) +
  coord_cartesian(ylim = c(40, 110)) +
  scale_color_brewer(palette = "Blues", direction = -1) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_5/E.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 55, units = "mm", dpi = 300)
mu_neuronal_depth %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(neuronal_depth) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
data <- mu_neuronal_depth %>% dplyr::filter(activation_threshold < 101)
data <- data %>% dplyr::mutate(neuronal_depth = factor(neuronal_depth))
data <- within(data, neuronal_depth <- relevel(neuronal_depth, ref = "3.25"))
mod0 <- glm(activation_threshold ~ 1, family = poisson(link = "log"), data = data) 
mod1 <- glm(activation_threshold ~ factor(neuronal_depth), family = poisson(link = "log"), data = data) 
summary(mod0)
summary(mod1)
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)
