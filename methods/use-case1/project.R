############################################################
# Project rasters with gdalwarp
#
# by Dominique Weber, BFH-HAFL
############################################################

# load packages
library(foreach)
library(doParallel)

project <- function(path, crs) {
  # get files
  files = list.files(path, pattern = "2020_2019.tif", full.names = T)
  
  # project lv95
  print(paste("processing", length(files), "files in parallel mode..."))
  print(files)
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  foreach(i=1:length(files)) %dopar% {
    path = dirname(files[[i]])
    in_file = files[[i]]
    out_file = paste(tools::file_path_sans_ext(files[[i]]), "_reprojected_cubic", ".tif", sep="")
    cmd = paste("gdalwarp -t_srs", crs, "-r cubic -tr 10 10 -co COMPRESS=LZW", in_file, out_file)
    system(cmd)
  }
  stopCluster(cl)
}