#===============================================================================#
# execute all steps necessary including those involving Google's Earth Engine to
# the final (WMS/WFS-ready) yearly change raster and polygons

# by Attilio Benini, BFH-HAFL
# inspiration taken from scripts written by Hannes Horneber, Dominique Weber and
# Alexandra Erbach, BFH-HAFL

#===============================================================================#
# READ BEFORE STARTING ####
#-------------------------------------------------------------------------------#
## HOW TO USE THIS SCRIPT ####
#-------------------------------------------------------------------------------#

# You can't send the below code in one flush to the console and except everything
# will work fine. Up to and including section PARAMETERS there's some interactivity
# involved. Twice you're prompted for input
# 1) your gmail / GEE account (something like EE.USER@gmail.com) in section 
#    GEE / rgee SET UP
# 2) the current year (= year for which you wish to calculate the max. NDVI-
#    composite) in section PARAMETERS

# Moreover in section GEE / rgee SET UP you have to pay close attention: Read
# the comments and run the code line by line!

# At the end of the PATHS section existence of relative and absolved paths is
# checked. Recheck the check!

# Having finished section PATHS you should be able execute the rest of the
# code in one go. This will take time (experiences made so far about 2 hours)!

#-------------------------------------------------------------------------------#
## NOTE ON rgee SET UP & NON-R-DEPENDENCIES ####
#-------------------------------------------------------------------------------#

# R-package rgee and its non-R-dependencies have to set up -> TODO: reference to more information / advice
# - gmail, Google Earth Engine (GEE) and Google Drive (GD) account are required
# - before starting make sure you're logged in on your gmail account associated with GEE 
# - you might need reset your credentials for GEE and GD while running
#   ee_Initialize(user = 'EE.USER@gmail.com', drive = TRUE) with an interactively 
#   generated token --> s. below section GEE / rgee SET UP

#===============================================================================#
# SYSTEM LANGUAGE ####
#-------------------------------------------------------------------------------#

# set environment Variable language to English 
Sys.setenv(LANG = "en_US.UTF-8")
# --> all error, warning and message text returned is in English --> makes 
# searching help online easier

#===============================================================================#
# PACKAGES ####
#-------------------------------------------------------------------------------#

# library(dplyr)
# library(retry)
# library(gdalraster)
# library(gdalUtilities)
library(terra)
library(sf) 
library(stars)
library(exactextractr)
library(mapview)
library(rgee)

#===============================================================================#
# GEE / rgee SET UP ####
#-------------------------------------------------------------------------------#

ee_check() # continue only if everything is Ok!

# prompting for EE-account
ee_user_mail_account <- readline("your gmail / Earth Engine user account: ")
# remove prefix & suffix generated while reading pasted 'EE.USER@gmail.com' or "EE.USER@gmail.com"
ee_user_mail_account <- gsub("'", "", gsub('\"', "", ee_user_mail_account, fixed = TRUE), fixed = TRUE)
ee_user_mail_account # check if Earth Engine account has no typos 

# Here the Google's Earth Engine (GEE) is authenticated and initialized
ee_Initialize(user = ee_user_mail_account, drive = TRUE)
# might involve interactive generation of token
# error message prompting to try running rgee::ee_Authenticate() might pop up -->
# ee_Authenticate()
# ee_Initialize(drive = TRUE)

ee_users() # EE & GD column muss be checked for only a single user!
ee_check_credentials() 

#===============================================================================#
# PARAMETERS ####
#-------------------------------------------------------------------------------#

# use test area (= canton TI + Missox) to run below code? TRUE / FALSE
use_test_area <- FALSE

# previous years (the earliest possible is 2016 due Start of Sentinel2 on 2015-06-23)
year_curr <- as.integer(readline("current year: "))
# previous years = year before current year
year_prev <- year_curr - 1L # previous year

# crs to project into
crs_reproject <- st_crs("EPSG:3857")

# raster cell size (resultion)
cell_size <- 10L # [m]

# parameters for 5 POLYGONIZE
min_area <- units::set_units(399, m^2) 
# default is >399 (>= 400), but may be increased as threshold is lowered (e.g. 499 for threshold = -600)
# threshold used to be -1000 (until Oct 2022).
# TODO: Ask Hannes about relationship between min_area & threshold_poly 

