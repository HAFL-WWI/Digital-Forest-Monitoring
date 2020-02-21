############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

# Pixel composites based on VI and composite function
calc_pixel_composites <- function(stack_path, band_names, dates, stack_fun, ext=NULL) {
  
  # load packages
  library(raster)
  library(rgdal)
  library(foreach)
  library(doParallel)

  # NBR function (NIR -> "B08", SWIR -> "B12")
  calc_nbr <- function(stack) {
    return((stack$B08 - stack$B12) / (stack$B08 + stack$B12))
  }
  
  # filter .tif files and dates
  fileNames = list.files(stack_path)
  fileNames = fileNames[grep("tif$", fileNames)]
  fileNames = fileNames[grepl(paste(dates, collapse="|"), fileNames)]
  files <- fileNames
  fileNames = paste(stack_path, fileNames, sep="")
  
  # prepare stack
  vi_stk = stack()
  print("Images to process:")
  print(fileNames)
  
  # register for paralell processing
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  
  # apply stack function
  vi_stk = foreach(i=1:length(fileNames), .packages = c("raster"), .combine = "addLayer") %dopar% {
    print(paste("processing", i, "of", length(fileNames),"..."))
    # get stack
    stk_tmp = stack(fileNames[i])
    names(stk_tmp) = band_names
    
    # calculate indices
    vi_tmp = stack_fun(stk_tmp)
    vi_tmp_2 = calc_nbr(stk_tmp)
    
    vi_tmp = stack(vi_tmp, vi_tmp_2)
    return(vi_tmp)
  }
  
  # calculate index raster
  ind_raster <- which.max(ndvi_stk)
    
  # NBR stack
  nbr_stk = subset(vi_stk, subset=(1+length(fileNames)):nlayers(vi_stk))
  
  # NBR composite
  nbr_composite = stackSelect(nbr_stk, ind_raster)

  # date
  #date_ras <- ind_raster
  #for (i in 1:length(fileNames)){
  #date_ras[date_ras==i] <- substring(strsplit(files[i],"_")[[1]][3],1,8)
  #}
    
  #composite_all = stack(ndvi_composite, ind_raster, date_ras, rgb_composite, nbr_composite)
  composite_all = nbr_composite
   
  # crop
  if (!is.null(ext)) composite_all = crop(composite_all, ext)
  
  
  # plot composites in PDF
  #pdf(paste("composite_", txt, ".pdf", sep=""))
  #plot(pixel_composite)
  #dev.off()
  
  # stop cluster only here, otherwise tmp files may get lost
  stopCluster(cl)

  return(composite_all)
}