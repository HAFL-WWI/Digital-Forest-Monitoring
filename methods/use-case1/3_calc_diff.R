#---------------------------------------------------------------------#
# Calculate NDVI max composite difference.
#
# by Dominique Weber, Alexandra Erbach and Hannes Horneber, BFH-HAFL
#---------------------------------------------------------------------#

# NDVI composites
# ndvi_2015 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2015/ndvi_max_ch_forest.tif"
# ndvi_2016 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2016/ndvi_max_ch_forest.tif"
# ndvi_2017 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2017/ndvi_max_ch_forest.tif"
# ndvi_2018 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2018/ndvi_max_ch_forest.tif"
# ndvi_2019 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2019/ndvi_max_ch_forest.tif"
# ndvi_2020 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2020/ndvi_max_ch_forest.tif"
ndvi_2021 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2021/ndvi_max_ch_forest.tif"
ndvi_2022 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2022/ndvi_max_ch_forest.tif"

# START...
start_time <- Sys.time()

# calc differences
# diff_2016_2015 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2016_2015_Int16.tif"
# system(paste("gdal_calc.py -A ", ndvi_2016, " -B ", ndvi_2015, " --outfile=", diff_2016_2015, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
# print(Sys.time()- start_time)
# 
# diff_2017_2016 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2017_2016_Int16.tif"
# system(paste("gdal_calc.py -A ", ndvi_2017, " -B ", ndvi_2016, " --outfile=", diff_2017_2016, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
# print(Sys.time()- start_time)
# 
# diff_2018_2017 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2018_2017_Int16.tif"
# system(paste("gdal_calc.py -A ", ndvi_2018, " -B ", ndvi_2017, " --outfile=", diff_2018_2017, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
# print(Sys.time()- start_time)
# 
# diff_2019_2018 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2019_2018_Int16.tif"
# system(paste("gdal_calc.py -A ", ndvi_2019, " -B ", ndvi_2018, " --outfile=", diff_2019_2018, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
# print(Sys.time()- start_time)
# 
# diff_2020_2019 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2020_2019_Int16.tif"
# system(paste("gdal_calc.py -A ", ndvi_2020, " -B ", ndvi_2019, " --outfile=", diff_2020_2019, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
# print(Sys.time()- start_time)
# 
# diff_2021_2020 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2021_2020_Int16.tif"
# system(paste("gdal_calc.py -A ", ndvi_2021, " -B ", ndvi_2020, " --outfile=", diff_2021_2020, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
# print(Sys.time()- start_time)

diff_2022_2021 = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/ndvi_diff_2022_2021_Int16.tif"
system(paste("gdal_calc.py -A ", ndvi_2022, " -B ", ndvi_2021, " --outfile=", diff_2022_2021, " --calc=\"(A-B) * 10000 \" --co=\"COMPRESS=LZW\" --type='Int16'", sep=""))
print(Sys.time()- start_time)

# END ...
print(Sys.time()- start_time)
print("DONE calculating difference.")