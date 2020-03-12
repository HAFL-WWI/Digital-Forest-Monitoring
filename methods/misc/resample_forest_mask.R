############################################################
# Create forest mask resampled to reference raster
#
# by Dominique Weber, BFH-HAFL
############################################################

# load libraries
library(raster)
library(rgdal)

# files
in_mask = raster("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95.tif")
ref = raster("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2015/ndvi_max_ch.tif")
out_mask = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95_rs.tif"

# resample
print("do resampling and write new mask...")
resample(in_mask, ref, filename=out_mask, datatype="INT1U", overwrite=T)
