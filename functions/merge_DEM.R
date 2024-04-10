merge_DEM <- function(data.path, output.res = c(5, 10, 20)){
  
  if(!dir.exists(data.path)){
    print("The current data path is not valid. Check folder setup.")
    }
  
  dem_tiles <- list.files(str_c(data.path, "dem/by_tile"), pattern = ".tif$", full.names = T)
  
  if(length(dem_tiles) > 1){
    r_dem <- dem_tiles %>% vrt()
  } else {
    r_dem <- NA
    return("No tiles to merge. Check folder.")
  }
  
  for(i in 1:length(output.res)){
    if(as.integer(output.res[i]) > min(res(r_dem))){
      terra::aggregate(r_dem, fact = as.integer(output.res[i])) %>%
        writeRaster(str_c(data.path, "dem/DEM_", output.res[i], ".tif"))
    } else {
      writeRaster(r_dem, str_c(data.path, "dem/DEM_", output.res[i], ".tif"))
    }
  }
}
