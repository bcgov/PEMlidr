download_lidarbc <- function(aoi.index, data.path, cores = 6L){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  options(timeout = 600)
  
  ## These will be pulled from the function environment when using the clusterEvalQ function so need to be redefined here
  aoi.index = aoi.index; data.path = data.path
  
  # Make a cluster with a number of cores, closing previous cores if needed
  cl = makeCluster(cores)
  # Load in required packages
  clusterEvalQ(cl, {library(tidyverse); library(sf)})
  # Export variables from global environment into each cluster
  clusterExport(cl, c("aoi.index", "data.path"))
  
  pblapply(
    aoi.index$task.no,
    cl = cl,
    FUN = function(j){
      
      tictoc::tic()
      # Get tile of interest
      tile <- filter(aoi.index, task.no == j)
      # Get URLs
      tile_url <- tile$s3Url
      rpt_url <- tile$acc_rpt_ur
      # Download las tile
      file_dest <- file.path(str_c(data.path,  'las/'), basename(tile_url))
      try(download.file(tile_url, file_dest, mode = 'wb'), silent = TRUE)
      # Download tile accuracy report
      if(is.character(rpt_url)){
        file_dest <- file.path(str_c(data.path,  'report/'), basename(rpt_url))
        try(download.file(rpt_url, file_dest, mode = 'wb'), silent = TRUE)
      }
      tictoc::toc()
      # Wait 30 seconds between downloads to avoid time out
      Sys.sleep(30)
      
    })
  
  # Stop cluster
  stopCluster(cl)
  
  list.files(str_c(data.path, "las/"), pattern = ".laz$", full.names = T) %>% readLAScatalog() %>% lidR:::catalog_laxindex()
  
  print('Downloads completed for area of interest')

}