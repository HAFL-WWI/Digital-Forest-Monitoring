############################################################
# Vectorization of NDVI Max change surfaces
#
# by Alexandra Erbach & Dominique Weber, BFH-HAFL
############################################################

library(raster)
library(rgdal)
library(velox)
library(foreach)
library(doParallel)

# parameters
minsize = 300 # m^2
thrvalue = -1000
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
years = c("2016_2015", "2017_2016", "2018_2017", "2019_2018", "2020_2019")

cl = makeCluster(detectCores() -1)
registerDoParallel(cl)
foreach(i=1:length(years), .packages=c("raster", "rgdal", "velox")) %dopar% {
  
  start_time <- Sys.time()
  
  # parameters
  year = years[i]
  in_path = paste0("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_", year, "_Int16_reproj_bilinear.tif")
  
  # out shp layer & raster
  lyr = paste0("ndvi_diff_", year)
  out_shp = paste0(out_path, "/", lyr, ".shp")
  out_ras_name = paste0(lyr,"_forWMS.tif")
  out_ras = paste0(out_path,"/",out_ras_name)
  out_mask_name = paste0(lyr,"_mask.tif")
  out_mask = paste0(out_path,"/",out_mask_name)
  
  # create binary mask & raster for WMS publication (values > thrvalue auf NA)
  print("create binary mask...")
  system(paste("gdal_calc.py -A ", in_path,  " --outfile=", out_ras, " --calc=\"(A<=", thrvalue, ")*A\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=0 --overwrite", sep=""))
  system(paste("gdal_calc.py -A ", out_ras,  " --outfile=", out_mask, " --calc=\"A<0\" --co=\"COMPRESS=LZW\" --type='Byte' --NoDataValue=0 --overwrite", sep=""))
  
  # raster to polygon
  print("raster to polygon...")
  system(paste("gdal_polygonize.py", out_mask, out_shp, sep=" "))
  
  print("calculate area and mean diff...")
  diffmask_vec = readOGR(out_shp)
  # calculate area
  diffmask_vec$area = round(area(diffmask_vec),0)
  
  # filter out surfaces smaller than min. size
  diffmask_vec = diffmask_vec[which(diffmask_vec$area > minsize),]
  
  # calculate mean change per polygon
  diff_raster = raster(in_path)
  velox_mask = velox(diff_raster, res=res(diff_raster))
  diffmask_vec$meandiff <- round(as.vector(velox_mask$extract(diffmask_vec, fun=mean))/10000, 2)
  
  # delete first column
  diffmask_vec = diffmask_vec[,-1]
  
  # reproject > doesn't make a difference...
  #diffmask_vec = spTransform(diffmask_vec, "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +ellps=WGS84 +datum=WGS84 +units=m +nadgrids=@null +wktext +no_defs")
  
  # save shapefile > careful, CRS ist not correctly written by writeOGR, has to be manually set in GIS
  print("save shapefile...")
  writeOGR(diffmask_vec, dsn=out_path, layer=lyr, driver="ESRI Shapefile", overwrite_layer = T)
  
  print(Sys.time() - start_time) # ca. 6 mins
  
}
stopCluster(cl)