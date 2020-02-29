dir_exist_create = function(main_dir, sub_dir){
  
  output_dir = paste(main_dir,sub_dir,sep="")
  
  if (!dir.exists(output_dir)){
    dir.create(output_dir)
  } 
  return(output_dir)
}