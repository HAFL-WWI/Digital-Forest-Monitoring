#------------------------------------------------------------------------------#
# Prototype UC4 - local dev
# this file contains paths for local dev (SETTINGS GENERAL)
# and the latest changes. Some things may not work properly.
# For a stable execution, use UC4_main.R.
#
# (c) by Hannes Horneber, HAFL, BFH, 2021-09-15
#------------------------------------------------------------------------------#

library(rgdal) # OGR driver (shp files)
library(lidR) # LAS processing
library(raster) # raster/grid processing

library(viridis) # for color palette
library(RColorBrewer) # for color palette
library(rstac) # get STAC info (swisssurface3D)
library(magrittr) # for pipe operator (%>%)

library(mapview) # for debugging

#-------------------------------#
####    SETTINGS GENERAL     ####
#-------------------------------#
# Base Path:  allows to switch easily between server/local path or various platforms 
#             if you copy/move the folder with all subfolders
# BASE_PATH = "P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.010499-52-FWWG-01_Wissenstransfer_Fernerkundung/Entwicklung/Digital_Forest_Monitoring_git/methods/use-case4" # on HARA
BASE_PATH = "C:/Users/hbh1/Projects/H02_Wissenstransfer_Fernerkundung/Digital-Forest-Monitoring_git/methods/use-case4" # local dev
# BASE_PATH = "/usr/local/src/uc4" # in docker

# WD: Working Directory. Best, if you keep this script at this place 
#     and all subfolders (data/shp, profiles, ...) in this folder
WD = file.path(BASE_PATH, "")

#-------------------------------#
####       SETTINGS DEV      ####
#-------------------------------#

# write intermediate results
OUTPUT_INTERMEDIATE = TRUE
# generate and write CHM
OUTPUT_CHM = TRUE
# write LAS files
OUTPUT_LAS = TRUE
# write PDF with plots for coverage
OUTPUT_PLOTPDF = TRUE
# write HTML including mapview with all raster layers
OUTPUT_MAPVIEW = TRUE
# write final results (cover_shp, class-tifs) in subdirs for easier post-proc
OUTPUT_SUBDIRS = TRUE

# use KML file
#TODO replace by
KML = TRUE
# script output
VERBOSE = TRUE
# continue processing of a file with multiple polygons
START_ITER = 1
# IDX_ITER = c(1:4,19:20,30:37)

# if working with normalized las, set to FALSE
NORMALIZE = TRUE
# turn on manual normalization 
MANUAL_NORMALIZATION = FALSE
# TRUE

#-------------------------------#
####      SETTINGS USER      ####
#   adjusted manually by user   #
#-------------------------------#

#.............. parameters for data in/output ................... #
# clean from previos runs:
if(exists("PATH_LAS_BASE")) remove("PATH_LAS_BASE")
if(exists("FILE_DTM")) remove("FILE_DTM")

# path (within WD) to shapefile
DIR_INPUT = file.path(WD, "input") 
# path 
DIR_BASE_OUTPUT = file.path(WD, "output", gsub(" ", "_", gsub(":", "", Sys.time())))
# substr(gsub(" ", "_", gsub(":", "", Sys.time())),3,10) # extract only YY-MM-DD

# specify LAS dataset to use (LAS dataset(s) to crop from)
# if specified (not empty ("") or missing) overrides LAS_STAC_DOWNLOAD (= FALSE)
# PATH_LAS_BASE = "C:/Users/hbh1/Projects/data/LAS/ALS_Bern_4_perimeters"
# PATH_LAS_BASE = "P:/HAFL/7 WWI/74b FF GNG/742b Aktuell/2018-2020_FINTCH_R.009030-52-FWGN-01/AP6_Abgrenzung_der_WST/Entwicklung/TBk_Bern/BGB_20191114/LiDAR_Daten_Festmeter/ALS_Bern_all_data_ETRS89_ell_H"

