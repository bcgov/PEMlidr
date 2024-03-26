setup_DEM <- function(data.path, res = c(1, 5, 10, 20), cores = 6){
  
  ### Initialize lines with the working directory and desired number of cores
  init.lines <- str_c("set f_dir=", data.path) %>%
    str_replace(pattern = "/$", replace = "") %>%
    rbind(., str_c("set cores=", as.numeric(cores)), sep = "\n")
  
  ### Grab lines for creation of DEM files for each tile as a 1m res .bil
  dem.create.lines <- read.csv("LAStools_batch_files/base/03_surface_models_DEM.bat",
                               header = FALSE,
                               blank.lines.skip = F)
  ### Merge the 1m .bil files into the desired resolution(s)
  dem.merge.lines <- data.frame()
  
  for(i in 1:length(res)){
    ### Get template file
    dem.merge.lines.new <- read.csv("LAStools_batch_files/base/04_surface_models_DEM_merge.bat",
                                header = FALSE,
                                blank.lines.skip = F)
    
    ### Replace the "res" tag with desired resolution
    new.lines <- dem.merge.lines.new %>%
      filter(str_detect(V1, "res")) %>%
      mutate(V1 = str_replace(V1, "res", as.character(res[i])))
    
    dem.merge.lines.new[grepl("step", dem.merge.lines.new$V1),] <- new.lines[grepl("step", new.lines$V1),]
    dem.merge.lines.new[grepl("DEM_", dem.merge.lines.new$V1),] <- new.lines[grepl("DEM_", new.lines$V1),]
    
    ### Append
    dem.merge.lines = rbind(dem.merge.lines, dem.merge.lines.new)
    
  }

  lines <- rbind(init.lines, dem.create.lines, dem.merge.lines, sep = "\n")
  
  write.table(lines, str_c(data.path, "LAStools_batch_files/surface_models_DEM.bat"),
              quote = F,
              col.names = F,
              row.names = F,
              append = F)
  
  print("DEM batch file complete.")
  return(str_c(data.path, "LAStools_batch_files/surface_models_DEM.bat"))
  
}
