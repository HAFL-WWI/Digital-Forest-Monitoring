#------------------------------------------------------------------------------#
# Generate Rasters from LAS for Rejuvenation Indications - tilewise processing
#------------------------------------------------------------------------------#
# This will generate a set of rejuvenation rasters from LAS data.
#
# LAS and DTM tiles are assumed to be downloaded previously (swisstopo swissSurface3D/swissAlti3D)
#
# Vector Tiles: Additional input is a vector file, that contains the tiles to be processed (swisstiles).
# We recommend masking the swisstiles with a forest mask, so that they are partially masked
# (to the forest area) to avoid computationally intensive LAS processes being applied to non-forest.
# 
#------------------------------------------------------------------------------#
# Disclaimer: This contains Paths specific to the BFH-HAFL infrastructure 
# Adjust these to your needs/local setting.
# Also contains a "history" of paths that are processed.
#
# (c) by Hannes Horneber, HAFL, BFH, 2022-10-05
#------------------------------------------------------------------------------#
# TODO Switch to terra (from library(raster), replace all raster with rast) 
#------------------------------------------------------------------------------#

library(rgdal) # OGR driver (shp files)
library(lidR) # LAS processing
library(raster) # raster/grid processing
library(sf)
library(grainscape) # for patchfilter
library(tictoc)
library(terra)

#-------------------------------#
####     SETTINGS PATHS      ####
#-------------------------------#
# BASE_CEPH = "P:/LFE" # HARA/Local
BASE_CEPH = "/mnt/smb.hdd.rbd" # R-Server

# Base Path:  allows to switch easily between server/local path or various platforms 
#             if you copy/move the folder with all subfolders
# BASE_PATH = "P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.010499-52-FWWG-01_Wissenstransfer_Fernerkundung/Entwicklung/Digital_Forest_Monitoring_git/methods/use-case4" # on HARA
# BASE_PATH = "C:/Users/hbh1/Projects/H06_Totholz/A_Tessin/Daten" # local dev
# BASE_PATH = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten") 
BASE_PATH = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH")
# BASE_PATH = file.path("P:/HAFL/9 Share/PermanenteOrdner/Geodaten/Forst_Daten/waldmonitoring/UC4/data")
# BASE_PATH = file.path("//bfh.ch/data/HAFL/9 Share/PermanenteOrdner/Geodaten/Forst_Daten/waldmonitoring/UC4/data")

# WD: Working Directory. Best, if you keep this script at this place 
#     and all subfolders (data/shp, profiles, ...) in this folder
WD = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/uc4_wd")
# WD = file.path(BASE_PATH, "")

# PATH_LAS_BASE = file.path(BASE_CEPH, "BFH/Geodata/swisstopo/meta/swissSURFACE3D/2056-LASzip") # Zentralschweiz (TI, LU, AG, ...)
PATH_LAS_BASE = file.path(BASE_CEPH, "BFH/Geodata/swisstopo/swissSURFACE3D/LAS") # Ost- / Westschweiz (FR, VD, ...)
# PATH_DTM = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/Data_others/DTM/swissALTI3D") # Tessin
# PATH_DTM = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/Data_others/DTM/swissALTI3D_VD") # Vaud
PATH_DTM = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/Data_others/DTM/DTM_05m/tiles") # all of CH

DIR_BASE_OUTPUT = file.path(WD, gsub(" ", "_", gsub(":", "", Sys.time())))
# substr(gsub(" ", "_", gsub(":", "", Sys.time())),3,10) # extract only YYYY-MM-DD

