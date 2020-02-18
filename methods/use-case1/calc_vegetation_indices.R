# Functions to calculate vegetation indices

# INFO
# band_names = c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B09", "B10","B11", "B12")

# NDVI (NIR -> "B08", RED -> "B04")
calc_ndvi <- function(stack) {
  return((stack$B08 - stack$B04) / (stack$B08 + stack$B04))
}

# GNDVI
calc_gndvi <- function(stack) {
  return((stack$B07 - stack$B03) / (stack$B07 + stack$B03))
}

# NDI45
calc_ndi45 <- function(stack) {
  return((stack$B05 - stack$B04) / (stack$B05 + stack$B04))
}


# NBR (NIR -> "B08", SWIR -> "B12")
calc_nbr <- function(stack) {
  return((stack$B08 - stack$B12) / (stack$B08 + stack$B12))
}

# IRECI
calc_ireci <- function(stack) {
  return((stack$B07 - stack$B04) / (stack$B05 / stack$B06))
}

# MCARI
calc_mcari <- function(stack) {
  return((stack$B05 - stack$B04) - 0.2 * (stack$B05 - stack$B03)) * (stack$B05 - stack$B04)
}
