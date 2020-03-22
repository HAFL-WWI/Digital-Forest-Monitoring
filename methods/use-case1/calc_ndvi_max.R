############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

#' Pixel composites based on VI (NDVI) max
#' @return Raster layer (ndvi max) or stack (ndvi max, index)
calc_ndvi_max <- function(stack_path, band_names, dates, ext=NULL, ind=F) {
  # load packages
  library(raster)
  library(rgdal)
  library(foreach)
  library(doParallel)
  
  # filter .tif files and dates
  fileNames = list.files(stack_path)
  fileNames = fileNames[grep("tif$", fileNames)]
  fileNames = fileNames[grepl(paste(dates, collapse="|"), fileNames)]
  files <- fileNames
  fileNames = file.path(stack_path, fileNames)
  
  # ndvi function
  calc_ndvi <- function(stack) {
    return((stack$B08 - stack$B04) / (stack$B08 + stack$B04))
  }

  print("==========================")
  print(paste("Calculate NDVI of", length(fileNames), "stacks in parallel mode:"))
  print(fileNames)
  
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  ndvi_stk = foreach(i=1:length(fileNames), .packages = c("raster"), .combine = "addLayer") %dopar% {
    # get stack
    stk_tmp = brick(fileNames[i])
    names(stk_tmp) = band_names
    
    # crop
    if (!is.null(ext)) stk_tmp = crop(stk_tmp, ext)
    
    # calculate ndvi
    return(calc_ndvi(stk_tmp))
  }
  stopCluster(cl)
  
  print("==========================")
  print("calculate max")
  ndvi_max = calc(ndvi_stk, max, na.rm=T)
  if (ind){ 
    max_ind = which.max(ndvi_stk)
    return(stack(ndvi_max, max_ind))
  }
  return(ndvi_max)
}