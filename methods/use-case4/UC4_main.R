#------------------------------------------------------------------------------#
# Prototype UC4
#
#
# (c) by Hannes Horneber, HAFL, BFH, 2021-07-30 | 2021-09-07
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

# print("------------ DOCKER VERSION ---------------")
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
#-------------------------------#

# input LAS (LAS dataset(s) to crop from)
# FILE_LAS_BASE = file.path(BASE_PATH, "data/swisssurface3d/2640_1219.las")
# input DTM (if you have a pre-calculated/external DTM for the area of interest)
# FILE_DTM = file.path(BASE_PATH, "LiDAR_Profiles/data/DHM/dtm_ALS_Bern_2019_nNA.tif")

# path (within WD) to shapefile

DIR_INPUT = file.path(WD, "input") 

# directories
DIR_LAS = file.path(WD, "data/swisssurface3D")
DIR_BASE_OUTPUT = file.path(WD, "output", gsub(" ", "_", gsub(":", "", Sys.time())))

# use KML file
KML = TRUE

# las class for ground points (for filtering), default is 2
CLASS_GROUND = 2
# resolution of resulting layer (in m)
RASTER_RES = 5
# RASTER_RES = 10 # 2
# resolution of VHM
VHM_RES = 0.5
# vector with height-thresholds (in meters) to define height classes with
# HEIGHT_CLASSES = c(1,2,5,12,24)
HEIGHT_CLASSES_min = c(12,24, 0,0,0, 0,12,24)
HEIGHT_CLASSES_max = c(99,99, 1,2,5,12,24,99)
# threshold of relative LiDAR point density per cell to define area as covered
THRESH_DENS = 0.1

#.............. parameters for mapview ................... #
# below this density threshold, pixels will be declared NA (and be transparent)
THRESH_DENS_NA = 0.2
# above this density threshold in coverclass, pixels will be considered covered
THRESH_DENS_COV = 0.33
# index (in HEIGHT_CLASSES_min) of the coverclass (by default 1)
IDX_COVERCLASS = 1
# indexes (in HEIGHT_CLASSES_min) of the classes included in the map/output
IDX_INCLUDECLASS = 8:3
# Factor to multiply density under cover with
COV_DENS_FACTOR = 3


