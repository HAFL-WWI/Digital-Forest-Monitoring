############################################################
# Calculate NBR difference raster(s) and return stack
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

calc_diff = function(stk1, stk2, cloud_value, nodata_value, time_int, out_path, tile){
 
  # load packages
  library(raster)
  library(foreach)
  library(doParallel)
    
  # register for paralell processing
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  
  # build NBR stack & save NDVIs & NBRs
  diff_stk = foreach(i=nlayers(stk1):1, .packages = c("raster"), .combine = "addLayer") %dopar% {  
  
    diff_tmp = stk1[[i]]-stk2[[i]]
    diff_tmp = round(diff_tmp*100)
    diff_tmp[(stk1[[i]] == cloud_value)] = cloud_value # clouds
    diff_tmp[(stk1[[i]] == nodata_value)] = nodata_value # nodata
    ras_name = paste(tile,"_NBR_diff_",substr(names(stk1[[i]]),2,9),"_",time_int,"days", sep="")
    #cloud_perc = round(100*ncell(diff_tmp[diff_tmp==cloud_value])/(ncell(diff_tmp[diff_tmp!=nodata_value])))
  
  # save as 16 Bit Integer
    writeRaster(diff_tmp, paste(out_path, ras_name,".tif",sep=""), overwrite=T, datatype='INT2S')
  }
  
  stopCluster(cl)
  #return(diff_stk)
  
}