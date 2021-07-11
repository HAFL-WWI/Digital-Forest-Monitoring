############################################################
# Function for automatic calculation of NBR differences (with NDVI max archive)
#
# by Alexandra Erbach, HAFL, BFH
############################################################

calc_nbr_differences = function(main_path, out_path, tile="T32TMT", year="2021", ref_date=as.Date("2021-06-23"), time_int_nbr, time_int_refstack, cloud_vec=c(3,7:10), cloud_value=-999, nodata_vec=c(0:2,5,6,11), nodata_value=-555){
  
  # load packages
  library(raster)
  library(doParallel)
  library(velox)
  
  # source functions
  source("general/dir_exists_create_func.R")
  source("use-case2/calc_diff.R")
  source("general/cleanup_files.R")
  
  # paths
  stack_path = paste(main_path, substr(tile,2,6),"/",year,"/", sep="")
  out_path = dir_exist_create(out_path,paste(tile,"/",sep=""))
  out_path = dir_exist_create(out_path,paste(year,"/",sep=""))
  nbr_raw_path = dir_exist_create(out_path,"nbr_raw/")
  ndvi_raw_path = dir_exist_create(out_path,"ndvi_raw/")
  nbr_path = dir_exist_create(out_path,"nbr/")
  comp_path = dir_exist_create(out_path,"nbr_comp/")
  diff_path = dir_exist_create(out_path,"nbr_diff/")
  
  # filter files and dates
  B8Names = list.files(stack_path, pattern="B08_10m", recursive=T)
  dates_all = as.Date(substring(lapply(strsplit(B8Names,"_"), "[[", 3),1,8), format = "%Y%m%d")
  nbr_files = list.files(nbr_path)
  dates_nbr = as.Date(substring(lapply(strsplit(nbr_files,"_"), "[[", 3),1,8), format = "%Y%m%d")
  
  #dates_todo = which(dates_all > max(dates_nbr))
  dates_todo = which((dates_all <= ref_date) & (dates_all >= ref_date-time_int_nbr))
  
  if (length(dates_todo)>0){
    
    B8Names = B8Names[dates_todo]
    filesB8 = B8Names
    B8Names = paste(stack_path, B8Names, sep="")
    B12Names = list.files(stack_path, pattern="B12_20m", recursive=T, full.names = T)[dates_todo]
    sclNames = list.files(stack_path, pattern="SCL_20m", recursive=T, full.names = T)[dates_todo]
    
    # register for paralell processing
    print("starting multi-core processing, calculating masked NBRs...")
    cl = makeForkCluster(detectCores() -1)
    registerDoParallel(cl)
    
    # build NBR stack & save NDVIs & NBRs
    nbr_stk = foreach(i=length(dates_todo):1, .packages = c("raster", "velox"), .combine = "addLayer", .inorder = F) %dopar% {
      
      if (length(grep(gsub("-","",dates_all[dates_todo[i]]), nbr_files))<1){
        
        # calculate indices
        b8 = raster(B8Names[i])
        b12 = disaggregate(raster(B12Names[i]),2)
        scl = disaggregate(raster(sclNames[i]),2)
        
        # majority filter on scl
        scl_cl = scl
        scl_cl[scl_cl %in% nodata_vec] = nodata_value
        scl_cl[scl_cl %in% cloud_vec] = cloud_value
        scl_vx = velox(scl_cl)
        scl_vx$medianFocal(wrow=5, wcol=5, bands=1)
        scl_vx = scl_vx$as.RasterLayer()
        
        # calculate nbr
        nbr_tmp = (b8 - b12)/(b8 + b12)
        nbr_tmp = round(nbr_tmp*100)
        rm(b8,b12,scl)
        
        # mask nodata
        nbr_tmp[scl_vx == nodata_value] = nodata_value
        
        # mask clouds and create buffer
        cloud_ras = scl_vx == cloud_value
        vx = velox(cloud_ras)
        vx$sumFocal(weights=matrix(1,11,11), bands=1) # should be input parameter in function
        cloud_ras = vx$as.RasterLayer()
        nbr_tmp[cloud_ras > 0] = cloud_value
        rm(cloud_ras)
        
        nbr_tmp_name = paste(tile, "_NBRc_", substring(lapply(strsplit(filesB8[i],"_"), "[[", 3),1,8), sep="")
        writeRaster(nbr_tmp, paste(nbr_path,nbr_tmp_name,".tif",sep=""), overwrite=T, datatype='INT2S')
      }
      nbr_files = list.files(nbr_path)
      nbr_tmp = raster(list.files(nbr_path,full.names=T)[grep(gsub("-","",dates_all[dates_todo[i]]), nbr_files)])
      return(nbr_tmp)
    }
    names(nbr_stk) = substring(lapply(strsplit(filesB8[nlayers(nbr_stk):1],"_"), "[[", 3),1,8)
    
    stopCluster(cl)
    gc(verbose = F)
    
    # get composite stack
    comp_stk = stack(rev(list.files(comp_path, full.names=T)))[[1:length(dates_todo)]]
    names(comp_stk) = lapply(strsplit(names(comp_stk),"_"), "[[", 5)
    
    # calculate NBR difference raster(s) and return stack
    diff_stk = calc_diff (nbr_stk, comp_stk, cloud_value, nodata_value, out_path = diff_path, tile)
    
    rm(nbr_stk, comp_stk)
    
    # delete files if necessary
    cleanup (nbr_path, refdate = ref_date, timeint = time_int_nbr, path_vec_delete = nbr_path, split_ind = 3)
    cleanup (diff_path, refdate = ref_date, timeint = time_int_nbr, path_vec_delete = diff_path, split_ind = 4)
    
    return(diff_stk)
    } 
}