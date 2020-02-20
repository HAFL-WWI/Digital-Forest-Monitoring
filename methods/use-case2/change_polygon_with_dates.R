library(raster)
library(rgdal)
library(velox)
library(rgeos)
library(mapview)

# thresholds
th = -15
area_th = 500

files = list.files("//home/eaa2/nbr_test_copy/nbr_diff/", pattern="*.tif", full.names=T)[c(2,4,7,11,16)]

ls = list()

for(i in 1:length(files)){
  print(paste(i, " of ", length(files), "...", sep=""))
  r = raster(files[i])
  e = c(478032, 498403, 5267230, 5280917)
  r = crop(r, e) 
  
  change = ((r < th) & (r > -999))
  change[is.na(change)] = 0
 
  # focal median (=mode) using velox (much faster)
  start_time <- Sys.time()
  vx = velox(change)
  vx$medianFocal(wrow=5, wcol=5, bands=1)
  change = vx$as.RasterLayer()
  print(paste("focal filter:", Sys.time() - start_time))
  
  # create polygons
  start_time <- Sys.time()
  change[change != 1] = NA
  change[r == -999] = -1
  polys = rasterToPolygons(change, dissolve=T)
  polys = disaggregate(polys)
  names(polys) = "class"
  print(paste("raster to polygon:", Sys.time() - start_time))
  
  # add area and filter small polys
  polys$area = area(polys)
  polys = polys[(((polys$area > area_th) & (polys$class==1)) | polys$class==-1) ,]
  
  # add time attribute
  str = substr(names(r), 17, 24)
  date = as.Date(str, format = "%Y%m%d")
  polys$time = date
  
  # calc change attributes
  vx = velox(r)
  polys$mean = as.vector(vx$extract(sp = polys, fun = function(x) mean(x, na.rm = TRUE)))
  polys$max = as.vector(vx$extract(sp = polys, fun = function(x) min(x, na.rm = TRUE)))
  polys$p90 = as.vector(vx$extract(sp = polys, fun = function(x) quantile(x, 0.1, na.rm = TRUE)))
  
  # add to list
  ls = append(ls, polys)
}

# combine all changes
all_change = do.call(bind, ls) 

# reproject to epsg 3857
all_change = spTransform(all_change, CRS("+init=epsg:3857"))

# plot
#mapview(all_change[all_change$time == "2017-08-25",]) + mapview(crop(raster(files[[5]]),e), at = seq(-50, 0, 5))

# write shape
writeOGR(all_change, "//home/eaa2/", "nbr_change", driver="ESRI Shapefile", overwrite_layer = T)