# number of pixels a patch of adjacent raster cells being =< threshold_poly has 
# to have in order to be turned into a polygon
threshold_n_pixel <- {min_area / cell_size^2} %>% round() %>% as.integer()

# threshold below which pixels get polygonized
threshold_poly <- -600L

#===============================================================================#
# PATHS ####
#-------------------------------------------------------------------------------#

# absolute paths (P-device / data storage)

# path_use_cases <- file.path("P:", "LFE", "HAFL", "WWI-Sentinel-2", "Use-Cases")
# path to current regular data storage for Digital-Forest-Monitoring
path_use_cases <- file.path("P:", "HAFL", "7 WWI", "74a FF WG", "742a Aktuell", "R.011551-52-WFOM-01_Fernerkundungstools_Forstliche_Praxis", "Methoden", "Use-Cases")
# path to temp. data storage for Digital-Forest-Monitoring -> TODO change after development is finished
fs::dir_tree(path_use_cases, type = "directory")
path_use_case_1       <- file.path(path_use_cases, "Use-Case1")
path_general          <- file.path(path_use_cases, "general")
path_swiss_boundaries <- file.path(path_general, "swissBOUNDARIES3D")
path_forest_mask      <- file.path(path_general, "swissTLM3D_Wald")

# relative paths (local clone of Wald-Monitoring repo / scripts)

path_methods <- file.path(getwd(), "methods")

# check paths

ls(pattern = "path_") %>% 
  setNames(sapply(., function(x) dir.exists(get(x))), .) %>% 
  data.frame(exists = .)

#===============================================================================#
# START TIME ####
#-------------------------------------------------------------------------------#

t0 <- Sys.time() 

#===============================================================================#
# 1 GEE ####
#-------------------------------------------------------------------------------#
## 1.1 AREA OF INTEREST ####
#-------------------------------------------------------------------------------#

t0_GEE <- Sys.time()

# swiss     <- ee$Geometry$Rectangle(5.4, 45.5, 11, 48.1)
# too large? used in former version of Use Case 1 
swiss     <- ee$Geometry$Rectangle(5.9, 45.81, 10.5, 47.81) 
# BB of CH in EGSG 4326 + some min. margin
area_test <- ee$Geometry$Rectangle(8.34, 45.8, 9.32, 46.65)
# test area = canton TI + Missox
if(use_test_area){aoi <- area_test}else{aoi <- swiss}

# view area of interest
aoi_sf <- ee_as_sf(aoi) %>% st_set_crs("EPSG:4326")
mapview(aoi_sf, lwd = 2, color = "red", alpha.regions = 0, layer.name = "Area of Interest")

#-------------------------------------------------------------------------------#
## 1.2 MAX NDVI COMPOSITE PREVIOUS YEAR  ####
#-------------------------------------------------------------------------------#

# source function ee_S2_max_ndvi() from script
path_ee_S2_max_ndvi <- file.path(path_methods, "use-case1", "ee_S2_max_ndvi.R")
file.exists(path_ee_S2_max_ndvi)
source(path_ee_S2_max_ndvi)

S2_max_ndvi_prev <- ee_S2_max_ndvi(year = year_prev)

# source function ee_map_max_ndvi_rgb() from script
path_ee_map_max_ndvi_rgb <- file.path(path_methods, "use-case1", "ee_map_max_ndvi_rgb.R")
file.exists(path_ee_map_max_ndvi_rgb)
source(path_ee_map_max_ndvi_rgb)

ee_map_max_ndvi_rgb(S2_max_ndvi_prev, year = year_prev)

ndvi_max_prev <- S2_max_ndvi_prev$select('NDVI')

#-------------------------------------------------------------------------------#
## 1.3 MAX NDVI COMPOSITE CURRENT YEAR  ####
#-------------------------------------------------------------------------------#

S2_max_ndvi_curr <- ee_S2_max_ndvi(year = year_curr)

ee_map_max_ndvi_rgb(S2_max_ndvi_curr, year = year_curr)

ndvi_max_curr <- S2_max_ndvi_curr$select('NDVI')

