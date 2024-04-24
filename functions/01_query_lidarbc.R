query_lidarbc <- function(aoi,
                          index,
                          data.path,
                          keep.geometry = FALSE){
  
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
  
  # Add projection info
  aoi.index <- read.csv("projection_codes.csv", header = T) %>%
    select(!URL) %>%
    left_join(aoi.index, ., by = "projection", keep = F)
  
  # Define file destination
  aoi.index <- aoi.index %>%
    rename(file.orig = s3Url) %>%
    mutate(file.dest = file.path(str_c(data.path,  'las'), basename(file.orig))) %>%
    relocate(file.dest , .after = file.orig)
  
  print(str_c('There are ', nrow(aoi.index), ' lidar point cloud tiles that can be downloaded from LidarBC'))
  
  # Write to the data folder
  if(keep.geometry == TRUE){
    st_write(aoi.index, str_c(data.path, "aoi_index.gpkg"), append = FALSE)
  } else {
    write.csv2(aoi.index, str_c(data.path, "aoi_index.csv"), append = FALSE)
  }

}






