library(raster)
library(rgdal)
library(velox)
library(rgeos)
library(stars)
library(foreach)
library(doParallel)

start_time <- Sys.time()
# thresholds
th = -15
area_th = 500

files = list.files("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/Use-Case2/NBR differences/", pattern="*.tif", full.names=T)[c(2,4,7,11,16)]

# prepare multi-core
print("Prepare multi-core processing...")
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

print(paste("polygonize", length(files), "rasters in parallel processing mode..."))
ls = foreach(i=1:length(files), .packages = c("raster", "velox", "stars"), .combine = "append") %dopar% {
  
  r = raster(files[i])
  # e = c(478032, 498403, 5267230, 5280917)
  # r = crop(r, e) 
  
  change = ((r < th) & (r > -999))
  change[is.na(change)] = 0
 
  # focal median (=mode) using velox (much faster)
  print("focal filtering...")
  vx = velox(change)
  vx$medianFocal(wrow=5, wcol=5, bands=1)
  change = vx$as.RasterLayer()

  # set raster values
  change[change != 1] = NA
  change[r == -999] = -1
  
  # TODO first drop_crumps ? 
  
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

#end cluster
stopCluster(cl)

# combine all changes
all_change = do.call(bind, ls)

# reproject to epsg 3857
all_change = spTransform(all_change, CRS("+init=epsg:3857"))

# library(mapview)
# mapview(all_change[all_change$time == "2017-08-25",]) + mapview(crop(raster(files[[5]]),e), at = seq(-50, 0, 5))

# write shape
writeOGR(all_change, "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/Use-Case2/", "nbr_change", driver="ESRI Shapefile", overwrite_layer = T)
Sys.time() - start_time