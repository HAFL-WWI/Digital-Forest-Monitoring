# configured for use on bfh.science R container
setwd("~/Digital-Forest-Monitoring/methods")

# load packages
library(terra)
library(raster) # deprecated, but still used
library(doParallel)
# library(velox) # deprecated

# source functions
# these functions have yet to be updated to using terra instead of raster...
source("general/dir_exists_create_func.R")
source("general/calc_veg_indices.R")
source("general/calc_max_composite.R")
source("use-case2/build_polygons.R")

#### SETTINGS ####
# P:\LFE\HAFL\WWI-Sentinel-2\Use-Cases\Use-Case2\2023-02_Sturm_VD\S2data\sen2R_output
# P:\LFE\HAFL\WWI-Sentinel-2\Use-Cases\Use-Case2\2023-02_Sturm_VD\S2data
# P:\LFE\HAFL\WWI-Sentinel-2\Use-Cases\Use-Case2\2023-02_Sturm_VD\S2data
BASE_PATH = "/mnt/smb.hdd.rbd/" # on bfh-science cluster
# BASE_PATH = "P:/LFE" # on HARA/Windows

# define paths
# main_path = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Sturm_ZG"
main_path = file.path(BASE_PATH, "HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/2023-02_Sturm_VD/S2data")
# out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Sturm_ZG_2021/"
out_path = file.path(BASE_PATH, "HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/2023-02_Sturm_VD/results")
# mask_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.tif"
mask_path = file.path(BASE_PATH, "HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.tif")
shp_path = out_path

# create folders
nbr_path = dir_exist_create(out_path,"nbr/")
nbr_raw_path = dir_exist_create(out_path,"nbr_raw/")
ndvi_raw_path = dir_exist_create(out_path,"ndvi_raw/")
comp_path = dir_exist_create(out_path,"nbr_comp/")
diff_path = dir_exist_create(out_path,"nbr_diff/")

# parameters
tile = "T31TGM"
# tile = "T32TLS"
thr = 0.99
# for scene classification SCL
cloud_vec = c(3,7:10)
cloud_value = -999
nodata_vec = c(0:2,5,6,11)
nodata_value = -555

#### SELECT FILES ####

# get dates
stack_path = main_path
B8Names = list.files(stack_path, pattern=paste0("(", tile, ").*(B08_10m)"), recursive=T)
dates_all = as.Date(substring(lapply(strsplit(B8Names,"_"), "[[", 3),1,8), format = "%Y%m%d")
# take all dates except for the last one
# this assumes that only one image is after the storm (!)
dates_for_comp = dates_all[1:(length(dates_all)-1)]

# build stacks
b8 = list.files(stack_path, pattern=paste0("(", tile, ").*(B08_10m)"), recursive=T, full.names=T)[1:(length(dates_all)-1)]
b12 = list.files(stack_path, pattern=paste0("(", tile, ").*(B12_20m)"), recursive=T, full.names=T)[1:(length(dates_all)-1)]
b4 = list.files(stack_path, pattern=paste0("(", tile, ").*(B04_10m)"), recursive=T, full.names=T)[1:(length(dates_all)-1)]
stk_b8 = stack(b8)
stk_b4 = stack(b4)


####_____________________________####
#### CALC COMPOSITE BEFORE STORM ####
#-----------------------------------#
# calculate NDVI & NBR
ndvi_stk = calc_veg_indices (stk_1 = stk_b8, stk_2 = stk_b4, ndvi_raw_path, dates_for_comp, veg_ind="NDVI", tilename=tile, ext=NULL, thr=thr)
stk_b12 = disaggregate(stack(b12),2)
nbr_stk = calc_veg_indices (stk_1 = stk_b8, stk_2 = stk_b12, nbr_raw_path, dates_for_comp, veg_ind="NBR", tilename=tile, ext=NULL, thr=thr)

# call calc_pixel_comp function
ind_ras = calc_max_composite (vi_stk=ndvi_stk, ext=NULL, calc_max=F, calc_ind=T)
comp_tmp = stackSelect(nbr_stk, ind_ras)

#### > write nbr composite ####
comp_tmp_name = paste(tile, "_NBR_comp_", dates_for_comp[1], "_", dates_for_comp[12], sep="")
writeRaster(comp_tmp, paste(comp_path,comp_tmp_name,".tif",sep=""), overwrite=T, datatype='INT2S')


####_____________________________####
#### CALC NBR IMAGE AFTER STORM  ####
#-----------------------------------#

#### > load and resample img data ####
# calc NBR of image after storm
B8Names = list.files(stack_path, pattern=paste0("(", tile, ").*(B08_10m)"), recursive=T, full.names = T)[length(dates_all)]
B12Names = list.files(stack_path, pattern=paste0("(", tile, ").*(B12_20m)"), recursive=T, full.names = T)[length(dates_all)]
sclNames = list.files(stack_path, pattern=paste0("(", tile, ").*(SCL_20m)"), recursive=T, full.names = T)[length(dates_all)]

