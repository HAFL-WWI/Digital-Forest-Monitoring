#------------------------------------------------------------------------------#
# Generate Rasters from LAS for DW Detection - tilewise processing
#
# (c) by Hannes Horneber, HAFL, BFH, 2021-12-15
#------------------------------------------------------------------------------#

library(rgdal) # OGR driver (shp files)
library(lidR) # LAS processing
library(raster) # raster/grid processing
library(sf)
library(grainscape) # for patchfilter

#-------------------------------#
####     SETTINGS PATHS      ####
#-------------------------------#
BASE_CEPH = "P:/LFE" # HARA/Local
# BASE_CEPH = "/mnt/smb.hdd.rbd" # R-Server

# Base Path:  allows to switch easily between server/local path or various platforms 
#             if you copy/move the folder with all subfolders
# BASE_PATH = "P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.010499-52-FWWG-01_Wissenstransfer_Fernerkundung/Entwicklung/Digital_Forest_Monitoring_git/methods/use-case4" # on HARA
# BASE_PATH = "C:/Users/hbh1/Projects/H06_Totholz/A_Tessin/Daten" # local dev
# BASE_PATH = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten") 
# BASE_PATH = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH")
# BASE_PATH = file.path("P:/HAFL/9 Share/PermanenteOrdner/Geodaten/Forst_Daten/waldmonitoring/UC4/data")
BASE_PATH = file.path("//bfh.ch/data/HAFL/9 Share/PermanenteOrdner/Geodaten/Forst_Daten/waldmonitoring/UC4/data")

# WD: Working Directory. Best, if you keep this script at this place 
#     and all subfolders (data/shp, profiles, ...) in this folder
# WD = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH/data/uc4_wd")
WD = file.path(BASE_PATH, "")

PATH_LAS_BASE = file.path(BASE_CEPH, "BFH/Geodata/swisstopo/meta/swissSURFACE3D/2056-LASzip") # Zentralschweiz (TI, LU, AG, ...)
# PATH_LAS_BASE = file.path(BASE_CEPH, "BFH/Geodata/swisstopo/swissSURFACE3D/LAS") # Ost- / Westschweiz (FR, VD, ...)
PATH_DTM = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/Data_others/DTM/swissALTI3D") 

DIR_BASE_OUTPUT = file.path(WD, gsub(" ", "_", gsub(":", "", Sys.time())))
# substr(gsub(" ", "_", gsub(":", "", Sys.time())),3,10) # extract only YYYY-MM-DD

# should be a .shp. Implementations for .csv also possible, but needs a solution for mask (clip).
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles_test.shp")
FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles.shp")
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles_missing.shp")

# generate output folder from filename of tile list
DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST))))
# use custom output folder name 
# DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", "UC4_tile")

# set to true if processing is to be continued from an earlier script interrupt
CONTINUE = FALSE
# FILE_TILE_LIST and DIR_OUTPUT generally should be manually specified if continuing (overwrite the above)
if(CONTINUE){
  FILE_TILE_LIST = file.path(BASE_PATH, "_output/2021-12-09_140636_DW_tile/Wald_LV95_ticino_tiles_2021-12-09_140636.shp")
  DIR_OUTPUT = file.path(WD,"_output", "2021-12-09_140636_DW_tile")
}

# tile filename patterns for DTM/LAS datasets
PATTERN_DTM = "swissalti3d_YEAR_TILEKEY1-TILEKEY2_0.5_2056_5728.tif"
PATTERN_DTM_YEARS = c("2019", "2020", "2021") # if swissalti3d tiles are from several years
PATTERN_LAS = "TILEKEY1_TILEKEY2.laz"

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
  FILE_TILE_LIST = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST)), "_", gsub(" ", "_", gsub(":", "", time_start)), ".shp"))
  st_write(tiles, FILE_TILE_LIST, append = FALSE)
} else {
  #### >  output folder continue ####
  if(VERBOSE) print(paste0("--> reuse output folder: ", DIR_OUTPUT))
  if(VERBOSE) print(paste0("--> continue processing tiles: ", length(which(tiles$processed == FALSE)), "/", nrow(tiles)))
  
  # create copy of processing file list 
  FILE_TILE_LIST = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST)), "_ctd", gsub(" ", "_", gsub(":", "", time_start)), ".shp"))
  st_write(tiles, FILE_TILE_LIST, append = FALSE)
}

