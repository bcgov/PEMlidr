make_gpkg_index <- function(){
  
  ### Check the date of the most recent LAS index file.
  latest.index <- list.files("las_index_files", pattern = ".gpkg") %>%
    str_extract(pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}") %>%
    lubridate::ymd() %>%
    max()
  
  ### If the most recent index file is greater than 6 months old, grab a newer version and save it. If the user does not have an ArcGIS license OR the index is more recent than 6 months, use it.
  if((Sys.Date() - latest.index) > 180 & arc.check_product()["license"] %in% c("Advanced", "Standard", "Basic")){
      
      gpkg.path <- str_c("las_index_files/las_index_", Sys.Date(), ".gpkg")
      
      ind <- arc.open("https://services6.arcgis.com/ubm4tcTYICKBpist/arcgis/rest/services/LiDAR_BC_S3_Public/FeatureServer/4") %>%
        arc.select() %>%
        arc.data2sp() %>%
        st_as_sf()
        # st_transform(crs = 3005)
        
        st_write(ind, dsn = gpkg.path, append = FALSE)
      
      return(gpkg.path)
      print("Index updated.")
      
  } else {
    
    gpkg.path <- list.files("las_index_files", pattern = as.character(latest.index)) %>% str_c("las_index_files/", .)
    
    return(gpkg.path)
    print("Current index used.")
  }
  
}
