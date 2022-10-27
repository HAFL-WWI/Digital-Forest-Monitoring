#---------------------------------------------------------------------#
# Project rasters with gdalwarp
#
# by Dominique Weber, BFH-HAFL
#---------------------------------------------------------------------#

# load packages
library(foreach)
library(doParallel)

# can be called with suffix to determine output name pattern
# defaults to crs (without :, e.g. EPSG:3857 -> EPSG3857)
project <- function(path, crs, pattern, suffix = NULL) {
  # set suffix to default value
  if(is.null(suffix)) suffix = paste0("_", gsub(":", "", crs))
  
  # get files
  files = list.files(path, pattern = pattern, full.names = T)
  
  # project lv95
  print(paste("processing", length(files), "file(s) in parallel mode..."))
  print(files)
  cl = makeCluster(detectCores() -1)
  registerDoParallel(cl)
  foreach(i=1:length(files)) %dopar% {
    path = dirname(files[[i]])
    in_file = files[[i]]
    out_file = paste0(tools::file_path_sans_ext(files[[i]]), suffix, ".tif")
    cmd = paste("gdalwarp -t_srs", crs, "-r bilinear -tr 10 10 -co COMPRESS=LZW", in_file, out_file)
    system(cmd)
  }
  stopCluster(cl)
}