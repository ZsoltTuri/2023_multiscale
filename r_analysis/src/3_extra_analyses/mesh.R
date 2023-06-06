library(ProjectTemplate)
load.project()

# ROI size -------
d <- mesh_roi_size %>% dplyr::group_by(mesh) %>% dplyr::summarise_at(vars(roi_size), list(mean = mean, sd = sd)) %>% dplyr::ungroup()
range(d$mean)

# Mesh properties: Tetrahedron edge length -------
range(mesh_tetrahedron$tet_edge_len)

# Mesh properties: Tetrahedron volume -------
range(mesh_tetrahedron$tet_vol)