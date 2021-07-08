############################################################
# Reclassify UC3 rasters for WMS
#
############################################################

# load library
library(raster)
library(doParallel)
library(foreach)

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

# main path
main_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3"
dirs = dir(paste0(main_path,"/New_results_final"), full.names=T)
out_dir = paste0(main_path,"/New_results_final_forWMS_new")

# loop over files
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

foreach(i=1:length(dirs), .packages=c("raster")) %dopar% {
  
  in_file = dirs[i]
  out_file = paste0(dir(main_path, pattern="NDVI_Anomaly")[i],"_forWMS.tif")
  out_file = file.path(out_dir, out_file)
  
  system(paste("gdal_calc.py -A ", in_file, " --outfile=", out_file, " --calc=\"(A<=-100)*A + (A>=100)*A + (A>-100)*(A<100)*(-32767)\" --co=\"PIXELTYPE=SIGNEDBYTE\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=-32767 --allBands=A --overwrite", sep=""))
}

stopCluster(cl)
