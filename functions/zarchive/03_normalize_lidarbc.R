normalize_lidarbc <- function(data.path, cores = 6L, redownload = FALSE){
  
  norm.index <- list.files(str_c(data.path, "las"), pattern = ".laz$", full.names = TRUE) %>%
    tibble(file.orig = .) %>%
    mutate(file.dest = str_replace(file.orig, pattern = "las/", replacement = "las/normalized/"))
  
  if(redownload == FALSE){
    ## Remove already normalized
    norm.index <- norm.index[which(!norm.index$file.dest %in% list.files(str_c(data.path,  'las/normalized'), pattern = ".laz$", full.names = TRUE)),]
  }

  # PARALLEL SECTION --------------------------------------------------------

  # Double check lookup table and define task numbers
  norm.index <- norm.index %>%
    mutate(task.no = row_number()) %>%
    relocate(task.no, .before = 1)
  # Redefine global vars if needed
  data.path = data.path
  # Make a cluster with a number of cores, closing previous cores if needed
  if(exists("cl")){stopCluster(cl); rm(cl)}
  cl = makeCluster(cores)
  # Load in required packages
  clusterEvalQ(cl, {library(tidyverse); library(sf); library(lidR)})
  # Export variables from global environment into each cluster
  clusterExport(cl, c("norm.index", "data.path"))
  
  pblapply(
    norm.index$task.no,
    cl = cl,
    FUN = function(j){
      
      tictoc::tic()
      
      # Get tile of interest
      tile <- filter(norm.index, task.no == j)
      
      # Read LAS file
      las <- readLAS(tile$file.orig) %>% filter_duplicates()
      # Skip if empty
      if (lidR::is.empty(las)){
        return(NULL)
      }
      
      # Remove noise and reclass unusual classes to unclassed
      las@data <- las@data %>%
        filter(Z >= 0) %>% ## Filter low points
        mutate(Classification = as.integer(Classification)) %>%
        filter(Classification != 7) %>% # Filter noise points
        mutate(Classification = case_when(as.integer(Classification) == 17 ~ 1L,
                                          as.integer(Classification) == 5 ~ 1L,
                                          TRUE ~ Classification))
      
      # Skip if there are too few points after removing noise
      if(nrow(las@data) < 100){
        return(NULL)
      }
      
      # Check for ground classification
      if(nrow(filter(las@data, Classification == 2)) < 100){
        las.uncl <- las
        # las.uncl@data <- las@data %>% filter(Classification == 1)
        ws <- seq(3, 12, 3); th <- seq(0.1, 1.5, length.out = length(ws))
        las.gnd <- classify_ground(las.uncl, algorithm = pmf(ws = ws, th = th))
        las@data <- las.gnd@data %>%
          dplyr::select(c(X, Y, Z, Classification)) %>%
          left_join(las@data, ., by = c("X", "Y", "Z")) %>%
          mutate(Classification = as.integer(Classification.y)) %>%
          select(!c(Classification.x, Classification.y))
      }
      
      # Normalize height
      normalize_height(las, tin()) %>%
        writeLAS(., tile$file.dest, index = TRUE)
      
      tictoc::toc()
      # Wait 30 seconds between downloads to avoid time out
      Sys.sleep(30)
      
    })
  
  # Stop cluster
  stopCluster(cl)
  
  # PARALLEL SECTION --------------------------------------------------------
  
  print('Normalized tiles completed')

}
