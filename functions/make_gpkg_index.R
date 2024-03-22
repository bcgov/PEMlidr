make_gpkg_index <- function(shp.path){
  
  gpkg.path <- str_split(shp.path, pattern = "/", simplify = T) %>% .[length(.)] %>%
    str_replace(., pattern = "shp", replacement = "gpkg")
  
  st_write(st_read(shp.path), dsn = gpkg.path, append = FALSE)
  
  print(str_c("The updated gpkg path is: ", gpkg.path))
  
}
