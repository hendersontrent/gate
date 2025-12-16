#' Computes smoothed spatial kernel density estimation using data and geometry information
#'
#' @importFrom dplyr select
#' @importFrom sf st_transform st_as_sf st_set_crs
#' @importFrom spatstat.geom as.ppp Window as.owin
#' @importFrom stars st_as_stars
#' @import spatstat
#'
#' @param data \code{sf} object containing a data frame of the data to plot
#' @param geometries \code{sf} object containing geometries
#' @param ... arguments to be passed to methods
#' @return \code{spatialdensity} object containing the estimated spatial kernel density information and geometric information
#' @references https://stackoverflow.com/questions/68643517/smoothed-density-maps-for-points-in-using-sf-within-a-given-boundary-in-r
#' @author Trent Henderson
#' @export
#'

spatialkernel <- function(data, geometries, ...){

  stopifnot(inherits(data, "sf") == TRUE)
  stopifnot(inherits(geometries, "sf") == TRUE)

  # Set a projected CRS since it's required by {spatstat}

  sf_data <- geometries |>
    sf::st_transform(32650)

  sf_points <- data |>
    sf::st_transform(32650)

  # Convert points to spatial point pattern

  ppp_points <- spatstat.geom::as.ppp(sf::st_transform(sf_points))
  spatstat.geom::Window(ppp_points) <- spatstat.geom::as.owin(sf_data)

  # Smooth points

  density_spatstat <- density(ppp_points, dimyx = 256)

  # Convert to spatiotemporal array

  density_stars <- stars::st_as_stars(density_spatstat)

  # Set projected CRS again

  density_sf <- sf::st_as_sf(density_stars) |>
    sf::st_set_crs(32650)

  outs <- list(density_sf, sf_data)
  names(outs) <- c("density_sf", "sf_data")
  outs <- structure(outs, class = "spatialdensity")
  return(outs)
}
