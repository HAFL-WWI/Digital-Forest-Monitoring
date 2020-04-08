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
main_path = "//mnt/smb.hdd.rbd/BFH/Geodata/ESA/S2MSI2Ap/SAFE/"
out_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Test_all/"

tile_vec = c("32TLT", "32TLS", "32TMT", "32TMS", "32TNT", "32TNS", "32TMR", "31TGM")
#tile_vec = tile_vec[3]

# register for paralell processing
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

# calculate composite & clean up
foreach(i=1:length(tile_vec)) %dopar% {
  build_composite_stack(main_path, out_path, tile_vec[i], year="2017", ref_date=as.Date("2017-08-19"), time_int_nbr=45, time_int_refstack=45, thr=0.99)
}

stopCluster(cl)

print(Sys.time() - start_time)