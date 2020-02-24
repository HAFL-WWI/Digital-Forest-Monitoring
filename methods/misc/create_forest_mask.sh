#!/bin/sh

# file paths
SHP_IN=/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/general/swissTLM3D_Wald/Wald.shp
SHP_OUT=/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.shp
RASTER_OUT=/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Projekt_Use-Cases/general/swissTLM3D_Wald/Wald_wgs84.tif

# reproject lv03 to wgs84
ogr2ogr -s_srs EPSG:21781 -t_srs EPSG:32632 -f "ESRI Shapefile" $SHP_OUT $SHP_IN

# rasterize 
gdal_rasterize -burn 1 -tr 10 10 -te 264850.0, 5073820.0, 609780.0, 5295110.0 -ot Byte -init 255 -a_nodata 255 -co COMPRESS=LZW $SHP_OUT $RASTER_OUT
