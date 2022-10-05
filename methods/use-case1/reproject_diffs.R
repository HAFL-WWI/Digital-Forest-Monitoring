#---------------------------------------------------------------------#
# Reproject diff rasters
#
# by Dominique Weber, BFH-HAFL
#---------------------------------------------------------------------#

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

# source functions
source("use-case1/project.R")

# folder in which files to reproject are stored
path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/"

# filename pattern of files that are to be reprojected
# filename_pattern = "2021_2020_Int16.tif"
filename_pattern = "2022_2021_Int16.tif"

# crs to project into
crs = "EPSG:3857"

# START...
start_time <- Sys.time()

# call function (see function code to understand behavior)
project(path, crs, filename_pattern)

# END ...
print(Sys.time()- start_time)
print("DONE reprojecting.")