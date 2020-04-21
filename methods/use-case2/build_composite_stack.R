############################################################
# Function for automatic calculation of NBR-NDVI max composites 
############################################################

build_composite_stack = function(main_path, out_path, tile="T32TLT", year="2017", ref_date=as.Date("2017-08-19"), time_int_nbr=45, time_int_refstack=45, thr=0.99){
  
  # load packages
  library(raster)
  library(doParallel)
  
  # source functions
  source("general/dir_exists_create_func.R")
  source("general/cleanup_files.R")
  source("general/calc_veg_indices.R")
  
  # paths
  stack_path = paste(main_path, substr(tile,2,6),"/",year,"/", sep="")
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
  comp_files = list.files(comp_path)
  dates_comp = as.Date(substring(lapply(strsplit(comp_files,"_"), "[[", 5),1,8), format = "%Y%m%d")
  
  #dates_todo = which(dates_all > max(dates_comp))
  dates_todo = which((dates_all <= ref_date) & (dates_all >= ref_date-time_int_nbr))
  
  if (length(dates_todo)>0){
    
    # define dates within time interval
    date_to_do = as.Date(substring(lapply(strsplit(B8Names[dates_todo[length(dates_todo)]],"_"), "[[", 3),1,8), format = "%Y%m%d")
    date_to_do_start = as.Date(substring(lapply(strsplit(B8Names[dates_todo[1]],"_"), "[[", 3),1,8), format = "%Y%m%d")
    ind_dates = which((dates_all <= date_to_do) & (dates_all >= date_to_do_start - time_int_refstack))
    dates_for_comp = gsub("-","",dates_all[ind_dates])
    
    b8 = list.files(stack_path, pattern="B08_10m", recursive=T, full.names=T)
    b8 = b8[grepl(paste(dates_for_comp, collapse="|"), b8)]
    b12 = list.files(stack_path, pattern="B12_20m", recursive=T, full.names=T)
    b12 = b12[grepl(paste(dates_for_comp, collapse="|"), b12)]
    b4 = list.files(stack_path, pattern="B04_10m", recursive=T, full.names=T)
    b4 = b4[grepl(paste(dates_for_comp, collapse="|"), b4)]
    
    stk_b8 = stack(b8)
    stk_b4 = stack(b4)
    
    ndvi_stk = calc_veg_indices (stk_1 = stk_b8, stk_2 = stk_b4, ndvi_raw_path, dates_for_comp, veg_ind="NDVI", tilename=tile, ext=NULL, thr=thr)
    rm(stk_b4)
    stk_b12 = disaggregate(stack(b12),2)
    nbr_stk = calc_veg_indices (stk_1 = stk_b8, stk_2 = stk_b12, nbr_raw_path, dates_for_comp, veg_ind="NBR", tilename=tile, ext=NULL, thr=thr)
    
    rm(stk_b8, stk_b12)
    gc(verbose = F)
    
    # register for parallel processing
    cl = makeForkCluster(detectCores() -1)
    registerDoParallel(cl)
    
    # build NBR-NDVImax composite stack
    comp_stk = foreach(i=length(dates_todo):1, .packages = c("raster"), .combine = "addLayer", .inorder = F) %dopar% {
      
      source("general/calc_max_composite.R")
      
      date_to_do = as.Date(substring(lapply(strsplit(B8Names[dates_todo[i]],"_"), "[[", 3),1,8), format = "%Y%m%d")
      ind_dates = which((dates_all <= date_to_do) & (dates_all >= date_to_do - time_int_refstack))
      dates_for_comp = gsub("-","",dates_all[ind_dates])
      start_ind = grep(dates_for_comp[1], names(ndvi_stk))
      end_ind = grep(dates_for_comp[length(dates_for_comp)], names(ndvi_stk))
      
       # call calc_pixel_comp function
      ind_ras = calc_max_composite (vi_stk=ndvi_stk[[start_ind:end_ind]], ext=NULL, calc_max=F, calc_ind=T)
      
      # only for testing, to be removed later
      #writeRaster(ind_ras, paste(out_path,"ind_test/ind", dates_for_comp[length(dates_for_comp)],".tif",sep=""), overwrite=T)
      
      comp_tmp = stackSelect(nbr_stk[[start_ind:end_ind]], ind_ras)
      rm(ind_ras)
      
      comp_tmp_name = paste(tile, "_NBR_comp_", dates_for_comp[1], "_", dates_for_comp[length(dates_for_comp)], sep="")
      writeRaster(comp_tmp, paste(comp_path,comp_tmp_name,".tif",sep=""), overwrite=T, datatype='INT2S')
      
      return(comp_tmp)
    }
    stopCluster(cl)
    
    rm(ndvi_stk, nbr_stk, comp_stk)
   
    # delete files if necessary
    cleanup (ndvi_raw_path, refdate = ref_date, timeint = time_int_nbr + time_int_refstack, path_vec_delete = c(nbr_raw_path, ndvi_raw_path), split_ind = 3)
    cleanup (comp_path, refdate = ref_date, timeint = time_int_nbr, path_vec_delete = comp_path, split_ind = 5)
    
    gc(verbose = F)
    # return(comp_stk)
  }
}