############################################################
# Raster calc performance tests
#
# by Dominique Weber, BFH-HAFL
############################################################

# see: https://www.earthdatascience.org/courses/earth-analytics/multispectral-remote-sensing-data/process-rasters-faster-in-R/

#############################
# 1.) stack vs. brick

library(raster)
library(microbenchmark)

# global params
band_names = c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B09", "B10","B11", "B12")
file = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI1C/GeoTIFF/T32TLT/2018/S2B_MSIL1C_20180619T103019_N0206_R108_T32TLT_20180619T123724.tif"

calc_ndvi <- function(b4, b8) {
  return (b8 - b4) / (b8 + b4)
}

# stack
stk = stack(file)
names(stk) = band_names
microbenchmark(calc_ndvi(stk$B04, stk$B08), times=5)
# tested locally --> mean of 39 sec.

# brick
stk = brick(file)
names(stk) = band_names
microbenchmark(calc_ndvi(stk$B04, stk$B08), times=5)
# tested locally --> mean of 39 sec.

#############################
# 2.) calc vs. overlay

library(raster)
library(microbenchmark)

# global params
band_names = c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B09", "B10","B11", "B12")
file = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI1C/GeoTIFF/T32TLT/2018/S2B_MSIL1C_20180619T103019_N0206_R108_T32TLT_20180619T123724.tif"

# load data
stk = stack(file)
names(stk) = band_names

calc_ndvi <- function(b4, b8) {
  return (b8 - b4) / (b8 + b4)
}

# calc
microbenchmark(calc_ndvi(stk$B04, stk$B08), times=5)
# tested locally --> mean of 39 sec.

# overlay
microbenchmark(overlay(stk$B04, stk$B08, fun = calc_ndvi), times=5)
# tested locally --> mean of 39 sec.

#############################
# 3.) calc vs. calc cluster

library(raster)
library(snow)
library(microbenchmark)

# global params
band_names = c("B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B09", "B10","B11", "B12")
file = "//mnt/smb.hdd.rbd/BFH/Geodata/World/Sentinel-2/S2MSI1C/GeoTIFF/T32TLT/2018/S2B_MSIL1C_20180619T103019_N0206_R108_T32TLT_20180619T123724.tif"

# load data
stk = stack(file)
names(stk) = band_names

calc_ndvi <- function(b4, b8) {
  return (b8 - b4) / (b8 + b4)
}

# calc
microbenchmark(calc_ndvi(stk), times=5)

# calc with cluster
beginCluster()
microbenchmark(clusterR(stk[[c("B04", "B08")]], overlay, args=list(fun=calc_ndvi)), times=5)
endCluster()

#############################
# 4.) which.max

library(raster)
library(snow)
library(microbenchmark)

# test with small NDVI stack
stk = brick("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/misc/vi_test.tif")
microbenchmark(calc(stk, max), times=5)
microbenchmark(calc(stk, which.max), times=5)
beginCluster()
microbenchmark(clusterR(stk, calc, args=list(fun=which.max)), times=5)
endCluster()