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
BASE_PATH = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/LiDAR_CH")

# WD: Working Directory. Best, if you keep this script at this place 
#     and all subfolders (data/shp, profiles, ...) in this folder
WD = file.path(BASE_PATH, "data/uc4_wd")

PATH_LAS_BASE = file.path(BASE_CEPH, "BFH/Geodata/swisstopo/meta/swissSURFACE3D/2056-LASzip") # Zentralschweiz (TI, LU, AG, ...)
# PATH_LAS_BASE = file.path(BASE_CEPH, "BFH/Geodata/swisstopo/swissSURFACE3D/LAS") # Ost- / Westschweiz (FR, VD, ...)
PATH_DTM = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/Data_others/DTM/swissALTI3D") 

DIR_BASE_OUTPUT = file.path(WD, "_output", gsub(" ", "_", gsub(":", "", Sys.time())))
# substr(gsub(" ", "_", gsub(":", "", Sys.time())),3,10) # extract only YYYY-MM-DD

# should be a .shp. Implementations for .csv also possible, but needs a solution for mask (clip).
FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles_test.shp")
# FILE_TILE_LIST = file.path(BASE_CEPH, "HAFL/WWI-Waldwildnis/DW_Tessin/Daten/Waldmaske/Wald_LV95_ticino_tiles.shp")
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
  dir.create(DIR_OUTPUT, recursive = TRUE, showWarnings = FALSE)
  
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
      
      #### > density grids ####
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | canopy coverage" ))
      
      # #### > CHM           ####
      # chm = grid_canopy(lasn, 1, pitfree(c(0,2,5,10,15), c(0, 1)))
      # plot(chm, main=paste(tiles$TileKey[tile_id], "chm"))
      
      # grid all points
      # r_dgrid_all = grid_density(lasp, res=ref_raster)
      r_npoints_all = grid_metrics(lasn, ~length(Z), res=ref_raster)
      plot(r_npoints_all, main=paste(tiles$TileKey[tile_id], "r_npoints_all"))
      # plot(r_npoints_all<10, main=paste(tiles$TileKey[tile_id], "r_npoints_all"))
      
      # grid canopy points
      lasp_cover = filter_poi(lasn, Z>=CNPY_HEIGHT_MIN , Z<CNPY_HEIGHT_MAX)
      r_npoints_cov = grid_metrics(lasp_cover, ~length(Z), res=ref_raster)
      plot(r_npoints_cov, main=paste(tiles$TileKey[tile_id], "r_npoints_cov"))
      remove("lasp_cover") # clean up to save RAM
      
      #### > coverage grid ####
      # e.g. 100 points total, 98 above = 98% canopy coverage (dense forest, no light on ground)
      # e.g. 100 points total, 1 above =  1% canopy coverage (clearing, near full view of ground)
      # canopy coverage is high (max 1), if cell has only points in canopy (>5)
      # canopy coverage is low (min 0), if cell has only points on ground (<5)
      # percentage covered for weighting lower points
      r_ccoverage = (r_npoints_cov/r_npoints_all)
      plot(r_ccoverage, main=paste(tiles$TileKey[tile_id], "r_ccoverage"))
      
      # binary covered grid for vector creation
      r_ccovered = (r_ccoverage > THRESH_COVERED)
      plot(r_ccovered, main=paste(tiles$TileKey[tile_id], "r_ccovered"))
      
      
      #### > rejuvenation grids ####
      # filter to vegetation pointcloud
      lasv = filter_poi(lasn, Classification != 2) # remove ground classification
      lasv = filter_poi(lasv, Z>=0, Z<REJ_HEIGHT2) # remove points too close to ground
      # lasv = filter_poi(lasv, ReturnNumber == NumberOfReturns) # only last
      lasv = filter_poi(lasv, Intensity>20) # only above certain intensity
      
      # higher rejuvenation layer (filter top down to save computation)
      # lasp_vrj2 = filter_poi(lasn, Z<REJ_HEIGHT2)
      r_npoints_rej2 = grid_metrics(lasp_rej2, ~length(Z), res=ref_raster_ds)
      plot(r_npoints_rej2, main=paste(tiles$TileKey[tile_id], "r_npoints_rej2"))
      
      # lower rejuvenation layer (filter top down to save computation)
      lasp_vrj1 = filter_poi(lasv, Z<REJ_HEIGHT1)
      # calc in high res for deadwood detection
      r_npoints_vrj1_hs = grid_metrics(lasp_vrj1, ~length(Z), res=ref_raster_hs)
      r_npoints_vrj1 = aggregate(r_npoints_vrj1_hs, RASTER_RES/RASTER_RES_HS, fun=mean)
      plot(r_npoints_vrj1_hs, main=paste(tiles$TileKey[tile_id], "r_npoints_vrj1_hres"))
      plot(r_npoints_vrj1, main=paste(tiles$TileKey[tile_id], "r_npoints_vrj1"))
      
      
      #### ****** dw_tiles calc ****** ####
      # consider points below
      lasp_c = filter_poi(lasn, Z>=-0.5, Z<2)
      r_npoints_low = grid_metrics(lasp_c, ~length(Z), res=ref_raster)
      
      #### > coverage grid ####
      # e.g. 100 points total,  2 low = 98% canopy coverage (dense forest, no light on ground)
      # e.g. 100 points total, 99 low =  1% canopy coverage (clearing, full view of ground)
      # canopy coverage is high (max 1), if cell has only points in canopy (>2)
      # canopy coverage is low (min 0), if cell has only points on ground (<2)
      r_ccoverage = 1 - (r_npoints_low/r_npoints_all)
      # plot(r_ccoverage)
      
      #### > deadwood candidate grid ####
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | deadwood candidates" ))
      # consider (intense) bottom points
      lasp_c = filter_poi(lasp_c, Classification != 2) # remove ground classification
      lasp_c = filter_poi(lasp_c, Z>=0.2, Z<2) # remove points
      lasp_c = filter_poi(lasp_c, ReturnNumber == NumberOfReturns) # only last
      lasp_c = filter_poi(lasp_c, Intensity>20) # only above certain intensity
      r_npoints_bottom = grid_metrics(lasp_c, ~length(Z), res=ref_raster)
      
      # create mask and filter small spots
      r_dwc = r_npoints_bottom>0
      r_dwc = patchFilter(r_dwc, area=5, directions=8)
      # CRS gets deleted by patchFilter
      crs(r_dwc) = crs(r_npoints_bottom)
      plot(r_dwc, main=paste(tiles$TileKey[tile_id]), "r_dwc")
      
      # r_chm_bottom = grid_canopy(lasp_c, res=ref_raster, p2r(0.5))
      # r_chm_bottom = grid_metrics(lasp_c, ~max(Z), res=ref_raster)
      # plot(r_chm_bottom)
      
      #### > downsample ####
      if(VERBOSE) print(paste0("> ", tile_id, " generate grids | downsampling" ))
      r_dwc_ds = aggregate(r_dwc, RASTER_RES_DS/RASTER_RES, fun=mean)
      r_ccoverage_ds = aggregate(r_ccoverage, RASTER_RES_DS/RASTER_RES, fun=mean)
      plot(r_dwc_ds, main=paste(tiles$TileKey[tile_id]), "r_dwc_ds")
      plot(r_ccoverage_ds, main=paste(tiles$TileKey[tile_id]), "r_ccoverage_ds")
      
      
      ####*************************####
      ####          OUTPUT         ####
      #-------------------------------#
      if(VERBOSE) print(paste0("> ", tile_id, " write output" ))
      #### > create dirs ####
      dir.create(file.path(DIR_OUTPUT, "r_dwc_05m"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_dwc_25m"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_ccoverage_05m"), recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(DIR_OUTPUT, "r_ccoverage_25m"), recursive = TRUE, showWarnings = FALSE)
      
      #### > write files ####
      writeRaster(r_dwc, file.path(DIR_OUTPUT, "r_dwc_05m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_dwc_ds, file.path(DIR_OUTPUT, "r_dwc_25m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_ccoverage, file.path(DIR_OUTPUT, "r_ccoverage_05m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      writeRaster(r_ccoverage_ds, file.path(DIR_OUTPUT, "r_ccoverage_25m", paste0(tiles$TileKey[tile_id], ".tif")), overwrite=T)
      
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
      tiles$proc_comm[tile_id] = e
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