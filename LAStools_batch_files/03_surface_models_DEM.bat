

:: Set global environments
set f_dir=D:\Kitimat_LiDAR\data
set cores=12


:: processing stream

:: make DEM
blast2dem -i %f_dir%\las\01_retiled\*.laz ^
	-use_tile_bb ^
	-keep_class 2 ^
	-step 1 ^
	-obil ^
	-nbits 32 ^
	-odir %f_dir%\dem\by_tile ^
	-kill 200 ^
	-cores %cores%

:: Merge rasters to DEM - 1m
lasgrid -i %f_dir%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 1 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\dem\DEM_1m.tif ^
	-cores %cores%

:: Merge rasters to DEM - 5m
lasgrid -i %f_dir%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 5 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\dem\DEM_5m.tif ^
	-cores %cores%


:: Merge rasters to DEM - 10m
lasgrid -i %f_dir%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 10 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\dem\DEM_10m.tif
	-cores %cores%

:: Merge rasters to DEM - 20m
lasgrid -i %f_dir%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 20 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_dir%\dem\DEM_20m.tif
	-cores %cores%





