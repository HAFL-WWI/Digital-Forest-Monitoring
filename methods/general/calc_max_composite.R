############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

#' Pixel composites based on VI (NDVI) max
#' @return Raster layer (ndvi max or index) or stack (ndvi max, index)
calc_max_composite <- function(vi_stk, ext=NULL, calc_max=F, calc_ind=T) {
  
  # load packages
  library(raster)

  # crop
  if (!is.null(ext)) vi_stk = crop(vi_stk, ext)

  # calc vegetation index max / max index
  if (calc_max){
    vi_max = calc(vi_stk, max, na.rm=T)
    if (!calc_ind) return (vi_max)
  }
  
  if (calc_ind){ 
    max_ind = which.max(vi_stk)
    if (!calc_max) return (max_ind)
  }
  
  return(stack(vi_max,max_ind))
}