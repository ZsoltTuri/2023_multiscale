#######################################
# ROTATE CELL / NEURONAL ORIENTATION #
######################################

library(ProjectTemplate)
load.project()

# Fraction of activated cells ----
str(mu_rotate_cell)
range(mu_rotate_cell$y_angle)
d <- mu_rotate_cell %>% dplyr::count(y_angle)
d$activated_cells <- mu_rotate_cell %>% dplyr::filter(activation_threshold < 101) %>% dplyr::count(y_angle) %>% dplyr::pull(n)
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d
range(d$percent)
41.38/20.74

ggplot(data = d, aes(x = y_angle, y = percent, fill = y_angle)) + 
  geom_segment(aes(x = y_angle, xend = y_angle, y = 0, yend = percent)) +
  geom_point(shape = 21, size = 3, stroke = 1) +
  labs(x = "", y = "Activated cells (%)") +
  scale_x_continuous(breaks = seq(from = 0, to = 330, by = 30)) +
  coord_cartesian(ylim = c(0, 50)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 10), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_4/B.", format, sep = ""), plot = last_plot(), 
       width = 100, height = 55, units = "mm", dpi = 300)


# GLM with binomial distribution
data <- mu_rotate_cell %>% dplyr::mutate(y_angle = factor(y_angle),
                                         activated = case_when(activation_threshold < 101 ~ 1,
                                                               activation_threshold == 101 ~ 0,
                                                                TRUE ~ NA_real_))
mod0 <- glm(activated ~ 1, family = binomial, data = data) 
mod1 <- glm(activated ~ y_angle, family = binomial, data = data) 
summary(mod0)
summary(mod1)
summary(mod1)$coefficients
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj)

# Activation threshold (of activated cells) ----
ggplot(data =  mu_rotate_cell %>% dplyr::filter(activation_threshold < 101), aes(x = y_angle, y = activation_threshold, color = y_angle, fill = y_angle)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.05) +
  labs(x = "", y = "Intensity (MSO%)") +
  scale_y_continuous(breaks = seq(from = 40, to = 100, by = 20)) +
  scale_x_continuous(breaks = seq(from = 0, to = 330, by = 30)) +
  coord_cartesian(ylim = c(40, 100)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 10), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_4/C.", format, sep = ""), plot = last_plot(), 
       width = 100, height = 55, units = "mm", dpi = 300)
mu_rotate_cell %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(y_angle) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()

data <- data %>% dplyr::filter(activation_threshold < 101)
mod0 <- glm(activation_threshold ~ 1, family = poisson(link = "log"), data = data) 
mod1 <- glm(activation_threshold ~ y_angle, family = poisson(link = "log"), data = data) 
summary(mod0)
summary(mod1)
summary(mod1)$coefficients
p_vals <- coef(summary(mod1))[,4]
p_vals_adj <- p.adjust(p_vals, method = "holm")
p_vals_adj < 0.05
sort(p_vals_adj, decreasing = T)

