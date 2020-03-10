############################################################
# Calculate NDVI max composite for Switzerland.
#
# IMPORTANT: Forest mask must have same crs, dimension, extent, origin as mosaic
# see https://github.com/HAFL-FWI/Digital-Forest-Monitoring/blob/master/methods/misc/create_forest_mask.sh
# 
# by Dominique Weber, BFH-HAFL
############################################################

# load library
library(raster)

# source functions
source("calc_ndvi_max.R")
source("project.R")
source("mosaic.R")

###########################################
# define year and output directory here
year = "2018"
out_dir = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2018"
###########################################

###########################################
# DEFAULT SETTINGS
base_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI1C/GeoTIFF"
band_names = c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B09", "B10","B11", "B12")
months = c("06", "07")
tiles = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
ch_shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissBOUNDARIES3D/swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET.shp"
forest_mask = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95.tif" 
mosaic_file = file.path(out_dir, "ndvi_max.tif")
mosaic_ch_file = file.path(out_dir, "ndvi_max_ch.tif")
mosaic_ch_forest_file = file.path(out_dir, "ndvi_max_ch_forest.tif")
###########################################

# START...
start_time <- Sys.time()

# create ndvi max per tile
if (!dir.exists(out_dir)){ dir.create(out_dir) } 
print(paste("NDVI Max", year, "out path:", out_dir))
print("processing tiles:")
print(tiles)
for(i in 1:length(tiles)) {
  # prepare
  images_path = file.path(base_path, tiles[i], year)
  dates_filter = paste(year, months, sep="")
  
  # calc max composite
  comp = calc_ndvi_max(images_path, band_names, dates_filter, ext=NULL, ind=F)
  
  # write
  tiles_path = file.path(out_dir, "tiles")
  if (!dir.exists(tiles_path)){ dir.create(tiles_path) } 
  writeRaster(comp, file.path(tiles_path, paste("ndvi_max_", tiles[i], ".tif", sep="")), overwrite=T)
}
print(Sys.time()- start_time)

# TODO re-projection probably leads to less accuracte pixel locations 
print("project tiles to LV95...")
project(tiles_path)
print(Sys.time()- start_time)

print("mosaic all tiles...")
mosaic(tiles_path, mosaic_file)
print(Sys.time()- start_time)

print("clip mosaic to swiss boundaries...")
system(paste("gdalwarp -cutline", ch_shp, "-crop_to_cutline -wo CUTLINE_ALL_TOUCHED=TRUE -dstnodata -9999", mosaic_file, mosaic_ch_file))

print("clip mosaic to forest mask...")
# TODO to make sure that forest mask has same dimension etc. it should be generated based on the extent of the mosaic
system(paste("gdal_calc.py -A ", mosaic_ch_file," -B ", forest_mask, " --outfile=", mosaic_ch_forest_file, " --calc=\"A*(B==1)\" --co=\"COMPRESS=LZW\" --type='Float32' --NoDataValue=-9999", sep=""))

# END ...
print(Sys.time()- start_time)