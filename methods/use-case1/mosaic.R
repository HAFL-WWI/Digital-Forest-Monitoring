############################################################
# Project to LV95 and mosaic all tiles
#
# by Dominique Weber, BFH-HAFL
############################################################

# load packages
library(foreach)
library(doParallel)

mosaic <- function(path, out) {
  files = list.files(path, pattern = "lv95.tif", full.names = T)
  path = dirname(files[[1]])
  in_files = do.call(paste, c(as.list(files), sep=" "))
  cmd = paste("gdal_merge.py -o", out, in_files)
  system(cmd)
}