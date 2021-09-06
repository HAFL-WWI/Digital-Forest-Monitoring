#------------------------------------------------------------------------------#
# Prototype UC4
#
#
# (c) by Hannes Horneber, HAFL, BFH, 2021-07-30
#------------------------------------------------------------------------------#

library(rgdal) # OGR driver (shp files)
library(lidR) # LAS processing
library(raster) # raster/grid processing

library(viridis) # for color palette
library(rstac) # get STAC info (swisssurface3D)
library(magrittr) # for pipe operator (%>%)

#-------------------------------#
####    SETTINGS GENERAL     ####
#-------------------------------#
# Base Path:  allows to switch easily between server/local path or various platforms 
#             if you copy/move the folder with all subfolders
BASE_PATH = "/uc4" # in docker

# WD: Working Directory. Best, if you keep this script at this place 
#     and all subfolders (data/shp, profiles, ...) in this folder
WD = file.path(BASE_PATH, "")

print("------------ DEV VERSION ---------------")
print(list.files(pattern = "*", recursive = TRUE))

#-------------------------------#
####       SETTINGS DEV      ####
#-------------------------------#

# turn on manual normalization 
MANUAL_NORMALIZATION = FALSE
# write intermediate results
OUTPUT_INTERMEDIATE = TRUE
# write PDF with plots for coverage
OUTPUT_PLOTPDF = TRUE
# download LAS
STAC_DOWNLOAD = TRUE
# download LAS
STAC_STORE = TRUE
# script output
VERBOSE = TRUE

#-------------------------------#
####     SETTINGS CUSTOM     ####
#   adjusted manually by user   #
####_________________________####

# input LAS (LAS dataset(s) to crop from)
# FILE_LAS_BASE = file.path(BASE_PATH, "data/swisssurface3d/2640_1219.las")
# input DTM (if you have a pre-calculated/external DTM for the area of interest)
# FILE_DTM = file.path(BASE_PATH, "LiDAR_Profiles/data/DHM/dtm_ALS_Bern_2019_nNA.tif")

# path (within WD) to shapefile

DIR_INPUT = file.path(WD, "input")

# directories
DIR_LAS = file.path(WD, "data/swisssurface3D")
DIR_BASE_OUTPUT = file.path(WD, "output", gsub(" ", "_", gsub(":", "", Sys.time())))

# buffer LAS clip around shapefile (in meter)
BUFFER_M = 10
# las class for ground points (for filtering), default is 2
CLASS_GROUND = 2
# resolution of resulting layer (in m)
RASTER_RES = 2
VHM_RES = 0.5
# vector with height-thresholds (in meters) to define height classes with
HEIGHT_CLASSES = c(1,2,5,12,24)
# threshold of relative LiDAR point density per cell to define area as covered
THRESH_COV = 0.1

# use KML file
KML = TRUE



#-------------------------------#
####        LOAD DATA        ####
#-------------------------------#
if(VERBOSE) print(paste0("######  load data: ", DIR_INPUT, " ######"))
# get input files from dir