filesB8 = list.files(stack_path, pattern=paste0("(", tile, ").*(B08_10m)"), recursive=T, full.names = F)[length(dates_all)]

# load rasters (upsample 20 m to 10 m raster)
# b8 = raster(B8Names)
# b12 = disaggregate(raster(B12Names),2)
# scl = disaggregate(raster(sclNames),2)
b8 = terra::rast(B8Names)
b12 = terra::disagg(rast(B12Names),2)
scl = terra::disagg(rast(sclNames),2)

#### > process SCL ####
# scene classification data
# majority filter on scl
scl_cl = scl
scl_cl[scl_cl %in% nodata_vec] = nodata_value
scl_cl[scl_cl %in% cloud_vec] = cloud_value

# package velox is not available, hence switching to terra  
#scl_vx = velox(scl_cl)
# scl_vx$medianFocal(wrow=5, wcol=5, bands=1)
# scl_vx = scl_vx$as.RasterLayer()
scl_vx = terra::focal(scl_cl, w=matrix(1,nrow=5,ncol=5), fun = median)

#### > calculate nbr ####
nbr_tmp = (b8 - b12)/(b8 + b12)
nbr_tmp = round(nbr_tmp*100)

#### > postprocess ####
# mask nodata
nbr_tmp[scl_vx == nodata_value] = nodata_value

# mask clouds and create buffer
cloud_ras = scl_vx == cloud_value
cloud_ras = terra::focal(cloud_ras, w=matrix(1,nrow=11,ncol=11), fun = sum)
nbr_tmp[cloud_ras > 0] = cloud_value
rm(cloud_ras)

#### > write nbr img ####
nbr_tmp_name = paste(tile, "_NBRc_", substring(lapply(strsplit(filesB8,"_"), "[[", 3),1,8), sep="")
writeRaster(nbr_tmp, paste(nbr_path,nbr_tmp_name,".tif",sep=""), overwrite=T, datatype='INT2S')
# nbr_tmp = rast(paste(nbr_path,nbr_tmp_name,".tif",sep=""))

####_____________________________####
####           CALC DIFF         ####
#-----------------------------------#
# re-read comp_tmp to coerce to terra::rast
comp_tmp = rast(paste(comp_path,comp_tmp_name,".tif",sep=""))

diff_tmp = nbr_tmp - comp_tmp
diff_tmp[(nbr_tmp == cloud_value)] = cloud_value # clouds
diff_tmp[(nbr_tmp == nodata_value) | (is.na(comp_tmp))] = nodata_value # nodata

#### > save diff raster ####
ras_name = paste0(tile,"_NBR_diff_",substr(names(nbr_tmp),2,9),"_",substring(lapply(strsplit(filesB8,"_"), "[[", 3),1,8), ".tif")
# save as 16 Bit Integer
writeRaster(diff_tmp, file.path(out_path, ras_name), overwrite=T, datatype='INT2S')

#### > save diff polygons ####
# apply forest mask
forest_mask = rast(mask_path)
forest_mask = crop(forest_mask, diff_tmp)
diff_tmp = crop(diff_tmp, forest_mask)
diff = terra::mask(diff_tmp, forest_mask, updatevalue=0)

# polygonize
tempvec = file.path(shp_path,paste0("temp_change_",dates_all[length(dates_all)],".gpkg"))

# source("use-case2/build_polygons.R")
# polys = build_polygons(diff, th = -15, area_th = 500, tempvec)
#--------------------------------------------------------------------------------------------------------#
#------------------------------ source("use-case2/build_polygons.R")-------------------------------------#
r = diff
th = -15
area_th = 500

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
polys = as.polygons(change)
polys = disagg(polys)  # package terra
writeVector(polys, tempvec, overwrite=T)
# polys_nondiss = as.polygons(change, dissolve=FALSE) # package terra
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
  polys$area[polys$class==1] = expanse(polys[(polys$class==1),])
  hel = polys[(((polys$area > area_th) & (polys$class==1)) | polys$class<0) ,]
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

#END--------------------------- source("use-case2/build_polygons.R")-------------------------------------#
#--------------------------------------------------------------------------------------------------------#

vec_path = file.path(shp_path,paste0("change_",dates_all[length(dates_all)],".gpkg"))
writeVector(polys, vec_path, overwrite=T)

vec_path_transformed = file.path(shp_path,paste0("change_",dates_all[length(dates_all)],"_EPSG3857.gpkg"))
polys = project(polys, "EPSG:3857")
writeVector(polys, vec_path, overwrite=T)

