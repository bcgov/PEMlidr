require(lidR)


aoi2 <- st_read("D:/Kitimat_LiDAR/AOI/Kitimat_PEM_AOI.shp")

t <- list.files("D:/Kitimat_LiDAR/data/las/", pattern = ".laz$", full.names = T) %>% readLAScatalog()
t.norm <- list.files("D:/Kitimat_LiDAR/data/las/02_norm", pattern = ".laz$", full.names = T) %>% readLAScatalog()
plot(t.norm)

st_crs(t) <- st_crs(3005)

st_write(t@data, dsn = "D:/Kitimat_LiDAR/data/ctg_orig.shp", append = F)

las <- readLAS("D:/Kitimat_LiDAR/data/las/bc_103h055_4_1_4_xyes_17_utm09_20170806.laz")

st_write(, dsn = "D:/Kitimat_LiDAR/data/las_bbox.shp", append = F)


### Filing a CHM

fill.na <- function(x, i=5) { if (is.na(x)[i]) { return(mean(x, na.rm = TRUE)) } else { return(x[i]) }}
w <- matrix(1, 3, 3)

chm <- rasterize_canopy(las, res = 0.5, algorithm = p2r(subcircle = 0.15), pkg = "terra")
filled <- terra::focal(chm, w, fun = fill.na)
smoothed <- terra::focal(chm, w, fun = mean, na.rm = TRUE)

chms <- c(chm, filled, smoothed)
names(chms) <- c("Base", "Filled", "Smoothed")
plot(chms, col = col)


