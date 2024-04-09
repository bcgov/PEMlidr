normalize_lidarbc <- function(data.path, cores = 6L){
  
  ## Read new catalog for troubleshooting
  ctg_retiled <- list.files(str_c(data.path, "las/01_retiled"), pattern = ".laz$", full.names = T) %>%
    readLAScatalog()
  
  ## Set options for new catalog
  opt_chunk_buffer(ctg_retiled) <- 30
  opt_chunk_size(ctg_retiled) <- 0 # Maintain tile size as they were retiled before
  opt_laz_compression(ctg_retiled) <- TRUE
  opt_output_files(ctg_retiled) <- str_c(data.path, "las/02_norm/{ORIGINALFILENAME}")
  opt_stop_early(ctg_retiled) <- FALSE
  
  ctg_retiled@data %<>% mutate(file.check = file.exists(str_replace(filename, pattern = "01_retiled", replacement = "02_norm"))) %>%
    filter(file.check == F)
  
  ## Start future cores
  plan(multisession, workers = cores)
  set_lidr_threads(cores)
  
  ctg_normalized <-  catalog_apply(ctg_retiled, .options = options, function(chunk){
    las <- readLAS(chunk)
    if (lidR::is.empty(las)) return(NULL)
    las_norm <- normalize_height(las, tin())
    las_norm@data <- las_norm@data %>% filter(Z >= 0 & Z < 100) ## Filter again for high outliers
    return(las_norm)})
  
  ## End future cores
  plan(sequential) 
  
  ## Index files
  lidR:::catalog_laxindex(ctg_normalized)
}
