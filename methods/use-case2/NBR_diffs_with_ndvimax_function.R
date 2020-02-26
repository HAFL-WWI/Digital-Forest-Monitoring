############################################################
# Function for automatic calculation of NBR differences (with NDVI max archive)
#
# by Alexandra Erbach, HAFL, BFH
############################################################

calc_nbr_differences = function(main_path, out_path, tile="T32TMT", year="2017", ref_date=as.Date("2017-08-09"), time_int_nbr=5, time_int_refstack=45, scl_vec=c(3,5,7:10), cloud_value=-999, nodata_value=-555){

# load packages
library(raster)
library(foreach)
library(doParallel)

# source functions
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/calc_nbr_composite.R")
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/dir_exists_create_func.R")
  
# paths
stack_path = paste(main_path,tile,"/",year,"/", sep="")
out_path = dir_exist_create(out_path,paste(tile,"/",sep=""))
out_path = dir_exist_create(out_path,paste(year,"/",sep=""))
nbr_raw_path = dir_exist_create(out_path,"nbr_raw/")
ndvi_raw_path = dir_exist_create(out_path,"ndvi_raw/")
nbr_path = dir_exist_create(out_path,"nbr/")
comp_path = dir_exist_create(out_path,"nbr_comp/")
diff_path = dir_exist_create(out_path,"nbr_diff/")

# filter files and dates
B8Names = list.files(stack_path, pattern="B08_10m", recursive=T)
dates_all = as.Date(substring(lapply(strsplit(B8Names,"_"), "[[", 3),1,8), format = "%Y%m%d")
nbr_files = list.files(nbr_path)
dates_nbr = as.Date(substring(lapply(strsplit(nbr_files,"_"), "[[", 3),1,8), format = "%Y%m%d")

#dates_todo = which(dates_all > max(dates_nbr))
dates_todo = which((dates_all <= ref_date) & (dates_all >= ref_date-time_int_nbr))

if (length(dates_todo)>0){
  
  B8Names = B8Names[dates_todo]
  filesB8 = B8Names
  B8Names = paste(stack_path, B8Names, sep="")

  B4Names = list.files(stack_path, pattern="B04_10m", recursive=T, full.names = T)[dates_todo]
  B12Names = list.files(stack_path, pattern="B12_20m", recursive=T, full.names = T)[dates_todo]
  sclNames = list.files(stack_path, pattern="SCL_20m", recursive=T, full.names = T)[dates_todo]

  # register for paralell processing
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)

  # build NBR stack & save NDVIs & NBRs
  vi_stk = foreach(i=length(dates_todo):1, .packages = c("raster"), .combine = "addLayer") %dopar% {
    
    # calculate indices
    b4 = raster(B4Names[i])
    b8 = raster(B8Names[i])
    b12 = disaggregate(raster(B12Names[i]),2)
    scl = disaggregate(raster(sclNames[i]),2)
    
    ndvi = (b8 - b4)/(b8 + b4)
    ndvi_name = paste(tile, "_NDVI_", substring(lapply(strsplit(filesB8[i],"_"), "[[", 3),1,8), sep="")
    writeRaster(ndvi, paste(ndvi_raw_path,ndvi_name,".tif",sep=""), overwrite=T)
    
    vi_tmp = (b8 - b12)/(b8 + b12)
    nbr_raw_name = paste(tile, "_NBR_", substring(lapply(strsplit(filesB8[i],"_"), "[[", 3),1,8), sep="")
    writeRaster(vi_tmp, paste(nbr_raw_path, nbr_raw_name,".tif",sep=""), overwrite=T)
    
    # mask clouds and nodata
    vi_tmp[scl %in% scl_vec] = cloud_value # clouds
    vi_tmp[scl == 0] = nodata_value # nodata
    vi_tmp_name = paste(tile, "_NBRc_", substring(lapply(strsplit(filesB8[i],"_"), "[[", 3),1,8), sep="")
    writeRaster(vi_tmp, paste(nbr_path,vi_tmp_name,".tif",sep=""), overwrite=T)
    
    return(vi_tmp)
  }
  names(vi_stk) = substring(lapply(strsplit(filesB8[nlayers(vi_stk):1],"_"), "[[", 3),1,8)
  
  # build NBR-NDVImax composite stack
  comp_stk = foreach(i=length(dates_todo):1, .packages = c("raster"), .combine = "addLayer") %dopar% {
 
    # define dates within time interval
    date_to_do = as.Date(substring(lapply(strsplit(B8Names[i],"_"), "[[", 3),1,8), format = "%Y%m%d")
    ind_dates = which((dates_all < date_to_do) & (dates_all >= date_to_do - time_int_refstack))
    dates_for_comp = gsub("-","",dates_all[ind_dates])
    
    # call calc_pixel_comp function
    comp_tmp = calc_pixel_composites (stack_path, ndvi_raw_path, nbr_raw_path, dates_for_comp, tile)
    
    comp_tmp_name = paste(tile, "_NBR_comp_", dates_for_comp[1], "_", dates_for_comp[length(dates_for_comp)], sep="")
    writeRaster(comp_tmp, paste(comp_path,comp_tmp_name,".tif",sep=""), overwrite=T)
    
    return(comp_tmp)
  }
  
  # calculate NBR difference raster(s)
  # --> function(stk1, stk2, cloud_value, nodata_value, time_int)
  for (i in length(dates_todo):1){
      nbr_diff = vi_stk[[i]]-comp_stk[[i]]
      nbr_diff = round(nbr_diff*100)
      nbr_diff[(vi_stk[[i]] == cloud_value)] = cloud_value # clouds
      nbr_diff[(vi_stk[[i]] == nodata_value)] = nodata_value # nodata
      ras_name = paste(tile,"_NBR_diff_",substr(names(vi_stk[[i]]),2,9),"_",time_int_refstack,"days", sep="")
      cloud_perc = round(100*ncell(nbr_diff[nbr_diff==cloud_value])/(ncell(nbr_diff[nbr_diff!=nodata_value])))
     
      # save as 16 Bit Integer
      writeRaster(nbr_diff, paste(diff_path, ras_name,"_",cloud_perc,".tif",sep=""), overwrite=T, datatype='INT2S')
    }

  stopCluster(cl)

  # delete files if necessary
  # --> function(path, refdate, time_int, path_vec_delete)
  # 1) NDVI & NBR raw files
  nbr_raw_files = list.files(nbr_raw_path)
  dates_nbr_raw = as.Date(substring(lapply(strsplit(nbr_raw_files,"_"), "[[", 3),1,8), format = "%Y%m%d")
  ind = which(dates_nbr_raw < ref_date - time_int_nbr - time_int_refstack)
  if (length(ind)>0){
    unlink(list.files(nbr_raw_path, full.names = T)[ind],sep="")
    unlink(list.files(ndvi_raw_path, full.names = T)[ind],sep="")
  }
  
  # 2) cNBRs and composites and difference rasters
  nbr_files = list.files(nbr_path)
  dates_nbr = as.Date(substring(lapply(strsplit(nbr_files,"_"), "[[", 3),1,8), format = "%Y%m%d")
  ind_nbr = which(dates_nbr < ref_date - time_int_nbr)
  if (length(ind_nbr)>0){ # careful, may be dangerous based on only one index if sth goes wrong?
    unlink(list.files(nbr_path, full.names=T)[ind_nbr])
    unlink(list.files(comp_path, full.names=T)[ind_nbr]) 
    unlink(list.files(diff_path, full.names=T)[ind_nbr]) 
  } 

}
}