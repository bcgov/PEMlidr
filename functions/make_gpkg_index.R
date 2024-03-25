make_gpkg_index <- function(){
  
  latest.index <- list.files("las_index_files", pattern = ".gpkg") %>%
    str_extract(pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}") %>%
    lubridate::ymd() %>%
    max()
  
  if((Sys.Date() - latest.index) > 180 & arc.check_product()["license"] %in% c("Advanced", "Standard", "Basic")){
      
      gpkg.path <- str_c("las_index_files/las_index_", Sys.Date(), ".gpkg")
      
      arc.open("https://services6.arcgis.com/ubm4tcTYICKBpist/arcgis/rest/services/LiDAR_BC_S3_Public/FeatureServer/4") %>%
        arc.select() %>%
        arc.data2sp() %>%
        st_write(., dsn = gpkg.path, append = FALSE)
      
      return(gpkg.path)
      
  } else {
    gpkg.path <- list.files("las_index_files", pattern = as.character(latest.index)) %>% str_c("las_index_files/", .)
    return(gpkg.path)
  }
  

  

  
  print(str_c("The updated gpkg path is: ", gpkg.path))
  
}
