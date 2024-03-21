# ------------------------------------------------------------------------------
#
# Script created by Liam Irwin, November 4 2022, Contact: lakirwin@mail.ubc.ca
#
# Downloading LidarBC tiles programmatically with R
# 
# To use this script you must first; get the tile index layer from LidarBC
# 
# 1. Navigate to LidarBC Map Grid 
# https://governmentofbc.maps.arcgis.com/home/item.html?id=5f6a1f31212a4cb2826743d2e52ef02a
# 2. Select Open in ArcGIS Desktop -> Open in ArcGIS Pro
# 3. Double click item.pitemx file to open in ArcGIS
# 4. Download point cloud index layer eg Point Cloud Index  - 1:2,500 Grid
# 5. Right click -> Data -> Export Features -> Save as SHP 
# 
# Using the script
# 
# 1. Read in the point cloud index grid from the URL above as index
# 2. Read in your area of interest (where you want tiles) as aoi
# 3. run the query_lidarbc function with your
# 4. Enjoy your lidar data
# ------------------------------------------------------------------------------

library(sf)
require(tidyverse)
require(lidR)
require(pbapply)
require(future)
require(parallel)

data.path <- "D:/Kitimat_LiDAR/"

# Load area of interest polygon

aoi <- sf::st_read(str_c(data.path, "AOI/Kitimat_PEM_AOI.shp"))

# Load lidarBC point cloud index map grid

index <- sf::st_read('shapefiles/las_index_nov2022.shp')

# Save function to memory

query_lidarbc <- function(aoi, index, cores){
 
  print('Lidar index last updated November 2022')
  
  # Does AOI CRS match LidarBC Index?
  if(sf::st_crs(aoi) != sf::st_crs(index)){
    aoi <- sf::st_transform(aoi, sf::st_crs(index))
    print('Transformed area of interest CRS')
  }
  
  # Extract intersecting polygons of aoi and LidarBC index
  aoi_index <- sf::st_intersection(index, aoi) %>% st_drop_geometry()
  
  # Create directories for downloading if they do not exist
  dl_dir <- paste0(data.path,'lidarbc-aoi-', Sys.Date())
  las_dir <- paste0(dl_dir, '/las')
  rpt_dir <- paste0(dl_dir, '/report')
  dir.create(dl_dir, showWarnings = FALSE)
  dir.create(las_dir, showWarnings = FALSE)
  dir.create(rpt_dir, showWarnings = FALSE)
  
  # Check if some tiles are already downloaded?
  # If they are, remove them from the area of interest index
  aoi_index <- aoi_index[which(!aoi_index$filename %in% list.files(las_dir)),] %>%
    mutate(task.no = row_number()) %>%
    relocate(task.no, .before = 1)
  
  print(paste0('Beginning download of ', 
               nrow(aoi_index), ' lidar point cloud tiles from LidarBC'))
  
  options(timeout=600)
  
  # Make a cluster with a number of cores
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

# Call function to download your tiles
# Arguments: 
# aoi = area of interset (loaded as sf object above)
# shps = directory to shapefiles with LidarBC map tiles

query_lidarbc(aoi = aoi, index = index, cores = 6)





