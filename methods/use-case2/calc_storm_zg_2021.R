setwd("~/Digital-Forest-Monitoring/methods")

# load packages
library(raster)
library(doParallel)
library(velox)

# source functions
source("general/dir_exists_create_func.R")
source("general/calc_veg_indices.R")
source("general/calc_max_composite.R")
source("use-case2/build_polygons.R")

# define paths
main_path = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Sturm_ZG"
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Sturm_ZG_2021/"
mask_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.tif"
shp_path = out_path

nbr_path = dir_exist_create(out_path,"nbr/")
nbr_raw_path = dir_exist_create(out_path,"nbr_raw/")
ndvi_raw_path = dir_exist_create(out_path,"ndvi_raw/")
comp_path = dir_exist_create(out_path,"nbr_comp/")
diff_path = dir_exist_create(out_path,"nbr_diff/")

# parameters
tile = "T32TMT"
thr = 0.99
cloud_vec = c(3,7:10)
cloud_value = -999
nodata_vec = c(0:2,5,6,11)
nodata_value = -555

# get dates
stack_path = main_path
B8Names = list.files(stack_path, pattern="B08_10m", recursive=T)
dates_all = as.Date(substring(lapply(strsplit(B8Names,"_"), "[[", 3),1,8), format = "%Y%m%d")
dates_for_comp = dates_all[1:12]

# build stacks
b8 = list.files(stack_path, pattern="B08_10m", recursive=T, full.names=T)[1:12]
b12 = list.files(stack_path, pattern="B12_20m", recursive=T, full.names=T)[1:12]
b4 = list.files(stack_path, pattern="B04_10m", recursive=T, full.names=T)[1:12]
stk_b8 = stack(b8)
stk_b4 = stack(b4)

# calculate NDVI & NBR
ndvi_stk = calc_veg_indices (stk_1 = stk_b8, stk_2 = stk_b4, ndvi_raw_path, dates_for_comp, veg_ind="NDVI", tilename=tile, ext=NULL, thr=thr)
stk_b12 = disaggregate(stack(b12),2)
nbr_stk = calc_veg_indices (stk_1 = stk_b8, stk_2 = stk_b12, nbr_raw_path, dates_for_comp, veg_ind="NBR", tilename=tile, ext=NULL, thr=thr)

# call calc_pixel_comp function
ind_ras = calc_max_composite (vi_stk=ndvi_stk, ext=NULL, calc_max=F, calc_ind=T)
comp_tmp = stackSelect(nbr_stk, ind_ras)
comp_tmp_name = paste(tile, "_NBR_comp_", dates_for_comp[1], "_", dates_for_comp[12], sep="")
writeRaster(comp_tmp, paste(comp_path,comp_tmp_name,".tif",sep=""), overwrite=T, datatype='INT2S')

###################################################################################################
# calc NBR of image after storm
B8Names = list.files(stack_path, pattern="B08_10m", recursive=T, full.names = T)[13]
B12Names = list.files(stack_path, pattern="B12_20m", recursive=T, full.names = T)[13]
sclNames = list.files(stack_path, pattern="SCL_20m", recursive=T, full.names = T)[13]

filesB8 = list.files(stack_path, pattern="B08_10m", recursive=T, full.names = F)[13]

# calculate indices
b8 = raster(B8Names)
b12 = disaggregate(raster(B12Names),2)
scl = disaggregate(raster(sclNames),2)

# majority filter on scl
scl_cl = scl
scl_cl[scl_cl %in% nodata_vec] = nodata_value
scl_cl[scl_cl %in% cloud_vec] = cloud_value
scl_vx = velox(scl_cl)
scl_vx$medianFocal(wrow=5, wcol=5, bands=1)
scl_vx = scl_vx$as.RasterLayer()

# calculate nbr
nbr_tmp = (b8 - b12)/(b8 + b12)
nbr_tmp = round(nbr_tmp*100)

# mask nodata
nbr_tmp[scl_vx == nodata_value] = nodata_value

# mask clouds and create buffer
cloud_ras = scl_vx == cloud_value
vx = velox(cloud_ras)
vx$sumFocal(weights=matrix(1,11,11), bands=1) # should be input parameter in function
cloud_ras = vx$as.RasterLayer()
nbr_tmp[cloud_ras > 0] = cloud_value
rm(cloud_ras)

nbr_tmp_name = paste(tile, "_NBRc_", substring(lapply(strsplit(filesB8,"_"), "[[", 3),1,8), sep="")
writeRaster(nbr_tmp, paste(nbr_path,nbr_tmp_name,".tif",sep=""), overwrite=T, datatype='INT2S')

##################################################################################################
# Calculate difference
diff_tmp = nbr_tmp - comp_tmp
diff_tmp[(nbr_tmp == cloud_value)] = cloud_value # clouds
diff_tmp[(nbr_tmp == nodata_value) | (is.na(comp_tmp))] = nodata_value # nodata
ras_name = paste(tile,"_NBR_diff_",substr(names(nbr_tmp),2,9), sep="")

# save as 16 Bit Integer
writeRaster(diff_tmp, paste(out_path, ras_name,".tif",sep=""), overwrite=T, datatype='INT2S')

#################################################################################################
# apply forest mask
forest_mask = raster(mask_path)
forest_mask = crop(forest_mask, diff_tmp)
diff_tmp = crop(diff_tmp, forest_mask)
diff = mask(diff_tmp, forest_mask, updatevalue=0)

# polygonize
polys = build_polygons(diff, th = -15, area_th = 500)
polys = spTransform(polys, CRS("+init=epsg:3857"))
shp = file.path(shp_path,paste0("change_",dates_all[13],"_epsg3857.shp"))
shapefile(polys, shp)



