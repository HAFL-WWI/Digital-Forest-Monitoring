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
source("//home/eaa2/Digital-Forest-Monitoring/methods/general/dir_exists_create_func.R")
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/calc_diff.R")
  
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
  
  stopCluster(cl)
  
  # get composite stack
  comp_stk = stack(rev(list.files(comp_path, full.names=T)))[[1:length(dates_todo)]]

  # calculate NBR difference raster(s) and return stack
  nbr_diff = calc_diff (vi_stk, comp_stk, cloud_value, nodata_value, time_int_refstack, out_path = diff_path)

 }
}