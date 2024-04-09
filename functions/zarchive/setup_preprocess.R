setup_preprocess <- function(data.path,
                             cores = 6,
                             convert = T,
                             retile = T,
                             normalize = T){
  
  init.lines <- str_c("set f_dir=", data.path) %>%
    str_replace(pattern = "/$", replace = "") %>%
    str_replace_all(pattern = "/", replace = "\\\\") %>%
    rbind(., str_c("set cores=", as.numeric(cores)), sep = "\n")
  
    convert.lines <- read.csv("LAStools_batch_files/base/00_convert_index.bat",
                              header = FALSE,
                              blank.lines.skip = F)

    retile.lines <- read.csv("LAStools_batch_files/base/01_retile_index.bat",
                             header = FALSE,
                             blank.lines.skip = F)
  
    norm.lines <- read.csv("LAStools_batch_files/base/02_normalize_index.bat",
                           header = FALSE,
                           blank.lines.skip = F)
    if(!convert){
      
      convert.lines <- vector()
      
      fix.source.folder <- retile.lines %>%
        filter(str_detect(V1, "00_converted")) %>%
        mutate(V1 = str_replace(V1, "\\\\00_converted", ""))
      
      retile.lines[grepl("00_converted", retile.lines$V1),] <- fix.source.folder
      
    }
    
    if(!retile){
      
      retile.lines <- vector()
      
      fix.source.folder <- norm.lines %>%
        filter(str_detect(V1, "01_retiled")) %>%
        mutate(V1 = str_replace(V1, "\\\\01_retiled", ""))
      
      norm.lines[grepl("01_retiled", norm.lines$V1),] <- fix.source.folder
    }
    
    
  lines <- rbind(init.lines, convert.lines,"\n", retile.lines, "\n", norm.lines, "\npause")
  
  
  write.table(lines, str_c(data.path, "LAStools_batch_files/preprocessing.bat"),
              quote = F,
              col.names = F,
              row.names = F,
              append = F)
  
  print("Preprocess batch file complete.")
  return(str_c(data.path, "LAStools_batch_files/preprocessing.bat"))
}
