############################################################
# Project to LV95
#
# by Dominique Weber, BFH-HAFL
############################################################

# load packages
library(foreach)
library(doParallel)

project <- function(path) {
  # get files
  files = list.files(path, pattern = ".tif", full.names = T)
  
  # project lv95
  print(paste("processing", length(files), "tiles in parallel mode..."))
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  foreach(i=1:length(files)) %dopar% {
    path = dirname(files[[i]])
    in_file = files[[i]]
    out_file = paste(tools::file_path_sans_ext(files[[i]]), "_lv95", ".tif", sep="")
    cmd = paste("gdalwarp -t_srs EPSG:2056 -tr 10 10", in_file, out_file)
    system(cmd)
  }
  stopCluster(cl)
}