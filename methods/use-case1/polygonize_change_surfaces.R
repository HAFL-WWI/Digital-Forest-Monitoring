############################################################
# Vectorization of NDVI Max change surfaces
#
# by Alexandra Erbach, HAFL, BFH
############################################################

#start_time <- Sys.time()

library(raster)
library(rgdal)
library(velox)

# parameters
minsize = 300 # m^2
thrvalue = -0.1

# read raster
diff_2017_18 = raster("//home/eaa2/ndvi_max_ch_forest_diff_2018_2017.tif")

# create binary mask
diff_mask = diff_2017_18
diff_mask[diff_mask>thrvalue] = NA
diff_mask[!is.na(diff_mask)] = 1

# raster to polygon
diff_mask_clump = clump(diff_mask, directions=4)
diffmask_vec = rasterToPolygons(diff_mask_clump, fun=NULL, n=4, digits=10, dissolve=T)
diffmask_vec = diffmask_vec[,-1]

# calculate area
diffmask_vec$area = area(diffmask_vec)

# filter out surfaces smaller than min. size
diffmask_vec = diffmask_vec[which(diffmask_vec$area > minsize),]

# calculate mean change per polygon
velox_mask = velox(diff_2017_18, res=res(diff_2017_18))
diffmask_vec$meandiff <- as.vector(velox_mask$extract(diffmask_vec, fun=mean))

#project to EPSG 3857
diffmask_vec_3857 = spTransform(diffmask_vec, CRS("+init=epsg:3857"))

# save shapefile
writeOGR(diffmask_vec_3857, dsn="//home/eaa2", layer="NDVImax_diff_2018_2017", driver="ESRI Shapefile", overwrite_layer = T)

# print(Sys.time() - start_time) # ca. 35 mins