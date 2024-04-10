create_DEM <- function(data.path, cores = 6L){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  ### Start with loading in the non-normalized tiles

  ctg <- list.files(str_c(data.path, "las/"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog(filter = "-drop_withheld")
  
  opt_chunk_buffer(ctg) <- 30
  opt_output_files(ctg) <- str_c(data.path, "dem/by_tile/{ORIGINALFILENAME}")
  opt_chunk_size(ctg) <- 0 # Maintain tile size as they were retiled before
  opt_stop_early(ctg) <- FALSE
  
  # ctg@data %<>% mutate(file.check = str_replace(filename, pattern = "las", replacement = "dem\\\\by_tile"),
  #                          file.check = str_replace(file.check, pattern = ".laz", replacement = ".tif"),
  #                          file.check = file.exists(file.check)) %>%
  #   filter(file.check == F)
  
  # Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  dem_tiles <- catalog_apply(ctg, .options = list(automerge = T), function(chunk){
    las <- readLAS(chunk)
    if (lidR::is.empty(las)) return(NULL)
    las@data <- las@data %>%
      filter(Classification != 7) %>%
      filter(Z >= 0)
    dem <- rasterize_terrain(las, res = 1, algorithm = tin())
    return(dem)
    })
  
  plan(sequential)
  
}
