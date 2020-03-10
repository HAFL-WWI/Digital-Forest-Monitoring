############################################################
# Crop and resample forest mask per Sentinel-2 tile
#
# by Dominique Weber, BFH-HAFL
############################################################

# load libraries
library(raster)
library(rgdal)

# files
forest_mask = raster("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.tif")
forest_mask_utm31 = raster("//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_wgs84_utm31.tif")
tiles = c("32TLT", "32TMT", "32TNT", "32TPT", "31TGM", "32TLS", "32TMS", "32TNS", "32TPS", "32TLR", "32TMR")
img_path = "//mnt/smb.hdd.rbd/BFH/Geodata.new/World/Sentinel-2/S2MSI1C/GeoTIFF"
out_path = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald"

# create forest masks aligned to sentinel-2 pixels
for(i in tiles){
  print(i)
  ref = raster(list.files(file.path(img_path, i), recursive=T, pattern="tif$", full.names = T)[1])
  if(i == "31TGM"){
    mask = crop(forest_mask_utm31, extent(ref))
  }else{
    mask = crop(forest_mask, extent(ref))
  }
  out = file.path(out_path, paste("forest_mask_", i, ".tif", sep=""))
  resample(mask, ref, filename=out, datatype="INT1U", overwrite=T)
}