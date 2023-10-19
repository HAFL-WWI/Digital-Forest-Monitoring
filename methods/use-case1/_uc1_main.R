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
prevyear = "2022"
curryear = "2023"

# for 5 Polygonization
years = c(paste0(curryear, "_", prevyear)) # process single year

#-----------------------------------------#
####           DEFAULT SETTINGS        ####
#-----------------------------------------#
basepath = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
ch_shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissBOUNDARIES3D/swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET.shp"
forest_mask = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95_rs.tif" 

# crs to project into
crs = "EPSG:3857"

# parameters for 5 POLYGONIZE
minsize = units::set_units(399, m^2) # default is >399 (>= 400), but may be increased as threshold is lowered (e.g. 499 for thr=-600)
minsize_pixels = round(units::drop_units(minsize) / 100) # 1 pixel = 100 m^2 
# threshold used to be -1000 (until Oct 2022).
# For raster generation we now use a much less restrictive threshold (-200) to allow threshold adjustements via styling
# For polygonization, the threshold was updated to -600.
thrvalue = -600 
out_path = basepath
previous_suffix = "_Int16_EPSG3857"
add_suffix = paste0("_NA-", abs(thrvalue)) # added to files where threshold is applied

# use gdal_sieve to remove patches smaller than threshhold before polygonization 
# (achieving the same result with usually faster computation time!)
GDAL_SIEVE = TRUE
GDAL_SIEVE_OutputRaster = TRUE
# use morphological image operations to remove spots, noise, thin lines, extrusions and close gaps 
# --- EXPERIMENTAL! --- 
# also messes up CRS with writeRaster (CRS needs to be manually reassigned on older R versions)
MORPH = FALSE
# skip polygonize (if just generating rasters)
SKIP_POLYGONIZE = FALSE

#-----------------------------------------#
####         > generate paths          ####
#-----------------------------------------#
# automatically generate paths based on above settings

## paths 2 GEE Postprocessing (ndvi_max_gee_postprocess)
out_dir = paste0(basepath, "/NDVI_max_", curryear)
mosaic_file = file.path(out_dir, "ndvi_max.tif")
mosaic_ch_file = file.path(out_dir, "ndvi_max_ch.tif")
mosaic_ch_forest_file = file.path(out_dir, "ndvi_max_ch_forest.tif")

## paths 3 CALC_DIFF
ndvi_prevyear = paste0(basepath, "/NDVI_max_", prevyear ,"/ndvi_max_ch_forest.tif")
ndvi_curryear = paste0(basepath, "/NDVI_max_", curryear, "/ndvi_max_ch_forest.tif")
diff_raster_path = paste0(basepath, "/ndvi_diff_", curryear, "_", prevyear, "_Int16.tif")

## paths 4 REPROJECT
## filename pattern of files that are to be reprojected
filename_pattern = paste0(curryear, "_", prevyear, "_Int16.tif")

## paths 5 POLYGONIZE
# in_path = paste0(basepath, "/ndvi_diff_", tools::file_path_sans_ext(filename_pattern), "_EPSG3857.tif")
in_path = file.path(basepath, paste0("ndvi_diff_", years[1], previous_suffix, ".tif"))

# out shp layer & raster
lyr = paste0("ndvi_diff_", years[1], previous_suffix, add_suffix)
# out_shp = paste0(out_path, "/", lyr, ".shp")
out_gpkg = paste0(out_path, "/", lyr, ".gpkg")
out_ras_name = paste0(lyr,  ".tif")
out_ras = paste0(out_path,"/",out_ras_name)
out_mask_name = paste0(lyr,"_mask.tif")
out_mask = file.path(out_path,"temp",out_mask_name)

