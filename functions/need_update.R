need_update <- function() {
  
  latest.index <- str_extract(list.files(pattern = ".gpkg"), pattern = "[a-z]{3}[0-9]{4}") %>%
    lubridate::my(str_c(match(str_extract(., "[a-z]{3}"), tolower(month.abb)), "-", str_extract(., "[0-9]{4}"))) %>%
    max()
  
  if((Sys.Date() - latest.index) > 180){
    print(str_c("GET NEW INDEX - Follow instructions in next chunk"))
  } else {
    path = list.files(pattern = ".gpkg")
    print(str_c("Index does not need updating. The gpkg path is ", path))
  }
}
