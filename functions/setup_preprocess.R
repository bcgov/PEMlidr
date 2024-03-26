setup_preprocess <- function(data.path,
                             cores = 6,
                             convert = T,
                             retile = T,
                             normalize = T){
  
  init.lines <- str_c("set f_dir=", data.path) %>%
    str_replace(pattern = "/$", replace = "") %>%
    rbind(., str_c("set cores=", as.numeric(cores)), sep = "\n")
  
  if(convert){
    convert.lines <- read.csv("LAStools_batch_files/base/00_convert_index.bat",
                              header = FALSE,
                              blank.lines.skip = F)
  } else {
    convert.lines = NA_character_
  }
  
  if(retile){
    retile.lines <- read.csv("LAStools_batch_files/base/01_retile_index.bat",
                             header = FALSE,
                             blank.lines.skip = F)
  } else{
    retile.lines = NA_character_
  }
  
  if(normalize){
    norm.lines <- read.csv("LAStools_batch_files/base/02_normalize_index.bat",
                           header = FALSE,
                           blank.lines.skip = F)
  } else{
    norm.lines = NA_character_
  }
  
  lines <- rbind(init.lines, convert.lines, retile.lines, norm.lines, sep = "\n")
  
  
  write.table(lines, str_c(data.path, "LAStools_batch_files/preprocessing.bat"),
              quote = F,
              col.names = F,
              row.names = F,
              append = F)
  
  print("Preprocess batch file complete.")
  return(str_c(data.path, "LAStools_batch_files/preprocessing.bat"))
}
