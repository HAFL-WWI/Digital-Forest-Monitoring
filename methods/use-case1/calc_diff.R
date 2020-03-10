############################################################
# Calculate NDVI max composite difference.
#
# 
# by Dominique Weber, BFH-HAFL
############################################################

# NDVI composites
ndvi_2017 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2017/ndvi_max_ch_forest.tif"
ndvi_2018 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2018/ndvi_max_ch_forest.tif"

# calc differences

# 2018 - 2017
diff_2018_2017 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2018_2017.tif"
system(paste("gdal_calc.py -A ", ndvi_2018, " -B ", ndvi_2017, " --outfile=", diff_2018_2017, " --calc=\"A-B * (A != -9999) * (B != -9999)\" --co=\"COMPRESS=LZW\" --type='Float32'", sep=""))
