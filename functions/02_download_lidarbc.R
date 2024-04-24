download_lidarbc <- function(data.path,
                             redownload = FALSE,
                             cores = 6L){
  
  options(timeout = 600)
  
  # Pull index file created
  aoi.index <- list.files(data.path, pattern = "aoi_index", full.names = T) %>%
    st_read()
  
  if(redownload == FALSE){
    ## Remove already downloaded files
    aoi.index <- aoi.index[which(!aoi.index$filename %in% list.files(str_c(data.path,  'las/'))),]
  }
  
  # Double check lookup table and define task numbers
  aoi.index <- aoi.index %>%
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
  clusterExport(cl, c("aoi.index", "data.path"))
  
  pblapply(
    aoi.index$task.no,
    cl = cl,
    FUN = function(j){
      
      tictoc::tic()
      
      # Get tile of interest
      tile <- filter(aoi.index, task.no == j)
      
      # Download las tile
      # try(download.file(tile$file.orig, tile$file.dest, mode = 'wb'), silent = TRUE)
      
      # Check projection by reading in single tile as catalog (faster)
      if(file.exists(tile$file.dest)){
        las.ctg <- readLAScatalog(tile$file.dest)
        opt_independent_files(las.ctg) <- T
        opt_laz_compression(las.ctg) <- T
        opt_output_files(las.ctg) <- tools::file_path_sans_ext(tile$file.dest)
        
        # If projection of "catalog" does not match the specified CRS, read full LAS and repair using EPSG code from index
        if(st_crs(las.ctg) != st_crs(as.numeric(tile$epsg))){
          catalog_apply(las.ctg, function(chunk){
            las <- readLAS(chunk)
            if (lidR::is.empty(las)) return(NULL)
            st_crs(las) = st_crs(as.numeric(tile$epsg))
            return(las)
          })
        }
      }
      
      tictoc::toc()
      
      # Wait 30 seconds between downloads to avoid time out
      Sys.sleep(30)
      
    })
  
  # Stop cluster
  stopCluster(cl)
  
  # Index files
  list.files(str_c(data.path, "las/"), pattern = ".laz$", full.names = T) %>% readLAScatalog() %>% lidR:::catalog_laxindex()
  
  print('Downloads completed for area of interest')

}
