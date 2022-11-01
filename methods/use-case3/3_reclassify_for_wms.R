#-------------------------------------------------------------------------------#
# Reclassify UC3 rasters for WMS 
# (thresholding and masking to NA)
#
#
# by Dominique Weber, Alexandra Erbach, Hannes Horneber, BFH-HAFL
#-------------------------------------------------------------------------------#

# load library
library(raster)
library(doParallel)
library(foreach)

# set wd
setwd("~/Digital-Forest-Monitoring/methods")

#-----------------------------------------#
####         GENERAL SETTINGS          ####
# main path
main_path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3"
# get files to reclassify from a folder (expanded output)
# select with regular expression pattern
# in_files = dir(paste0(main_path,"/2_expand_output"), full.names=T, pattern="*.tif$") # all years
in_files = dir(paste0(main_path,"/2_expand_output"), full.names=T, pattern=".*(2022).*(.tif)$") # 2022
# in_files = dir(paste0(main_path,"/2_expand_output"), full.names=T, pattern=".*(2022|2021).*(.tif)$") # 2021 or 2022
out_dir = paste0(main_path,"/3_reclassified_forWMS")
#-----------------------------------------#

print(paste("RECLASSIFY: process", length(in_files), "files"))
print(in_files)

# loop over files
cl = makeCluster(detectCores() -1)
registerDoParallel(cl)

foreach(i=1:length(in_files), .packages=c("raster")) %dopar% {
  # get input filename
  in_file = in_files[i]
  # create output filename
  out_file = paste0(tools::file_path_sans_ext(basename(in_file)),"_forWMS.tif")
  out_file = file.path(out_dir, out_file)
  
  # call gdal command
  print(paste(i, "> processing", in_file))
  system(paste("gdal_calc.py -A ", in_file, " --outfile=", out_file, " --calc=\"(A<=-100)*A + (A>=100)*A + (A>-100)*(A<100)*(-32767)\" --co=\"PIXELTYPE=SIGNEDBYTE\" --co=\"COMPRESS=LZW\" --type='Int16' --NoDataValue=-32767 --allBands=A --overwrite", sep=""))
  print(paste(i, "> done:", out_file))
  
}
stopCluster(cl)
