merge_CHM <- function(data.path, output.res = c(5, 10, 20)){
  
  terra::terraOptions(overwrite = T, todisk = T, tempdir = "E:/temp")
  
  chm_tiles <- list.files(str_c(data.path, "chm/by_tile"), pattern = ".tif$", full.names = T)
  
  if(length(chm_tiles) > 1){
    r_chm <- chm_tiles %>% vrt()
  } else {
    r_chm <- NA
    return("No tiles to merge. Check folder.")
  }
  
  for(i in 1:length(output.res)){
    if(as.integer(output.res[i]) > min(res(r_chm))){
      terra::aggregate(r_chm, fact = as.integer(output.res[i])) %>%
        writeRaster(str_c(data.path, "chm/CHM_", output.res[i], ".tif"))
    } else {
      writeRaster(r_chm, str_c(data.path, "chm/CHM_", output.res[i], ".tif"))
    }
  }
}
