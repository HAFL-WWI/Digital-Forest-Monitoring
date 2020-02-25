############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

# Pixel composites based on VI and composite function
calc_pixel_composites <- function(stack_path, ndvi_path, nbr_path, dates, tilename="", ext=NULL) {
  
  # load packages
  library(raster)
  library(foreach)
  library(doParallel)

  # filter bands and dates
  namesB8 = list.files(stack_path, pattern="B08_10m", recursive=T, full.names=T)
  namesB4 = list.files(stack_path, pattern="B04_10m", recursive=T, full.names=T)
  namesB12 = list.files(stack_path, pattern="B12_20m", recursive=T, full.names=T)
  namesB8 = namesB8[grepl(paste(dates, collapse="|"), namesB8)]
  namesB4 = namesB4[grepl(paste(dates, collapse="|"), namesB4)]
  namesB12 = namesB12[grepl(paste(dates, collapse="|"), namesB12)]
  
  ndvi_names = list.files(ndvi_path, full.names=T)
  ndvi_names = ndvi_names[grepl(paste(dates, collapse="|"), ndvi_names)]
  nbr_names = list.files(nbr_path, full.names=T)
  nbr_names = nbr_names[grepl(paste(dates, collapse="|"), nbr_names)]
  
  # prepare stack
  vi_stk = stack()

  # register for paralell processing
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  
  # apply stack function
  vi_stk = foreach(i=1:length(dates), .packages = c("raster"), .combine = "addLayer") %dopar% {
   
    # NDVI
    if (length(grep(dates[i], ndvi_names))>0){
      vi_tmp = raster(ndvi_names[grep(dates[i], ndvi_names)])
      }
    else {
      b4 = raster(namesB4[i])
      b8 = raster(namesB8[i])
      vi_tmp = (b8 - b4)/(b8 + b4)
      ndvi_name = paste(tilename, "_NDVI_", dates[i], sep="")
      writeRaster(vi_tmp, paste(ndvi_path, ndvi_name, ".tif",sep=""), overwrite=T)
      }
    
    # NBR
    if (length(grep(dates[i], nbr_names))>0){
      vi_tmp_2 = raster(nbr_names[grep(dates[i], nbr_names)])
    }
    else {
      b12 = disaggregate(raster(namesB12[i]),2)
      b8 = raster(namesB8[i])
      vi_tmp_2 = (b8 - b12)/(b8 + b12)
      nbr_name = paste(tilename, "_NBR_", dates[i], sep="")
      writeRaster(vi_tmp_2, paste(nbr_path, nbr_name, ".tif",sep=""), overwrite=T)
    }
    
    vi_tmp = stack(vi_tmp, vi_tmp_2)
    return(vi_tmp)
  }
  
  # calculate index raster
  ndvi_stk = subset(vi_stk, subset=1:length(dates))
  ind_raster <- which.max(ndvi_stk)
    
  # NBR stack
  nbr_stk = subset(vi_stk, subset=(1+length(dates)):nlayers(vi_stk))
  
  # NBR composite
  nbr_composite = stackSelect(nbr_stk, ind_raster)

  # crop
  if (!is.null(ext)) composite_all = crop(composite_all, ext)
  
  stopCluster(cl)

  return(nbr_composite)
}