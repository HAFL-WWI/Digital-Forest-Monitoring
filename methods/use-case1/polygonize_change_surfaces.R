############################################################
# Vectorization of NDVI Max change surfaces
#
# by Alexandra Erbach & Dominique Weber, BFH-HAFL
############################################################

start_time <- Sys.time()

library(raster)
library(rgdal)
library(velox)

# parameters
minsize = 300 # m^2
thrvalue = -0.1

# read raster
diff_raster = raster("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2017_2016.tif")

# out shp layer
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
lyr = "ndvi_diff_2017_2016"

# create binary mask
print("create binary mask...")
diff_mask = diff_raster
diff_mask[diff_mask>thrvalue] = NA
diff_mask[!is.na(diff_mask)] = 1

# raster to polygon
print("raster to polygon...")
diff_mask_clump = clump(diff_mask, directions=4)
diffmask_vec = rasterToPolygons(diff_mask_clump, fun=NULL, n=4, digits=10, dissolve=T)
diffmask_vec = diffmask_vec[,-1]

print("calculate area and mean diff...")
# calculate area
diffmask_vec$area = area(diffmask_vec)

# filter out surfaces smaller than min. size
diffmask_vec = diffmask_vec[which(diffmask_vec$area > minsize),]

# calculate mean change per polygon
velox_mask = velox(diff_raster, res=res(diff_raster))
diffmask_vec$meandiff <- as.vector(velox_mask$extract(diffmask_vec, fun=mean))

# project to EPSG 3857
print("project to EPSG 3857...")
diffmask_vec_3857 = spTransform(diffmask_vec, CRS("+init=epsg:3857"))

# save shapefile
print("save shapefile...")
writeOGR(diffmask_vec_3857, dsn=out_path, layer=lyr, driver="ESRI Shapefile", overwrite_layer = T)

print(Sys.time() - start_time) # ca. 35 mins