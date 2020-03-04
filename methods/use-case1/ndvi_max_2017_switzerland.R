############################################################
# Calculate NDVI max composite for Switzerland.
# 
# by Dominique Weber, BFH-HAFL
############################################################

start_time <- Sys.time()

library(raster)

# source functions
source("calc_ndvi_max.R")
source("mosaic.R")

print("NDVI Max 2017")

# settings
base_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI1C/GeoTIFF"
band_names = c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B09", "B10","B11", "B12")
year = "2017"
months = c("06", "07")
tiles = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/Use-Case1"

print("processing tiles:")
print(tiles)
for(i in 1:length(tiles)) {
  # prepare
  images_path = file.path(base_path, tiles[i], year)
  dates_filter = paste(year, months, sep="")
  
  # calc max composite
  comp = calc_ndvi_max(images_path, band_names, dates_filter, ext=NULL, ind=F)
  
  # write
  writeRaster(comp, file.path(out_path, paste("ndvi_max_", tiles[i], ".tif", sep="")), overwrite=T)
}
print(Sys.time()- start_time)

print("mosaic")
Sys.time()
mosaic(out_path)
print(Sys.time()- start_time)

# TODO Clip to forest mask & polygonize