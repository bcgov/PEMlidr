set f_dir=D:/Kitimat_LiDAR/data_test
set cores=6



:: make CHM files for each normalized tile
lascanopy -i %f_in%\las\02_norm\*.laz ^
	-use_tile_bb ^
	-drop_class 7 ^
	-drop_z_above 100 ^
	-drop_z_below 0 ^
	-step 1 ^
	-p 99 ^
	-obil ^
	-odir %f_dir%\chm\by_tile ^
	-cores %cores%
:: Merge rasters to CHM
lasgrid -i %f_dir%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 1 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\chm\CHM_1m.tif
:: Merge rasters to CHM
lasgrid -i %f_dir%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 3 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\chm\CHM_3m.tif
:: Merge rasters to CHM
lasgrid -i %f_dir%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 5 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\chm\CHM_5m.tif
:: Merge rasters to CHM
lasgrid -i %f_dir%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 7 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\chm\CHM_7m.tif
:: Merge rasters to CHM
lasgrid -i %f_dir%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 9 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\chm\CHM_9m.tif


