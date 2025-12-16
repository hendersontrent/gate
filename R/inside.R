#' Map smaller polygons in one object to larger polygons in another by area intersection
#'
#' @importFrom dplyr select rename distinct inner_join rename rowwise mutate ungroup filter group_by
#' @importFrom tidyr crossing
#' @importFrom sf st_crs st_intersects st_intersection st_area st_area st_geometrycollection
#'
#' @param A \code{sf} object containing the larger polygons
#' @param B \code{sf} object containing the smaller polygons to be mapped
#' @return \code{sf} object containing the smaller geometry data but with mapping information
#' @author Trent Henderson
#' @export
#'

inside <- function(A, B){

  stopifnot(inherits(A, "sf") == TRUE)
  stopifnot(inherits(B, "sf") == TRUE)

  A_sub <- A |>
    dplyr::select(c("id", "geometry")) |>
    dplyr::rename(id_big = id)

  B_sub <- B |>
    dplyr::select(c("id", "geometry")) |>
    dplyr::distinct()

  # Ensure same CRS

  st_crs(A_sub) <- sf::st_crs(B_sub)

  # Make all pairwise geometric combinations

  overlaps <- tidyr::crossing(id_big = A_sub$id_big, id = B_sub$id) |>
    dplyr::inner_join(A_sub, by = c("id_big" = "id_big")) |>
    dplyr::rename(geometry_big = geometry) |>
    dplyr::inner_join(B_sub, by = c("id" = "id"))

  overlaps <- st_as_sf(overlaps)

  # Compute intersection and metrics for all pairwise combinations of A-B

  sf_obj <- overlaps |>
    dplyr::rowwise() |>
    dplyr::mutate(
      does_intersect = sf::st_intersects(geometry, geometry_big, sparse = FALSE)[1, 1],
      intersection = if(does_intersect) sf::st_intersection(geometry, geometry_big)
      else st_sfc(sf::st_geometrycollection(), crs = sf::st_crs(geometry)),
      overlap_area = if(does_intersect) as.numeric(sf::st_area(intersection)) else 0,
      area_A = as.numeric(sf::st_area(geometry)),
      proportion_A_in_B = overlap_area / area_A
    ) |>
    dplyr::ungroup()

  # Retain only those which actually intersect

  sf_obj <- sf_obj |>
    dplyr::filter(does_intersect)

  # Find combination for each B with highest proportion of intersection

  sf_obj <- sf_obj |>
    dplyr::group_by(id) |>
    dplyr::slice_max(order_by = proportion_A_in_B, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    as.data.frame() |>
    dplyr::select(c(id, id_big, proportion_A_in_B)) |>
    dplyr::rename(zone_id = id_big)

  # Check we didn't gain or lose any squares

  stopifnot(nrow(sf_obj) == nrow(B_sub))

  # Produce final object with mappings

  B_mapped <- B |>
    dplyr::inner_join(sf_obj, by = c("id" = "id"))

  # Check we didn't gain or lose any squares

  stopifnot(nrow(B_mapped) == nrow(B_sub))
  return(B_mapped)
}
