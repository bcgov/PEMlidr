require(lidR)


t <- list.files("D:/Kitimat_LiDAR/data_test/las/", pattern = ".laz$", full.names = T) %>% readLAScatalog()
t2 <- list.files("D:/Kitimat_LiDAR/data_test/las/01_retiled", pattern = ".laz$", full.names = T) %>% readLAScatalog()


st_crs(t) <- st_crs(3005)

st_write(t@data, dsn = "D:/Kitimat_LiDAR/data/ctg_orig.shp", append = F)

las <- readLAS("D:/Kitimat_LiDAR/data/las/bc_103h055_4_1_4_xyes_17_utm09_20170806.laz")



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