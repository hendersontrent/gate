#' Allocates position based on lat-long coordinates to a polygon geometry
#' 
#' @importFrom dplyr select
#' @importFrom sf st_crs st_join st_within
#' 
#' @param coords \code{sf} object containing a data frame with coordinate data as point geometries
#' @param geometries \code{sf} object containing geometries to map to. Should contain at least two named columns: \code{"id"} and \code{"geometry"}
#' @param quadrant \code{Boolean} denoting whether the geometry {sf} is for quadrants or not. Defaults to \code{FALSE}
#' @return \code{sf} object containing mapping
#' @author Trent Henderson
#' @export
#' 

allocate <- function(coords, geometries){
  
  stopifnot(inherits(coords, "sf") == TRUE)
  stopifnot(inherits(geometries, "sf") == TRUE)
  
  # Clean up columns
  
  geometries <- geometries |> 
    dplyr::select(c(id, geometry))
  
  # Ensure same CRS
  
  st_crs(coords) <- sf::st_crs(geometries)
  
  # Perform join
  
  coords_allocated <- sf::st_join(coords, geometries, join = sf::st_within)
  return(coords_allocated)
}
