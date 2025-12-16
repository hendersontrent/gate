#' Dissolve boundaries from multiply polygons into a single geometric polygon
#'
#' @importFrom dplyr group_by_at reframe ungroup vars
#' @importFrom sf st_union st_make_valid st_sf
#'
#' @param geometries \code{sf} object contain the geometry
#' @param .group \code{character} denoting the column name of the grouping variable to aggregate over (if applicable). Defaults to \code{NULL}. If \code{NULL}, all boundaries in \code{data} will be dissolved into a single polygon geometry
#' @return \code{sf} object
#' @author Trent Henderson
#' @export
#'

dissolve <- function(geometries, .group = NULL){

  stopifnot(inherits(geometries, "sf") == TRUE)

  if(!is.null(.group)){
    stopifnot(is.character(.group))

    agg_poly <- geometries |>
      dplyr::group_by_at(dplyr::vars(.group)) |>
      dplyr::reframe(geometry = sf::st_union(sf::st_make_valid(geometry))) |>
      dplyr::ungroup()
  } else{
    agg_poly <- geometries |>
      dplyr::reframe(geometry = sf::st_union(sf::st_make_valid(geometry)))
  }

  agg_poly <- sf::st_sf(geometry = agg_poly)
  return(agg_poly)
}
