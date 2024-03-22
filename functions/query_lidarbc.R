# ------------------------------------------------------------------------------
#
# Script created by Liam Irwin, November 4 2022, Contact: lakirwin@mail.ubc.ca
#
# ------------------------------------------------------------------------------

query_lidarbc <- function(aoi, index, data.path, cores = 3){
  
  # Does AOI CRS match LidarBC Index?
  if(sf::st_crs(aoi) != sf::st_crs(index)){
    aoi <- sf::st_transform(aoi, sf::st_crs(index))
    print('Transformed area of interest CRS')
  }
  
  # Extract intersecting polygons of aoi and LidarBC index
  aoi_index <- sf::st_intersection(index, aoi) %>% st_drop_geometry()
  
  # Create directories for downloading if they do not exist
  
  if(!exists("data.path",  envir = environment())){
    return(print("Did you define the data path?"))
  }
  
  las_dir <- str_c(data.path,  'las/')
  rpt_dir <- str_c(data.path, 'report/')
  
  # Check if some tiles are already downloaded?
  # If they are, remove them from the area of interest index
  aoi_index <- aoi_index[which(!aoi_index$filename %in% list.files(las_dir)),] %>%
    mutate(task.no = row_number()) %>%
    relocate(task.no, .before = 1)
  
  print(str_c('Beginning download of ', 
               nrow(aoi_index), ' lidar point cloud tiles from LidarBC'))
  
  options(timeout=600)
  
  # Make a cluster with a number of cores, closing previous cores if needed
  if(exists("cl",  envir = environment())){stopCluster(cl)}
  cl = makeCluster(cores)
  # Load in required packages
  clusterEvalQ(cl, {library(tidyverse); library(sf)})
  # Export variables from global environment into each cluster
  clusterExport(cl, c("aoi_index", "las_dir"))
  
  
  pblapply(
    aoi_index$task.no,
    cl = cl,
    FUN = function(j){
      
      tictoc::tic()
      # Get tile of interest
      tile <- filter(aoi_index, task.no == j)
      # Get URLs
      tile_url <- tile$s3Url
      rpt_url <- tile$acc_rpt_ur
      # Download las tile
      file_dest <- file.path(las_dir, basename(tile_url))
      try(download.file(tile_url, file_dest, mode = 'wb'), silent = TRUE)
      # Download tile accuracy report
      if(is.character(rpt_url)){
        file_dest <- file.path(rpt_dir, basename(rpt_url))
        try(download.file(rpt_url, file_dest, mode = 'wb'), silent = TRUE)
      }
      tictoc::toc()
      # Wait 30 seconds between downloads to avoid time out
      Sys.sleep(30)
      
    })
  
  # Stop cluster
  stopCluster(cl)
  
  print('Downloads completed for area of interest')

}

query_lidarbc(aoi = aoi, index = index, data.path = data.path)






