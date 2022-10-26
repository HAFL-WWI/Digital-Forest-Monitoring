#-------------------------------------------------------------------------------#
# execute all steps necessary from gee_output to 
# the final (WMS-ready) yearly change raster and polygons
#
# IMPORTANT: Forest mask must have same crs, dimension, extent, origin as mosaic
# see scripts under Digital-Forest-Monitoring/misc
#
# by Hannes Horneber, BFH-HAFL
# based on scripts by Dominique Weber/Alexandra Erbach, BFH-HAFL
#-------------------------------------------------------------------------------#

# load library
library(raster)
# for vectorization
library(sf) # for use with exactextractr
library(exactextractr) # replaces velox (fast raster extraction)
# for reprojection / vectorization
library(foreach)
library(doParallel)

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

# source functions
source("use-case1/mosaic.R")

#-----------------------------------------#
####               SETTINGS            ####
#-----------------------------------------#
# define years here
prevyear = "2021"
curryear = "2022"

#-----------------------------------------#
####           DEFAULT SETTINGS        ####
#-----------------------------------------#
basepath = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
ch_shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissBOUNDARIES3D/swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET.shp"
forest_mask = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95_rs.tif" 

# crs to project into
crs = "EPSG:3857"

# parameters for vectorization
# parameters
minsize = units::set_units(399, m^2) # default is >399 (>= 400), but may be increased as threshold is lowered (e.g. 499 for thr=-600)
minsize_pixels = round(units::drop_units(minsize) / 100) # 1 pixel = 100 m^2, for gdal_sieve
thrvalue = -1000 # threshold was -1000, but -600 seems more appropriate. 
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
add_suffix = paste0("_NA-", abs(thrvalue)) # added to files where threshold is applied
year_diff = c(paste0(curryear, "_", prevyear))

# use gdal_sieve to remove patches smaller than threshhold before polygonization (usually faster computation time!)
GDAL_SIEVE = TRUE  


#-----------------------------------------#
####         > generate paths          ####
#-----------------------------------------#
# automatically generate paths based on above settings

## for ndvi_max_gee_postprocess
out_dir = paste0(basepath, "/NDVI_max_", curryear)
mosaic_file = file.path(out_dir, "ndvi_max.tif")
mosaic_ch_file = file.path(out_dir, "ndvi_max_ch.tif")
mosaic_ch_forest_file = file.path(out_dir, "ndvi_max_ch_forest.tif")

## for calc_diff
ndvi_prevyear = paste0(basepath, "/NDVI_max_", prevyear ,"/ndvi_max_ch_forest.tif")
ndvi_curryear = paste0(basepath, "/NDVI_max_", curryear, "/ndvi_max_ch_forest.tif")
diff_raster_path = paste0(basepath, "/ndvi_diff_", curryear, "_", prevyear, "_Int16.tif")

## filename pattern of files that are to be reprojected
filename_pattern = paste0(curryear, "_", prevyear, "_Int16.tif")

## paths for vectorization 
in_path = paste0(basepath, "/ndvi_diff_", year_diff, "_Int16_reproj_bilinear.tif")

# out shp layer & raster
lyr = paste0("ndvi_diff_", year)
out_shp = paste0(out_path, "/", lyr, ".shp")
out_ras_name = paste0(lyr,"_Int16_reproj_bilinear_forWMS.tif")
out_ras = paste0(out_path,"/",out_ras_name)
out_mask_name = paste0(lyr,"_mask.tif")
out_mask = paste0(out_path,"/",out_mask_name)

if(GDAL_SIEVE){
  out_mask_sieved_name = paste0(lyr,"_mask_sieved.tif")
  out_mask_sieved = file.path(out_path,"temp",out_mask_sieved_name)
  out_mask_sieved_b_name = paste0(lyr,"_mask_sieved_byte.tif")
  out_mask_sieved_b = file.path(out_path,"temp",out_mask_sieved_b_name)
}
#-----------------------------------------#

#------------------------------------------------------------------#
#### 1 GEE  #### 
# make sure you have executed the ndvi_max_gee_script.js
# on google earth engine (GEE) and saved results in the respective folder
#------------------------------------------------------------------#

start_time_overall <- Sys.time()

#------------------------------------------------------------------#
#### 2 GEE Postprocessing #### 
#------------------------------------------------------------------#

# START gee postprocessing...
print("Start google earth engine output post processing")
start_time <- Sys.time()

print("mosaic all tiles...")
mosaic(out_dir, mosaic_file, ".tif")
print(Sys.time()- start_time)

print("clip mosaic to swiss boundaries...")
system(paste("gdalwarp -cutline", ch_shp, "-crop_to_cutline -wo CUTLINE_ALL_TOUCHED=TRUE -dstnodata -9999", mosaic_file, mosaic_ch_file))