# input DTM (if you have a pre-calculated/external DTM for the area of interest)
# if not specified, DTM for normalization will be generated on-the-fly
# FILE_DTM = "C:/Users/hbh1/Projects/H05_LiDAR/LiDAR_Profiles/data/DHM/dtm_ALS_Bern_2019_nNA.tif"
# FILE_DTM = "P:/HAFL/7 WWI/74b FF GNG/742b Aktuell/2018-2020_FINTCH_R.009030-52-FWGN-01/AP6_Abgrenzung_der_WST/Entwicklung/TBk_Bern/BGB_20191114/LiDAR_Daten_Festmeter/DTM_Bern_05m/dtm_ALS_Bern_2019_nNA.tif"

#.............. parameters for STAC download/storage ................... #
# directory in which LAS tiles downloaded from STAC are stored
DIR_STAC_STORE = file.path(DIR_INPUT, "LAS_STAC_STORE")
# download LAS (overridden if a LAS BASE FILE is already specified)
LAS_STAC_DOWNLOAD = TRUE
if(exists("PATH_LAS_BASE") && PATH_LAS_BASE != "") LAS_STAC_DOWNLOAD = FALSE else remove("PATH_LAS_BASE")
# create DIR_STAC_STORE in case it doesn't exist
if(LAS_STAC_DOWNLOAD) dir.create(DIR_STAC_STORE, recursive = TRUE, showWarnings = FALSE)

#.............. parameters CRS ................... #
CRS_ROI = CRS("+init=epsg:4326")  # default for kml from map.geo.admin.ch
CRS_LAS = CRS("+init=epsg:21781") # LV03
if(LAS_STAC_DOWNLOAD) CRS_LAS = CRS("+init=epsg:2056")  # LV95 default for swisstopo

#.............. parameters for method ................... #
# las class for ground points (for filtering), default is 2
CLASS_GROUND = 2
# resolution of resulting layer (in m)
RASTER_RES = 5
# RASTER_RES = 10 # 2
# resolution of VHM
VHM_RES = 0.5
# vector with height-thresholds (in meters) to define height classes with
# HEIGHT_CLASSES = c(1,2,5,12,24)
# HEIGHT_CLASSES_min = c(12, 0,0,0, 0,12,24)
# HEIGHT_CLASSES_max = c(99, 1,2,5,12,24,99)
HEIGHT_CLASSES_min = c(12, 0,0)
HEIGHT_CLASSES_max = c(99, 2,5)
# above this density threshold in coverclass, pixels will be considered covered
THRESH_DENS_COV = 0.33

#.............. parameters for mapview ................... #
# below this density threshold, pixels will be declared NA (and be transparent)
THRESH_DENS_NA = 0.2
# index (in HEIGHT_CLASSES_min/max) of the coverclass (by default 1)
IDX_COVERCLASS = 1
# indexes (in HEIGHT_CLASSES_min/max) of the classes included in the map/output
IDX_INCLUDECLASS = length(HEIGHT_CLASSES_min):2
# Factor to multiply density under cover with
COV_DENS_FACTOR = 2.5


####_________________________####
####        LOAD DATA        ####
#-------------------------------#
if(VERBOSE) print(paste0("######  load data: ", DIR_INPUT, " ######"))
# get input files from dir

#### > read shp/kml ####
if(KML){
  input_files = list.files(path=DIR_INPUT, pattern='.kml', full.names = TRUE)
  if(VERBOSE) print(paste0("found ", length(input_files), " .kml files in input directory"))
  if(VERBOSE && (length(input_files) > 0)) print(input_files)
  
  tryCatch(
    expr = {
      if(VERBOSE) print(paste0("selecting only first: ", input_files[1]))
      FILE_ROI = input_files[1]
      
      # load shapefile (kml -> shp)
      roi_shp = readOGR(FILE_ROI)
    },
     error = function(e){
      message("Loading KML skipped/failed. Search for .shp file.")
    }, finally = { } #trycatch-error close
  )
}
if(!KML || length(input_files) == 0){
  input_files = list.files(path=DIR_INPUT, pattern='.shp', full.names = TRUE)
  if(VERBOSE) print(paste0("found ", length(input_files), " .shp files in input directory"))
  
  if(VERBOSE) print(paste0("selecting only first: ", input_files[1]))
  FILE_ROI = input_files[1]
  
  if(VERBOSE) print(paste0("read ", FILE_ROI))
  
  # load shapefile (shp)
  roi_shp = readOGR(FILE_ROI)
}

