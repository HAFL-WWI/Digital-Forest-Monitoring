#!/bin/sh

# file paths
SHP_IN=/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald.shp
SHP_OUT=/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95.shp
RASTER_OUT=/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/general/swissTLM3D_Wald/Wald_LV95.tif

# reproject LV03 to LV95
ogr2ogr -s_srs EPSG:21781 -t_srs EPSG:2056 -f "ESRI Shapefile" $SHP_OUT $SHP_IN

# rasterize 
gdal_rasterize -burn 1 -tr 10 10 -te 2485406.16245 1075269.99667 2833846.16245 1295939.99667 -ot Byte -init 255 -a_nodata 255 -co COMPRESS=LZW $SHP_OUT $RASTER_OUT