# should be a .gpkg. Implementations for .csv also possible, but needs a solution for mask (clip).
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles_test.shp")
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles.shp")
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles_missing.shp")
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/VD/base_data/Wald_O_GB_GH_swissTLM2021_LV95_VD_tiles.shp")
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/FR/base_data/swissTiles_forest_FR_galmwald.shp") # ext1 / las
FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest_kleinprojekte/swissTiles_forest_FR_Derbaly.gpkg") # ext1 / las
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest_kleinprojekte/swissTiles_forest_FR_Derbaly_Marteloskop.gpkg") # ext1 / las
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_FR.shp") # ext1 / las         #1a
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_AG.shp") # ext2 / laz         #2b
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_SH-ZH-TG.shp") # ext1 / las   #3a 
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_LU.shp") # ext2 / laz         #4b
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_NE.shp") # ext1 / las         #5a
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_ZG-SZ-GL.shp") # ext1 / las   #6a
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_OW-NW-UR.shp") # ext2 / laz   #7b
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_SG-AA-AI.shp") # ext1 / las   #8a
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_SG-AA-AI.shp") # ext1 / las   #8a
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/swissTiles_forest/swissTiles_forest_SG-AA-AI.shp") # ext1 / las   #8a
FILE_TILE_LIST_TYPE = ".gpkg"

# tile filename patterns for DTM/LAS datasets
PATTERN_DTM = "swissalti3d_YEAR_TILEKEY1-TILEKEY2_0.5_2056_5728.tif"
PATTERN_DTM_YEARS = c("2019", "2020", "2021") # if swissalti3d tiles are from several years
PATTERN_LAS = "TILEKEY1_TILEKEY2.las" # for ext1 swissSURFACE3D/LAS
# PATTERN_LAS = "TILEKEY1_TILEKEY2.laz" # for ext2 swissSURFACE3D/2056-LASzip

# generate output folder from filename of tile list
DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST))))
# DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", "UC4_tile") # use custom output folder name 

# by default, virtual rasters (.vrt) are generated to merge results from tiled tifs into a single virtual raster
# if MERGE_TO_SINGLE_TIF is true, the .vrt is used to create an actual merged raster .tif on disk
MERGE_TO_SINGLE_TIF = TRUE

# set to true if processing is to be continued from an earlier script interrupt
CONTINUE = FALSE
# FILE_TILE_LIST and DIR_OUTPUT generally should be manually specified if continuing (overwrite the above)
if(CONTINUE){
  FILE_TILE_LIST = file.path(BASE_PATH, "_output/2021-12-09_140636_DW_tile/Wald_LV95_ticino_tiles_2021-12-09_140636.gpkg")
  DIR_OUTPUT = file.path(WD,"_output", "2021-12-09_140636_DW_tile")
}

#-------------------------------#
####      SETTINGS PROC      ####
#-------------------------------#
# processing output for console
VERBOSE = TRUE
# raster resolution for output
RASTER_RES = 5
# raster resolution for downsampled output
RASTER_RES_DS = 25
# raster resolution for high resolution output
RASTER_RES_HS = 0.5

#-------------------------------#
####      SETTINGS THRESH    ####
#-------------------------------#
# height thresholds for rejuvenation / canopy
REJ_HEIGHT_MIN = 0 # height above ground to start considering points
REJ_HEIGHT1 = 2 # max height class 1 (from ground)
REJ_HEIGHT2 = 5 # max height class 2 (from ground)
CNPY_HEIGHT_MIN = REJ_HEIGHT2 # lowest height to consider for canopy points
CNPY_HEIGHT_MAX = 99

# coverage threshold to consider a cell "covered"
THRESH_COVERED = 0.33

# weight of coverage (influences, how strong relative point density under coverage is amplified based on coverage)
FACTOR_COVERAGE_WEIGHT = 2

####_________________________####
####        PREP DATA        ####
#-------------------------------#

#### > prepare tile list ####
tiles = st_read(FILE_TILE_LIST)
time_start = Sys.time()

# order tile list by TileKey
tiles = tiles[order(tiles$TileKey),]

