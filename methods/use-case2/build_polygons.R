############################################################
# Create change polygons.
#
# by Dominique Weber, BFH-HAFL
############################################################

build_polygons <- function(r, th = -15, area_th = 500, tempvec) {
  
  library(raster)
  library(rgdal)
  # library(velox)
  library(terra)
  library(rgeos)
  # library(stars)
  
  print("threshold and clouds...")
  change = ((r < th) & (r > -555)) # careful with use of absolute number...
  
  print("focal filtering...")
  # vx = velox(change)
  # vx$medianFocal(wrow=5, wcol=5, bands=1)
  # change = vx$as.RasterLayer()
  change = terra::focal(change, w=matrix(1,nrow=5,ncol=5), fun = median)
  
  # set raster values
  change[change == 0] = NA
  change[r == -999] = -1 # cloud
  change[r == -555] = -2 # nodata
  
  # create polygons
  print("polygonize...")
  polys = as.polygons(change) # package terra
  names(polys) = "class"
  
  dir.create(tempvec, recursive = T)
  tryCatch(
    expr = {
      # try saving the shp file 
      print("> Save temp vector...")
      writeVector(polys, tempvec, overwrite=T)
    },#/endexpr (tryCatch STAC download)
    error = function(e){
      message('> Couldnt save vector temp file')
      print(e)
    }, finally = { } #trycatch-error close
  )#/endtry (saving status process-shp)
  
  # add area and filter small polys
  print("filtering by area...")
  polys$area = polys$mean = polys$max = polys$p90 = NA
  if (length(which(polys$class==1))>0){
    polys$area[polys$class==1] = area(polys[(polys$class==1),])
    polys = polys[(((polys$area > area_th) & (polys$class==1)) | polys$class<0) ,]
  }
  # add attributes
  if (length(which(polys$class==1))>0){
    polys$mean[polys$class==1] = as.vector(extract(r, polys[(polys$class==1),], fun = function(x) mean(x, na.rm = TRUE)))
    polys$mean[polys$class==1] = as.vector(extract(r, polys[(polys$class==1),], fun = function(x) min(x, na.rm = TRUE)))
    polys$mean[polys$class==1] = as.vector(extract(r, polys[(polys$class==1),], fun = function(x) quantile(x, 0.1, na.rm = TRUE)))
    # vx = velox(r)
    # polys$mean[polys$class==1] = as.vector(vx$extract(sp = polys[(polys$class==1),], fun = function(x) mean(x, na.rm = TRUE)))
    # polys$max[polys$class==1] = as.vector(vx$extract(sp = polys[(polys$class==1),], fun = function(x) min(x, na.rm = TRUE)))
    # polys$p90[polys$class==1] = as.vector(vx$extract(sp = polys[(polys$class==1),], fun = function(x) quantile(x, 0.1, na.rm = TRUE)))
  }
  
  # rounding and conversion
  polys$p90 = round(as.numeric(polys$p90))
  polys$mean = round(as.numeric(polys$mean))
  polys$max = as.numeric(polys$max)
  polys$area = as.numeric(polys$area)
  
  polys$time = as.Date(substr(names(r),2,9), format = "%Y%m%d")
  
  return(polys) 
}