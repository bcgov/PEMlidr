create_DEM <- function(data.path, cores = 6L){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  ### Start with loading in the non-normalized tiles

  ctg_prepro <- list.files(str_c(data.path, "las/01_retiled/"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog()
  
  # Set the global CRS for the catalog
  if(is.na(crs(ctg_prepro))){crs(ctg_prepro) <- 3005}
  
  opt_chunk_buffer(ctg_prepro) <- 30
  opt_output_files(ctg_prepro) <- str_c(data.path, "dem/by_tile/{ORIGINALFILENAME}")
  opt_chunk_size(ctg_prepro) <- 0 # Maintain tile size as they were retiled before
  opt_stop_early(ctg_prepro) <- FALSE
  
  ctg_prepro@data %<>% mutate(file.check = str_replace(filename, pattern = "las\\\\01_retiled", replacement = "dem\\\\by_tile"),
                           file.check = str_replace(file.check, pattern = ".laz", replacement = ".tif"),
                           file.check = file.exists(file.check)) %>%
    filter(file.check == F)
  
  # Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  dem_tiles <- catalog_apply(ctg_prepro, .options = list(automerge = T), function(chunk){
    las <- readLAS(chunk)
    if (lidR::is.empty(las)) return(NULL)
    dem <- rasterize_terrain(las, res = 1, algorithm = tin())
    return(dem)
    })
  
  plan(sequential)
  
}