#-------------------------------------------------------------------------------#
## 1.4 CALCULATE DIFFERENCE #### 
#-------------------------------------------------------------------------------#

# calculate difference of max. NDVI composite of current and previous year 
ndvi_max_diff <- 
  ndvi_max_curr$subtract(ndvi_max_prev)$ # diff. of current and previous year
  multiply(10^4)$ # [-2,2] -> [-20'000, 20'000]
  round()$        # round to integers
  int16()         # as int16

(t_GEE <- Sys.time() - t0_GEE)

#-------------------------------------------------------------------------------#
## 1.5 EXPORT TO GOOGLE DRIVE #### 
#-------------------------------------------------------------------------------#

t0_ex_GD <- Sys.time()

# name diff layer / exported raster
ndvi_diff_name <- paste0("ndvi_diff_", year_curr, "_", year_prev)

# export to GD
task_img <-
  ee_image_to_drive(
    image          = ndvi_max_diff,
    description    = ndvi_diff_name,
    fileNamePrefix = ndvi_diff_name,
    scale          = 10,
    maxPixels      = 2000000000,
    region         = aoi,
    crs            = 'EPSG:2056'
  )
task_img$start()
# ee_monitoring(task_img)

# wait until image is completely stored on GD
retry::wait_until(basename(ee$batch$Task$status(task_img)[["state"]]) == "COMPLETED", interval = 10)

(t_ex_GD <- Sys.time() - t0_ex_GD)

#-------------------------------------------------------------------------------#
## 1.6 EXPORT TO LOCAL DRIVE #### 
#-------------------------------------------------------------------------------#

t0_ex_local <- Sys.time()

# export to local drive
path_ndvi_diff <- file.path(path_use_case_1, ndvi_diff_name)
if(!dir.exists(path_ndvi_diff)){dir.create(path_ndvi_diff)}
dsn_tif <- file.path(path_ndvi_diff, paste0("ndvi_max.tif"))
ee_drive_to_local(task = task_img, dsn = dsn_tif, consider = "all")

(t_ex_local <- Sys.time() - t0_ex_local)

#===============================================================================#
# 2 GEE POSTPROCESSING ####
#-------------------------------------------------------------------------------#
## 2.1 READ (META-)DATA ####
#-------------------------------------------------------------------------------#

st_layers(path_swiss_boundaries)
ch_boundaries <- 
  st_read(
    dsn   = path_swiss_boundaries,
    layer = "swissBOUNDARIES3D_1_1_TLM_LANDESGEBIET",
    quiet = TRUE
    ) %>%
  st_make_valid()

path_ndvi_diff_tif <- path_ndvi_diff %>% list.files(pattern = ".tif$", full.names = TRUE) 
path_ndvi_diff_tif %>% file.exists() %>% all()
ndvi_max_diff <-
  path_ndvi_diff_tif %>%
  lapply(read_stars, proxy = TRUE) %>%
  do.call(st_mosaic, .)

path_forest_mask_tif <- file.path(path_forest_mask, "Wald_LV95_rs.tif")
file.exists(path_forest_mask_tif)
forest_mask <- 
  read_stars(
    path_forest_mask_tif,
    proxy = TRUE,
    quiet = TRUE
    )

#-------------------------------------------------------------------------------#
## 2.2 OVERVIEW INPUT DATA ####
#-------------------------------------------------------------------------------#

# vector with names of geodata input 
input <- c("ch_boundaries", "ndvi_max_diff", "forest_mask")
# class of intput data
input %>% setNames(lapply(., function(x) class(get(x))), .)
# CRS / EPSG of input geodata, should be all the same
input %>% setNames(sapply(., function(x) st_crs(get(x))$epsg), .)
# dimensions of input raster layers, might differ, which is ok
input[-1] %>% setNames(lapply(., function(x) dim(get(x))), .)

# for each geodata input xyz make bounding box as sfc object bb_xyz
for(i in input){
  assign(paste0("bb_", i), get(i) %>% st_bbox() %>% st_as_sfc())
}

