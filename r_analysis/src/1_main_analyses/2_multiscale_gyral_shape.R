###############
# GYRAL SHAPE #
###############

library(ProjectTemplate)
load.project()

# Fraction of activated cells ----
mu_gyral_shape %>% dplyr::group_by(shape) %>% dplyr::count(neuronal_model) %>% dplyr::ungroup()

d <- mu_gyral_shape %>% dplyr::count(shape)
d$activated_cells <- mu_gyral_shape %>% dplyr::filter(activation_threshold < 101) %>% dplyr::count(shape) %>% dplyr::pull(n)
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d
d$percent[1]/d$percent[2]

# Figure
ggplot(data = d, aes(x = shape, y = percent, fill = shape)) + 
  geom_col(fill = c(c1, c2)) +
  labs(x = "", y = "Activated cells (%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 40, by = 10)) +
  coord_cartesian(ylim = c(0, 40)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_3/A.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 65, units = "mm", dpi = 300)

# GLM with binomial distribution
data <- mu_gyral_shape %>% dplyr::mutate(shape = factor(shape),
                                         activated = case_when(activation_threshold < 101 ~ 1,
                                                               activation_threshold == 101 ~ 0,
                                                               TRUE ~ NA_real_))
data <- within(data, 
               shape <- relevel(shape, ref = "Sine"))
mod0 <- glm(activated ~ 1, family = binomial, data = data) 
mod1 <- glm(activated ~ shape, family = binomial, data = data) 
summary(mod0)
summary(mod1)
summary(mod1)$coefficients
exp(coefficients(mod1))
exp(confint.default(mod1))

# Activation threshold (of activated cells) ----
ggplot(data =  mu_gyral_shape %>% dplyr::filter(activation_threshold < 101), aes(x = shape, y = activation_threshold, color = shape, fill = shape)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.05) +
  labs(x = "Gyral shape", y = "Intensity (MSO%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 100, by = 20)) +
  scale_fill_manual(values = c(c1, c2)) +
  scale_color_manual(values = c(c1, c2)) +
  coord_cartesian(ylim = c(0, 110)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_3/B.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 65, units = "mm", dpi = 300)
mu_gyral_shape %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(shape) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()

# permutation test statistics
data <- mu_gyral_shape %>% dplyr::filter(activation_threshold < 101)
original <- t.test(activation_threshold ~ shape, data = data)
t_orig <- original[["statistic"]][["t"]]
df = data.frame('DV' = data$activation_threshold,
                'IV' = data$shape)
perm <- permutation_t_test(df, 10000)
perm <- data.frame('t_values' = perm)
ggplot(data = perm, aes(x = t_values)) + 
  geom_histogram(bins = 100)

t_mean_perm = mean(perm$t_values)
t_std_perm  = sd(perm$t_values)
z = (t_orig - t_mean_perm) / t_std_perm
p = 2 * pnorm(q = z, lower.tail = FALSE)
p

# E-field for neuronal activation ----
mu_gyral_shape_actefield %>% dplyr::filter(activated == TRUE) %>% dplyr::group_by(shape) %>% dplyr::count(shape) %>% dplyr::ungroup()
ggplot(data =  mu_gyral_shape_actefield %>% dplyr::filter(activated == TRUE), aes(x = shape, y = activation_efield, color = shape, fill = shape)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.05) +
  labs(x = "", y = "E-field (V/m)") +
  scale_y_continuous(breaks = seq(from = 50, to = 300, by = 50)) +
  scale_fill_manual(values = c(c1, c2)) +
  scale_color_manual(values = c(c1, c2)) +
  coord_cartesian(ylim = c(50, 300)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/figure_3/A.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 65, units = "mm", dpi = 300)

# permutation test statistics
original <- t.test(activation_efield ~ shape, data = mu_gyral_shape_actefield %>% dplyr::filter(activated == TRUE))
t_orig <- original[["statistic"]][["t"]]
df = data.frame('DV' = mu_gyral_shape_actefield$activation_efield,
                'IV' = mu_gyral_shape_actefield$shape)
perm <- permutation_t_test(df, 10000)
perm <- data.frame('t_values' = perm)
ggplot(data = perm, aes(x = t_values)) + 
  geom_histogram(bins = 100)

t_mean_perm = mean(perm$t_values)
t_std_perm  = sd(perm$t_values)
z = (t_orig - t_mean_perm) / t_std_perm
p = 2 * pnorm(q = z, lower.tail = FALSE)
z
mu_gyral_shape_actefield %>% dplyr::filter(activated == TRUE) %>% dplyr::group_by(shape) %>% dplyr::summarise_at(vars(activation_efield), list(mean = mean, sd = sd)) %>% dplyr::ungroup()


