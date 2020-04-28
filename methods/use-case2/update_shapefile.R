############################################################
# Update change shapefile if existing.
#
# by Dominique Weber, BFH-HAFL
############################################################

update_shapefile <- function(polys, shp, length_of_archive=NULL) {
  
  library(rgdal)
  
  # create new file
  if(!file.exists(shp)){
    if (!dir.exists(dirname(shp))){
      dir.create(dirname(shp))
    }
    shapefile(polys, shp)
  }else{
    existing = shapefile(shp)
    crs(polys) = crs(existing)
    new = bind(existing, polys)
    
    # "length_of_archive" handling
    if (!is.null(length_of_archive)) new = new[(as.Date(new$time) >= max(as.Date(new$time))-length_of_archive),]
    
    shapefile(new, shp, overwrite=T)
  }
}