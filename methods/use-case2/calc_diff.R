############################################################
# Calculate NBR difference raster(s) and return stack
#
# by Dominique Weber & Alexandra Erbach, HAFL, BFH
############################################################

calc_diff = function(nbr_stk, comp_stk, cloud_value, nodata_value, out_path, tile){
  
  # load packages
  library(raster)
  library(foreach)
  library(doParallel)
  
  # register for paralell processing
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  
  # build NBR stack & save NDVIs & NBRs
  n = nlayers(nbr_stk)
  dates_nbr_stk = as.Date(substring(names(nbr_stk),2,9), format = "%Y%m%d")
  dates_comp_stk = as.Date(substring(names(comp_stk),2,9), format = "%Y%m%d")
  
  ind_comp = rep(NA,n)
  for (i in 1:n){
    ind_comp[i] = which(dates_comp_stk < dates_nbr_stk[i])[1]
  }
  ind_comp = ind_comp[which(!is.na(ind_comp))]
  
  diff_stk = foreach(i=length(ind_comp):1, .packages = c("raster"), .combine = "addLayer") %dopar% {  
    
    j = ind_comp[i]
    diff_tmp = nbr_stk[[i]]-comp_stk[[j]]
    diff_tmp[(nbr_stk[[i]] == cloud_value)] = cloud_value # clouds
    diff_tmp[(nbr_stk[[i]] == nodata_value) | (is.na(comp_stk[[j]]))] = nodata_value # nodata
    time_int = as.integer(dates_nbr_stk[i] - dates_comp_stk[j])
    ras_name = paste(tile,"_NBR_diff_",substr(names(nbr_stk[[i]]),2,9),"_",time_int,"days", sep="")
    #cloud_perc = round(100*ncell(diff_tmp[diff_tmp==cloud_value])/(ncell(diff_tmp[diff_tmp!=nodata_value])))
    
    # save as 16 Bit Integer
    writeRaster(diff_tmp, paste(out_path, ras_name,".tif",sep=""), overwrite=T, datatype='INT2S')
    
    return(diff_tmp)
  }
  
  stopCluster(cl)
  
  names(diff_stk) = paste(tile,"_NBR_diff_",substr(names(nbr_stk[[1:length(ind_comp)]]),2,9),sep="")
  return(diff_stk)
  
}