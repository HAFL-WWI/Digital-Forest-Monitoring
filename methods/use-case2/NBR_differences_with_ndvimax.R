############################################################
# Automatic calculation of NBR differences (with NDVI max archive)
#
# by Alexandra Erbach, HAFL, BFH
############################################################

start_time <- Sys.time()

library(raster)
library(rgdal)
library(foreach)
library(doParallel)

# set working directory
setwd("~/")

# source function
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/calc_nbr_composite.R")

# parameters
ref_date = as.Date("2017-08-06") # Sys.Date()
time_int_nbr = 3
time_int_refstack = 45 # in days
tile = "T32TMT"
year = "2017"

# paths
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI2Ap/SAFE/"
stack_path = paste(main_path,tile,"/",year,"/", sep="")
nbr_path = "//home/eaa2/nbr_test_ndvimax/nbr/"
comp_path = "//home/eaa2/nbr_test_ndvimax/ndvimax/"
diff_path = "//home/eaa2/nbr_test_ndvimax/nbr_diff/"

# filter files and dates
B8Names = list.files(stack_path, pattern="B08_10m", recursive=T)
dates_all = as.Date(substring(lapply(strsplit(B8Names,"_"), "[[", 3),1,8), format = "%Y%m%d")
nbr_files = list.files(nbr_path)
comp_files = list.files(comp_path)
dates_nbr = as.Date(substring(lapply(strsplit(nbr_files,"_"), "[[", 3),1,8), format = "%Y%m%d")

#dates_todo = which(dates_all > max(dates_nbr))
dates_todo = which((dates_all <= ref_date) & (dates_all >= ref_date-time_int_nbr))

if (length(dates_todo)>0){
  
  B8Names = B8Names[dates_todo]
  filesB8 = B8Names
  B8Names = paste(stack_path, B8Names, sep="")

  B12Names = list.files(stack_path, pattern="B12_20m", recursive=T)
  B12Names = B12Names[dates_todo]
  B12Names = paste(stack_path, B12Names, sep="")

  sclNames = list.files(stack_path, pattern="SCL_20m", recursive=T)
  sclNames = sclNames[dates_todo]
  sclNames = paste(stack_path, sclNames, sep="")

  # register for paralell processing
  print("starting multi-core processing, applying stack function...")
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)

  # build NBR stack
  vi_stk = foreach(i=length(filesB8):1, .packages = c("raster"), .combine = "addLayer") %dopar% {
    
    # calculate indices
    b8 = raster(B8Names[i])
    b12 = disaggregate(raster(B12Names[i]),2)
    scl = disaggregate(raster(sclNames[i]),2)
    vi_tmp = (b8 - b12)/(b8 + b12)
    vi_tmp[scl %in% c(3, 7:10)] <- -9
    vi_tmp_name = paste(tile, "_NBR_", substring(lapply(strsplit(filesB8[i],"_"), "[[", 3),1,8), sep="")
    writeRaster(vi_tmp, paste(nbr_path,vi_tmp_name,".tif",sep=""), overwrite=T)
  
    return(vi_tmp)
  }
  
  # build NBR-NDVImax composite stack
  comp_stk = foreach(i=length(filesB8):1, .packages = c("raster"), .combine = "addLayer") %dopar% {
    # start with most recent date!
    
    # define dates
    date_to_do = as.Date(substring(lapply(strsplit(B8Names[i],"_"), "[[", 3),1,8), format = "%Y%m%d")
    ind_dates = which((dates_all <= date_to_do) & (dates_all >= date_to_do - time_int_refstack))
    dates_for_comp = gsub("-","",dates_all[ind_dates])
    
    # call calc_pixel_comp function
    comp_tmp = calc_pixel_composites (stack_path, dates_for_comp)
    
    comp_tmp_name = paste(tile, "_NBR_comp_", dates_for_comp[1], "_", dates_for_comp[length(dates_for_comp)], sep="")
    writeRaster(comp_tmp, paste(comp_path,comp_tmp_name,".tif",sep=""), overwrite=T)
    
    return(comp_tmp)
  }
  
  # delete last NBR & NBR-NDVI composite if necessary
  ind = which(dates_nbr < ref_date - time_int_nbr)
  if (length(ind)>0){
    unlink(paste(nbr_path, nbr_files[ind],sep=""))
    unlink(paste(comp_path, comp_files[ind],sep="")) # careful, may be dangerous based on only one index if sth goes wrong?
    nbr_files = nbr_files[-ind]
    comp_files = comp_files[-ind]
  }
  
  # get old NBRs & NBR-NDVI composites within time range if existant
  if (length(nbr_files)>0){
    nbr_stack_old = stack(paste(nbr_path, rev(nbr_files), sep=""))
    vi_stk = stack(vi_stk, nbr_stack_old)
    }
  names(vi_stk) = rev(unlist(lapply(strsplit(list.files(nbr_path),".tif"), "[[", 1)))
  
  if (length(comp_files)>0){
    comp_stack_old = stack(paste(comp_path, rev(comp_files), sep=""))
    comp_stk = stack(comp_stk, comp_stack_old)
  }
  names(comp_stk) = rev(unlist(lapply(strsplit(list.files(comp_path),".tif"), "[[", 1)))
  
  # save dates to csv
  df = data.frame(nbr_dates = substr(names(vi_stk),2,9))
  write.csv(df, file="nbr_dates.csv", row.names=F, quote=F)
  
  # clip to forest mask > could be saved per tile in order to increase speed, or use gdal...
  #forest_mask = raster("Z_Wald_wgs84.tif")
  #forest_mask = crop(forest_mask, raster(vi_stk[[1]]), snap='near')
  #forestmask_recl = resample(forest_mask, raster(vi_stk[[1]]))
  forestmask_recl = raster("forest_mask_T32TMT.tif")
  vi_stk = mask(vi_stk, forestmask_recl)
  comp_stk = mask(comp_stk, forestmask_recl)

  # calculating difference raster
  for (i in length(dates_todo):1){
      nbr_diff = vi_stk[[i]]-vi_comp[[i]]
      nbr_diff = round(nbr_diff*100)
      nbr_diff[(vi_stk[[i]] == -9)] = -999
      #ras_name = paste(tile,"_NBR_diff_",substr(names(vi_stk[[i]]),2,9),"_",substr(names(vi_stk[[j]]),2,9),sep="")
      cloud_perc = round(100*ncell(nbr_diff[nbr_diff==-999])/(ncell(nbr_diff[!is.na(nbr_diff)])))
     
      # projekt to EPSG:3857 and save as 16 Bit Integer
      NAvalue(nbr_diff) = -999
      nbr_diff_3857 = projectRaster(nbr_diff, crs=CRS("+init=epsg:3857"), method='ngb')
      writeRaster(nbr_diff_3857, paste(diff_path, ras_name,"_",cloud_perc,".tif",sep=""), overwrite=T, datatype='INT2S')
    }

stopCluster(cl)
}
print(Sys.time() - start_time)