####_________________________####
####++++++++ MAIN LOOP |>>>>>####
#-------------------------------#
# loop over tiles
for(tile_id in which(tiles$processed == FALSE)){
  # for(tile_id in rev(which(tiles$processed == FALSE))){ # process in reverse order
  tryCatch( #/starttry (processing tile)
    expr = {
      if(VERBOSE) print(paste0("process ",tile_id,"/",nrow(tiles),": ",tiles$TileKey[tile_id], 
                               " [", gsub(" ", "_", gsub(":", "", Sys.time())), "] "))
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
      
      
      
      #### > rejuvenation grid 2 ####
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | rejuvenation" ))
      
      lasv = filter_poi(lasv, Z>=0, Z<REJ_HEIGHT2) # remove points too close to ground
      # lasv = filter_poi(lasv, Intensity>20) # only above certain intensity
      
      # higher rejuvenation layer (compute top down to subsequently reduce point cloud)
      r_npoints_rej2 = grid_metrics(lasv, ~length(Z), res=ref_raster) # npoints
      # plot(r_npoints_rej2, main=paste(tiles$TileKey[tile_id], "r_npoints_rej2"))
      
      # calc density
      r_reldens_rej2 = r_npoints_rej2/r_npoints_all
      # plot(r_reldens_rej2, main=paste(tiles$TileKey[tile_id], "r_reldens_rej2"))
      
      # weight density with coverage
      r_reldensweighted_rej2 = (r_reldens_rej2 + r_reldens_rej2 * r_ccoverage * FACTOR_COVERAGE_WEIGHT)
      # r_reldensweighted_rej2 = min(r_reldensweighted_rej2,1) # cap values at 1 (= 100%)
      # plot(r_reldensweighted_rej2, main=paste(tiles$TileKey[tile_id], "r_reldensweighted_rej2"))
      # plot(r_reldensweighted_rej2 > 0.2, main=paste(tiles$TileKey[tile_id], "r_reldensweighted_rej2"))
      
      r_rej2_cov = r_reldensweighted_rej2
      r_rej2_cov[is.na(r_ccovered)] = NA
      r_rej2_open = r_reldensweighted_rej2
      r_rej2_open[r_ccovered==1] = NA
      # plot(r_rej2_cov, main=paste(tiles$TileKey[tile_id], "r_rej2_cov"))
      # plot(r_rej2_open, main=paste(tiles$TileKey[tile_id], "r_rej2_open"))
      
      #### > high-res (deadwood canidates) grid ####
      lasv = filter_poi(lasv, Z<REJ_HEIGHT1) # remove points of higher rejuvenation layer
      
      # calc in high res for deadwood detection
      r_npoints_rej1_hs = grid_metrics(lasv, ~length(Z), res=ref_raster_hs)
      remove("lasv") # clean up to save RAM
      
      # create mask and filter small spots
      r_dwc = r_npoints_rej1_hs > 0 # more than one point
      r_dwc = patchFilter(r_dwc, area=5, directions=8)
      # CRS gets deleted by patchFilter
      crs(r_dwc) = crs(r_npoints_rej1_hs)
      # plot(r_dwc, main=paste(tiles$TileKey[tile_id]), "r_dwc")
      
      #### > rejuvenation grid 1 ####
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
      # dir.create(file.path(DIR_OUTPUT, "r_reldensweighted_rej1"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_reldens_rej2"), recursive = TRUE, showWarnings = FALSE)
      # dir.create(file.path(DIR_OUTPUT, "r_reldensweighted_rej2"), recursive = TRUE, showWarnings = FALSE)
      # main output
      dir.create(file.path(DIR_OUTPUT, "r_dwc_05m"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej1_cov"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej1_open"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej2_cov"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_rej2_open"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_ccoverage"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_ccovered"), recursive = TRUE, showWarnings = FALSE)
      
      #### > convert to int ####
      r_reldens_rej1 = as.integer(r_reldens_rej1 * 100)
      r_reldens_rej2 = as.integer(r_reldens_rej2 * 100)
      
      r_ccoverage = as.integer(r_ccoverage * 100)
      r_rej1_cov = as.integer(r_rej1_cov * 100)
      r_rej1_open = as.integer(r_rej1_open * 100)
      r_rej2_cov = as.integer(r_rej2_cov * 100)
      r_rej2_open = as.integer(r_rej2_open * 100)
      
      #### > write files ####
      writeRaster(r_reldens_rej1, file.path(DIR_OUTPUT, "r_reldens_rej1", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      # writeRaster(r_reldensweighted_rej1, file.path(DIR_OUTPUT, "r_reldensweighted_rej1", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_reldens_rej2, file.path(DIR_OUTPUT, "r_reldens_rej2", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T, datatype='INT1U')
      # writeRaster(r_reldensweighted_rej2, file.path(DIR_OUTPUT, "r_reldensweighted_rej2", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      
      writeRaster(r_dwc, file.path(DIR_OUTPUT, "r_dwc_05m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
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
      message('> Couldnt update .shp file with process info')
      print(e)
    }, finally = { } #trycatch-error close
  )#/endtry (saving status process-shp)
}
####>>>>>>>| MAIN LOOP ++++++####
time_end = Sys.time()

#### > update process shp ####
FILE_TILE_LIST2 = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_TILE_LIST)), "_", gsub(" ", "_", gsub(":", "", time_end)), ".shp"))
tryCatch(
  expr = {
    # try saving the shp file with process info
    st_write(tiles, FILE_TILE_LIST, append = FALSE)
  },#/endexpr (tryCatch STAC download)
  error = function(e){
    message('> Couldnt update .shp file with process info')
    print(e)
  }, finally = { } #trycatch-error close
)#/endtry (saving status process-shp)