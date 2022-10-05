#---------------------------------------------------------------------#
# Vectorization of NDVI Max change surfaces
#
# by Alexandra Erbach, Dominique Weber, Hannes Horneber (BFH-HAFL)
#---------------------------------------------------------------------#

library(raster)
library(rgdal)
library(sf) # for use with exactextractr
library(exactextractr) # replaces velox (fast raster extraction)
# for parallelization
library(foreach)
library(doParallel)

# parameters
minsize = units::set_units(300, m^2)
thrvalue = -1000
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
years = c("2022_2021")

# init in_path
in_path = paste0("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_", years[1], "_Int16_reproj_bilinear.tif")

#------------------------------------------------#
####              PARALLELIZATION             ####
#------------------------------------------------#
# parallelization makes only sense when processing multiple rasters
# uncomment the following lines if you want to activate parallelization
#------------------------------------------------#
# cl = makeCluster(detectCores() -1)
# registerDoParallel(cl)
# foreach(i=1:length(years), .packages=c("raster", "rgdal", "sf", "exactextractr")) %dopar% {
  # year = years[i]
  # in_path = paste0("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_", year, "_Int16_reproj_bilinear.tif")
#------------------------------------------------#
  start_time <- Sys.time()
  
  # out shp layer & raster
  lyr = paste0("ndvi_diff_", year)
  out_shp = paste0(out_path, "/", lyr, ".shp")
  out_ras_name = paste0(lyr,"_Int16_reproj_bilinear_forWMS.tif")
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
  diffmask_sf = read_sf(out_shp)
  # calculate area
  diffmask_sf$area = diffmask_sf$area <- round(st_area(diffmask_sf))
  #filter out surfaces smaller than min. size
  diffmask_sf = diffmask_sf[which(diffmask_sf$area > minsize),]

  # calculate mean change per polygon
  # this was implemented using R-package velox, which no longer is maintained (https://github.com/hunzikp/velox/issues/43)
  # switched to exact_extract in Oct 2022
  print("calculate mean change per polygon...")
  diff_raster = raster(in_path)
  meandiff = exact_extract(diff_raster, diffmask_sf, 'mean')
  # prettify values (raster values were multiplied by 10000 to be stored as int)
  diffmask_sf$meandiff <- round(meandiff/10000, 2)
  
  # drop first column
  diffmask_sf = diffmask_sf[,-1]
  
  ## shape deprecated, use geopackage instead (for better performance and an overall better format :])
  ## save shapefile > careful, CRS might not be correctly set. Check with GIS.
  # print("save shapefile...")
  # st_write(diffmask_sf, file.path(out_path, paste0(lyr, ".shp")), delete_dsn = T )
  
  print("save geopackage...")
  st_write(diffmask_sf, file.path(out_path, paste0(lyr, ".gpkg")) )
           
  print(Sys.time() - start_time) 

#------------------------------------------------#
# }
# stopCluster(cl)
#------------------------------------------------#