# map swiss boundaries + all bb_xyz
m_poly_ch_boundaries <- mapview(ch_boundaries, lwd = 0.5, layer.name = "polygon ch_boundaries", native.crs = TRUE)
m_bb_ch_boundaries   <- mapview(bb_ch_boundaries, lwd = 5, color = "cyan", alpha.regions = 0, layer.name = "bb ch_boundaries", native.crs = TRUE)
m_bb_forest_mask     <- mapview(bb_forest_mask, lwd = 2, color = "yellow", alpha.regions = 0, layer.name = "bb forest_mask", native.crs = TRUE)
m_bb_ndvi_max_diff   <- mapview(bb_ndvi_max_diff, lwd = 2, color = "magenta", alpha.regions = 0, layer.name = "bb ndvi_max_diff", native.crs = TRUE)
m_poly_ch_boundaries + m_bb_ch_boundaries + m_bb_forest_mask + m_bb_ndvi_max_diff

#-------------------------------------------------------------------------------#
## 2.4 REDUCE FOREST MASK TO TEST AREA ####
#-------------------------------------------------------------------------------#

# if test area is used --> reduce forest mask, else leave forest mask as is
if(use_test_area){
  bb_forest_mask_4_test <-
    aoi_sf %>% 
    st_transform(st_crs(forest_mask)) %>%
    st_bbox() %>%
    st_as_sfc() %>%
    st_intersection(bb_forest_mask) %>%
    st_make_valid() %>%
    st_bbox() %>%
    {round(. / 10)}*10
  
  forest_mask_vrt <- file.path(tempdir(), "forest_mask.vrt") # virtual dataset
  gdalUtilities::gdalbuildvrt(
    gdalfile   = path_forest_mask_tif,   
    output.vrt = forest_mask_vrt, 
    te         = st_bbox(bb_forest_mask_4_test), # 
    tr         = c("10", "10"),
    a_srs      = "EPSG:2056",
    overwrite  = TRUE
    )
  
  path_forest_mask_tif <- forest_mask_vrt
  forest_mask <- read_stars(path_forest_mask_tif, proxy = TRUE, quiet = TRUE)
  }

#-------------------------------------------------------------------------------#
## 2.5 HOMOGENIZE RASTERS ####
#-------------------------------------------------------------------------------#
# ?gdalUtilities::gdalbuildvrt

ndvi_max_diff_vrt <- file.path(tempdir(), "ndvi_max_diff.vrt") # virtual dataset
gdalUtilities::gdalbuildvrt(
  gdalfile   = path_ndvi_diff_tif,   # all NDVI max diff GeoTIFF (GEE --> GD --> local)
  output.vrt = ndvi_max_diff_vrt, 
  te         = st_bbox(forest_mask), # same extent as forest mask
  tr         = c("10", "10"),
  a_srs      = "EPSG:2056",
  overwrite  = TRUE
  )
# gdalUtilities::gdalinfo(ndvi_max_diff_vrt)

#-------------------------------------------------------------------------------#
## 2.6 MASK BY FOREST MASK ####
#-------------------------------------------------------------------------------#
# ?gdalraster::calc

# GeoTIFF of NDVI max diff masked by forest / original projection --> WMS
path_ndvi_diff_out_tif <- file.path(path_use_case_1, paste0(ndvi_diff_name, "_Int16.tif"))

# forest_mask: 1 = forest, no data = NA = everything else --> 
# by multiplying with forest_mask everything outside the forest is knock out

t0_mask <- Sys.time()

gdalraster::calc(
  expr         = "ndvi_diff * forest_mask", 
  rasterfiles  = c(
    ndvi_max_diff_vrt,   # virtual dataset
    path_forest_mask_tif # path to GeoTIFF on local drive
  ),
  var.names    = c("ndvi_diff", "forest_mask"),
  dstfile      = path_ndvi_diff_out_tif,
  dtName       = "Int16",
  options      = c("COMPRESS=LZW"),
  write_mode   = "overwrite",
  nodata_value = -32767L, 
  setRasterNodataValue = TRUE
  )

(t_mask <- Sys.time() - t0_mask)  

#===============================================================================#
# 3a REPROJECT (gdalUtilities) #### 
#-------------------------------------------------------------------------------#

