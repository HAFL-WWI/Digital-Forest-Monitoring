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
  change = ((r < th) & (r > -999))
  change[is.na(change)] = 0
  
  print("focal filtering...")
  vx = velox(change)
  vx$medianFocal(wrow=5, wcol=5, bands=1)
  change = vx$as.RasterLayer()
  
  # set raster values
  change[change != 1] = NA
  change[r == -999] = -1

  # create polygons
  print("polygonize...")
  tmp = st_as_stars(change)
  polys = st_as_sf(tmp, merge=T)
  polys = as(polys, 'Spatial')
  test = disaggregate(polys)
  names(polys) = "class"
  
  # add area and filter small polys
  print("filtering by area...")
  polys$area = area(polys)
  polys = polys[(((polys$area > area_th) & (polys$class==1)) | polys$class==-1) ,]
  
  # add attributes
  polys$time = as.Date(substr(names(r), 17, 24), format = "%Y%m%d")
  vx = velox(r)
  polys$mean = as.vector(vx$extract(sp = polys, fun = function(x) mean(x, na.rm = TRUE)))
  polys$max = as.vector(vx$extract(sp = polys, fun = function(x) min(x, na.rm = TRUE)))
  polys$p90 = as.vector(vx$extract(sp = polys, fun = function(x) quantile(x, 0.1, na.rm = TRUE)))
  
  return(polys) 
}