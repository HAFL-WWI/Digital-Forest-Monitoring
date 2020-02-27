############################################################
# Calculate vegetation index, save results and return stack
# (--> for L-2A data, could be extended to also be used for L-1c)
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

calc_veg_indices <- function(stack_path, x1_pattern, x2_pattern, stk_1, stk_2, out_path, dates, veg_ind="NDVI", tilename="", ext=NULL) {
  
  # load packages
  library(raster)
  library(foreach)
  library(doParallel)
  
  # filter bands and dates
  if (!is.null(stack_path) & !is.null(x1_pattern) & !is.null(x2_pattern)) {
  namesX1 = list.files(stack_path, pattern=b1_pattern, recursive=T, full.names=T)
  namesX2 = list.files(stack_path, pattern=b2_pattern, recursive=T, full.names=T)
  
  namesX1 = namesX1[grepl(paste(dates, collapse="|"), namesX1)]
  namesX2 = namesX2[grepl(paste(dates, collapse="|"), namesX2)]
  }
  
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
      if (!is.null(stk_1) & !is.null(stk_2)){
        x1 = stk_1[[i]]
        x2 = stk_2[[i]]
      }
      else {
        x1 = raster(namesX1[i])
        x2 = raster(namesX2[i])
      }
      vi_tmp = (x1 - x2)/(x1 + x2)
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