############################################################
# Update change shapefile if existing.
#
# by Dominique Weber, BFH-HAFL
############################################################

library(rgdal)

update_shapefile <- function(polys, shp, length_of_archive=NULL) {
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
    
    # TODO implement "length_of_archive" handling
    shapefile(new, shp, overwrite=T)
  }
}