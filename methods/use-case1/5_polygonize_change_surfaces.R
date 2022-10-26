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
minsize = units::set_units(399, m^2) # default is >399 (>= 400), but may be increased as threshold is lowered (e.g. 499 for thr=-600)
minsize_pixels = round(units::drop_units(minsize) / 100) # 1 pixel = 100 m^2 
thrvalue = -600 # threshold was -1000, but -600 seems more appropriate. 
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1"
years = c("2022_2021","2021_2020","2020_2019","2019_2018","2018_2017","2017_2016")
previous_suffix = "_Int16_EPSG3857"
add_suffix = paste0("_NA-", abs(thrvalue))

# use gdal_sieve to remove patches smaller than threshhold before polygonization 
# (achieving the same result with usually faster computation time!)
GDAL_SIEVE = TRUE  
# use morphological image operations to remove spots, noise, thin lines, extrusions and close gaps 
# --- EXPERIMENTAL! --- 
# also messes up CRS with writeRaster (CRS needs to be manually reassigned on older R versions)
MORPH = FALSE

# init in_path (will be overwritten if parallelization is "activated" by uncommenting below lines)
in_path = paste0("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_", years[1], previous_suffix, ".tif")
#------------------------------------------------#
####              PARALLELIZATION             ####
#------------------------------------------------#
# parallelization makes only sense when processing multiple rasters
# uncomment the following lines if you want to activate parallelization
# DON'T FORGET TO UNCOMMENT THE TWO LINES AT THE END OF THE PARALLELIZATION BLOCK
#------------------------------------------------#
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)
foreach(i=1:length(years), .packages=c("raster", "rgdal", "sf", "exactextractr")) %dopar% {
  year = years[i]
  in_path = paste0("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_", year, "_Int16_EPSG3857.tif")
#------------------------------------------------#
  start_time <- Sys.time()
  
  # out shp layer & raster
  lyr = paste0("ndvi_diff_", years, previous_suffix, add_suffix)
  # out_shp = paste0(out_path, "/", lyr, ".shp")
  out_gpkg = paste0(out_path, "/", lyr, ".gpkg")
  out_ras_name = paste0(lyr,  ".tif")
  out_ras = paste0(out_path,"/",out_ras_name)
  out_mask_name = paste0(lyr,"_mask.tif")
  out_mask = file.path(out_path,"temp",out_mask_name)
  
  # create binary mask & raster for WMS publication (values > thrvalue auf NA)
  print("create binary mask...")
  system(paste("gdal_calc.py -A ", in_path,  " --outfile=", out_ras, " --calc=\"(A<=", thrvalue, ")*A\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=0 --overwrite", sep=""))
  system(paste("gdal_calc.py -A ", out_ras,  " --outfile=", out_mask, " --calc=\"A<0\" --co=\"COMPRESS=LZW\" --type='Byte' --NoDataValue=0 --overwrite", sep=""))
  
  if(GDAL_SIEVE){
    print("filter raster with gdal_sieve...")
    
    out_mask_sieved_name = paste0(lyr,"_mask_sieved.tif")
    out_mask_sieved = file.path(out_path,"temp",out_mask_sieved_name)
    out_mask_sieved_b_name = paste0(lyr,"_mask_sieved_byte.tif")
    out_mask_sieved_b = file.path(out_path,"temp",out_mask_sieved_b_name)
    
    # sieve with gdal (remove patches smaller than threshhold)
    # change no data value, since sieve doesn't filter areas surrounded by NA
    system(paste("gdal_edit.py -a_nodata 255", out_mask, sep=" ")) 
    # sieve with -st AREA_THRESHOLD = minsize_pixels
    print(paste0(" - gdal_sieve removes pixel patches with less than ", minsize_pixels, " pixels"))
    system(paste("gdal_sieve.py -st", minsize_pixels, out_mask, out_mask_sieved, sep=" "))
    # output is always Integer; sieve doesn't allow creation options, set NA value to 0 again
    system(paste("gdal_translate -ot Byte -a_nodata 0 -co \"COMPRESS=LZW\" ", out_mask_sieved, out_mask_sieved_b, sep=" "))
    # clean up (large) temporary files
    print(" - cleanup")
    file.remove(out_mask_sieved) # mask sieved is an unnecessary, uncompressed Int16-raster with probably >1GB
    
    # continue further processing with sieved raster
    print(" - continue with sieved mask")
    out_mask = out_mask_sieved_b
  }
  print(Sys.time() - start_time) 

  if(MORPH){
    # raster to polygon
    print("run morphological processing...")
    # --- EXPERIMENTAL --- #
    # morphological image processing
    library(EBImage)
    # mask_raster = raster(file.path(out_path,"temp","ndvi_diff_2022_2021_Int16_EPSG3857_clip_mask.tif")) # test file
    print(" - load raster")
    mask_raster = raster(file.path(out_path,"temp","ndvi_diff_2022_2021_Int16_EPSG3857_clip_mask.tif"))
    print(" - extract matrix")
    mask_matrix = as.matrix(mask_raster) # creates a "Large matrix (2903145 elements, 11.1 Mb): int [1:1505, 1:1929]"
    # mask_vector = mask_raster[,] # creates a "Large integer (2903145 elements, 11.1 Mb): int [1:2903145]"
    
    kern3 = makeBrush(3, shape='box')
    kern5 = makeBrush(5, shape='box')
    print(" - morphological closing, kernel 3")
    mask_matrix = closing(mask_matrix, kern3)
    print(" - morphological opening, kernel 3")
    mask_matrix = opening(mask_matrix, kern3)
    # display(mask_matrix)
    # display(erode(mask_matrix, kern), title='Erosion of x')
    # display(dilate(mask_matrix, kern), title='Dilatation of x')
    
    print(" - create output")
    out_mask_morph_name = paste0(lyr,"_mask_morphed.tif")
    out_mask_morph = file.path(out_path,"temp",out_mask_morph_name)
    mask_raster[] = mask_matrix
    writeRaster(mask_raster, out_mask_morph, datatype ="INT1U", options="COMPRESS=LZW", overwrite = T)
    print(" - continue with morphed mask")
    out_mask = out_mask_morph
  }
  
  # raster to polygon
  print("raster to polygon...")
  # system(paste("gdal_polygonize.py", out_mask, out_shp, sep=" "))
  system(paste("gdal_polygonize.py", out_mask, out_gpkg, sep=" "))
  
  print(paste0("calculate area and filter polygons smaller than minsize = ", minsize, " m^2"))
  # diffmask_sf = read_sf(out_shp)
  diffmask_sf = read_sf(out_gpkg)
  # calculate area
  diffmask_sf$area = diffmask_sf$area <- round(st_area(diffmask_sf))
  #filter out surfaces smaller than min. size
  diffmask_sf = diffmask_sf[which(diffmask_sf$area > minsize),]

  # calculate mean change per polygon
  # this was implemented using R-package velox, which no longer is maintained (https://github.com/hunzikp/velox/issues/43)
  # switched to exact_extract in Oct 2022
  print("calculate attributes per polygon...")
  diff_raster = raster(in_path)
  print(Sys.time() - start_time) 

  print("calculate meandiff per polygon...")
  meandiff = exact_extract(diff_raster, diffmask_sf, 'mean')
  # prettify values (raster values were multiplied by 10000 to be stored as int)
  diffmask_sf$meandiff <- round(meandiff/10000, 3)
  print(Sys.time() - start_time) 
  
  print("calculate sumdiff per polygon...")
  sumdiff = exact_extract(diff_raster, diffmask_sf, 'sum')
  diffmask_sf$sumdiff <- round(sumdiff/10000, 3)
  print(Sys.time() - start_time) 
  
  print("calculate maxdiff per polygon...")
  maxdiff = exact_extract(diff_raster, diffmask_sf, 'max')
  diffmask_sf$maxdiff <- round(maxdiff/10000, 3)
  print(Sys.time() - start_time) 
  
  print("count diff pixels per polygon...")
  countdiff = exact_extract(diff_raster, diffmask_sf, 'count')
  diffmask_sf$countdiff <- round(countdiff, 3)
  print(Sys.time() - start_time) 
  
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
}
stopCluster(cl)
#------------------------------------------------#