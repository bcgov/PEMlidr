
:: Merge rasters to DEM
lasgrid -i %f_dir%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step res ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\dem\DEM_resm.tif ^
	-cores %cores%
