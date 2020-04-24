############################################################
# Create change polygons.
#
# by Dominique Weber, BFH-HAFL
############################################################

build_polygons <- function(r, th = -15, area_th = 500) {
  
  library(raster)
  library(rgdal)
  library(velox)
  library(rgeos)
  library(stars)
  
  print("threshold and clouds...")
  change = ((r < th) & (r > -555)) # careful with use of absolute number...
  change[is.na(change)] = 0
 
  #print("focal filtering...")
  vx = velox(change)
  vx$medianFocal(wrow=5, wcol=5, bands=1)
  change = vx$as.RasterLayer()
  
  # set raster values
  change[change == 0] = NA
  change[r == -999] = -1
  change[r == -555] = -2
 
  # create polygons
  print("polygonize...")
  tmp = st_as_stars(change)
  polys = st_as_sf(tmp, merge=T)
  polys = as(polys, 'Spatial')
  names(polys) = "class"
  
  # add area and filter small polys
  print("filtering by area...")
  polys$area = polys$mean = polys$max = polys$p90 = NA
  if (length(which(polys$class==1))>0){
    polys$area[polys$class==1] = area(polys[(polys$class==1),])
    polys = polys[(((polys$area > area_th) & (polys$class==1)) | polys$class<0) ,]
  }
    # add attributes
  if (length(which(polys$class==1))>0){
    vx = velox(r)
    polys$mean[polys$class==1] = as.vector(vx$extract(sp = polys[(polys$class==1),], fun = function(x) mean(x, na.rm = TRUE)))
    polys$max[polys$class==1] = as.vector(vx$extract(sp = polys[(polys$class==1),], fun = function(x) min(x, na.rm = TRUE)))
    polys$p90[polys$class==1] = as.vector(vx$extract(sp = polys[(polys$class==1),], fun = function(x) quantile(x, 0.1, na.rm = TRUE)))
  }
  
  polys$time = as.Date(substr(names(r), 17, 24), format = "%Y%m%d")
  
  return(polys) 
}