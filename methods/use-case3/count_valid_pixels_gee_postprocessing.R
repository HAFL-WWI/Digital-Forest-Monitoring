############################################################
# Mosaic and clip ndvi anomalies exported from google earth engine 
#
# IMPORTANT: Forest mask must have same crs, dimension, extent, origin as mosaic
# see scripts under Digital-Forest-Monitoring/misc
#
# by Dominique Weber, BFH-HAFL
############################################################

# load library
library(raster)

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

# source functions
source("use-case1/mosaic.R")

###########################################
# define year and output directory here
out_dir = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3/valid_mon_2020_06-07"
###########################################

###########################################
# DEFAULT SETTINGS
ch_shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissBOUNDARIES3D/swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET.shp"
forest_mask = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95_rs.tif" 
mosaic_file = file.path(out_dir, "ndvi_anomaly.tif")
mosaic_ch_file = file.path(out_dir, "ndvi_anomaly_ch.tif")
mosaic_ch_file_byte = file.path(out_dir, "ndvi_anomaly_ch_byte.tif")
mosaic_ch_forest_file = file.path(out_dir, "ndvi_anomaly_ch_forest.tif")
###########################################

# START...
start_time <- Sys.time()

print("mosaic all tiles...")
mosaic(out_dir, mosaic_file, ".tif")
print(Sys.time()- start_time)

print("clip mosaic to swiss boundaries...")
system(paste("gdalwarp -cutline", ch_shp, "-crop_to_cutline -wo CUTLINE_ALL_TOUCHED=TRUE -dstnodata -9999", mosaic_file, mosaic_ch_file))

print("convert to byte...")
# TODO to make sure that forest mask has same dimension etc. it should be generated based on the extent of the mosaic
system(paste("gdal_calc.py -A ", mosaic_ch_file, " --outfile=", mosaic_ch_file_byte, " --calc=\"round_(A)\" --co=\"PIXELTYPE=SIGNEDBYTE\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=-9999", sep=""))

print("clip mosaic to forest mask...")
# TODO to make sure that forest mask has same dimension etc. it should be generated based on the extent of the mosaic
system(paste("gdal_calc.py -A ", mosaic_ch_file_byte," -B ", forest_mask, " --outfile=", mosaic_ch_forest_file, " --calc=\"A*(B==1)\" --co=\"PIXELTYPE=SIGNEDBYTE\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=-9999", sep=""))

# END ...
print(Sys.time()- start_time)