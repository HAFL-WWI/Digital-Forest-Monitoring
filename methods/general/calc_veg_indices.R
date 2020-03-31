############################################################
# Calculate vegetation index, save results and return stack
# (--> for L-2A data, could be extended to also be used for L-1c)
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

calc_veg_indices <- function(stk_1, stk_2, out_path, dates, veg_ind="NDVI", tilename="", ext=NULL, thr=0.99) {
  
  # load packages
  library(raster)
  library(foreach)
  library(doParallel)
  
  # filter bands and dates
  out_names = list.files(out_path, full.names=T)
  out_names = out_names[grepl(paste(dates, collapse="|"), out_names)]
  
  # prepare stack
  vi_stk = stack()
  
  # register for paralell processing
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  
  # apply stack function
  vi_stk = foreach(i=1:length(dates), .packages = c("raster"), .combine = "addLayer") %dopar% {
    
    # NDVI
    if (length(grep(dates[i], out_names))>0){
      vi_tmp = raster(out_names[grep(dates[i], out_names)])
    }
    else {
      x1 = stk_1[[i]]
      x2 = stk_2[[i]]
      
      vi_tmp = (x1 - x2)/(x1 + x2)
      if (!is.null(thr)) vi_tmp[vi_tmp >= thr] = NA
      out_name = paste(tilename, "_", veg_ind, "_", dates[i], sep="")
      writeRaster(vi_tmp, paste(out_path, out_name, ".tif",sep=""), overwrite=T)
    }
    
    return(vi_tmp)
  }
  # crop
  if (!is.null(ext)) vi_stk = crop(vi_stk, ext)
  
  stopCluster(cl)
  
  return(vi_stk)
}