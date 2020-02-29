############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

#' Pixel composites based on VI (NDVI) max
#' @return Raster layer (ndvi max or index) or stack (ndvi max, index)
calc_max_composite <- function(stack_path, stk=NULL, dates, ext=NULL, calc_max=F, calc_ind=T) {
  
  # load packages
  library(raster)

  if (is.null(stk)){
    # filter dates
    fileNames = list.files(stack_path, full.names = T)
    fileNames = fileNames[grepl(paste(dates, collapse="|"), fileNames)]

    # get stack
    vi_stk = brick(fileNames)
    }
  else {
    vi_stk = stk
  }
  
  # crop
  if (!is.null(vi_stk)) vi_stk = crop(vi_stk, ext)

  # calc vegetation index max / max index
  if (calc_max){
    vi_max = calc(vi_stk, max, na.rm=T)
    if (!calc_ind) return (vi_max)
  }
  
  if (calc_ind){ 
    max_ind = which.max(vi_stk)
    if (!calc_max) return (ind_max)
  }
  
  return(stack(vi_max,max_ind))
}