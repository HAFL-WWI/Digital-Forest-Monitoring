############################################################
# Greenest pixel (NDVI max, NBR min) composite
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

# Pixel composites based on VI and composite function
calc_pixel_composites <- function(stack_path, band_names, dates, txt, stack_fun, composite_fun=max, ext=NULL, ind=T) {
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
  
  # calculate composite based on function provided (i.e. max)
  ndvi_stk = subset(vi_stk, subset=1:length(fileNames))
  print("Building composite...")
  if (ind==F){
    pixel_composite = calc(ndvi_stk, max, na.rm=T)
    
    # crop
    if (!is.null(ext)) pixel_composite = crop(pixel_composite, ext)
  }

  
  if (ind==T){
    # calculate index raster
    ind_raster <- which.max(ndvi_stk)  # Achtung eigentlich müsste man unterscheiden nach composite function min/max
    
    # nbr stack
    nbr_stk = subset(vi_stk, subset=(1+length(fileNames)):nlayers(vi_stk))
    
    # NDVI composite
    ndvi_composite = stackSelect(ndvi_stk, ind_raster)
    
    # NBR composite
    nbr_composite = stackSelect(nbr_stk, ind_raster)
    
    # RGB composite
    stk_b2 = stack(fileNames, bands=2)
    stk_b3 = stack(fileNames, bands=3)
    stk_b4 = stack(fileNames, bands=4)
    
    b2_comp = stackSelect(stk_b2, ind_raster)
    b3_comp = stackSelect(stk_b3, ind_raster)
    b4_comp = stackSelect(stk_b4, ind_raster)
    
    rgb_composite = stack(b4_comp, b3_comp, b2_comp)
    
    # date
    date_ras <- ind_raster
    for (i in 1:length(fileNames)){
      date_ras[date_ras==i] <- substring(strsplit(files[i],"_")[[1]][3],1,8)
    }
    
    composite_all = stack(ndvi_composite, ind_raster, date_ras, rgb_composite, nbr_composite)
    
    # crop
    if (!is.null(ext)) composite_all = crop(composite_all, ext)
  }
  
  # plot composites in PDF
  #pdf(paste("composite_", txt, ".pdf", sep=""))
  #plot(pixel_composite)
  #dev.off()
  
  # stop cluster only here, otherwise tmp files may get lost
  stopCluster(cl)
  if (ind==T){
    return(composite_all)
  } else {
    return(pixel_composite)
  }
}