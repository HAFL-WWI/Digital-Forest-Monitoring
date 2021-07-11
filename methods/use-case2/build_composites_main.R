############################################################
# Automatic calculation of NBR reference composites
#
# by Alexandra Erbach, BFH-HAFL
############################################################

start_time <- Sys.time()

setwd("~/Digital-Forest-Monitoring/methods")

# source functions
source("use-case2/build_composite_stack.R")

# paths
main_path = "/mnt/smb.hdd.rbd/BFH/Geodata/ESA/S2MSI2A/SAFE/"
out_path = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Sturm_ZG_2021/"

tile_vec = c("T32TLT", "T32TLS", "T32TMT", "T32TMS", "T32TNT", "T32TNS", "T32TMR", "T31TGM")
tile_vec = c("32TMT")

#calculate composite & clean up
for (i in 1:length(tile_vec)){
 build_composite_stack(main_path, out_path, tile_vec[i], year="2021", ref_date=as.Date("2021-06-23"), time_int_nbr=10, time_int_refstack=45, thr=0.99)
}

print(Sys.time() - start_time)