normalize_lidarbc <- function(data.path, cores = 6L, keep.existing = FALSE){
  
  data.path = data.path
  
  ## Read new catalog for troubleshooting
  las.index <- list.files(str_c(data.path, "las/"), pattern = ".laz$", full.names = T) %>%
    tibble(filename = .) %>%
    mutate(file.dest = str_replace(filename, pattern = "las/", replacement = "las/normalized/"))
  
  # Check if some tiles are already downloaded?
  # If they are, remove them from the area of interest index
  
  if(keep.existing == FALSE){
    las.index <- las.index[which(!las.index$file.dest %in% list.files(str_c(data.path,  'las/normalized/'), full.names = T)),] %>%
      mutate(task.no = row_number()) %>%
      relocate(task.no, .before = 1)
  } else {
    las.index <- las.index %>%
      mutate(task.no = row_number()) %>%
      relocate(task.no, .before = 1)
  }
  
  # Make a cluster with a number of cores, closing previous cores if needed
  if(exists("cl")){stopCluster(cl); rm(cl)}
  cl = makeCluster(cores)
  # Load in required packages
  clusterEvalQ(cl, {library(tidyverse); library(sf); library(lidR)})
  # Export variables from global environment into each cluster
  clusterExport(cl, c("las.index", "data.path"))
  
  pblapply(
    las.index$task.no,
    cl = cl,
    FUN = function(j){
      
      tictoc::tic()
      
      # Get tile of interest
      tile <- filter(las.index, task.no == j)
      
      # Read LAS file and skip if empty, then filter
      las <- readLAS(tile$filename)
      if (lidR::is.empty(las)) return(NULL)
      las@data <- las@data %>%
        filter(Classification != 7) %>%
        filter(Z >= 0)
      
      # Normalize height
      normalize_height(las, tin()) %>%
        writeLAS(., tile$file.dest, index = TRUE)
      
      tictoc::toc()
      # Wait 30 seconds between downloads to avoid time out
      Sys.sleep(30)
      
    })
  
  # Stop cluster
  stopCluster(cl)
  
  print('Normalized tiles completed')

}