print("clip mosaic to forest mask...")
# TODO to make sure that forest mask has same dimension etc. it should be generated based on the extent of the mosaic
system(paste("gdal_calc.py -A ", mosaic_ch_file," -B ", forest_mask, " --outfile=", mosaic_ch_forest_file, " --calc=\"A*(B==1)\" --co=\"COMPRESS=LZW\" --type='Float32' --NoDataValue=-9999", sep=""))

# END ...
print(Sys.time()- start_time)
print("DONE with gee postprocessing.")


#------------------------------------------------------------------#
#### 3 CALC DIFF #### 
#------------------------------------------------------------------#
# Calculate NDVI max composite difference 
#-----------------------------------------#

# START calc diff...
print("Start calculating difference")
system(paste("gdal_calc.py -A ", ndvi_curryear, " -B ", ndvi_prevyear, " --outfile=", diff_raster_path, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
print(Sys.time()- start_time)

# END ...
print(Sys.time()- start_time)
print("DONE calculating difference.")

#------------------------------------------------------------------#
#### 4 REPROJECT ####
#------------------------------------------------------------------#
# Reproject diff rasters

# source functions
source("use-case1/project.R")

# START reprojecting...
print("Start reprojecting")
start_time <- Sys.time()

# call function (see function code to understand behavior)
project(basepath, crs, filename_pattern)

# END ...
print(Sys.time()- start_time)
print("DONE reprojecting.")


#------------------------------------------------------------------#
####       5 POLYGONIZE      ####
#------------------------------------------------------------------#
# Vectorization of NDVI Max change surfaces

# START reprojecting...
print("Start vectorization")
start_time <- Sys.time()

if(GDAL_SIEVE){
  # sieve with gdal (remove patches smaller than threshhold)
  # change no data value, since sieve doesn't filter areas surrounded by NA
  system(paste("gdal_edit.py -a_nodata 255", out_mask, sep=" ")) 
  # sieve with -st AREA_THRESHOLD = minsize_pixels
  system(paste("gdal_sieve.py -st", minsize_pixels, out_mask, out_mask_sieved, sep=" "))
  # output is always Integer; sieve doesn't allow creation options, set NA value to 0 again
  system(paste("gdal_translate -ot Byte -a_nodata 0 -co \"COMPRESS=LZW\" ", out_mask_sieved, out_mask_sieved_b, sep=" "))
  # clean up (large) temporary files
  file.remove(out_mask_sieved) # mask sieved is an unnecessary, uncompressed Int16-raster with probably >1GB
  
  # continue further processing with sieved raster
  out_mask = out_mask_sieved_b
}

# create binary mask & raster for WMS publication (values > thrvalue auf NA)
print("create binary mask...")
system(paste("gdal_calc.py -A ", in_path,  " --outfile=", out_ras, " --calc=\"(A<=", thrvalue, ")*A\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=0 --overwrite", sep=""))
system(paste("gdal_calc.py -A ", out_ras,  " --outfile=", out_mask, " --calc=\"A<0\" --co=\"COMPRESS=LZW\" --type='Byte' --NoDataValue=0 --overwrite", sep=""))

# raster to polygon
print("raster to polygon...")
system(paste("gdal_polygonize.py", out_mask, out_shp, sep=" "))

print("calculate area and mean diff...")
diffmask_sf = read_sf(out_shp)
# calculate area
diffmask_sf$area <- round(st_area(diffmask_sf))
#filter out surfaces smaller than min. size
diffmask_sf = diffmask_sf[which(diffmask_sf$area > minsize),]

# calculate mean change per polygon
# this was implemented using R-package velox, which no longer is maintained (https://github.com/hunzikp/velox/issues/43)
# switched to exact_extract in Oct 2022
print("calculate mean change per polygon...")
diff_raster = raster(in_path)
meandiff = exact_extract(diff_raster, diffmask_sf, 'mean')
# prettify values (raster values were multiplied by 10000 to be stored as int)
diffmask_sf$meandiff <- round(meandiff/10000, 3)

# drop first column
diffmask_sf = diffmask_sf[,-1]

## shape deprecated, use geopackage instead (for better performance and an overall better format :])
## save shapefile > careful, CRS might not be correctly set. Check with GIS.
# print("save shapefile...")
# st_write(diffmask_sf, file.path(out_path, paste0(lyr, ".shp")), delete_dsn = T )

print("save geopackage...")
st_write(diffmask_sf, file.path(out_path, paste0(lyr, ".gpkg")), delete_dsn = T )

print(Sys.time() - start_time) 
print("Finished vectorization")

print("ALL STEPS DONE")
print(Sys.time() - start_time_overall)

