############################################################
# Function for automatic calculation of NBR-NDVI max composites 
############################################################

build_composite_stack = function(main_path, out_path, tile="T32TMT", year="2017", ref_date=as.Date("2017-08-09"), time_int_nbr=5, time_int_refstack=45){
  
  # load packages
  library(raster)
  library(foreach)
  library(doParallel)
  
  # source functions
  source("//home/eaa2/Digital-Forest-Monitoring/methods/general/calc_veg_indices.R")
  source("//home/eaa2/Digital-Forest-Monitoring/methods/general/calc_max_composite.R")
  source("//home/eaa2/Digital-Forest-Monitoring/methods/general/dir_exists_create_func.R")
  source("//home/eaa2/Digital-Forest-Monitoring/methods/general/cleanup_files.R")

  # paths
  stack_path = paste(main_path,tile,"/",year,"/", sep="")
  out_path = dir_exist_create(out_path,paste(tile,"/",sep=""))
  out_path = dir_exist_create(out_path,paste(year,"/",sep=""))
  nbr_path = dir_exist_create(out_path,"nbr/")
  nbr_raw_path = dir_exist_create(out_path,"nbr_raw/")
  ndvi_raw_path = dir_exist_create(out_path,"ndvi_raw/")
  comp_path = dir_exist_create(out_path,"nbr_comp/")
  diff_path = dir_exist_create(out_path,"nbr_diff/")
  
  # filter files and dates
  B8Names = list.files(stack_path, pattern="B08_10m", recursive=T)
  dates_all = as.Date(substring(lapply(strsplit(B8Names,"_"), "[[", 3),1,8), format = "%Y%m%d")
  nbr_files = list.files(nbr_path)
  dates_nbr = as.Date(substring(lapply(strsplit(nbr_files,"_"), "[[", 3),1,8), format = "%Y%m%d")
  
  #dates_todo = which(dates_all > max(dates_nbr))
  dates_todo = which((dates_all <= ref_date) & (dates_all >= ref_date-time_int_nbr))
  
  if (length(dates_todo)>0 & length(list.files(comp_path))<length(nbr_files)){
    
    # register for parallel processing
    cl = makeCluster(detectCores() -1)
    registerDoParallel(cl)
  
    # build NBR-NDVImax composite stack
    comp_stk = foreach(i=length(dates_todo):1, .packages = c("raster"), .combine = "addLayer") %dopar% {
  
      # define dates within time interval
      date_to_do = as.Date(substring(lapply(strsplit(B8Names[i],"_"), "[[", 3),1,8), format = "%Y%m%d")
      ind_dates = which((dates_all <= date_to_do) & (dates_all >= date_to_do - time_int_refstack))
      dates_for_comp = gsub("-","",dates_all[ind_dates])
  
      # call calc_pixel_comp function
      source("//home/eaa2/Digital-Forest-Monitoring/methods/general/calc_veg_indices.R")
      source("//home/eaa2/Digital-Forest-Monitoring/methods/general/calc_max_composite.R")
      ndvi_stk = calc_veg_indices (stack_path, "B04_10m", "B08_10m", stk1 = NULL, stk2 = NULL, ndvi_raw_path, dates_for_comp, veg_ind="NDVI", tilename=tile, ext=NULL)
  
      names8 = list.files(stack_path, pattern="B08_10m", recursive=T, full.names=T)
      names12 = list.files(stack_path, pattern="B12_20m", recursive=T, full.names=T)
      names8 = names8[grepl(paste(dates_for_comp, collapse="|"), names8)]
      names12 = names12[grepl(paste(dates_for_comp, collapse="|"), names12)]
      nbr_stk = calc_veg_indices (NULL, NULL, NULL, stk1 = stack(names8), stk2 = disaggregate(stack(b12),2), nbr_raw_path, dates_for_comp, veg_ind="NBR", tilename=tile, ext=NULL)
  
      ind_ras = calc_max_composite (stack_path=NULL, stk=ndvi_stk, dates=NULL, ext=NULL, calc_max=F, calc_ind=T)
  
      comp_tmp = stackSelect(nbr_stk, ind_ras)
  
      comp_tmp_name = paste(tile, "_NBR_comp_", dates_for_comp[1], "_", dates_for_comp[length(dates_for_comp)], sep="")
      writeRaster(comp_tmp, paste(comp_path,comp_tmp_name,".tif",sep=""), overwrite=T)
  
      return(comp_tmp)
    }
    stopCluster(cl)
    
    # delete files if necessary
    cleanup (nbr_raw_path, refdate = ref_date, timeint = time_int_nbr + time_int_refstack, path_vec_delete = c(nbr_raw_path, ndvi_raw_path))
    cleanup (nbr_path, refdate = ref_date, timeint = time_int_nbr, path_vec_delete = c(nbr_path, comp_path, diff_path))
    
    return(comp_stk)
  }
}