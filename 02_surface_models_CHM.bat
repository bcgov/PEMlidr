

:: Set global environments
set f_in = D:\Kitimat_LiDAR\lidarbc-aoi-2024-03-18\las
set f_out = D:\Kitimat_LiDAR\lidarbc-aoi-2024-03-18
set cores = 12

:: make CHM files for each normalized tile
lascanopy -i %f_in%\02_norm\*.laz ^
	-use_tile_bb ^
	-drop_class 7 ^
	-drop_z_above 100 ^
	-drop_z_below 0 ^
	-step 1 ^
	-p 99 ^
	-obil ^
	-odir %f_out%\chm\by_tile ^
	-cores %cores%

:: Merge rasters to CHM - 1m
lasgrid -i %f_out%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 1 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\chm\CHM_1m.tif

:: Merge rasters to CHM - 5m
lasgrid -i %f_out%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 5 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\chm\CHM_5m.tif

:: Merge rasters to CHM - 10m
lasgrid -i %f_out%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 10 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\chm\CHM_10m.tif

:: Merge rasters to CHM - 20m
lasgrid -i %f_out%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 20 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\chm\CHM_20m.tif