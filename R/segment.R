#' Divide an sf object polygon into some number of roughly equally-sized parts and calculate the centroid coordinates
#'
#' @importFrom stats kmeans
#' @importFrom tibble as_tibble
#' @importFrom dplyr rowwise mutate ungroup
#' @importFrom sf st_sample st_geometry st_as_sf st_intersection st_union st_make_valid st_centroid st_coordinates
#' @importFrom dismo voronoi
#' @importFrom raster crs
#'
#' @param sf_poly \code{sf} object contain the geometry
#' @param n_zones \code{integer} denoting the number of zones to divide the geometry into. Defaults to \code{25}
#' @param n_points \code{integer} denoting the number of points to use to construct the clustering algorithm. Defaults to \code{1e4}
#' @param seed \code{integer} denoting the fix for R's pseudo-random number generator. Defaults to \code{123}
#' @return \code{sf} object
#' @references https://gis.stackexchange.com/questions/375345/dividing-polygon-into-parts-which-have-equal-area-using-r
#' @references https://gis.stackexchange.com/questions/321021/splitting-polygon-into-equal-area-polygons-using-qgis
#' @references https://blog.cleverelephant.ca/2018/06/polygon-splitting.html
#' @references https://www.khetarpal.org/polygon-splitting/
#' @author Trent Henderson
#' @export
#'

segment <- function(sf_poly, n_zones = 25, n_points = 1e4, seed = 123){

  stopifnot(inherits(sf_poly, "sf") == TRUE)

  # Set seed for reproducibility

  set.seed(seed)

  # Create random points

  points_rnd <- sf::st_sample(sf_poly, size = n_points)

  # k-means clustering

  points <- do.call(rbind, sf::st_geometry(points_rnd)) |>
    tibble::as_tibble() |>
    setNames(c("lon","lat"))

  k_means <- stats::kmeans(points, centers = n_zones)

  # Create voronoi polygons

  voronoi_polys <- dismo::voronoi(k_means$centers, ext = sf_poly)

  # Clip to sf_poly and dissolve MULTIPOLYGON into POLYGON

  raster::crs(voronoi_polys) <- raster::crs(sf_poly)
  voronoi_sf <- sf::st_as_sf(voronoi_polys)

  equal_areas <- sf::st_intersection(voronoi_sf, sf_poly) |>
    dplyr::rowwise() |>
    dplyr::mutate(geometry = sf::st_union(sf::st_make_valid(geometry))) |>
    dplyr::ungroup()

  equal_areas$area <- sf::st_area(equal_areas)

  # Calculate centroid of each zone and pull out x,y coordinates

  equal_areas <- equal_areas |>
    dplyr::mutate(
      centroid = sf::st_centroid(geometry),
      centroid_x = sf::st_coordinates(centroid)[, 1],
      centroid_y = sf::st_coordinates(centroid)[, 2]
    )

  return(equal_areas)
}
