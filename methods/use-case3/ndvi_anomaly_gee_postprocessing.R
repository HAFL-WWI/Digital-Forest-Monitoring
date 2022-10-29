#-------------------------------------------------------------------------------#
# Postprocess ndvi anomalies exported from google earth engine 
#
# IMPORTANT: Forest mask must have same crs, dimension, extent, origin as mosaic
# see scripts under Digital-Forest-Monitoring/misc
#
# by Dominique Weber & Alexandra Erbach, BFH-HAFL
#-------------------------------------------------------------------------------#

# load library
library(raster)
library(doParallel)
library(foreach)

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

# source functions
source("use-case1/mosaic.R")
source("general/dir_exists_create_func.R")

#-----------------------------------------#
####         GENERAL SETTINGS          ####
# main path
main_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3"
# dirs = dir(main_path, full.names=T, pattern="NDVI_Anomaly") # process all folders
dirs_name = dir(main_path, pattern="NDVI_Anomaly_2022") # process specific year
dirs = dir(main_path, full.names=T, pattern="NDVI_Anomaly_2022") # process specific year

#-----------------------------------------#

#-----------------------------------------#
####         DEFAULT SETTINGS          ####
# general parameters
ch_shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissBOUNDARIES3D/swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET.shp"
forest_mask = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95_rs.tif" 
crs = "EPSG:3857"
thr_valid = 5
tmp_name ="tmp_thr5"
#-----------------------------------------#

# init i (will be overwritten if parallelization is "activated" by uncommenting below lines)
i = 1
#------------------------------------------------#
####              PARALLELIZATION             ####
#------------------------------------------------#
# parallelization makes only sense when processing multiple rasters
# uncomment the following lines if you want to activate parallelization
# DON'T FORGET TO UNCOMMENT THE TWO LINES AT THE END OF THE PARALLELIZATION BLOCK
#------------------------------------------------#
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

foreach(i=1:length(dirs), .packages=c("raster")) %dopar% {
#------------------------------------------------#
  
  # source functions
  source("use-case1/mosaic.R")
  source("general/dir_exists_create_func.R")

  out_dir = paste0(dirs[i],"/")
  dir_exist_create(out_dir, tmp_name)
  #-----------------------------------------#
  
  #-----------------------------------------#
  ####      generate output paths        ####
  mosaic_file = file.path(paste0(out_dir, tmp_name), "ndvi_anomaly.tif")
  mosaic_ch_file = file.path(paste0(out_dir, tmp_name), "ndvi_anomaly_ch.tif")
  mosaic_ch_forest_file = file.path(paste0(out_dir, tmp_name), "ndvi_anomaly_ch_forest.tif")
  mosaic_ch_forest_filtered = file.path(paste0(out_dir, tmp_name), "ndvi_anomaly_ch_forest_filtered.tif")
  out_file_final = paste0(dirs_name[i],".tif") # name file like the subdir
  mosaic_ch_forest_filtered_3857 = file.path(out_dir, out_file_final)
  #-----------------------------------------#
  
  # START...
  start_time <- Sys.time()
  
  print("mosaic all tiles...")
  mosaic(paste0(out_dir,"/gee_output"), mosaic_file, ".tif")
  print(Sys.time()- start_time)
  
  print("clip mosaic to swiss boundaries...")
  system(paste("gdalwarp -cutline", ch_shp, "-crop_to_cutline -wo CUTLINE_ALL_TOUCHED=TRUE -dstnodata -32767 -overwrite", mosaic_file, mosaic_ch_file))
  # 
  print("clip mosaic to forest mask...")
  # TODO to make sure that forest mask has same dimension etc. it should be generated based on the extent of the mosaic
  system(paste("gdal_calc.py -A ", mosaic_ch_file," -B ", forest_mask, " --outfile=", mosaic_ch_forest_file, " --calc=\"A*(B==1)\" --co=\"PIXELTYPE=SIGNEDBYTE\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=-32767 --allBands=A --overwrite", sep=""))
  
  print("filter out pixels with insufficient number of valid dates")
  system(paste("gdal_calc.py -A ", mosaic_ch_forest_file," --A_band=1 -B ",mosaic_ch_forest_file, " --B_band=2 --outfile=", mosaic_ch_forest_filtered," --calc=\"(A*(B>",thr_valid,"))+(32767*(B<=",thr_valid,"))\" --co=\"PIXELTYPE=SIGNEDBYTE\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=-32767 --overwrite", sep=""))
  
  print("reproject")
  system(paste("gdalwarp -t_srs", crs, "-r bilinear -tr 10 10 -co COMPRESS=LZW -overwrite", mosaic_ch_forest_filtered, mosaic_ch_forest_filtered_3857))
  
  # END ...
  print(Sys.time()- start_time)
  
#------------------------------------------------#
# un/comment the following two lines (together with lines in parallelization block) 
# to toggle parallelization (closes loop)
}
stopCluster(cl)
#------------------------------------------------#

