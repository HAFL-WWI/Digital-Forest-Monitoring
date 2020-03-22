############################################################
# Reproject diff rasters
#
# by Dominique Weber, BFH-HAFL
############################################################

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

# source functions
source("use-case1/project.R")

path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/"
crs = "EPSG:3857"
project(path, crs)