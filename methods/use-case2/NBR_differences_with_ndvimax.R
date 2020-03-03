############################################################
# Automatic calculation of NBR differences (with NDVI max archive)
#
# by Alexandra Erbach, HAFL, BFH
############################################################

start_time <- Sys.time()

# load packages
library(raster)
library(foreach)
library(doParallel)

# set working directory
setwd("~/")

# source functions
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/calc_nbr_differences.R")
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/build_composite_stack.R")

# paths
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI2Ap/SAFE/"
out_path = "//home/eaa2/nbr_test_ndvimax/"

tile_vec = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
tile_vec = tile_vec[3]

# register for paralell processing
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

# calculate NBR differences
foreach(i=1:length(tile_vec)) %dopar% {
calc_nbr_differences(main_path, out_path, tile_vec[i], year="2017", ref_date=as.Date("2017-08-09"), time_int_nbr=3, time_int_refstack=20, scl_vec=c(3,5,7:10), cloud_value=-999, nodata_value=-555)
}

# --> mask, polygonize etc.

# calculate composite & clean up
foreach(i=1:length(tile_vec)) %dopar% {
  build_composite_stack(main_path, out_path, tile_vec[i], year="2017", ref_date=as.Date("2017-08-09"), time_int_nbr=6, time_int_refstack=15)
}

stopCluster(cl)

print(Sys.time() - start_time)