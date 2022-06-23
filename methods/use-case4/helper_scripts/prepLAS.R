#------------------------------------------------------------------------------#
# Plots spatial extents and locations
# Merge and clip multiple las files
# Normalize LiDAR point cloud with DTM
# Write DTM and CHM rasters (if calculated)
# 
# if you have multiple datasets, this script needs to be run for each seperately
# (you may consider creating multiple versions to store paths/names)
#
# (c) by Hannes Horneber, HAFL, BFH, 2021-02-15
# based on script by Dominique Weber, HAFL, BFH
#------------------------------------------------------------------------------#

library(rgdal)
library(lidR)
library(mapview) # not needed probably
library(raster)

#-------------------------------#
####         SETTINGS        ####
#  copy to 2_lidar_profiles.R   #
#-------------------------------#
# Base Path:  allows to switch easily between server/local path or various platforms 
#             if you copy/move the folder with all subfolders
# BASE_PATH = "P:/HAFL/7 WWI/74a FF WG/742a Aktuell/LiDAR_Dominique/LiDAR_Profiles/continued_hbh1" # on HARA
BASE_PATH = "C:/Users/hbh1/Projects/H05_LiDAR" # local
# WD: Working Directory. Best, if you keep this script at this place 
#     and all subfolders (data/shp, profiles, ...) in this folder
WD = file.path(BASE_PATH, "LiDAR_Profiles/R/20210311_Wilisau")



# path (within WD) to shapefile
FILE_SHP = file.path(WD, "data/shp","wilisau.shp")

#-------------------------------#
####         SETTINGS 2      ####
#    adjust for each dataset    #
#-------------------------------#

# output file (LAS dataset cropped to shapefile (with buffer) will be generated)
# for each dataset add this path in DATA_LAS in R-Script: 2_lidar_profiles.R 
FILE_LAS_CLIPPED = file.path(WD, "data", paste("wilisau2020_", tools::file_path_sans_ext(basename(FILE_SHP)), ".las", sep=""))

# input LAS (LAS dataset(s) to crop from)
# FILES_LAS = c(file.path(BASE_PATH, "LiDAR_Profiles/data/LAS/swisssurface3d_wilisau/2640_1219.las"))
FILES_LAS = c("P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.010499-52-FWWG-01_Wissenstransfer_Fernerkundung/Entwicklung/Digital_Forest_Monitoring_git/methods/use-case4/output/2021-09-08_225037_0.1_Bern/Bern_1.las",
              "P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.010499-52-FWWG-01_Wissenstransfer_Fernerkundung/Entwicklung/Digital_Forest_Monitoring_git/methods/use-case4/output/2021-09-08_225037_0.1_Bern/Bern_2.las")


# input DTM (if you have a pre-calculated/external DTM for the area of interest)
FILE_DTM = file.path(BASE_PATH, "LiDAR_Profiles/data/DHM/dtm_ALS_Bern_2019_nNA.tif")
FILE_DTM = "P:/HAFL/7 WWI/74b FF GNG/742b Aktuell/2018-2020_FINTCH_R.009030-52-FWGN-01/AP6_Abgrenzung_der_WST/Entwicklung/TBk_Bern/BGB_20191114/LiDAR_Daten_Festmeter/DTM_Bern_05m/dtm_ALS_Bern_2019_nNA.tif"

# turn on manual normalization 
MANUAL_NORMALIZATION = TRUE

# buffer LAS clip around shapefile (should be > cross section width CS_WIDTH)
BUFFER_M = 20

#-------------------------------#
####        LOAD DATA        ####
#-------------------------------#
# load shapefile (kml -> shp)
sp = readOGR(FILE_SHP)
# create buffer around shapefile (in meters)
sp_b = buffer(sp, BUFFER_M)

# load las data as catalog
ctg <- catalog(FILES_LAS)

