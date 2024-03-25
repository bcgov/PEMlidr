:: Merge rasters to CHM
lasgrid -i %f_dir%\chm\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step res ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\chm\CHM_resm.tif