library(ProjectTemplate)
load.project()

str(mu_control_mesh_refinement)
mu_control_mesh_refinement %>% dplyr::group_by(mesh) %>% dplyr::summarise(mean_threshold = mean(threshold))
wilcox.test(data = mu_control_mesh_refinement, threshold~mesh, exact = F)
t.test(data = mu_control_mesh_refinement, threshold~mesh)