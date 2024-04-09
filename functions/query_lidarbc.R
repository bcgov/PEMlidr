# ------------------------------------------------------------------------------
#
# Script created by Liam Irwin, November 4 2022, Contact: lakirwin@mail.ubc.ca
#
# ------------------------------------------------------------------------------

query_lidarbc <- function(aoi, index, data.path, keep.geometry = FALSE, keep.existing = FALSE){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
  }
  
  # Does AOI CRS match LidarBC Index?
  if(sf::st_crs(aoi) != sf::st_crs(index)){
    aoi <- sf::st_transform(aoi, sf::st_crs(index))
    print('Transformed area of interest CRS')
  }
  
  # Extract intersecting polygons of aoi and LidarBC index
  if(keep.geometry == TRUE){
    aoi.index <- sf::st_intersection(index, aoi) %>% st_cast("POLYGON")
    st_write(aoi.index, dsn = str_c(data.path, "/aoi.index.gpkg"), append = FALSE)
  } else {
    aoi.index <- sf::st_intersection(index, aoi) %>% st_drop_geometry()
  }
  
  
  # Create directories for downloading if they do not exist
  
  if(!exists("data.path",  envir = environment())){
    return(print("Did you define the data path?"))
  }
  
  # Check if some tiles are already downloaded?
  # If they are, remove them from the area of interest index
  
  if(keep.existing == FALSE){
    aoi.index <- aoi.index[which(!aoi.index$filename %in% list.files(str_c(data.path,  'las/'))),] %>%
      mutate(task.no = row_number()) %>%
      relocate(task.no, .before = 1)
  } else {
    aoi.index <- aoi.index %>%
      mutate(task.no = row_number()) %>%
      relocate(task.no, .before = 1)
  }
  
  print(str_c('There are ', 
               nrow(aoi.index), ' lidar point cloud tiles to be downloaded from LidarBC'))
  
  return(aoi.index)

}