#### > load LAS ####
if(LAS_STAC_DOWNLOAD){
  #### >> STAC fetch URLs ####
  if(VERBOSE) print("fetch STAC URLs for loading LAS")

  # map.geo.admin.ch KML files don't come with an ITER field... add one
  if(is.null(roi_shp$ITER)) roi_shp$ITER = 1:length(roi_shp)
  
  if(exists("las_stac_urls")) remove("las_stac_urls")
  # iterate over polygons
  for(id in roi_shp$ITER){
    roi = roi_shp[roi_shp$ITER == id, ]
    # get bbox for STAC request
    roi_bbox = bbox(spTransform(roi, CRS("+init=epsg:4326")))
    # get STAC las tile
    it_obj <-
      stac("https://data.geo.admin.ch/api/stac/v0.9") %>%
      stac_search(collections = "ch.swisstopo.swisssurface3d",
                  bbox = roi_bbox) %>%
      get_request()
    
    # contains a collection of features, that contain downloadable assets with href (download url). E.g.:
    # it_obj[["features"]][[1]][["assets"]][["swisssurface3d_2020_2640-1219_2056_5728.las.zip"]][["href"]]
    # get url to las tile
    for(tile_n in 1:items_length(it_obj)){
      # init with first entry, otherwise append URLs (may create duplicates)
      if(!exists("las_stac_urls")) las_stac_urls = c(it_obj[["features"]][[tile_n]][["assets"]][[1]][["href"]])
      else las_stac_urls = c(las_stac_urls, it_obj[["features"]][[tile_n]][["assets"]][[1]][["href"]])
    }
    print(paste("Fetched", items_length(it_obj), "LAS URLs for Polygon ", id))

  }
  # order after las_url so that all polygons of one las tile will be processed together (caching lastile)
  # roi_shp = roi_shp[order(roi_shp$las_url), ]
  if(VERBOSE) print(paste0("fetched ", length(las_stac_urls)," STAC URLs with ", length(las_stac_urls)-length(unique(las_stac_urls)), " duplicates. Will load: ", length(unique(las_stac_urls)), " tile(s)") )
  las_stac_urls = unique(las_stac_urls)
  
  #### >> STAC download ####
  if(VERBOSE) print(paste0("download missing LAS tiles") )
  for(las_url in las_stac_urls){
    # build las tilename from URL
    las_tile = paste0(gsub("-", "_", gsub(".*swisssurface3d_\\d{4}_", "", gsub("_\\d{4}_\\d{4}.las.zip.*", "", las_url))), ".las")
    
    # try loading the tile (if it is stored)
    FILE_LAS_URL = file.path(DIR_STAC_STORE, las_tile)
    
    tryCatch(
      expr = {

        if(file.exists(FILE_LAS_URL)){
          if(VERBOSE) print(paste0("found stored LAS tile ", basename(FILE_LAS_URL)))
        }else{
          if(VERBOSE) print(paste0("DOWNLOAD LAS tile: ", las_url))
          # download las tile to temp file
          temp_dl <- tempfile()
          download.file(las_url, temp_dl)
          # unzip las tile to temp file
          temp_uzip <- tempdir()
          FILE_LAS_URL = unzip(temp_dl, exdir = temp_uzip)
          if(VERBOSE) print(paste0(" > download and extraction successful: ", basename(FILE_LAS_URL)))
          
          # if(VERBOSE) print(paste0(" > store at: ", file.path(DIR_STAC_STORE, basename(FILE_LAS_URL)) ))
          # move unpacked file
          file.rename(FILE_LAS_URL, file.path(DIR_STAC_STORE, basename(FILE_LAS_URL)))
          # update file name
          FILE_LAS_URL = file.path(DIR_STAC_STORE, basename(FILE_LAS_URL))

          # unlink temp files so they can be deleted
          unlink(temp_dl)
          unlink(temp_uzip)
        }

      },#/endexpr (tryCatch STAC download)
        error = function(e){
          message('Caught an error during STAC download!')
          print(e)
          message('skip')
        }, finally = { } #trycatch-error close
    )#/endtry ()
    
    if(!exists("PATH_LAS_BASE")) PATH_LAS_BASE = c(FILE_LAS_URL) 
    else PATH_LAS_BASE = c(PATH_LAS_BASE, FILE_LAS_URL)
  }#/endforloop (STAC download)

  # downloaded required LAS tiles
  if(VERBOSE) print(paste0("loading all LAS tiles") )
  #TODO: still need to figure out, how only relevant tiles are considered 
  # (if there are downloads from previous runs, they may clutter the catalog)
  lasBase = catalog(PATH_LAS_BASE)

} else {
#### >> load local LAS  #### 
  if(VERBOSE) print("Load LAS pointcloud from local file (LAS STAC Download deactivated)")
  if(VERBOSE) print(PATH_LAS_BASE)
  lasBase = catalog(PATH_LAS_BASE)
}

