## This section is intended to use LAStools to convert, retile, and normalize tiles


library(sf)
require(lidR)
library(tidyverse)
require(data.table)

ch_cr_dir <- function(path){
  for(i in 1:length(path)){
    if(!dir.exists(path[i])){
      dir.create(path[i])
    }
  }
}

data.path <- "D:/Kitimat_LiDAR/test_folder/"

las.path <- paste0(data.path, "las/")
chm.path <- paste0(data.path, "chm/")
dem.path <- paste0(data.path, "dem/")
mets.path <- paste0(data.path, "metrics/")

c(las.path,
  paste0(las.path, "00_converted/"),
  paste0(las.path, "01_retiled/"),
  paste0(las.path, "02_norm/"),
  chm.path,
  paste0(chm.path, "by_tile/"),
  dem.path,
  paste0(chm.path, "by_tile/")) %>%
  ch_cr_dir()


# preprocessing -------------------------------------------------------------------

prep.bat <- read.delim("preprocessing_test.bat")
write.table(prep.bat, "preprocessing_test.bat", quote = F, row.names = F, col.names = F, append = T)


tiles.index <- list.files(las.path, pattern = ".la[sz]$", full.names = F) %>%
  tibble(tiles.orig = str_c(las.path, .),
         tiles.conv = str_c(las.path, "00_converted/", .))

run.lines <- vector()

i = 1
for(i in 1:nrow(tiles.index)){
  
  if(!file.exists(tiles.index$tiles.conv[i])){
    tool <- "las2las"  # specify tool
    input.line <- paste0(" -i ", tiles.index$tiles.orig[i], "^")  # in dir f_in, find all .laz files assoc w met.name
    commands <- " -remove_vlrs_from_to 1 3 ^ \n -remove_padding ^ \n -set_version 1.4 ^ \n -cores 12 ^ \n" # assoc. commands with tool
    output.line <- paste0(" -o ", tiles.index$tiles.conv[i])  # write merged .tif output to f_out
    command.line <- paste0(tool, input.line, commands, output.line) %>% as.character()  # paste together and vectorize
    run.lines <- append(run.lines, command.line)  # append to previous lines
  }
  
}

init.lines <- "set cores = 12"

output = append("pause", as.vector(run.lines)) %>%
  append(., "pause") %>%
  str_replace_all(pattern = "/", replacement = "\\\\")

write.table(x = output,
            file = "D:/Kitimat_LiDAR/lastools_cmd_lines_R.bat",
            quote = F,
            row.names = F,
            col.names = F)
