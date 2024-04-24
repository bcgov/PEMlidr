
### Filing a CHM

fill.na <- function(x, i=5) { if (is.na(x)[i]) { return(mean(x, na.rm = TRUE)) } else { return(x[i]) }}
w <- matrix(1, 3, 3)

chm <- rasterize_canopy(las, res = 0.5, algorithm = p2r(subcircle = 0.15), pkg = "terra")
filled <- terra::focal(chm, w, fun = fill.na)
smoothed <- terra::focal(chm, w, fun = mean, na.rm = TRUE)

chms <- c(chm, filled, smoothed)
names(chms) <- c("Base", "Filled", "Smoothed")
plot(chms, col = col)




ctg <- list.files("D:/Kitimat_LiDAR/data_test/las", pattern = ".laz$", full.names = T) %>%
  readLAScatalog()

ctg2 <- list.files("D:/Kitimat_LiDAR/data/las", pattern = ".laz$", full.names = T)[1] %>%
  readLAScatalog()

st_crs(ctg2) <- 4269

writeLAS(las, "D:/Kitimat_LiDAR/data/las/bc_103h056_3_1_4_xyes_17_utm09_20170806.laz")

st_write(ctg2@data, "D:/Kitimat_LiDAR/data/ctg_test.shp", append = F)

las <- readLAS("D:/Kitimat_LiDAR/data/las/bc_103h056_3_1_4_xyes_17_utm09_20170806.laz")
st_crs(las) <- 6652

index %>% filter(filename == "bc_103h056_3_1_4_xyes_17_utm09_20170806.laz")

"D:/Kitimat_LiDAR/data_test/las/bc_103i089_3_2_1_xyes_8_utm09_2021.laz"


ctg_norm@data %<>% mutate(file.check = str_replace(filename, pattern = "las\\\\02_norm", replacement = "chm\\\\by_tile"),
                          file.check = str_replace(file.check, pattern = ".laz", replacement = ".tif"),
                          file.check = file.exists(file.check)) %>%
  filter(file.check == F)


# if(!retile){
#   
#   retile.lines <- vector()
#   
#   fix.source.folder <- norm.lines %>%
#     filter(str_detect(V1, "01_retiled")) %>%
#     mutate(V1 = str_replace(V1, "\\\\01_retiled", ""))
#   
#   norm.lines[grepl("01_retiled", norm.lines$V1),] <- fix.source.folder
# }
t <- readLAS("D:/Kitimat_LiDAR/data/las/bc_103h097_1_2_4_xyes_8_utm09_2019.laz")
n <- normalize_height(t, knnidw())

las <- classify_ground(t, algorithm = pmf(ws = 5, th = 3))

ctg.las <- readLAScatalog("D:/Kitimat_LiDAR/data/las/bc_103h097_1_2_4_xyes_8_utm09_2019.laz")


ctg <- readLAScatalog(list.files("D:/Kitimat_LiDAR/data/las", pattern = ".laz", full.names = T))

no.crs <- ctg@data %>% filter(CRS == 0)


  t <- readLAS("D:\\Kitimat_LiDAR\\data\\las\\bc_103h056_3_2_4_xyes_17_utm09_20170806.laz")

ctg.t <- readLAScatalog(readLAS("D:\\Kitimat_LiDAR\\data\\las\\bc_103h056_3_2_4_xyes_17_utm09_20170806.laz")
)

aoi.index <- list.files(data.path, pattern = "aoi_index", full.names = T) %>%
  st_read() %>%
  mutate(task.no = row_number()) %>%
  relocate(task.no, .before = 1)


las2 <- filter_duplicates(las)
# las2@data <- las2@data %>% filter(Classification == 17 | Classification == 2)
# plot(las2, color = "Classification", bg = "white")

las2@data <- las2@data %>% filter(Classification != 1)

# Reclass weird noise classes
las2@data <- las2@data %>%
  mutate(Class.new = case_when(Classification == 17 ~ 1,
                               Classification == 5 ~ 1,
                               TRUE ~ Classification))

las3 <- classify_ground(las2, algorithm = pmf(ws = 5, th = 3))

plot(las3, color = "Classification")

las3@data <- las3@data %>% filter(Classification == 17)

ws <- seq(3, 12, 3)
th <- seq(0.1, 1.5, length.out = length(ws))
las4 <- classify_ground(las2, algorithm = pmf(ws = ws, th = th))


