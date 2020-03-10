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
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI2Ap/SAFE/"
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/"
shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/nbr_diff.shp"

tile_vec = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
tile_vec = tile_vec[3]

# register for paralell processing
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

# calculate NBR differences
foreach(i=1:length(tile_vec)) %dopar% {
  nbr_diff = calc_nbr_differences(main_path, out_path, tile_vec[i], year="2017", ref_date=as.Date("2017-08-19"), time_int_nbr=45, time_int_refstack=45, scl_vec=c(3,5,7:10), cloud_value=-999, nodata_value=-555)


  # TODO apply forest mask

  # polygonize
  polys = build_polygons(nbr_diff)

  # update shapefile
  update_shapefile(polys, shp)

}

stopCluster(cl)

print(Sys.time() - start_time)