# create shp file with extents for las
# ext_sp <- as(extent(ctg), 'SpatialPolygons')
# crs(ext_sp) <- crs(ctg) # assign CRS
# shapefile(ext_sp, paste(tools::file_path_sans_ext(FILES_LAS[1]), "_ext.shp", sep="") )

#-------------------------------#
####      CHECK EXTENTS      ####
#-------------------------------#
plot(ctg)
plot(ctg, main="LAS extents and profile locations")
plot(sp_b, add=T, col="darkred")
plot(sp, add=T, col="red")

#-------------------------------#
####         CLIP LAS        ####
#-------------------------------#
# las = lasclip(ctg, extent(sp_b)) # deprecated
las = clip_roi(ctg, extent(sp_b))

# plot to check clip
plot(extent(las))
plot(sp_b, add=T, col="darkred")
plot(sp, add=T, col="red")

# write clipped las data
writeLAS(las, FILE_LAS_CLIPPED)
# write extent shapefile for las data
ext_sp <- as(extent(las), 'SpatialPolygons')
crs(ext_sp) <- crs(las) # assign CRS
# ext_spd <- as(ext_sp, "SpatialPolygonsDataFrame")
shapefile(ext_sp, paste(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_ext.shp", sep=""))


#-------------------------------#
####           DTM           ####
#-------------------------------#
if(!exists("FILE_DTM")){
  # generate dtm
  dtm = grid_terrain(las, algorithm = kriging(k = 10L))
} else {
  # load DTM and clip
  dtm_full = raster(FILE_DTM)
  # las = ctg
  dtm = crop(dtm_full, extent(las))
}
las = readLAS(FILES_LAS[2])
#-------------------------------#
####      NORMALIZE LAS      ####
#-------------------------------#
lasn = lasnormalize(las, dtm, na.rm=T) # deprecated
hist(lasn$Z, main = "", xlab = "Elevation before MIN subtract", breaks = 800)

# min = 42.794
# diff = 42.794 + 5.8 = 48.594
# subtract minimum to level to zero
lasn$Z <- lasn$Z - min(lasn$Z)
hist(lasn$Z, main = "", xlab = "Elevation minus MIN", breaks = 800)

if(MANUAL_NORMALIZATION) {
  # manual adjustment: 
  # run this script interactively to execute these lines according to your needs / histogram
  lasn$Z <- lasn$Z + 0.2 # raise point cloud by x (e.g. 0.2)
  lasn$Z <- lasn$Z - 48.794 # lower point cloud
  lasn$Z <- lasn$Z - 0.2 # lower point cloud
  # check height distribution with histogram
  hist(lasn$Z, main = "", xlab = "Elevation manual", breaks = 800)
  # set negative values to zero afterwards
  lasn$Z[lasn$Z < 0] = 0 # level points below zero (at the end)
}

writeLAS(las = lasn, file = "P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.010499-52-FWWG-01_Wissenstransfer_Fernerkundung/Entwicklung/Digital_Forest_Monitoring_git/methods/use-case4/output/2021-09-08_225037_0.1_Bern/Bern_2n_manual.las")

#-------------------------------#
####           CHM           ####
#-------------------------------#
chm = grid_canopy(lasn, 0.5, pitfree(c(0,2,5,10,15), c(0, 1.5)))
plot(chm)
plot(sp, add=T, col="red")

# save plot to base dir 
png(file.path(WD, paste(tools::file_path_sans_ext(basename(FILE_SHP)), "_chm.png", sep="")))
plot(chm)
plot(sp, add=T, col="red")
dev.off()

#-------------------------------#
####       WRITE OUTPUT      ####
#-------------------------------#
# write las_normalized, dtm and chm
writeLAS(lasn, paste(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_n.las", sep=""))
writeRaster(dtm, paste(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_dtm.tif", sep=""), overwrite=T)
writeRaster(chm, paste(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_chm_pitfree.tif", sep=""), overwrite=T)

