############################################################
# Automatic calculation of NBR differences
#
# by Alexandra Erbach, BFH-HAFL
############################################################

start_time <- Sys.time()

setwd("~/Digital-Forest-Monitoring/methods")

# load packages
library(raster)
library(doParallel)

# source functions
source("general/dir_exists_create_func.R")
source("use-case2/calc_nbr_differences.R")
source("use-case2/update_shapefile.R")
source("use-case2/build_polygons.R")

# paths
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/ESA/S2MSI2A/SAFE/"
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Sturm_ZG_2021"
mask_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.tif"
shp_path = dir_exist_create(out_path,"shp_dates")
targetpath = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Test_all/T32TMT/2017/nbr_diff/"  # reference for reprojection of T31TGM

tile_vec = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
tile_vec = c("T32TMT")

dates_all = character()

# get dates
for(i in 1:length(tile_vec)){
  
  diff_stk = calc_nbr_differences(main_path, out_path, tile_vec[i], year="2021", ref_date=as.Date("2021-06-23"), time_int_nbr=10, time_int_refstack=45, cloud_vec=c(3,7:10), cloud_value=-999, nodata_vec=c(0:2,5,6,11), nodata_value=-555)
  #diff_path = paste0(out_path,tile_vec[i],"/2017/nbr_diff")
  #diff_stk = stack(rev(list.files(diff_path, full.names=T)))
  #names(diff_stk) = rev(lapply(strsplit(list.files(diff_path),".tif"), "[[", 1))
  
  # reprojection of T31TGM
  if (grepl("T31",tile_vec[i])){
    cl = makeForkCluster(detectCores() -1)
    registerDoParallel(cl)
    
    target = raster(list.files(targetpath, full.names = T)[1])
    foreach (i = 1:nlayers(diff_stk), .packages="raster", .inorder=F) %dopar% {
      r = diff_stk[[i]]
      r_32 = projectRaster(r, crs=crs(target), method="ngb")
      extend_target = extend(target, r_32)
      r_32_resample = resample(r_32, extend_target, method="ngb")
      writeRaster(r_32_resample, paste0(diff_path,"/",names(r),".tif"), overwrite=T, datatype='INT2S')
      }
    stopCluster(cl)
  }
  
  dates = substring(lapply(strsplit(names(diff_stk),"_"), "[[", 4),1,8)
  dates_all = c(dates_all,dates)
}

dates_all = sort(unique(dates_all))
forest_mask = raster(mask_path)

for (i in 1:length(dates_all)){
  
  # get diff rasters
  diffnames = list.files(out_path, pattern=paste0("NBR_diff_",dates_all[i]), recursive=T,full.names = T)
  if (length(diffnames)>1){
    rlist = c(lapply(diffnames, FUN = raster))
    rlist$fun = min
    rlist$na.rm <- TRUE
    print("start mosaic...")
    mosaic_date = do.call("mosaic", rlist)
    } else {
    mosaic_date = raster(diffnames)
    }
  
  # apply forest mask
  print("start masking...")
  mosaic_date = merge(mosaic_date, forest_mask*(-555))
  mosaic_crop = crop(mosaic_date, forest_mask)
  mosaic_masked = mask(mosaic_crop, forest_mask, updatevalue=0)
  rm(mosaic_date, mosaic_crop)
 
  # polygonize
  print("start polygonize...")
  names(mosaic_masked) = dates_all[i]
  polys = build_polygons(mosaic_masked, th = -15, area_th = 500)
  rm(mosaic_masked)
  polys = spTransform(polys, CRS("+init=epsg:3857"))
  
  shp = file.path(shp_path,paste0("change_",dates_all[i],"_epsg3857.shp"))
  shapefile(polys, shp)
  if (i==1) polys_all = polys else polys_all = rbind(polys_all, polys)
  rm(polys, shp)
}

# update shapefile
print("update shapefile...")
shp = file.path(out_path,"change_all_epsg3857.shp")
update_shapefile(polys_all, shp, length_of_archive = 45)
  
print(Sys.time() - start_time)