if(!CONTINUE || is.null(tiles$processed)){
  # set all tiles to not processed
  tiles$processed = FALSE
  
  #### >  output folder create new ####
  if(VERBOSE) print(paste0("--> create output folder: ", DIR_OUTPUT))
  # dir.create(DIR_OUTPUT, recursive = TRUE, showWarnings = FALSE)
  dir.create(DIR_OUTPUT, recursive = FALSE, showWarnings = TRUE)
  
  # create processing file list 
  FILE_TILE_LIST = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST)), "_", gsub(" ", "_", gsub(":", "", time_start)), FILE_TILE_LIST_TYPE))
  st_write(tiles, FILE_TILE_LIST, append = FALSE)
} else {
  #### >  output folder continue ####
  if(VERBOSE) print(paste0("--> reuse output folder: ", DIR_OUTPUT))
  if(VERBOSE) print(paste0("--> continue processing tiles: ", length(which(tiles$processed == FALSE)), "/", nrow(tiles)))
  
  # create copy of processing file list 
  FILE_TILE_LIST = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST)), "_ctd", gsub(" ", "_", gsub(":", "", time_start)), FILE_TILE_LIST_TYPE))
  st_write(tiles, FILE_TILE_LIST, append = FALSE)
}

####_________________________####
####++++++++ MAIN LOOP |>>>>>####
#-------------------------------#
if(VERBOSE) tic()

