create_CHM <- function(data.path, cores = 6L){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  ctg.norm <- list.files(str_c(data.path, "las/02_norm/"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog()
  
  opt_chunk_buffer(ctg.norm) <- 30
  opt_output_files(ctg.norm) <- str_c(data.path, "chm/by_tile/{ORIGINALFILENAME}")
  opt_chunk_size(ctg.norm) <- 0
  opt_stop_early(ctg.norm) <- FALSE
  
  ## Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  f.chm.tiles <- catalog_apply(ctg.norm, .options = list(automerge = T), function(chunk){
    las <- readLAS(chunk)
    if (lidR::is.empty(las)) return(NULL)
    f.chm <- rasterize_canopy(las, res = 1, pitfree(thresholds = c(0, 10, 20), max_edge = c(0, 1.5))) %>%
      terra::focal(., w = matrix(1, 3, 3), fun = fill.na)
    return(f.chm)
  })
  
  plan(sequential)
}
