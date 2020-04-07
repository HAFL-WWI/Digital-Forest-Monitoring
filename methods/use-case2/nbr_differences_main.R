############################################################
# Automatic calculation of NBR differences
#
# by Alexandra Erbach, BFH-HAFL
############################################################

start_time <- Sys.time()

setwd("~/Digital-Forest-Monitoring/methods")

# load packages
library(raster)
library(foreach)
library(doParallel)

# source functions
source("use-case2/calc_nbr_differences.R")
source("use-case2/build_polygons.R")
source("use-case2/update_shapefile.R")

# paths
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/ESA/S2MSI2Ap/SAFE/"
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Test_all/"
masks = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/tiles/"

tile_vec = c("32TLT", "32TLS", "32TMT", "32TMS", "32TNT", "32TNS", "32TMR", "31TGM")
#tile_vec = tile_vec[3]

# register for paralell processing
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

#diff_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/T32TMT/2017/nbr_diff"
#diff_stk = stack(rev(list.files(diff_path, full.names=T)))[[1]]
#names(diff_stk) = rev(lapply(strsplit(list.files(diff_path),".tif"), "[[", 1))[1]

# calculate NBR differences
foreach(i=1:length(tile_vec), .packages = c("raster", "velox")) %dopar% {
  
  diff_stk = calc_nbr_differences(main_path, out_path, tile_vec[i], year="2017", ref_date=as.Date("2017-08-19"), time_int_nbr=45, time_int_refstack=45, cloud_vec=c(3,7:10), cloud_value=-999, nodata_vec=c(0:2,5,6,11), nodata_value=-555)
  
  if (!is.null(diff_stk)){
    # apply forest mask
    forest_mask = raster(list.files(masks, pattern=tile_vec[i], full.names = T))
    nbr_diff_masked = mask(diff_stk, forest_mask, updatevalue = 0)
    
    # polygonize and update shapefile
    shp = file.path(out_path, paste(tile_vec[i],"/2017/nbr_change_", tile_vec[i], ".shp", sep=""))
    for(j in 1:nlayers(nbr_diff_masked)){
      # polygonize
      polys = build_polygons(nbr_diff_masked[[j]])
    
      # update shapefile
      update_shapefile(polys, shp, length_of_archive = 45)
    }
  }
}

stopCluster(cl)

print(Sys.time() - start_time)