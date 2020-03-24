############################################################
# Calculate NDVI max composite difference.
#
# by Dominique Weber, BFH-HAFL
############################################################

# NDVI composites
ndvi_2015 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2015/ndvi_max_ch_forest.tif"
ndvi_2016 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2016/ndvi_max_ch_forest.tif"
ndvi_2017 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2017/ndvi_max_ch_forest.tif"
ndvi_2018 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2018/ndvi_max_ch_forest.tif"
ndvi_2019 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2019/ndvi_max_ch_forest.tif"

# calc differences
diff_2016_2015 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2016_2015.tif"
system(paste("gdal_calc.py -A ", ndvi_2016, " -B ", ndvi_2015, " --outfile=", diff_2016_2015, " --calc=\"A-B * (A != -9999) * (B != -9999)\" --co=\"COMPRESS=LZW\" --type='Float32'", sep=""))

diff_2017_2016 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2017_2016.tif"
system(paste("gdal_calc.py -A ", ndvi_2017, " -B ", ndvi_2016, " --outfile=", diff_2017_2016, " --calc=\"A-B * (A != -9999) * (B != -9999)\" --co=\"COMPRESS=LZW\" --type='Float32'", sep=""))

diff_2018_2017 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2018_2017.tif"
system(paste("gdal_calc.py -A ", ndvi_2018, " -B ", ndvi_2017, " --outfile=", diff_2018_2017, " --calc=\"A-B * (A != -9999) * (B != -9999)\" --co=\"COMPRESS=LZW\" --type='Float32'", sep=""))

diff_2019_2018 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2019_2018.tif"
system(paste("gdal_calc.py -A ", ndvi_2019, " -B ", ndvi_2018, " --outfile=", diff_2019_2018, " --calc=\"A-B * (A != -9999) * (B != -9999)\" --co=\"COMPRESS=LZW\" --type='Float32'", sep=""))