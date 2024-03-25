setup_CHM <- function(data.path, res = c(1, 5, 10, 20), cores = 6){
  
  init.lines <- str_c("set f_dir=", data.path) %>%
    str_replace(pattern = "/$", replace = "") %>%
    rbind(., str_c("set cores=", as.numeric(cores)), sep = "\n")
  
  chm.create.lines <- read.csv("LAStools_batch_files/base/05_surface_models_CHM.bat",
                               header = FALSE,
                               blank.lines.skip = F)
  
  chm.merge.lines <- data.frame()
  
  for(i in 1:length(res)){
    
    chm.merge.lines.new <- read.csv("LAStools_batch_files/base/06_surface_models_CHM_merge.bat",
                                header = FALSE,
                                blank.lines.skip = F)
    
    new.lines <- chm.merge.lines.new %>%
      filter(str_detect(V1, "res")) %>%
      mutate(V1 = str_replace(V1, "res", as.character(res[i])))
    
    chm.merge.lines.new[grepl("step", chm.merge.lines.new$V1),] <- new.lines[grepl("step", new.lines$V1),]
    chm.merge.lines.new[grepl("CHM_", chm.merge.lines.new$V1),] <- new.lines[grepl("CHM_", new.lines$V1),]
    
    chm.merge.lines = rbind(chm.merge.lines, chm.merge.lines.new)
    
  }

  lines <- rbind(init.lines, chm.create.lines, chm.merge.lines, sep = "\n")
  
  write.table(lines, str_c(data.path, "surface_models_CHM.bat"),
              quote = F,
              col.names = F,
              row.names = F,
              append = F)
  
  return(str_c("CHM batch file written to ", str_c(data.path, "surface_models_CHM.bat")))
  
}