if(GDAL_SIEVE){
  out_mask_sieved_name = paste0(lyr,"_mask_sieved_EPSG3857.tif")
  out_mask_sieved = file.path(out_path,"temp",out_mask_sieved_name)
  out_mask_sieved_b_name = paste0(lyr,"_mask_sieved_byte_EPSG3857.tif")
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


# END ...
print(Sys.time()- start_time)
print("DONE calculating difference.")

#------------------------------------------------------------------#
#### 4 REPROJECT ####
#------------------------------------------------------------------#
# Reproject diff rasters

# START reprojecting...
print("Start reprojecting")
start_time <- Sys.time()

# create gdalwarp command and execute
cmd = paste("gdalwarp -t_srs", crs, "-r bilinear -tr 10 10 -co COMPRESS=LZW", diff_raster_path, in_path)
system(cmd)

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


# create binary mask & raster for WMS publication (values > thrvalue auf NA)
print(paste0("raster for WMS/WCS publication (values < ", thrvalue, " => NA)..."))
system(paste("gdal_calc.py -A ", in_path,  " --outfile=", out_ras, " --calc=\"(A<=", thrvalue, ")*A\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=0 --overwrite", sep=""))
print("create binary mask...")
system(paste("gdal_calc.py -A ", out_ras,  " --outfile=", out_mask, " --calc=\"A<0\" --co=\"COMPRESS=LZW\" --type='Byte' --NoDataValue=0 --overwrite", sep=""))
print(Sys.time() - start_time) 

if(GDAL_SIEVE){
  print("filter raster with gdal_sieve...")
  
  out_mask_sieved_name = paste0(lyr,"_mask_sieved.tif")
  out_mask_sieved = file.path(out_path,"temp",out_mask_sieved_name)
  out_mask_sieved_b_name = paste0(lyr,"_mask_sieved_byte.tif")
  out_mask_sieved_b = file.path(out_path,"temp",out_mask_sieved_b_name)
  
  # sieve with gdal (remove patches smaller than threshhold)
  # change no data value, since sieve doesn't filter areas surrounded by NA
  system(paste("gdal_edit.py -a_nodata 255", out_mask, sep=" ")) 
  # sieve with -st AREA_THRESHOLD = minsize_pixels
  print(paste0(" - gdal_sieve removes pixel patches with less than ", minsize_pixels, " pixels"))
  system(paste("gdal_sieve.py -st", minsize_pixels, out_mask, out_mask_sieved, sep=" "))
  # output is always Integer; sieve doesn't allow creation options, set NA value to 0 again
  system(paste("gdal_translate -ot Byte -a_nodata 0 -co \"COMPRESS=LZW\" ", out_mask_sieved, out_mask_sieved_b, sep=" "))
  # clean up (large) temporary files
  print(" - cleanup")
  file.remove(out_mask_sieved) # mask sieved is an unnecessary, uncompressed Int16-raster with probably >1GB
  
  if(GDAL_SIEVE_OutputRaster) {
    print(" - create sieved raster with sieved mask")
    out_raster_sieved_name = paste0(lyr,"_sieved.tif")
    out_raster_sieved = file.path(out_path,out_raster_sieved_name)
    system(paste("gdal_calc.py -A ", out_ras, " -B ", out_mask_sieved_b, " --outfile=", out_raster_sieved, " --calc=\"A*B\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=0 --overwrite", sep=""))
  }
  
  # continue further processing with sieved raster
  print(" - continue with sieved mask")
  out_mask = out_mask_sieved_b
}
print(Sys.time() - start_time) 

# optional morphological operations to further "clean up" the mask
if(MORPH){
  # raster to polygon
  print("run morphological processing...")
  # --- EXPERIMENTAL --- #
  # morphological image processing
  library(EBImage)
  # mask_raster = raster(file.path(out_path,"temp","ndvi_diff_2022_2021_Int16_EPSG3857_clip_mask.tif")) # test file
  print(" - load raster")
  mask_raster = raster(file.path(out_path,"temp","ndvi_diff_2022_2021_Int16_EPSG3857_clip_mask.tif"))
  print(" - extract matrix")
  mask_matrix = as.matrix(mask_raster) # creates a "Large matrix (2903145 elements, 11.1 Mb): int [1:1505, 1:1929]"
  # mask_vector = mask_raster[,] # creates a "Large integer (2903145 elements, 11.1 Mb): int [1:2903145]"
  
  kern3 = makeBrush(3, shape='box')
  kern5 = makeBrush(5, shape='box')
  print(" - morphological closing, kernel 3")
  mask_matrix = closing(mask_matrix, kern3)
  print(" - morphological opening, kernel 3")
  mask_matrix = opening(mask_matrix, kern3)
  # display(mask_matrix)
  # display(erode(mask_matrix, kern), title='Erosion of x')
  # display(dilate(mask_matrix, kern), title='Dilatation of x')
  
  print(" - create output")
  out_mask_morph_name = paste0(lyr,"_mask_morphed.tif")
  out_mask_morph = file.path(out_path,"temp",out_mask_morph_name)
  mask_raster[] = mask_matrix
  writeRaster(mask_raster, out_mask_morph, datatype ="INT1U", options="COMPRESS=LZW", overwrite = T)
  print(" - continue with morphed mask")
  out_mask = out_mask_morph
}

# polygonization may take really long (several hours)
if(!SKIP_POLYGONIZE){
  # raster to polygon
  print("raster to polygon...")
  # system(paste("gdal_polygonize.py", out_mask, out_shp, sep=" "))
  system(paste("gdal_polygonize.py", out_mask, out_gpkg, sep=" "))
  
  print(paste0("calculate area and filter polygons smaller than minsize = ", minsize, " m^2"))
  # diffmask_sf = read_sf(out_shp)
  diffmask_sf = read_sf(out_gpkg)
  # calculate area
  diffmask_sf$area = diffmask_sf$area <- round(st_area(diffmask_sf))
  #filter out surfaces smaller than min. size
  diffmask_sf = diffmask_sf[which(diffmask_sf$area > minsize),]
  
  # calculate mean change per polygon
  # this was implemented using R-package velox, which no longer is maintained (https://github.com/hunzikp/velox/issues/43)
  # switched to exact_extract in Oct 2022
  print("calculate attributes per polygon...")
  diff_raster = raster(in_path)
  print(Sys.time() - start_time)
  
  print("calculate meandiff per polygon...")
  meandiff = exact_extract(diff_raster, diffmask_sf, 'mean')
  # prettify values (raster values were multiplied by 10000 to be stored as int)
  diffmask_sf$meandiff <- round(meandiff/10000, 3)
  print(Sys.time() - start_time)
  
  print("calculate sumdiff per polygon...")
  sumdiff = exact_extract(diff_raster, diffmask_sf, 'sum')
  diffmask_sf$sumdiff <- round(sumdiff/10000, 3)
  print(Sys.time() - start_time)
  
  print("calculate maxdiff per polygon...")
  maxdiff = exact_extract(diff_raster, diffmask_sf, 'max')
  diffmask_sf$maxdiff <- round(maxdiff/10000, 3)
  print(Sys.time() - start_time)
  
  print("count diff pixels per polygon...")
  countdiff = exact_extract(diff_raster, diffmask_sf, 'count')
  diffmask_sf$countdiff <- round(countdiff, 3)
  print(Sys.time() - start_time)
  
  # drop first column
  diffmask_sf = diffmask_sf[,-1]
  
  ## shape deprecated, use geopackage instead (for better performance and an overall better format :])
  ## save shapefile > careful, CRS might not be correctly set. Check with GIS.
  # print("save shapefile...")
  # st_write(diffmask_sf, file.path(out_path, paste0(lyr, ".shp")), delete_dsn = T )
  
  print("save geopackage...")
  st_write(diffmask_sf, file.path(out_path, paste0(lyr, ".gpkg")) )
}


print("Finished vectorization")
print(Sys.time() - start_time) 

print("ALL STEPS DONE")
print("Overall Time:")
print(Sys.time() - start_time_overall)