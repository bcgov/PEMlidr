
:: Merge rasters
lasgrid -i %f_dir%\metrics\by_tile\*%met%.bil ^
	-merged ^
	-step res ^
	-epsg 3005 ^
	-otif ^
	-o %f_dir%\metrics\%met%_resm.tif