# loop over tiles
for(tile_id in which(tiles$processed == FALSE)){
  # for(tile_id in rev(which(tiles$processed == FALSE))){ # process in reverse order
  tryCatch( #/starttry (processing tile)
    expr = {
      if(VERBOSE) print(paste0("process ",tile_id,"/",nrow(tiles),": ",tiles$TileKey[tile_id], 
                               " [", gsub(" ", "_", gsub(":", "", Sys.time())), "] "))
      if(VERBOSE) tic()
      #-------------------------------#
      ####        LOAD DATA        ####
      #-------------------------------#
      
      # create file names from TileKey
      tilekey1 = substr(tiles$TileKey[tile_id], 1, 4)
      tilekey2 = substr(tiles$TileKey[tile_id], 6, 10)
      tile_pathLAS = file.path(PATH_LAS_BASE, gsub("TILEKEY2", tilekey2, gsub("TILEKEY1", tilekey1, PATTERN_LAS)))
      tile_pathDTM = file.path(PATH_DTM, gsub("TILEKEY2", tilekey2, gsub("TILEKEY1", tilekey1, PATTERN_DTM)))
      
      for(year in PATTERN_DTM_YEARS) {
        if(file.exists(gsub("YEAR", year, tile_pathDTM))){
          tile_pathDTM = gsub("YEAR", year, tile_pathDTM)
          break
        }
      }
      
      #### > load/prep raster ####
      if(VERBOSE) print(paste0("> ", tile_id, " load DTM: ", tile_pathDTM))
      tile_dtm = raster(tile_pathDTM)
      # create ref_rasters for extent/resolution of lidR grid outputs 
      ref_raster <- raster(extent(tile_dtm), res = RASTER_RES)
      ref_raster_hs <- raster(extent(tile_dtm), res = RASTER_RES_HS)
      ref_raster_ds <- aggregate(ref_raster, RASTER_RES_DS/RASTER_RES, fun=min)
      # ref_raster_ds <- raster(extent(tile_dtm), res = RASTER_RES_DS)
      
      crs(ref_raster) = crs(tile_dtm)
      
      #### > load/prep LAS ####
      if(VERBOSE) print(paste0("> ", tile_id, " load LAS: ", tile_pathLAS))
      tile_las = catalog(tile_pathLAS)
      # use extent(tile_dtm), since this will always cover the full tile
      plot(extent(tile_dtm), main=tiles$TileKey[tile_id])
      plot(extent(tile_las), add=T, col="blue")
      plot(tiles[tile_id,], add=T, col="green")
      
      if(VERBOSE) print(paste0("> ", tile_id, " prep LAS (clip_roi)"))
      las = clip_roi(tile_las, tiles[tile_id,])
      if(VERBOSE) print(paste0("> ", tile_id, " prep LAS (normalize)"))
      lasn = normalize_height(las, tile_dtm, na.rm=T)
      
      remove("tile_dtm") # save memory
      remove("las") # save memory
      
      ####*************************####
      ####     GENERATE GRIDS      ####
      #-------------------------------#
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | canopy coverage" ))
      
      
      #### > CHM           ####
      # chm = grid_canopy(lasn, 1, pitfree(c(0,2,5,10,15), c(0, 1)))
      # plot(chm, main=paste(tiles$TileKey[tile_id], "chm"))
      
      
      #### > cnpy/all points grid ####
      # grid all points
      # r_dgrid_all = grid_density(lasp, res=ref_raster)
      r_npoints_all = grid_metrics(lasn, ~length(Z), res=ref_raster)
      plot(r_npoints_all, main=paste(tiles$TileKey[tile_id], "r_npoints_all"))
      
      # grid canopy points
      lasv = filter_poi(lasn, Classification != 2) # filter to vegetation pointcloud (remove ground classification)
      lasv_cover = filter_poi(lasv, Z>=CNPY_HEIGHT_MIN , Z<CNPY_HEIGHT_MAX) # filter to canopy layer
      r_npoints_cov = grid_metrics(lasv_cover, ~length(Z), res=ref_raster)
      # plot(r_npoints_cov, main=paste(tiles$TileKey[tile_id], "r_npoints_cov"))
      remove("lasv_cover") # clean up to save RAM
      
      
      #### > coverage grid ####
      # e.g. 100 points total, 98 above = 98% canopy coverage (dense forest, no light on ground)
      # e.g. 100 points total, 1 above =  1% canopy coverage (clearing, near full view of ground)
      # canopy coverage is high (max 1), if cell has only points in canopy (>5)
      # canopy coverage is low (min 0), if cell has only points on ground (<5)
      # percentage covered for weighting lower points
      r_ccoverage = (r_npoints_cov/r_npoints_all)
      # plot(r_ccoverage, main=paste(tiles$TileKey[tile_id], "r_ccoverage"))
      
      # binary covered grid for vector creation
      r_ccovered = (r_ccoverage > THRESH_COVERED)
      # remove zeroes (otherwise they will be turned into polygons)
      r_ccovered[r_ccovered==0] = NA
      # plot(r_ccovered, main=paste(tiles$TileKey[tile_id], "r_ccovered"))
      # vec_covered = rasterToPolygons(r_ccovered) # creates a polygon for each pixel
      # vec_covered = aggregate(r_ccovered, dissolve=T) # merges pixel-polygons
      
      #### > rejuvenation 2 ####
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | rejuvenation 2" ))
      #### __ high-res / detail above rej2  ####
      # check layer just above rejuvenation 2 to make sure, rej2 is not just understory/lower branches of slightly higher trees
      laspuff = filter_poi(lasv, Z>=REJ_HEIGHT2, Z<REJ_HEIGHT2+1.5) # get points above rejuvenation (1.5m puffer)
      # calc in high res
      r_npoints_rej2plus_hs = grid_metrics(laspuff, ~length(Z), res=ref_raster_hs)
      r_dtl_rej2plus = r_npoints_rej2plus_hs > 0
      remove("laspuff") # clean up to save RAM
      
      # get rej2 point cloud
      lasv = filter_poi(lasv, Z>=0, Z<REJ_HEIGHT2) # remove points too close to ground and above rejuvenation
      # lasv = filter_poi(lasv, Intensity>20) # only above certain intensity
      
      #### __ high-res / detail ####
      # filter point cloud (remove underlying points to ignore rejuvenation layer 1 for detail)
      lasdetail = filter_poi(lasv, Z>=REJ_HEIGHT1, Z<REJ_HEIGHT2) # remove points too close to ground and above rejuvenation
      # calc in high res 
      r_npoints_rej2_hs = grid_metrics(lasdetail, ~length(Z), res=ref_raster_hs)
      # create mask and filter small spots
      r_dtl_rej2 = r_npoints_rej2_hs > 0 # more than one point
      r_dtl_rej2_unfiltered = r_dtl_rej2 # save before modifying
      r_dtl_rej2[r_dtl_rej2plus == 1 & !is.na(r_dtl_rej2)] = 0 # remove areas where rej2 is directly continued and likely lower branches of higher vegetation
      r_dtl_rej2 = patchFilter(r_dtl_rej2, area=5, directions=8)
      # CRS gets deleted by patchFilter
      crs(r_dtl_rej2) = crs(r_npoints_rej2_hs)
      # plot(r_dtl_rej2, main=paste(tiles$TileKey[tile_id]), "r_dtl_rej2")
      remove("lasdetail") # clean up to save RAM
      
      #### __ detail density ####
      # create low res probability map from detail
      r_rej2_dtlp = aggregate(r_dtl_rej2, RASTER_RES/RASTER_RES_HS, fun=sum)
      r_rej2_dtlp = r_rej2_dtlp / (RASTER_RES^2/RASTER_RES_HS^2) 
      
      #### __ relative density ####
      # create grid with number of points
      r_npoints_rej2 = grid_metrics(lasv, ~length(Z), res=ref_raster) # npoints
      # # plot(r_npoints_rej2, main=paste(tiles$TileKey[tile_id], "r_npoints_rej2"))
      
      # calc relative density (densitiy in rej2 vs density in cell)
      r_reldens_rej2 = r_npoints_rej2/r_npoints_all
      # plot(r_reldens_rej2, main=paste(tiles$TileKey[tile_id], "r_reldens_rej2"))
      
      # weight relative density with coverage
      r_reldensweighted_rej2 = (r_reldens_rej2 + r_reldens_rej2 * r_ccoverage * FACTOR_COVERAGE_WEIGHT)
      # r_reldensweighted_rej2 = min(r_reldensweighted_rej2,1) # cap values at 1 (= 100%)
      # plot(r_reldensweighted_rej2, main=paste(tiles$TileKey[tile_id], "r_reldensweighted_rej2"))
      # plot(r_reldensweighted_rej2 > 0.2, main=paste(tiles$TileKey[tile_id], "r_reldensweighted_rej2"))
      
      # create separate layers for covered and not covered by canopy
      r_rej2_cov = r_reldensweighted_rej2
      r_rej2_cov[is.na(r_ccovered)] = NA
      r_rej2_open = r_reldensweighted_rej2
      r_rej2_open[r_ccovered==1] = NA
      # plot(r_rej2_cov, main=paste(tiles$TileKey[tile_id], "r_rej2_cov"))
      # plot(r_rej2_open, main=paste(tiles$TileKey[tile_id], "r_rej2_open"))
      
      
      #### > rejuvenation grid 1 ####
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | rejuvenation 1" ))
      lasv = filter_poi(lasv, Z<REJ_HEIGHT1) # remove points of higher rejuvenation layer
      
      #### __ high-res / detail ####
      # calc in high res for detail
      r_npoints_rej1_hs = grid_metrics(lasv, ~length(Z), res=ref_raster_hs)
      remove("lasv") # clean up to save RAM
      
      # create mask and filter small spots
      r_dtl_rej1 = r_npoints_rej1_hs > 0 # more than one point
      r_dtl_rej1 = patchFilter(r_dtl_rej1, area=5, directions=8)
      # CRS gets deleted by patchFilter
      crs(r_dtl_rej1) = crs(r_npoints_rej1_hs)
      # plot(r_dtl_rej1, main=paste(tiles$TileKey[tile_id]), "r_dtl_rej1")
      
      #### __ detail density ####
      # create low res probability map from detail
      r_rej1_dtlp = aggregate(r_dtl_rej1, RASTER_RES/RASTER_RES_HS, fun=sum)
      r_rej1_dtlp = r_rej1_dtlp / (RASTER_RES^2/RASTER_RES_HS^2) 
      
      #### __ relative density ####
      # create grid from high-res grid
      r_npoints_rej1 = aggregate(r_npoints_rej1_hs, RASTER_RES/RASTER_RES_HS, fun=sum)
      # plot(r_npoints_vrj1_hs, main=paste(tiles$TileKey[tile_id], "r_npoints_vrj1_hres"))
      # plot(r_npoints_vrj1, main=paste(tiles$TileKey[tile_id], "r_npoints_vrj1"))
      
      # calc density
      r_reldens_rej1 = r_npoints_rej1/r_npoints_all
      # plot(r_reldens_rej1, main=paste(tiles$TileKey[tile_id], "r_reldens_rej1"))
      
      # weight density with coverage
      r_reldensweighted_rej1 = (r_reldens_rej1 + r_reldens_rej1 * r_ccoverage * FACTOR_COVERAGE_WEIGHT)
      # plot(r_reldensweighted_rej2, main=paste(tiles$TileKey[tile_id], "r_reldensweighted_rej1"))
      
      # create separate layers for covered and not covered by canopy
      r_rej1_cov = r_reldensweighted_rej1
      r_rej1_cov[is.na(r_ccovered)] = NA
      r_rej1_open = r_reldensweighted_rej1
      r_rej1_open[r_ccovered==1] = NA
      
      
      ####*************************####
      ####          OUTPUT         ####
      #-------------------------------#
      if(VERBOSE) print(paste0("> ", tile_id, " write output" ))
      #### > create dirs ####
      # experimental
      dir.create(file.path(DIR_OUTPUT, "r_reldens_rej1"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_reldensweighted_rej1"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_reldens_rej2"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_reldensweighted_rej2"), recursive = TRUE, showWarnings = FALSE)
      # main output
      dir.create(file.path(DIR_OUTPUT, "r_dtl_rej1_05m"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_dtl_rej2_05m"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_dtl_rej2_05m_unfiltered"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_dtl_rej1_05m_npoints"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_dtl_rej2_05m_npoints"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_dtl_rej2plus_05m_npoints"), recursive = TRUE, showWarnings = FALSE)
      
      dir.create(file.path(DIR_OUTPUT, "r_rej1_dtlp"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej2_dtlp"), recursive = TRUE, showWarnings = FALSE)
      
      dir.create(file.path(DIR_OUTPUT, "r_rej1_cov"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej1_open"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej2_cov"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej2_open"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_ccoverage"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_ccovered"), recursive = TRUE, showWarnings = FALSE)
      
      #### > convert to int ####
      r_reldens_rej1 = as.integer(r_reldens_rej1 * 100)
      r_reldens_rej2 = as.integer(r_reldens_rej2 * 100)
      r_reldensweighted_rej1 = as.integer(r_reldensweighted_rej1 * 100)
      r_reldensweighted_rej2 = as.integer(r_reldensweighted_rej2 * 100)
      
      r_ccoverage = as.integer(r_ccoverage * 100)
      r_rej1_cov = as.integer(r_rej1_cov * 100)
      r_rej1_open = as.integer(r_rej1_open * 100)
      r_rej2_cov = as.integer(r_rej2_cov * 100)
      r_rej2_open = as.integer(r_rej2_open * 100)
      
      #### > write files ####
      if(VERBOSE) print(paste0("> ", tile_id, " e.g.: ", file.path(DIR_OUTPUT, "r_reldens_rej1", paste0(tiles$TileKey[tile_id], ".tif")), " ..."))  
      writeRaster(r_reldens_rej1, file.path(DIR_OUTPUT, "r_reldens_rej1", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_reldensweighted_rej1, file.path(DIR_OUTPUT, "r_reldensweighted_rej1", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_reldens_rej2, file.path(DIR_OUTPUT, "r_reldens_rej2", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_reldensweighted_rej2, file.path(DIR_OUTPUT, "r_reldensweighted_rej2", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      
      writeRaster(r_dtl_rej1, file.path(DIR_OUTPUT, "r_dtl_rej1_05m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_dtl_rej2, file.path(DIR_OUTPUT, "r_dtl_rej2_05m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_dtl_rej2_unfiltered, file.path(DIR_OUTPUT, "r_dtl_rej2_05m_unfiltered", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_npoints_rej1_hs, file.path(DIR_OUTPUT, "r_dtl_rej1_05m_npoints", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_npoints_rej2_hs, file.path(DIR_OUTPUT, "r_dtl_rej2_05m_npoints", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_npoints_rej2plus_hs, file.path(DIR_OUTPUT, "r_dtl_rej2plus_05m_npoints", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      
      writeRaster(r_rej1_dtlp, file.path(DIR_OUTPUT, "r_rej1_dtlp", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_rej2_dtlp, file.path(DIR_OUTPUT, "r_rej2_dtlp", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      
      writeRaster(r_rej1_cov, file.path(DIR_OUTPUT, "r_rej1_cov", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_rej1_open, file.path(DIR_OUTPUT, "r_rej1_open", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_rej2_cov, file.path(DIR_OUTPUT, "r_rej2_cov", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_rej2_open, file.path(DIR_OUTPUT, "r_rej2_open", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_ccoverage, file.path(DIR_OUTPUT, "r_ccoverage", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      writeRaster(r_ccovered, file.path(DIR_OUTPUT, "r_ccovered", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      
      #### > set as processed ####
      # if everything ran without errors, set processed = TRUE
      tiles$processed[tile_id] = TRUE
      tiles$proc_comm[tile_id] = ""
      if(VERBOSE) print(paste0("> ", tile_id, " DONE - ", length(which(tiles$processed == FALSE)), " left" ))
    },#/endexpr tryCatch (processing tile)
    error = function(e){
      message('> Tile couldnt be processed')
      print(e)
      
      tiles$processed[tile_id] = FALSE
      tiles$proc_comm[tile_id] = e$message
    }, finally = { } #trycatch-error close
  )#/endtry (processing tile)
  
  #### > update process shp ####
  tryCatch(
    expr = {
      # try saving the shp file with process info
      st_write(tiles, FILE_TILE_LIST, append = FALSE)
    },#/endexpr (tryCatch STAC download)
    error = function(e){
      message('> Couldnt update tile_list_vector file file with process info')
      print(e)
    }, finally = { } #trycatch-error close
  )#/endtry (saving status process-shp)
  if(VERBOSE) toc()
}
####>>>>>>>| MAIN LOOP ++++++####
if(VERBOSE) toc()

#### > update process shp ####
time_end = Sys.time()
FILE_TILE_LIST2 = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST)), "_", gsub(" ", "_", gsub(":", "", time_end)), FILE_TILE_LIST_TYPE))
tryCatch(
  expr = {
    # try saving the shp file with process info
    st_write(tiles, FILE_TILE_LIST, append = FALSE)
  },#/endexpr (tryCatch STAC download)
  error = function(e){
    message('> Couldnt update tile_list_vector file file with process info')
    print(e)
  }, finally = { } #trycatch-error close
)#/endtry (saving status process-shp)

#### > create VRTs ####
# DIR_OUTPUT = "/mnt/smb.hdd.rbd/HAFL/WWI-Waldwildnis/LiDAR_CH/data/uc4_wd/2022-07-07_015313_swissTiles_forest_FR_galmwald"
outputs = c("r_reldens_rej1", "r_reldensweighted_rej1", 
            "r_reldens_rej2", "r_reldensweighted_rej2", 
            "r_dtl_rej1_05m", "r_dtl_rej2_05m", "r_dtl_rej2_05m_unfiltered",
            "r_dtl_rej1_05m_npoints", "r_dtl_rej2_05m_npoints", "r_dtl_rej2plus_05m_npoints",
            "r_rej1_dtlp", "r_rej2_dtlp", 
            "r_rej1_cov", "r_rej1_open", 
            "r_rej2_cov", "r_rej2_open", 
            "r_ccoverage", "r_ccovered")

# create a vrt (virtual raster) from each subfolder (containing a tif for each tile)
for(output_name in outputs){
  if(VERBOSE) print(paste0("> ", output_name, " > create vrt: ", file.path(DIR_OUTPUT, paste0(output_name, ".vrt"))))
  filename_vrt = file.path(DIR_OUTPUT, paste0(output_name, ".vrt"))
  vrt(list.files(file.path(DIR_OUTPUT, output_name), full.names = TRUE), filename=filename_vrt, overwrite=TRUE)
  
  if(MERGE_TO_SINGLE_TIF) {
    if(VERBOSE) print(paste0("> ", output_name, " > create tif: ", file.path(DIR_OUTPUT, paste0(output_name, ".tif"))))
    filename_tif = file.path(DIR_OUTPUT, paste0(output_name, ".tif"))
    untiled_raster = rast(filename_vrt)
    writeRaster(untiled_raster, filename_tif, overwrite=TRUE)
  }
}
