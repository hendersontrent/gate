#'
"_PACKAGE"
#' @name gate
#' @title Geospatial Analysis and Temporal Engineering
#'
#' @description Geospatial Analysis and Temporal Engineering
#'
#' @importFrom stats kmeans
#' @importFrom tibble as_tibble
#' @importFrom dplyr select rename distinct inner_join rename rowwise mutate ungroup filter group_by group_by_at vars
#' @importFrom tidyr crossing
#' @importFrom sf st_sample st_geometry st_as_sf st_intersection st_union st_make_valid st_centroid st_coordinates st_intersects st_within st_boundary st_geometrycollection
#' @importFrom dismo voronoi
#' @importFrom stars st_as_stars
#' @importFrom spatstat.geom as.ppp Window as.owin
#' @importFrom ggplot2 ggplot aes geom_sf scale_fill_viridis_c labs theme_bw theme element_text
#' @importFrom stars st_as_stars
#' @importFrom raster crs
#' @import spatstat
NULL
