#===============================================================================#
# make composite of all Sentinel-2 bands where / when NDVI is maximal and add
# max. NDVI as new band. built on R-package rgee.

# by Attilio Benini, BFH-HAFL
#===============================================================================#
## FUNCTION ARGUMENTS ####
#-------------------------------------------------------------------------------#

# year:   numeric / year for which to calculate the max NDVI composite
# ee_aoi: ee.geometry.Geometry with area of interest to which die output GeoTIFF is restricted

#-------------------------------------------------------------------------------#
## FUNCTION ####
#-------------------------------------------------------------------------------#
ee_S2_max_ndvi <- function(year, ee_aoi = aoi, path_base = path_use_case_1){
  # start and end date of season (June, July, August)
  date_start <- paste0(year, '-06-01')
  date_end   <- paste0(year, '-09-01')
  
  # Sentine-2 imagery --> S2 for L1C, S2_SR for L2A
  S2 <- ee$ImageCollection('COPERNICUS/S2')$
    filterDate(date_start, date_end)$
    filterBounds(ee_aoi)
  
  # add layers
  addNDVI <- function(image) {
    image$addBands(image$normalizedDifference(list('B8', 'B4'))$rename('NDVI'))
  }
  # B8 = NIR, B4 = Red
  
  # add ndvi
  S2 <- S2$map(addNDVI)
  
  # build ndvi max composite
  S2$qualityMosaic('NDVI')
}
#===============================================================================#
# end of script
#===============================================================================#