#### >> CRS  #### 
# confirm/set CRS LAS Data
if(is.na(crs(lasBase))) {
  crs(lasBase) = CRS_LAS 
} else {
  CRS_LAS = crs(lasBase)
}

# confirm/set CRS_ROI
if(is.na(crs(roi_shp))) crs(roi_shp) = CRS_ROI
# reproject shp to CRS LAS
if(!compareCRS(crs(roi_shp), CRS_LAS)) roi_shp = spTransform(roi_shp, CRS_LAS)

if(exists("FILE_DTM") && FILE_DTM != "") {
  dtm_base = raster(FILE_DTM)
  if(!compareCRS(crs(dtm_base), CRS_LAS)) dtm_base = projectRaster(dtm_base, CRS_LAS)
} else {
  # remove dtm_base from previous run (so that it isn't mistaken as manually provided file)
  if(exists("dtm_base")) remove("dtm_base")
}

####_________________________####
####       ITERATE ROI       ####
#### // ********************* ####
# assign ITER if no ITER exists
if(is.null(roi_shp$ITER)) roi_shp$ITER = 1:length(roi_shp)
IDX_ITER = START_ITER:length(roi_shp)
if(VERBOSE) print("###### iterate ROI polygons ######")
for(id in START_ITER:length(roi_shp)){
  roi = roi_shp[roi_shp$ITER == id, ]
  if(VERBOSE) print(paste0(">> polygon #", which(roi_shp$ITER==id), "(", roi$ITER, ")") )
  #### > check extents      ####
  plot(lasBase, main="LAS extents and region of interest")
  plot(roi, add=T, col="red")
  
  #### > create output folder ####
  # DIR_OUTPUT = file.path(DIR_BASE_OUTPUT, id)
  DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", paste0(tools::file_path_sans_ext(basename(FILE_ROI))))
  if(VERBOSE) print(paste0("--> create output folder: ", DIR_OUTPUT))
  dir.create(DIR_OUTPUT, recursive = TRUE, showWarnings = FALSE)
  
  # output file (LAS dataset cropped to shapefile (with buffer) will be generated)
  FILE_LAS_CLIPPED = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_ROI)), "_", id, ".las"))
  
  ####_________________________####
  ####         PREPROC         ####
  #-------------------------------#
  if(VERBOSE) print(paste0(">> ", roi$ITER, " | preprocess" ))
  #### > CLIP LAS        ####
  las = clip_roi(lasBase, extent(roi))
  
  #### > DTM / normalize           ####
  if(NORMALIZE){
    if(MANUAL_NORMALIZATION){
      # load/generate dtm
      if(exists("dtm_base")) {
        dtm = crop(dtm_base, roi)
        if(VERBOSE) print(paste0(">> ", roi$ITER, " | DTM loaded:", FILE_DTM))
      } else { dtm = grid_terrain(las, algorithm = kriging(k = 10L)) }
      
      lasn = normalize_height(las, dtm, na.rm=T)
      # lasg = filter_poi(lasn, Classification ==CLASS_GROUND)
      # hist(lasg$Z, main = "", xlab = "Elevation manual ground", breaks = 800)
      # lasg$Z <- lasg$Z - 48.894 # lower point cloud # for BERN ALS
      # lasg$Z <- lasg$Z - 0.1 # lower point cloud
      # lasg = filter_poi(lasg, Z >= 0, Z <= 80)
      # hist(lasg$Z, main = "", xlab = "Elevation manual ground", breaks = 800)
      
      #### > filter ####
      # remove ground points:
      lasp = filter_poi(lasn, Classification !=CLASS_GROUND)
      # clean up RAM
      # remove("lasn")
      # min(lasn$Z)
      # hist(las$Z, main = "", xlab = "Elevation manual las", breaks = 800)
      # hist(lasp$Z, main = "", xlab = "Elevation manual lasp", breaks = 800)
      # lasn = lasp
      lasn$Z <- lasn$Z - 48.894 # lower point cloud # for BERN ALS
      # lasn$Z <- lasn$Z - 0.2 # lower point cloud
      # check height distribution with histogram
      # hist(lasn$Z, main = "", xlab = "Elevation manual", breaks = 800)
      # set negative values to zero afterwards
      lasn = filter_poi(lasn, Z >= 0, Z <= 80)
      # lasn$Z[lasn$Z < 0] = 0 # level points below zero (at the end)
      # check height distribution with histogram
      # hist(lasn$Z, main = "", xlab = "Elevation manual", breaks = 800)
    }else{
      # load/generate dtm
      if(exists("dtm_base")) {
        dtm = crop(dtm_base, roi)
        if(VERBOSE) print(paste0(">> ", roi$ITER, " | DTM loaded:", FILE_DTM))
      } else { dtm = grid_terrain(las, algorithm = kriging(k = 10L)) }
      
      # lasn = lasnormalize(las, dtm, na.rm=T) # deprecated
      lasn = normalize_height(las, dtm, na.rm=T)
    }
  } else lasn <- las
  
  #### > CHM           ####
  if(OUTPUT_CHM){
    chm = grid_canopy(lasn, VHM_RES, pitfree(c(0,2,5,10,15), c(0, 1.5)))
    # chm_low = grid_canopy(lasn, RASTER_RES, pitfree(c(0,2,5,10,15), c(0, 1.5)))
  }
  
  #### > output intermediate      ####
  if(OUTPUT_INTERMEDIATE) {
    print(paste0(">> ", roi$ITER, " | write intermediate results (e.g. las, dtm, vhm) to ", DIR_OUTPUT ))
    # write las, las_normalized, dtm and chm
    if(NORMALIZE && OUTPUT_LAS) writeLAS(las, FILE_LAS_CLIPPED)
    if(OUTPUT_LAS) writeLAS(lasn, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_n.las"))
    if(NORMALIZE) writeRaster(dtm, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_dtm.tif"), overwrite=T)
    if(OUTPUT_CHM) writeRaster(chm, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_chm_pitfree.tif"), overwrite=T)
  }
  # clean up RAM
  remove("las", "chm", "dtm")
  
  #### > filter ####
  # remove ground points:
  lasp = filter_poi(lasn, Classification !=CLASS_GROUND)
  # clean up RAM
  remove("lasn")

  ####_________________________####
  ####     HEIGHT CLASSES      ####
  #-------------------------------#
  if(VERBOSE) print(paste0(">> ", roi$ITER, " | main use case 4" ))
  
  #### > densitygrid ref  ####
  # point density per cell
  dgrid_ref = grid_density(lasp, RASTER_RES)
  dgrid_ref[is.na(dgrid_ref)] = 0
  # plot(dgrid_ref)
  
  # output densitygrid.tif
  if(OUTPUT_INTERMEDIATE) {
    print(paste0(">> ", roi$ITER, " | write densitygrid to ", DIR_OUTPUT ))
    # write las, las_normalized, dtm and chm
    writeRaster(dgrid_ref, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_densitygrid.tif"), overwrite=T)
  }
  # output plot densitygrid.pdf
  if(OUTPUT_PLOTPDF){
    if (VERBOSE) print(paste0(">> ", roi$ITER, " | plot and store PDF densitygrid.pdf"))
    pdf(paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_densitygrid.pdf"), width=10, height=6)
    plot(dgrid_ref, main=paste0("LiDAR Point Densitygrid \nComplete area"))
    dev.off()
  }
  
  #### > compute grids per class ####
  remove("class_df", "class_las_list", "class_dgrid_list", "class_dgridr_list") # clean dataframe from previous run
  #### > // ******* ####
  if (VERBOSE) print(paste0(">> ", roi$ITER, " | calculate height classes (extract, grid, store)"))
  for(c in 1:length(HEIGHT_CLASSES_min)){
    if(VERBOSE) print(paste0("  --> class ", c))
    # get min max height for class
    c_min = HEIGHT_CLASSES_min[c]
    c_max = HEIGHT_CLASSES_max[c]
    
    # filter las
    lasp_c = filter_poi(lasp, Z>=c_min, Z<c_max)
    # compute grid(s)
    dgrid_c = grid_density(lasp_c, RASTER_RES)
    
    # go to full extent (since areas w/o points are clipped)
    # dgrid_c = setExtent(dgrid_c, dgrid_ref, keepres = TRUE)
    # dgrid_c = resample(dgrid_c, dgrid_ref)
    
    dgrid_c[is.na(dgrid_c)] = 0 # remove NAs
    dgrid_rel_c = dgrid_c/dgrid_ref
    dgrid_rel_c[is.na(dgrid_rel_c)] = 0 # remove NAs
    
    ### >> output misc ####
    # output plot .pdf
    if(OUTPUT_PLOTPDF){
      pdf(paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "plot", c_min, "-", c_max, ".pdf"), width=10, height=6)
      plot(dgrid_rel_c, main=paste0("LiDAR Relative Point Densitygrid \nClass: ", c_min, "-", c_max, " m"), breaks=seq(0,1,0.05), col=c('#FFFFFFFF', mako(19, direction=-1)))
      plot(dgrid_c, main=paste0("LiDAR Point Densitygrid \nClass: ", c_min, "-", c_max, " m"))
      dev.off()
    }
    
    # show plot in RStudio/stdout for progress
    plot(dgrid_rel_c, main=paste0("LiDAR Relative Point Densitygrid \nClass: ", c_min, "-", c_max, " m"))
    
    # store results with info
    if(c == 1){
      class_las_list = list(lasp_c)
      class_dgrid_list <- list(dgrid_c)
      class_dgridr_list = list(dgrid_rel_c)
      class_df = data.frame(c_min = c_min, c_max = c_max)
    } else  {
      class_las_list <- append(class_las_list, list(lasp_c))
      class_dgrid_list <- append(class_dgrid_list, list(dgrid_c))
      class_dgridr_list <- append(class_dgridr_list, list(dgrid_rel_c))
      class_las_list
      class_df = rbind(class_df, data.frame(c_min = c_min, c_max = c_max))
    }
    
    #### >> output raster ####
    if(OUTPUT_INTERMEDIATE) {
      # write Point Densitygrid
      writeRaster(dgrid_c, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "dens_rel", c_min, "-", c_max, ".tif"), overwrite=T)
      # write Relative Point Densitygrid
      writeRaster(dgrid_rel_c, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "dens", c_min, "-", c_max, ".tif"), overwrite=T)
    }
  }#\endfor ()
  #### > ******* \\ ####

  #### > cover vector ####
  if (VERBOSE) print(paste0(">> ", roi$ITER, " | calculate cover layer"))
  # create cover raster/mask/polygon
  covered = ((resample(class_dgridr_list[[IDX_COVERCLASS]], dgrid_ref, method="ngb")) > THRESH_DENS_COV)
  # remove zeroes (otherwise they will be turned into polygons)
  covered[covered==0] = NA
  covered_vec = rasterToPolygons(covered) # creates a polygon for each pixel
  covered_vec = aggregate(covered_vec, dissolve=T) # merges pixel-polygons
  # write shapefile for cover
  if(OUTPUT_SUBDIRS){
    dir.create(file.path(dirname(FILE_LAS_CLIPPED), "cover_shp"), recursive = TRUE, showWarnings = FALSE)
    shapefile(covered_vec, 
              file.path(dirname(FILE_LAS_CLIPPED), "cover_shp", 
                        paste0(tools::file_path_sans_ext(basename(FILE_LAS_CLIPPED)), "__", "cover", 
                               HEIGHT_CLASSES_min[IDX_COVERCLASS], "-", 
                               HEIGHT_CLASSES_max[IDX_COVERCLASS], ".shp")), overwrite=T)
  }else {
    shapefile(covered_vec, 
              paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "__", "cover", 
                     HEIGHT_CLASSES_min[IDX_COVERCLASS], "-", 
                     HEIGHT_CLASSES_max[IDX_COVERCLASS], ".shp"), overwrite=T)
  }



  #### > compute final grids ####
  #### > // ******* ####
  if (VERBOSE) print(paste0(">> ", roi$ITER, " | process final class layers"))
  for(c in IDX_INCLUDECLASS){
    if(VERBOSE) print(paste0("--> class ", c))
    # get min max height for class
    c_min = HEIGHT_CLASSES_min[c]
    c_max = HEIGHT_CLASSES_max[c]
    
    #### >> compute layers ####
    layer_resampled = resample(class_dgridr_list[[c]], dgrid_ref, method="ngb")
    # mapview(class_dgridr_list[[4]], alpha= 0.42) + mapview(layer_resampled, alpha= 0.42)
    
    # covered areas only; remove areas that are open (not under cover)
    layer_cov = layer_resampled * (covered)
    # make NA values 0 for addition (otherwise it will work as a mask)
    layer_cov[is.na(layer_cov)] = 0
    
    # layer with combined
    layer_combined = layer_resampled + layer_cov * (COV_DENS_FACTOR-1)
    # cap values at 1 (= 100%)
    layer_combined = min(layer_combined, 1)
    # remove densities below treshold altogether
    layer_combined[layer_combined < THRESH_DENS_NA] = NA
    
    layer_cov = layer_combined * (covered)
    
    # open areas only; remove covered areas
    layer_open = layer_resampled * (is.na(covered))
    layer_open[layer_open < THRESH_DENS_NA] = NA
    
    #### >> output raster ####
    if(OUTPUT_SUBDIRS){
      # write layer with open vegetation
      dir.create(file.path(dirname(FILE_LAS_CLIPPED), paste0("open", c)), recursive = TRUE, showWarnings = FALSE)
      writeRaster(layer_open,
                  file.path(dirname(FILE_LAS_CLIPPED), paste0("open", c), 
                          paste0(tools::file_path_sans_ext(basename(FILE_LAS_CLIPPED)), "_", c, "open", c_min, "-", c_max, ".tif")), overwrite=T)
      # write layer with vegetation under cover
      dir.create(file.path(dirname(FILE_LAS_CLIPPED), paste0("cov", c)), recursive = TRUE, showWarnings = FALSE)
      writeRaster(layer_cov,
                  file.path(dirname(FILE_LAS_CLIPPED), paste0("cov", c), 
                            paste0(tools::file_path_sans_ext(basename(FILE_LAS_CLIPPED)), "_", c, "cov", c_min, "-", c_max, ".tif")), overwrite=T)
      # write layer with both
      # dir.create(file.path(dirname(FILE_LAS_CLIPPED), paste0("both", c)), recursive = TRUE, showWarnings = FALSE)
      # writeRaster(layer_combined,
      #             file.path(dirname(FILE_LAS_CLIPPED), paste0("both", c), 
      #                       paste0(tools::file_path_sans_ext(basename(FILE_LAS_CLIPPED)), "_", c, "both", c_min, "-", c_max, ".tif")), overwrite=T)
    }else {
      # write layer with open vegetation
      writeRaster(layer_open, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "open", c_min, "-", c_max, ".tif"), overwrite=T)
      # write layer with vegetation under cover
      writeRaster(layer_cov, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "cov", c_min, "-", c_max, ".tif"), overwrite=T)
      # write layer with both
      # writeRaster(layer_combined, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "both", c_min, "-", c_max, ".tif"), overwrite=T)
    }

    #### >> add to mapview ####
    if(OUTPUT_MAPVIEW){
      if(c >= 7){
        map_temp = mapview(layer_combined, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m")), na.color="#FFFFFF00",
                           at=seq(0,1,0.2), col.regions=c('#FFFFFFFF',  brewer.pal(n = 9, name = "Greens")), hide = TRUE)
      } else {
        map_temp = mapview(layer_combined, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m")), na.color="#FFFFFF00",
                           at=seq(0,1,0.2), col.regions=c('#FFFFFFFF',  brewer.pal(n = 9, name = "Greens")), hide = TRUE)  + 
          mapview(layer_cov, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [cov]")), na.color="#FFFFFF00",
                  at=seq(0,1,0.2), col.regions=c('#FFFFFFFF', brewer.pal(n = 9, name = "Greys")), hide = TRUE) +
          mapview(layer_open, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [open]")), na.color="#FFFFFF00",
                  at=seq(0,1,0.2), col.regions=c('#FFFFFFFF', brewer.pal(n = 9, name = "YlGn")), hide = TRUE)
      
        # doesn't work:
        # map_temp = mapview(list(layer_combined, layer_cov, layer_open), 
        #                    layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m"), 
        #                                   paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [cov]"), 
        #                                   paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [open]")), 
        #                    na.color="#FFFFFF00", hide = TRUE,
        #                    at=seq(0,1,0.2), col.regions=c('#FFFFFFFF',  brewer.pal(n = 9, name = "Greens")))
      }
    }
    # store results with info
    if(c == IDX_INCLUDECLASS[1]){
      layer_list_com = list(layer_combined)
      layer_list_cov = list(layer_cov)
      layer_list_open = list(layer_open)
      layer_names = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m"))
      
      if(OUTPUT_MAPVIEW) my_map = map_temp
  
    } else  {
      layer_list_com <- append(layer_list_com, list(layer_combined))
      layer_list_cov <- append(layer_list_cov, list(layer_cov))
      layer_list_open <- append(layer_list_open, list(layer_open))
      layer_names = cbind(layer_names, paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m"))
      
      if(OUTPUT_MAPVIEW) my_map = my_map + map_temp
    }
  }
  #### > ******* \\ ####
  if(OUTPUT_MAPVIEW){
    # add cover vector
    my_map = my_map + mapview(covered_vec, layer.name = "Unter Schirm", color = "brown", alpha = 1,  col.regions = "brown", alpha.regions = 0.3)
    # show map
    my_map
    # save map as .html
    if (VERBOSE) print(paste0(">> ", roi$ITER, " | save mapview"))
    mapshot(my_map, url = paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), ".html"))
  }
  if(VERBOSE) print(paste0(">> ", roi$ITER, " | DONE" ))
  if(VERBOSE) print("")
  
  # clean up RAM
  remove("lasn", "lasp", "lasp_c", "class_dgrid_list", "class_dgridr_list", 
         "dgrid_c", "dgrid_ref", "dgrid_rel_c",
         "layer_list_com", "layer_list_cov", "layer_list_open",
         "layer_combined", "layer_cov", "layer_open", 
         "covered", "covered_vec", "class_df",
         "my_map", "map_temp")
}#\endfor (polygons loop close)
#### *********************\\ ####
