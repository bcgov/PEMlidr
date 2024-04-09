merge_CHM <- function(data.path, output.res = c(5, 10, 20)){
  
  if(!dir.exists(data.path)){print("The current data path is not valid. Check folder setup.")}
  
  r_chm <- list.files(str_c(data.path, "chm/by_tile"), pattern = ".tif$", full.names = T) %>% vrt()
  
  for(i in 1:length(output.res)){
    if(as.integer(output.res[i]) > min(res(r_chm))){
      terra::aggregate(r_chm, fact = as.integer(output.res[i])) %>%
        writeRaster(str_c(data.path, "chm/CHM_", output.res[i], ".tif"))
    } else {
      writeRaster(r_chm, str_c(data.path, "chm/CHM_", output.res[i], ".tif"))
    }
  }
}