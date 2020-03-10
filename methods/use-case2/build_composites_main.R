############################################################
# Automatic calculation of NBR reference composites
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
source("use-case2/build_composite_stack.R")

# paths
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI2Ap/SAFE/"
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/"

tile_vec = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
tile_vec = tile_vec[3]

# register for paralell processing
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

# calculate composite & clean up
foreach(i=1:length(tile_vec)) %dopar% {
  build_composite_stack(main_path, out_path, tile_vec[i], year="2017", ref_date=as.Date("2017-08-19"), time_int_nbr=45, time_int_refstack=45)
}

stopCluster(cl)

print(Sys.time() - start_time)