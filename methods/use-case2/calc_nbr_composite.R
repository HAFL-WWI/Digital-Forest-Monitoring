############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

# Pixel composites based on VI and composite function
calc_pixel_composites <- function(stack_path, dates, ext=NULL) {
  
  # load packages
  library(raster)
  library(rgdal)
  library(foreach)
  library(doParallel)

  # NBR function (NIR -> "B08", SWIR -> "B12")
  calc_nbr <- function(stack) {
    return((stack$B08 - stack$B12) / (stack$B08 + stack$B12))
  }
  
  # filter bands and dates
  namesB8 = list.files(stack_path, pattern="B08_10m", recursive=T, full.names=T)
  namesB4 = list.files(stack_path, pattern="B04_10m", recursive=T, full.names=T)
  namesB12 = list.files(stack_path, pattern="B12_20m", recursive=T, full.names=T)
  namesB8 = namesB8[grepl(paste(dates, collapse="|"), namesB8)]
  namesB4 = namesB4[grepl(paste(dates, collapse="|"), namesB4)]
  namesB12 = namesB12[grepl(paste(dates, collapse="|"), namesB12)]
  
  fileNames = namesB8
  
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
    
    # calculate indices
    b4 = raster(namesB4[i])
    b8 = raster(namesB8[i])
    b12 = disaggregate(raster(namesB12[i]),2)
    
    vi_tmp = (b8 - b4)/(b8 + b4) # ndvi
    vi_tmp_2 = (b8 - b12)/(b8 + b12) # nbr
    
    vi_tmp = stack(vi_tmp, vi_tmp_2)
    return(vi_tmp)
  }
  
  # calculate index raster
  ndvi_stk = subset(vi_stk, subset=1:length(fileNames))
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