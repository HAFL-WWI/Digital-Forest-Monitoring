############################################################
# Calculate vegetation index, save results and return stack
# (--> for L-2A data, could be extended to also be used for L-1c)
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

calc_veg_indices <- function(stk_1, stk_2, out_path, dates, veg_ind="NDVI", tilename="", ext=NULL, thr=0.99) {
  
  # load packages
  library(raster)
  # library(terra)
  library(doParallel)
  
  # filter bands and dates
  out_names = list.files(out_path, full.names=T)
  #out_names = out_names[grepl(paste(dates, collapse="|"), out_names)]
  
  # prepare stack
  vi_stk = stack()
  
  # register for paralell processing
  cl = makeForkCluster(detectCores() -1)
  registerDoParallel(cl)
  
  # apply stack function
  vi_stk = foreach(i=1:length(dates), .packages = c("raster"), .combine = "addLayer") %dopar% {
    
    # NDVI
    if (length(grep(dates[i], out_names))<1){
      vi_tmp_1 = (stk_1[[i]] - stk_2[[i]])/(stk_1[[i]] + stk_2[[i]])
      if (!is.null(thr)) vi_tmp_1[vi_tmp_1 >= thr] = NA
      vi_tmp = round(vi_tmp_1*100)
      rm(vi_tmp_1)
      out_name = paste(tilename, "_", veg_ind, "_", dates[i], sep="")
      writeRaster(vi_tmp, paste(out_path, out_name, ".tif",sep=""), overwrite=T, datatype='INT2S')
      out_names = list.files(out_path, full.names=T)
    }
    vi_tmp = raster(out_names[grep(dates[i], out_names)])
    return(vi_tmp)
  }
  stopCluster(cl)
  
  rm(stk_1, stk_2)
  
  # crop
  if (!is.null(ext)) vi_stk = crop(vi_stk, ext)
  
  gc(verbose = F)
  return(vi_stk)
}