# ?gdalUtilities::gdalwarp
path_reproj_unfiltered_tif  <- file.path(tempdir(), "reproj_unfiltered.tif")
t0_repro <-  Sys.time()

gdalUtilities::gdalwarp(
  srcfile = path_ndvi_diff_out_tif, 
  dstfile = path_reproj_unfiltered_tif,
  s_srs   = "EPSG:2056",
  t_srs   = paste0("EPSG:", crs_reproject$epsg),
  r       = "bilinear",
  ot      = "Int16",
  tr      = c("10", "10"),
  overwrite = TRUE
  )

(t_repro <- Sys.time() - t0_repro)

#===============================================================================#
# 3b REPROJECT (gdalraster) #### 
#-------------------------------------------------------------------------------#
# gdalraster::warp() is an alternative to gdalUtilities::gdalwarp(),
# both functions work at about the same speed (comparison made so far with small raster input)

# args <- c(
#   "-s_srs", "EPSG:2056",
#   "-tr", "10", "10",
#   "-ot", "Int16",
#   "-r", "bilinear",
#   "-overwrite"
#   )

# ?gdalraster::warp

# t0_repro <-  Sys.time()
# 
# gdalraster::warp(
#   src_files    = path_ndvi_diff_out_tif,
#   dst_filename = path_reproj_unfiltered_tif,
#   t_srs        = paste0("EPSG:", crs_reproject$epsg),
#   cl_arg       = args
#   )
# 
# (t_repro <- Sys.time() - t0_repro)

#-------------------------------------------------------------------------------#
# 4 FILTER BY THERSHOLD ####
#-------------------------------------------------------------------------------#

# GeoTIFF reprojection --> WMS
tif_reproj <- paste0(ndvi_diff_name, "_Int16_EPSG", crs_reproject$epsg, "_NA-", abs(threshold_poly), ".tif")
path_reproj_tif <- file.path(path_use_case_1, tif_reproj)

t0_th <-  Sys.time()

expr <- paste0("ifelse(ndvi_diff <= ",  threshold_poly, ", ndvi_diff, NA_integer_)")
# expr
gdalraster::calc(
  expr         = expr,
  rasterfiles  = path_reproj_unfiltered_tif,
  var.names    = "ndvi_diff",
  dstfile      = path_reproj_tif,
  dtName       = "Int16",
  options      = c("COMPRESS=LZW"),
  write_mode   = "overwrite",
  nodata_value = -32767L,
  setRasterNodataValue = TRUE
  )

(t_th <- Sys.time() - t0_th)

#===============================================================================#
# 5 FILTER SIEVES #### 
#-------------------------------------------------------------------------------#

t0_sieves <- Sys.time()

# make dichotomy raster, 1 = value =< threshold, else no data = NA
expr <- "ifelse(is.na(filtered_by_th), NA_integer_, 1L)"
# expr
with_sieves_tif <- 
  gdalraster::calc(
    expr         = expr, 
    rasterfiles  = path_reproj_tif,
    var.names    = "filtered_by_th",
    dtName       = "Int16",
    write_mode   = "overwrite",
    nodata_value = -32767L, 
    setRasterNodataValue = TRUE
    )

without_sieves_unfiltered_tif <- file.path(tempdir(), "without_sieves_unfiltered.tif")

# ?gdalraster::rasterFromRaster
gdalraster::rasterFromRaster(
  srcfile = with_sieves_tif,
  dstfile = without_sieves_unfiltered_tif,
  dtName  = "Int16",
  init    = -32767L
  )

# ?gdalraster::sieveFilter
gdalraster::sieveFilter(
  src_filename   = with_sieves_tif,
  src_band       = 1L,
  dst_filename   = without_sieves_unfiltered_tif,
  dst_band       = 1L,
  size_threshold = threshold_n_pixel,
  connectedness  = 4L # 4L or 8L? --> 4L -->
  # diagonal pixels are not considered directly adjacent for polygon membership purposes
  )

expr <- "ifelse(unfiltered == 1L, 1L, NA_integer_)"
# expr
without_sieves_tif <- 
  gdalraster::calc(
    expr         = expr, 
    rasterfiles  = without_sieves_unfiltered_tif,
    var.names    = "unfiltered",
    dtName       = "Int16",
    write_mode   = "overwrite",
    nodata_value = -32767L, 
    setRasterNodataValue = TRUE
    )

