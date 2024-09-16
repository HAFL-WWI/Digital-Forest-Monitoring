#===============================================================================#
# show slider map of max. NDVI composite and RGB deriving from the same date as
# the max. NDVI. built on R-package rgee.

# by Attilio Benini, BFH-HAFL
#===============================================================================#
## FUNCTION ARGUMENTS ####
#-------------------------------------------------------------------------------#

# S2_max_ndvi:  composite of all Sentinel-2 bands where / when NDVI is maximal with max. NDVI as added band
# year:         numeric / year for which the composite was calculated
# ee_aoi:       ee.geometry.Geometry with area of interest to which die output GeoTIFF is restricted
# zoom:         integer / zoom level

#-------------------------------------------------------------------------------#
## FUNCTION ####
#-------------------------------------------------------------------------------#
ee_map_max_ndvi_rgb <- function(S2_max_ndvi, year, ee_aoi = aoi, zoom = 10){
  Map$centerObject(ee_aoi, zoom = zoom)
  map_ndvi_max <- Map$addLayer(S2_max_ndvi$select('NDVI'), list(min = 0, max =  1, palette = c('red', 'blue', 'green')), paste0('max NDVI composite: ', year))
  map_rgb      <- Map$addLayer(S2_max_ndvi, list(bands = c('B4', 'B3', 'B2'), max = 2500), paste0('Greenest pixel composite (RGB): ', year))
  map_ndvi_max | map_rgb
}
#===============================================================================#
# end of script
#===============================================================================#