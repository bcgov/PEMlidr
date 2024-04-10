repair_lidarbc <- function(data.path, cores = 6L){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  ### Set processing options for cloud-based ops
  options <- list(automerge = TRUE)
  
  ## Drop buffer if there is one
  ctg <- list.files(str_c(data.path, "las/"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog(filter = "-drop_withheld")
  
  ## Readd buffer, set filename, break up tiles, compress, skip errors
  opt_chunk_buffer(ctg) <- 30
  opt_output_files(ctg) <- str_c(data.path, "las/01_retiled/{XCENTER}_{YCENTER}")
  opt_chunk_size(ctg) <- 1000 # Break up tiles for consistent processing
  opt_laz_compression(ctg) <- TRUE
  opt_stop_early(ctg) <- FALSE
  
  ## Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  ## Check projections and remove noisy points (class 7) and outliers (Z < 0)
  ctg_retiled <- catalog_apply(ctg, .options = options, function(chunk){
    las <- readLAS(chunk)
    if (lidR::is.empty(las)) {return(NULL)}
    # if(st_crs(las) != st_crs(3005)){ crs(las) <- 3005 }
    las@data <- las@data %>%
      filter(Classification != 7) %>%
      filter(Z >= 0)
    return(las)
  })
  
  ## End future cores
  plan(sequential)
  
  ## Index files
  lidR:::catalog_laxindex(ctg_retiled)
  
  
}