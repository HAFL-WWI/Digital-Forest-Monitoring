setwd("~/Digital-Forest-Monitoring/methods")
source("use-case1/mosaic.R")

path = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3/Validierung/doi_10.5061_dryad.d51c5b019__v6/Early_wilting_CentralEurope"
tile_vec = c("32TLT", "32TLS", "32TMT", "32TMS", "32TNT", "32TNS", "32TMR", "31TGM")
ch_shp = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissBOUNDARIES3D/swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET.shp"

swiss = grep(paste(tile_vec,collapse="|"), list.files(path,full.names=T), value=TRUE)

mosaic_ch = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3/Validierung/early_wilting_ch.tif"
mosaic_ch_boundary = "//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case3/Validierung/early_wilting_ch_boundary.tif"

print("mosaic all tiles...")
swiss = do.call(paste, c(as.list(swiss), sep=" "))
cmd = paste("gdal_merge.py -o", mosaic_ch, swiss)
system(cmd)

print("clip mosaic to swiss boundaries...")
system(paste("gdalwarp -cutline", ch_shp, "-crop_to_cutline -wo CUTLINE_ALL_TOUCHED=TRUE -dstnodata -32767", mosaic_ch, mosaic_ch_boundary))