(t_sieves <- Sys.time() - t0_sieves)

#===============================================================================#
# 5 POLYGONIZE ####
#-------------------------------------------------------------------------------#

t0_poly <- Sys.time()

# dichotomous raster layer: 1L if raster value =< threshold, else NA (sieve filtered)
diff_mask_stars <- read_stars(without_sieves_tif, proxy = TRUE, quiet = TRUE)

# make grid-cells (retangles) for iterative polygonizing overlapping with swiss territory
ch_boundaries_reproj <- st_transform(ch_boundaries, crs = crs_reproject)
grid <- st_make_grid(diff_mask_stars, cellsize = 2*10^4)[ch_boundaries_reproj]
# plot(grid)
# clip grid-cells by extent of raster-layer
grid <- st_intersection(grid, st_as_sfc(st_bbox(diff_mask_stars))) %>% st_make_valid()
# plot(grid, col = "red", add = TRUE)

dsn_tmp <- file.path(tempdir(), "diff_mask_sf_tmp.gpkg") # tmp. storage for vector data
layer_tmp <- "diff_mask_sf"
# make sure there are no polygons inherited from previous runs in temp. data storage
if(file.exists(dsn_tmp)){st_delete(dsn = dsn_tmp, layer = layer_tmp, quiet = FALSE)}

for(i in seq_len(length(grid))) {
  # make virtual raster within in i-th grid polygon
  vrt_i <- file.path(tempdir(), "i.vrt") # virtual dataset
  gdalUtilities::gdalbuildvrt(
    gdalfile   = without_sieves_tif,
    output.vrt = vrt_i, 
    te         = st_bbox(grid[i]), # bb of i-th grid-polygon
    tr         = c("10", "10"),
    overwrite  = TRUE
  )
  # read raster within in i-th grid polygon into memory 
  diff_mask_stars_i <- read_stars(vrt_i, proxy = FALSE, quiet = TRUE)
  # polygonize if there any raster values but NA 
  if(!all(is.na(diff_mask_stars_i[[1]]))){ 
    diff_mask_sf_i <-
      # polygonize
      st_as_sf(diff_mask_stars_i, merge = TRUE, connect8 = FALSE) %>%
      # fix geometries
      st_make_valid() %>%
      # turn all geometries into multi-polygons ...
      st_cast("MULTIPOLYGON") %>%
      # ... in order to safely convert them all into single polygons
      st_cast("POLYGON", warn = FALSE)
    # make sure attribute and geometry column are always same-named
    names(diff_mask_sf_i)[1]    <- "without_sieves"
    st_geometry(diff_mask_sf_i) <- "geometry"
    # save in tmp. data storage
    st_write(
      diff_mask_sf_i,
      dsn    = dsn_tmp,
      layer  = layer_tmp,
      append = TRUE, # add polygons derived from i-th tile
      quiet  = TRUE
    )
  }
}

# st_layers(dsn_tmp)

diff_mask_sf <-
  # read polygons from tmp data storage
  st_read(dsn = dsn_tmp, layer = layer_tmp, quiet = TRUE) %>%
  # to be save: filter out any polygon not derived from filter sieves (--> s. above FILTER SIEVES)
  dplyr::filter(without_sieves == 1) %>%
  # merge all remaining polygons into 1 surface (multi-polygon)
  st_union() %>%
  # fix geometries
  st_make_valid() %>%
  # split multi-polygon into sub-geometries
  st_cast("POLYGON") %>%
  # turn sfc into sf obj.
  st_sf(geomtetry = .) %>%
  # filter by min. area (min_area --> s. above PARAMETERS)
  dplyr::filter(. , st_area(.) > min_area)

(t_poly <- Sys.time() - t0_poly)

#===============================================================================#
# 6 EXTRAT RASTER STATS ####
#-------------------------------------------------------------------------------#

# read as star proxy max. NDVI difference filter by forest mask & reprojected
ndvi_max_diff <- read_stars(path_reproj_unfiltered_tif, proxy = TRUE, NA_value = NA_integer_, quiet = TRUE)

