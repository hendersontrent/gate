#' Draw a sample point from a multivariate Gaussian parameterised by longitude and latitude and ensure it is within geometric boundaries
#'
#' @importFrom stats cov
#' @importFrom sf st_as_sf st_crs st_within
#'
#' @param longitude \code{numeric} vector containing longitude data
#' @param latitude \code{numeric} vector containing latitude data
#' @param geometries \code{sf} object containing geometric boundary to check point is within. Defaults to \code{NULL}
#' @param seed \code{integer} denoting the fix for R's pseudo-random number generator. Defaults to \code{123}
#' @param return_cov \code{Boolean} denoting whether to return the mean vector and covariance matrix in addition to sampled point. Defaults to \code{FALSE}. Returns a \code{list} object if \code{TRUE}
#' @return \code{sf} object containing the sampled point
#' @author Trent Henderson
#' @export
#'

expectation <- function(longitude, latitude, geometry = NULL, seed = 123, return_cov = FALSE){

  # Check args

  stopifnot(is.numeric(longitude))
  stopifnot(is.numeric(latitude))
  stopifnot(length(longitude) == length(latitude))
  stopifnot(length(longitude) >= 5)
  stopifnot(!is.null(geometry))
  stopifnot(inherits(geometry, "sf") == TRUE)

  # Calculate mean vector and covariance matrix

  set.seed(123)
  coords <- cbind(longitude, latitude)
  mu <- colMeans(coords, na.rm = TRUE) # Mean factor
  Sigma <- stats::cov(coords, use = "complete.obs") # Covariance matrix

  # Handle degenerate covariances (too few points)

  if(any(is.na(Sigma)) || det(Sigma) == 0){
    message("Degenerate covariance. Using mean instead.")
    E_lon <- mean(longitude, na.rm = TRUE)
    E_lat <- mean(latitude, na.rm = TRUE)

    pt_sf <- sf::st_as_sf(
      data.frame(longitude = E_lon, E_lat),
      coords = c("longitude", "latitude"),
      crs = sf::st_crs(geometry)
    )

  } else{

    # Draw one multivariate sample until we get one within the prescribed geometric bounds

    repeat{

      sample_point <- MASS::mvrnorm(n = 1, mu = mu, Sigma = Sigma)

      # Check if it is within the zone bounds (as covariance can mean that points could be generated outside bounds if call density is near border)

      pt_sf <- sf::st_as_sf(
        data.frame(longitude = sample_point[1], latitude = sample_point[2]),
        coords = c("longitude", "latitude"),
        crs = sf::st_crs(geometry)
      )

      if(sf::st_within(pt_sf, geometry, sparse = FALSE)){
        break
      }
    }
  }

  if(return_cov){
    outs <- list(pt_sf, mu, Sigma)
    names(outs) <- c("expectation", "mu", "Sigma")
    return(outs)
  } else{
    return(pt_sf)
  }
}
