############################################################
# Delete old files based on date selection
############################################################

cleanup = function(check_path, refdate, timeint, path_vec_delete){
  check_files = list.files(check_path)
  dates_check = as.Date(substring(lapply(strsplit(check_files,"_"), "[[", 3),1,8), format = "%Y%m%d")
  ind = which(dates_check < refdate - timeint)
  
  if (length(ind)>0){
    for (path in path_vec_delete){
      unlink(list.files(path, full.names = T)[ind])
    }
  }
}