####_________________________####
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
#### // ********************* ####

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
      }
      
      # assign CRS in case it wasn't read
      crs(lasBase) = CRS("+init=epsg:2056")
      
      #### > CHECK EXTENTS      ####
      plot(extent(lasBase), main="LAS extents and region of interest")
      plot(roi, add=T, col="red")
      
      #### > OUTPUT FOLDER ####
      # DIR_OUTPUT = file.path(DIR_BASE_OUTPUT, id)
      DIR_OUTPUT = paste0(DIR_BASE_OUTPUT, "_", THRESH_DENS, "_", paste0(tools::file_path_sans_ext(basename(FILE_ROI))))
      # output file (LAS dataset cropped to shapefile (with buffer) will be generated)
      FILE_LAS_CLIPPED = file.path(DIR_OUTPUT, paste0(tools::file_path_sans_ext(basename(FILE_ROI)), "_", id, ".las"))
      if(VERBOSE) print(paste0("--> create output folder: ", DIR_OUTPUT))
      dir.create(DIR_OUTPUT, recursive = TRUE)
      
      ####_________________________####
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
      
      chm_low = grid_canopy(lasn, RASTER_RES, pitfree(c(0,2,5,10,15), c(0, 1.5)))
      
      #### > WRITE PREPROC      ####
      
      if(OUTPUT_INTERMEDIATE) {
        print(paste0(">> ", roi$ID, " | write intermediate results (las, dtm, vhm) to ", DIR_OUTPUT ))
        # write las, las_normalized, dtm and chm
        writeLAS(las, FILE_LAS_CLIPPED)
        writeLAS(lasn, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_n.las"))
        writeRaster(dtm, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_dtm.tif"), overwrite=T)
        writeRaster(chm, paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_chm_pitfree.tif"), overwrite=T)
      }
      
      ####_________________________####
      ####     HEIGHT CLASSES      ####
      #-------------------------------#
      if(VERBOSE) print(paste0(">> ", roi$ID, " | main use case 4" ))
      
      #### > filter ####
      # remove ground points:
      lasp = filter_poi(lasn, Classification !=CLASS_GROUND)
      
      #### > densitygrid ####
      # point density per cell
      dgrid_ref = grid_density(lasp, RASTER_RES)
      dgrid_ref[is.na(dgrid_ref)] = 0
      # plot(dgrid_ref)
      
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
      remove("class_df", "class_las_list", "class_dgrid_list", "class_dgridr_list") # clean dataframe from previous run
      #### > // ******* ####
      if (VERBOSE) print(paste0(">> ", roi$ID, " | calculate height classes (extract, grid, store)"))
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
        cov_c = (dgrid_rel_c>=THRESH_DENS)
        
        ### > output misc ####
        # output plot .pdf
        if(OUTPUT_PLOTPDF){
          pdf(paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), "_", c, "plot", c_min, "-", c_max, ".pdf"), width=10, height=6)
          # plot(cov_c, main=paste0("Coverage (density >", THRESH_DENS, ")", "\nClass: ", c_min, "-", c_max, " m"))
          plot(dgrid_rel_c, main=paste0("LiDAR Relative Point Densitygrid \nClass: ", c_min, "-", c_max, " m"), breaks=seq(0,1,0.05), col=c('#FFFFFFFF', mako(19, direction=-1)))
          plot(cov_c, main=paste0("Coverage (density threshold >", THRESH_DENS, ")", "\nClass: ", c_min, "-", c_max, " m"), breaks=c(0,0.01,1), col=c('#FFFFFFFF','#55DD33FF'))
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
      #### > ******* \\ ####
      
      ####> create cover ####
      if (VERBOSE) print(paste0(">> ", roi$ID, " | calculate cover layer"))
      # create cover raster/mask/polygon
      covered = ((resample(class_dgridr_list[[IDX_COVERCLASS]], dgrid_ref, method="ngb")) > THRESH_DENS_COV)
      # remove zeroes (otherwise they will be turned into polygons)
      covered[covered==0] = NA
      covered_vec = rasterToPolygons(covered) # creates a polygon for each pixel
      covered_vec = aggregate(covered_vec, dissolve=T) # merges pixel-polygons
      
      #### > // ******* ####
      if (VERBOSE) print(paste0(">> ", roi$ID, " | process final class layers"))
      for(c in IDX_INCLUDECLASS){
        if(VERBOSE) print(paste0("--> class ", c))
        # get min max height for class
        c_min = HEIGHT_CLASSES_min[c]
        c_max = HEIGHT_CLASSES_max[c]
        
        ####> create layers ####
        layer_resampled = resample(class_dgridr_list[[c]], dgrid_ref, method="ngb")
        # mapview(class_dgridr_list[[4]], alpha= 0.42) + mapview(layer_resampled, alpha= 0.42)
        
        # covered areas only; remove areas that are free (not under cover)
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
        
        # free areas only; remove covered areas
        layer_free = layer_resampled * (is.na(covered))
        layer_free[layer_free < THRESH_DENS_NA] = NA
        
        if(c >= 7){
          map_temp = mapview(layer_combined, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m")), na.color="#FFFFFF00",
                             at=seq(0,1,0.2), col.regions=c('#FFFFFFFF',  brewer.pal(n = 9, name = "Greens")), hide = TRUE)
        } else {
          map_temp = mapview(layer_combined, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m")), na.color="#FFFFFF00",
                             at=seq(0,1,0.2), col.regions=c('#FFFFFFFF',  brewer.pal(n = 9, name = "Greens")), hide = TRUE)  + 
            mapview(layer_cov, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [cov]")), na.color="#FFFFFF00",
                    at=seq(0,1,0.2), col.regions=c('#FFFFFFFF', brewer.pal(n = 9, name = "Greys")), hide = TRUE) +
            mapview(layer_free, layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [open]")), na.color="#FFFFFF00",
                    at=seq(0,1,0.2), col.regions=c('#FFFFFFFF', brewer.pal(n = 9, name = "YlGn")), hide = TRUE)
          # doesn't work:
          # map_temp = mapview(list(layer_combined, layer_cov, layer_free), 
          #                    layer.name = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m"), 
          #                                   paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [cov]"), 
          #                                   paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m [free]")), 
          #                    na.color="#FFFFFF00", hide = TRUE,
          #                    at=seq(0,1,0.2), col.regions=c('#FFFFFFFF',  brewer.pal(n = 9, name = "Greens")))
        }
        
        # store results with info
        if(c == IDX_INCLUDECLASS[1]){
          layer_list_com = list(layer_combined)
          layer_list_cov = list(layer_cov)
          layer_list_free = list(layer_free)
          layer_names = c(paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m"))
          
          my_map = map_temp
          
        } else  {
          layer_list_com <- append(layer_list_com, list(layer_combined))
          layer_list_cov <- append(layer_list_cov, list(layer_cov))
          layer_list_free <- append(layer_list_free, list(layer_free))
          layer_names = cbind(layer_names, paste0(HEIGHT_CLASSES_min[c], "-", HEIGHT_CLASSES_max[c], " m"))
          
          my_map = my_map + map_temp
        }
      }
      #### > ******* \\ ####
      
      # add cover vector
      my_map = my_map + mapview(covered_vec, layer.name = "Unter Schirm", color = "brown", alpha = 1,  col.regions = "brown", alpha.regions = 0.3)
      
      # show map
      my_map
      
      # save map as .html
      if (VERBOSE) print(paste0(">> ", roi$ID, " | save mapview"))
      mapshot(my_map, url = paste0(tools::file_path_sans_ext(FILE_LAS_CLIPPED), ".html"))
      
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
#### *********************// ####
