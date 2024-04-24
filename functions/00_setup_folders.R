
setup_folders <- function(data.path){
  
  path <- c(str_c(data.path, "las/"),
            str_c(data.path, "las/", "01_retiled/"),
            str_c(data.path, "las/", "02_norm/"),
            str_c(data.path, "chm/"),
            str_c(data.path, "chm/", "by_tile/"),
            str_c(data.path, "dem/"),
            str_c(data.path, "dem/", "by_tile/"),
            str_c(data.path, "metrics/"),
            str_c(data.path, "metrics/", "by_tile/"),
            str_c(data.path, "LAStools_batch_files/"))
  
  for(i in 1:length(path)){
    if(!dir.exists(path[i])){
      dir.create(path[i])
    }
  }
  
  print("Setup of folders completed.")
}

