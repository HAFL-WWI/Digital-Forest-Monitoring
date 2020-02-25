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
source("//home/eaa2/Digital-Forest-Monitoring/methods/use-case2/NBR_diffs_with_ndvimax_function.R")

# paths
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI2Ap/SAFE/"
out_path = "//home/eaa2/nbr_test_ndvimax/"

tile_vec = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
tile_vec = tile_vec[3]

  for (tile_i in tile_vec){
    calc_nbr_differences(main_path, out_path, tile_i, year="2017", ref_date=as.Date("2017-08-09"), time_int_nbr=3, time_int_refstack=30, scl_vec=c(3,5,7:10), cloud_value0=-999, nodata_value=-555)
  }

print(Sys.time() - start_time)