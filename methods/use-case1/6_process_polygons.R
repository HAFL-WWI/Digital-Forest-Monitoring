#---------------------------------------------------------------------#
# Vector processing of NDVI changes
# THIS IS ONLY A STUB FOR FUTURE PROCESSING STEPS
#
# by Hannes Horneber (BFH-HAFL)
#---------------------------------------------------------------------#

library(raster)
library(rgdal)
library(sf) # for use with exactextractr
library(exactextractr) # replaces velox (fast raster extraction)
# for parallelization
library(foreach)
library(doParallel)

print(paste0("calculate area and filter polygons smaller than minsize = ", minsize, " m^2"))
# diffmask_sf = read_sf(out_shp)
diffmask_sf = read_sf(out_unfiltered_gpkg)
# calculate area
diffmask_sf$area = diffmask_sf$area <- round(st_area(diffmask_sf))
#filter out surfaces smaller than min. size
diffmask_sf = diffmask_sf[which(diffmask_sf$area > minsize),]