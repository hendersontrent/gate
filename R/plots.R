#' Plots geospatial kernel density in ggplot2
#'
#' @importFrom ggplot2 ggplot aes geom_sf scale_fill_viridis_c labs theme_bw theme element_text
#' @importFrom sf st_boundary
#'
#' @param data \code{sf} object containing a data frame of the data to plot
#' @param geometries \code{sf} object containing geometries
#' @param ... arguments to be passed to methods
#' @return \code{ggplot} object containing the graphic
#' @author Trent Henderson
#' @export
#'

plot.spatialdensity <- function(x, ...){

  stopifnot(inherits(x, "spatialdensity") == TRUE)

  p <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = x[["density_sf"]], ggplot2::aes(fill = v), col = NA) +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::geom_sf(data = sf::st_boundary(x[["sf_data"]]), colour = "white") +
    ggplot2::labs(x = "Longitude",
                  y = "Latitude",
                  fill = "Probability density") +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom",
                   legend.text = ggplot2::element_text(angle = 90))

  return(p)
}
