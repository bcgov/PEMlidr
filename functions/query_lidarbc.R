# ------------------------------------------------------------------------------
#
# Script created by Liam Irwin, November 4 2022, Contact: lakirwin@mail.ubc.ca
#
# ------------------------------------------------------------------------------

query_lidarbc <- function(aoi, index, data.path, keep.geometry = FALSE){
  
  # Does AOI CRS match LidarBC Index?
  if(sf::st_crs(aoi) != sf::st_crs(index)){
    aoi <- sf::st_transform(aoi, sf::st_crs(index))
    print('Transformed area of interest CRS')
  }
  
  # Extract intersecting polygons of aoi and LidarBC index
  if(keep.geometry == TRUE){
    aoi_index <- sf::st_intersection(index, aoi)
  } else {
    aoi_index <- sf::st_intersection(index, aoi) %>% st_drop_geometry()
  }
  
  
  # Create directories for downloading if they do not exist
  
  if(!exists("data.path",  envir = environment())){
    return(print("Did you define the data path?"))
  }
  
  # Check if some tiles are already downloaded?
  # If they are, remove them from the area of interest index
  aoi_index <- aoi_index[which(!aoi_index$filename %in% list.files(str_c(data.path,  'las/'))),] %>%
    mutate(task.no = row_number()) %>%
    relocate(task.no, .before = 1)
  
  print(str_c('There are ', 
               nrow(aoi_index), ' lidar point cloud tiles to be downlaoded from LidarBC'))
  
  return(aoi_index)

}






