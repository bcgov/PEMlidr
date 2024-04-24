create_DEM <- function(data.path, cores = 6L){
  
  ### Start with loading in the non-normalized tiles

  ctg <- list.files(str_c(data.path, "las/"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog(filter = "-drop_withheld")
  
  opt_chunk_buffer(ctg) <- 30
  opt_output_files(ctg) <- str_c(data.path, "dem/by_tile/{ORIGINALFILENAME}")
  opt_chunk_size(ctg) <- 0
  opt_stop_early(ctg) <- FALSE
  opt_restart(ctg) <- 673
  
  # Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  catalog_apply(ctg, function(chunk){
    # Read in chunk
    las <- readLAS(chunk)
    # Return if empty
    if(lidR::is.empty(las)) return(NULL)
    # Filter noise and low points
    las@data <- las@data %>%
      filter(Classification != 7) %>%
      filter(Z >= 0)
    
    # Skip if there are too few points after removing noise
    if(nrow(las@data) < 100) return(NULL)
    
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
    
    # Rasterize terrain and write to files/
    dem <- rasterize_terrain(las, res = 1, algorithm = tin())
    return(dem)
    })
  
  plan(sequential)
  
}
