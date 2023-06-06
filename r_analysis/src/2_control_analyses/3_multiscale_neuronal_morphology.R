library(ProjectTemplate)
load.project()

d <- mu_control_neuronal_morphology %>% dplyr::count(neuronal_model)
d$activated_cells <-  mu_control_neuronal_morphology %>% dplyr::filter(activation_threshold < 101) %>% dplyr::count(neuronal_model) %>% dplyr::pull(n)
d$percent <- 100 * round(d$activated_cells/d$n, 4)
d
27.2/12.3

ggplot(data = d, aes(x = neuronal_model, y = percent, fill = neuronal_model)) + 
  geom_col(fill = c(c1, c2)) +
  labs(x = "", y = "Activated cells (%)") +
  scale_y_continuous(breaks = seq(from = 0, to = 40, by = 10)) +
  coord_cartesian(ylim = c(0, 40)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S3/A.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 65, units = "mm", dpi = 300)
# GLM with binomial distribution
data <- mu_control_neuronal_morphology %>% dplyr::mutate(neuronal_model = factor(neuronal_model),
                                                         activated = case_when(activation_threshold < 101 ~ 1,
                                                                               activation_threshold == 101 ~ 0,
                                                                               TRUE ~ NA_real_))
data <- within(data, 
               neuronal_model <- relevel(neuronal_model, ref = "L23b"))
mod0 <- glm(activated ~ 1, family = binomial, data = data) 
mod1 <- glm(activated ~ neuronal_model, family = binomial, data = data) 
summary(mod0)
summary(mod1)

# Activated cells: Activation threshold 
ggplot(data =  mu_control_neuronal_morphology %>% dplyr::filter(activation_threshold < 101), aes(x = neuronal_model, y = activation_threshold, color = neuronal_model, fill = neuronal_model)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.5) +
  labs(x = "", y = "Intensity (MSO%)") +
  scale_y_continuous(breaks = seq(from = 40, to = 100, by = 20)) +
  scale_fill_manual(values = c(c1, c2)) +
  scale_color_manual(values = c(c1, c2)) +
  coord_cartesian(ylim = c(40, 110)) +
  theme_bw() +
  theme(axis.text = element_text(colour = "black", size = 12),
        axis.title = element_text(colour = "black", size = 12), 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position = "none")
ggsave(paste("graphs/supplemental_figures/S3/B.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 65, units = "mm", dpi = 300)
mu_control_neuronal_morphology %>% dplyr::filter(activation_threshold < 101) %>% dplyr::group_by(neuronal_model) %>% dplyr::summarise_at(vars(activation_threshold), list(mean = mean, sd = sd)) %>% dplyr::ungroup()

# statistics (permutation test)
original <- t.test(activation_threshold ~ neuronal_model, data = mu_neuronal_model %>% dplyr::filter(activation_threshold < 101))
t_orig <- original[["statistic"]][["t"]]
df = data.frame('DV' = mu_control_neuronal_morphology$activation_threshold,
                'IV' = mu_control_neuronal_morphology$neuronal_model)
perm <- permutation_t_test(df, 10000)
perm <- data.frame('t_values' = perm)
ggplot(data = perm, aes(x = t_values)) + 
  geom_histogram(bins = 100)

t_mean_perm = mean(perm$t_values)
t_std_perm  = sd(perm$t_values)
z = (t_orig - t_mean_perm) / t_std_perm
p = 2 * pnorm(q = z, lower.tail = FALSE)
z

# Activation E-field
mu_control_neuronal_morphology_actefield %>% dplyr::filter(activated == TRUE) %>% dplyr::group_by(neuronal_model) %>% dplyr::count(neuronal_model) %>% dplyr::ungroup()
ggplot(data =  mu_control_neuronal_morphology_actefield %>% dplyr::filter(activated == TRUE), aes(x = neuronal_model, y = activation_efield, color = neuronal_model, fill = neuronal_model)) + 
  geom_jitter(alpha = 0.25) +
  stat_summary(fun.data = "mean_cl_boot", colour = "white", linewidth = 0.5, size = 0.5) +
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
ggsave(paste("graphs/supplemental_figures/S3/C.", format, sep = ""), plot = last_plot(), 
       width = 60, height = 65, units = "mm", dpi = 300)
# permutation test statistics
original <- t.test(activation_efield ~ neuronal_model, data = mu_neuronal_model_actefield %>% dplyr::filter(activated == TRUE))
t_orig <- original[["statistic"]][["t"]]
df = data.frame('DV' = mu_neuronal_model_actefield$activation_efield,
                'IV' = mu_neuronal_model_actefield$neuronal_model)
perm <- permutation_t_test(df, 10000)
perm <- data.frame('t_values' = perm)
ggplot(data = perm, aes(x = t_values)) + 
  geom_histogram(bins = 100)

t_mean_perm = mean(perm$t_values)
t_std_perm  = sd(perm$t_values)
z = (t_orig - t_mean_perm) / t_std_perm
p = 2 * pnorm(q = z, lower.tail = FALSE)
z

mu_control_neuronal_morphology_actefield %>% dplyr::filter(activated == TRUE) %>% dplyr::group_by(neuronal_model) %>% dplyr::summarise_at(vars(activation_efield), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
