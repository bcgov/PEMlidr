kmz_to_gpkg <- function(aoi.path, kmz.path){
  unzip(kmz.path, exdir = aoi.path, junkpaths = F) %>%
    st_read(.) %>%
    st_write(str_c(aoi.path, "AOI.gpkg"), append = F)
  return(str_c(aoi.path, "AOI.gpkg"))
}