if(KML){
  input_files = list.files(path=DIR_INPUT, pattern='.kml', full.names = TRUE)
  if(VERBOSE) print(paste0("found ", length(input_files), " .kml files in input directory"))
  if(VERBOSE && (length(input_files) > 0)) print(input_files)

  tryCatch(
    expr = {
      FILE_ROI = input_files[1]

      # load shapefile (kml -> shp)
      roi_shp = readOGR(FILE_ROI)
      # assign CRS in case it wasn't read
      crs(roi_shp) = CRS("+init=epsg:4326")

      roi_shp = spTransform(roi_shp, CRS("+init=epsg:2056"))
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
  # assign CRS in case it wasn't read
  message("SHP files are assumed to be in LV95 (epsg:2056). Make sure they are!")
  crs(roi_shp) = CRS("+init=epsg:2056")
}


#### > STAC fetch URLs ####
if(STAC_DOWNLOAD){
  if(VERBOSE) print("fetch STAC URLs")
  # init column
  roi_shp$las_url = NA

  # map.geo.admin.ch KML files don't come with an ID field... add one
  if(is.null(roi_shp$ID)) roi_shp$ID = 1:length(roi_shp)

  # iterate over polygons
  for(id in roi_shp$ID){
    roi = roi_shp[roi_shp$ID == id, ]
    # get bbox for STAC request
    roi_bbox = bbox(spTransform(roi, CRS("+init=epsg:4326")))
    # get STAC las tile
    it_obj <-
      stac("https://data.geo.admin.ch/api/stac/v0.9") %>%
      stac_search(collections = "ch.swisstopo.swisssurface3d",
                  bbox = roi_bbox) %>%
      get_request()

    #STUB for supporting polygons that overlap tile boundaries
    #more complicated (because of tile caching etc... ) -> known issues
    # items_length(it_obj) # number of tiles returned
    # class(roi_shp$las_url) <- "list"
    # for(tile_n in 1:items_length(it_obj)){
    #   if(tile_n == 1) las_url = c(it_obj[["features"]][[tile_n]][["assets"]][[1]][["href"]])
    #   else las_url = c(las_url, it_obj[["features"]][[tile_n]][["assets"]][[1]][["href"]])
    # }
    # roi_shp@data[roi_shp$ID == id, ]$las_url[[1]]  = las_url
    print(paste("Fetched", items_length(it_obj), "LAS URLs for Polygon ", id))
    if(items_length(it_obj) > 1){
      print("-----------------------------------------------")
      print("WARNING: Polygon spans over multiple LAS tiles.")
      print("This is not yet supported.")
      print("The polygon will be clipped at the LAS tile border.")
      print("LAS tile distribution can be seen here:")
      print("https://s.geo.admin.ch/922252199e")
      print("-----------------------------------------------")
    }

    # contains a collection of features, that contain downloadable assets with href (download url). E.g.:
    # it_obj[["features"]][[1]][["assets"]][["swisssurface3d_2020_2640-1219_2056_5728.las.zip"]][["href"]]
    # get url to las tile
    las_url = it_obj[["features"]][[1]][["assets"]][[1]][["href"]]
    roi_shp@data[roi_shp$ID == id, ]$las_url  = las_url
  }
  # order after las_url so that all polygons of one las tile will be processed together (caching lastile)
  roi_shp = roi_shp[order(roi_shp$las_url), ]
  if(VERBOSE) print(paste0("fetched STAC URLs. Will load: ", length(unique(roi_shp$las_url)), " tile(s)") )
}


#### > iterate polygons ####
####********************####

if(VERBOSE) print("###### iterate polygons in .shp file ######")
for(id in roi_shp$ID){
  roi = roi_shp[roi_shp$ID == id, ]
  if(VERBOSE) print(paste0(">> polygon #", which(roi_shp$ID==id), "(", roi$ID, ")") )

  tryCatch(
    expr = {
      #### > STAC download ####
      if(STAC_DOWNLOAD){
        las_url = roi$las_url
        # build las tilename from URL
        las_tile = paste0(gsub("-", "_", gsub(".*swisssurface3d_\\d{4}_", "", gsub("_\\d{4}_\\d{4}.las.zip.*", "", las_url))), ".las")
        # check whether las tile is already cached
        # (use exists() instead of which(roi_shp$ID==id) == 1 || ... to check for first iter )
        if(!(exists("las_url_cache") && las_url == las_url_cache)){
          if(VERBOSE) print("no chached LAS tile found")

          if(STAC_STORE){
            DIR_STAC_STORE = file.path(DIR_INPUT, "stac_store")
            FILE_LAS_BASE = file.path(DIR_STAC_STORE, las_tile)
            if(file.exists(FILE_LAS_BASE)){
              if(VERBOSE) print(paste0("load stored LAS tile ", FILE_LAS_BASE))
              # load unzipped las tile
              lasBase = readLAS(FILE_LAS_BASE)
            }else{
              if(VERBOSE) print(paste0("No LAS tile found at ", FILE_LAS_BASE))
              break
            }
          }
          # download tile if it isn't stored
          if(!STAC_STORE || (STAC_STORE && !file.exists(FILE_LAS_BASE)) ){
            if(VERBOSE) print(paste0("download LAS data from ", las_url))
            # download las tile to temp file
            temp_dl <- tempfile()
            download.file(las_url, temp_dl)
            # unzip las tile to temp file
            temp_uzip <- tempdir()
            FILE_LAS_BASE = unzip(temp_dl, exdir = temp_uzip)
            if(VERBOSE) print(paste0("download and extraction successful: ", basename(FILE_LAS_BASE)))

            if(STAC_STORE){
              if(VERBOSE) print(paste0("store at: ", file.path(DIR_STAC_STORE, basename(FILE_LAS_BASE)) ))
              DIR_STAC_STORE = file.path(DIR_INPUT, "stac_store")
              dir.create(DIR_STAC_STORE, recursive = TRUE)
              # move unpacked file
              file.rename(FILE_LAS_BASE, file.path(DIR_STAC_STORE, basename(FILE_LAS_BASE)))
              # update variable
              FILE_LAS_BASE = file.path(DIR_STAC_STORE, basename(FILE_LAS_BASE))
            }

            # load unzipped las tile
            lasBase = readLAS(FILE_LAS_BASE)
            # lasBase = catalog(FILE_LAS_BASE) # not used so far, but reading as catalog may be more efficient

            # unlink temp files so they can be deleted
            unlink(temp_dl)
            unlink(temp_uzip)
          }

          # remember las_url in case other polygons are in the same tile
          las_url_cache = roi$las_url
        } else {
          if(VERBOSE) print(paste0("LAS tile cached, reusing FILE_LAS_BASE, lasBase: ", basename(FILE_LAS_BASE)))
        }
      } else {
        # load las
        lasBase = readLAS(FILE_LAS_BASE)
        # assign CRS in case it wasn't read
        crs(lasBase) = CRS("+init=epsg:2056")
      }

      #### > CHECK EXTENTS      ####
      plot(extent(lasBase), main="LAS extents and region of interest")
      plot(roi, add=T, col="red")

      #### > OUTPUT FOLDER ####
      # DIR_OUTPUT = file.path(DIR_BASE_OUTPUT, id)
      DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", THRESH_COV, "_", paste0(tools::file_path_sans_ext(basename(FILE_ROI))))
      # output file (LAS dataset cropped to shapefile (with buffer) will be generated)
      FILE_LAS_CLIPPED = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_ROI)), "_", id, ".las"))
      if(VERBOSE) print(paste0("--> create output folder: ", DIR_OUTPUT))
      dir.create(DIR_OUTPUT, recursive = TRUE)

      #-------------------------------#
      ####         PREPROC         ####
      #-------------------------------#
      if(VERBOSE) print(paste0(">> ", roi$ID, " | preprocess" ))
      #### > CLIP LAS        ####
      las = clip_roi(lasBase, extent(roi))

      #### > DTM           ####
      dtm = grid_terrain(las, algorithm = kriging(k = 10L))
      # lasn = lasnormalize(las, dtm, na.rm=T) # deprecated
      lasn = normalize_height(las, dtm, na.rm=T)

      #### > CHM           ####
      chm = grid_canopy(lasn, VHM_RES, pitfree(c(0,2,5,10,15), c(0, 1.5)))

      #### > WRITE PREPROC      ####
      ####_________________________####
      if(OUTPUT_INTERMEDIATE) {
        print(paste0(">> ", roi$ID, " | write intermediate results (las, dtm, vhm) to ", DIR_OUTPUT ))
        # write las, las_normalized, dtm and chm
        writeLAS(las, FILE_LAS_CLIPPED)
        writeLAS(lasn, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_n.las"))
        writeRaster(dtm, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_dtm.tif"), overwrite=T)
        writeRaster(chm, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_chm_pitfree.tif"), overwrite=T)
      }

      #-------------------------------#
      ####     HEIGHT CLASSES      ####
      #-------------------------------#
      if(VERBOSE) print(paste0(">> ", roi$ID, " | calculate height classes" ))

      #### > filter ####
      # remove ground points:
      lasp = filter_poi(lasn, Classification !=CLASS_GROUND)

      #### > densitygrid ####
      # point density per cell
      dgrid_ref = grid_density(lasp, RASTER_RES)
      # plot(densitygrid_ref)

      # output densitygrid.tif
      if(OUTPUT_INTERMEDIATE) {
        print(paste0(">> ", roi$ID, " | write densitygrid to ", DIR_OUTPUT ))
        # write las, las_normalized, dtm and chm
        writeRaster(dgrid_ref, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_densitygrid.tif"), overwrite=T)
      }
      # output plot densitygrid.pdf
      if(OUTPUT_PLOTPDF){
        if (VERBOSE) print(paste0(">> ", roi$ID, " | plot and store PDF densitygrid.pdf"))
        pdf(paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_densitygrid.pdf"), width=10, height=6)
        plot(dgrid_ref, main=paste0("LiDAR Point Densitygrid \nComplete area"))
        dev.off()
      }

      #### > compute grids per class ####
      remove("df_las", "list_las") # clean dataframe from previous run
      for(c in 1:(length(HEIGHT_CLASSES)+1)){
        if(VERBOSE) print(paste0("--> class ", c))
        # determine min max height for class
        if(c == 1){
          c_min = 0
          c_max = HEIGHT_CLASSES[c]
        } else if(c == length(HEIGHT_CLASSES)+1) {
          c_min = HEIGHT_CLASSES[c-1]
          c_max = 99
        } else {
          c_min = HEIGHT_CLASSES[c-1]
          c_max = HEIGHT_CLASSES[c]
        }

        # filter las
        lasp_c = filter_poi(lasp, Z>=c_min, Z<c_max)
        # compute grid(s)
        dgrid_c = grid_density(lasp_c, RASTER_RES)
        dgrid_rel_c = dgrid_c/dgrid_ref
        cov_c = (dgrid_rel_c>=THRESH_COV)

        #### > output misc ####
        # output plot .pdf
        if(OUTPUT_PLOTPDF){
          pdf(paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "plot", c_min, "-", c_max, ".pdf"), width=10, height=6)
          # plot(cov_c, main=paste0("Coverage (density >", THRESH_COV, ")", "\nClass: ", c_min, "-", c_max, " m"))
          plot(dgrid_rel_c, main=paste0("LiDAR Relative Point Densitygrid \nClass: ", c_min, "-", c_max, " m"), breaks=seq(0,1,0.05), col=c('#FFFFFFFF', mako(19, direction=-1)))
          plot(cov_c, main=paste0("Coverage (density threshold >", THRESH_COV, ")", "\nClass: ", c_min, "-", c_max, " m"), breaks=c(0,0.01,1), col=c('#FFFFFFFF','#55DD33FF'))
          plot(dgrid_c, main=paste0("LiDAR Point Densitygrid \nClass: ", c_min, "-", c_max, " m"))
          dev.off()
        }


        # show plot in RStudio/stdout for progress
        plot(dgrid_rel_c, main=paste0("LiDAR Relative Point Densitygrid \nClass: ", c_min, "-", c_max, " m"))

        # store results with info (not yet further processed)
        if(c == 1){
          list_las = list(lasp_c)
          df_las = data.frame(c_min = c_min, c_max = c_max)
        } else  {
          list_las <- append(list_las, list(lasp_c))
          df_las = rbind(df_las, data.frame(c_min = c_min, c_max = c_max))
        }

        #### > output raster ####
        dir.create(DIR_OUTPUT, recursive = TRUE)
        # write Cover Layer
        writeRaster(cov_c, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "cov", c_min, "-", c_max, ".tif"), overwrite=T)
        if(OUTPUT_INTERMEDIATE) {
          # write Point Densitygrid
          writeRaster(dgrid_c, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "dens_rel", c_min, "-", c_max, ".tif"), overwrite=T)
          # write Relative Point Densitygrid
          writeRaster(dgrid_rel_c, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "dens", c_min, "-", c_max, ".tif"), overwrite=T)
        }

      }
      if(VERBOSE) print(paste0(">> ", roi$ID, " | DONE" ))
      if(VERBOSE) print("")
    },#trycatch-exp close
    error = function(e){
      message('Caught an error!')
      print(e)
      message('skip')
    }, finally = { } #trycatch-error close
  )#trycatch close
}#for-loop polygons close
