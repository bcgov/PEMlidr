create_CHM <- function(data.path, cores = 6L){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  ### Start with loading in the non-normalized tiles
  
  ctg_norm <- list.files(str_c(data.path, "las/02_norm/"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog()
  
  # Set the global CRS for the catalog
  if(is.na(crs(ctg_norm))){crs(ctg_norm) <- 3005}
  
  opt_chunk_buffer(ctg_norm) <- 30
  opt_output_files(ctg_norm) <- str_c(data.path, "chm/by_tile/{ORIGINALFILENAME}")
  opt_chunk_size(ctg_norm) <- 0 # Maintain tile size as they were retiled before
  opt_stop_early(ctg_norm) <- FALSE
  
  ctg_norm@data %<>% mutate(file.check = str_replace(filename, pattern = "las\\\\02_norm", replacement = "chm\\\\by_tile"),
                            file.check = str_replace(file.check, pattern = ".laz", replacement = ".tif"),
                            file.check = file.exists(file.check)) %>%
    filter(file.check == F)
  
  ## Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  chm_tiles <- catalog_apply(ctg_norm, .options = list(automerge = T), function(chunk){
    las <- readLAS(chunk)
    if (lidR::is.empty(las)) return(NULL)
    chm <- rasterize_canopy(las, res = 1, pitfree(thresholds = c(0, 10, 20), max_edge = c(0, 1.5)))
    f.chm <- terra::focal(chm, w = matrix(1, 3, 3), fun = fill.na)
    return(list(chm, f.chm))
  })
  
  
  
  plan(sequential)
}