# check if raster and polygon mask have same CRS
# st_crs(ndvi_max_diff) == st_crs(diff_mask_sf)

# TODO: Ask Hannes if area [m^2] has to be added attribute & if so: -->
# what calculation method: st_area() or countdiff * cell_size^2 ?

t0_extr <-  Sys.time()

new_attributes <-
  # for each polygon calculate mean, sum & max of NDVI-max-composite-diff + count pixels 
  exactextractr::exact_extract(
    x        = terra::rast(ndvi_max_diff),
    y        = diff_mask_sf,
    fun      = c("mean", "sum", "max", "count"),
    progress = FALSE
  ) %>%
  dplyr::transmute(
    # column area [m^2]
    area      = as.integer(round(count)) * 100L,
    # prettify values (raster values were multiplied by 10'000 to be stored as integers)
    meandiff  = round(mean / 10^4, 3),
    sumdiff   = round(sum / 10^4, 3),
    maxdiff   = round(max / 10^4, 3),
    countdiff = as.integer(round(count))
  )

(t_extr <- Sys.time() - t0_extr)

# head(new_attributes)

# add new attribute to polygons
diff_mask_sf <- cbind(diff_mask_sf, new_attributes)

# plot(
#   x = as.numeric(st_area(diff_mask_sf)),
#   y = diff_mask_sf$area,
#   xlab = "area of polygon [m^2]",
#   ylab = "area overlapping rasters filtered by thershold [m^2]"
#   )
# 
# plot(
#   x =  as.numeric(st_area(diff_mask_sf)),
#   y =  as.numeric(st_area(diff_mask_sf)) - diff_mask_sf$area,
#   xlab = "area of polygon [m^2]" ,
#   ylab = "diff of polygon area and area overlapping rasters filtered by thershold  [m^2]"
#   )
# 
# hist(as.numeric(st_area(diff_mask_sf)) - diff_mask_sf$area)
# table((as.numeric(st_area(diff_mask_sf)) - diff_mask_sf$area) > 0) / nrow(diff_mask_sf) * 100
# table((as.numeric(st_area(diff_mask_sf)) - diff_mask_sf$area) > as.numeric(min_area)) / nrow(diff_mask_sf) * 100

#===============================================================================#
# 7 SAVE GPKG ####
#-------------------------------------------------------------------------------#

# GPKG reprojected --> WFS 
layer <- paste0(ndvi_diff_name, "_Int16_EPSG", crs_reproject$epsg, "_NA-", abs(threshold_poly))
# layer # check
dsn <- file.path(path_use_case_1, paste0(layer, ".gpkg"))

t0_gpkg <- Sys.time() 

st_write(
  diff_mask_sf,
  dsn    = dsn,
  layer  = layer,
  append = FALSE, # replace / overwrite existing layer
  quiet  = TRUE
  )

(t_gpkg <- Sys.time() - t0_gpkg)

#===============================================================================#
# RUN TIMES ####
#-------------------------------------------------------------------------------#

t_total <- Sys.time() - t0

t <- c(
  "Google Earth Engine"    = t_GEE,
  "export to Google Drive" = t_ex_GD,
  "export to local drive"  = t_ex_local,
  "mask by forest raster"  = t_mask,
  "filter by threshold"    = t_th,
  x                        = t_repro,
  "sieve filtering"        = t_sieves,
  "polygonize"             = t_poly,
  "extract raster values"  = t_extr,
  "save .gpkg"             = t_gpkg
  )

t <- c(t, "everthing else" = t_total - sum(t), "overall total" = t_total)

repro_name <- paste0("reproject to EGSG ", crs_reproject$epsg)
row_names  <- ifelse(names(t) == "x", repro_name, names(t))

tab_run_times <-
  data.frame(
    as.numeric(t, units = "mins") %>% round(2) ,
    row.names = row_names
  ) %>%
  setNames("run time [min]")
 
path_run_times <- paste0(ndvi_diff_name, "_tab_run_times.RData") %>% file.path(path_use_case_1, .)

save(tab_run_times, file = path_run_times)

#===============================================================================#
# end of script
#===============================================================================#