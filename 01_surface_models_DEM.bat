

:: Set global environments
set f_in = D:\Kitimat_LiDAR\lidarbc-aoi-2024-03-18\las
set f_out = D:\Kitimat_LiDAR\lidarbc-aoi-2024-03-18
set cores = 12


:: processing stream

:: make DEM
blast2dem -i %f_in%\01_retiled\*.laz ^
	-use_tile_bb ^
	-keep_class 2 ^
	-step 1 ^
	-odix _dem_1m ^
	-obil ^
	-nbits 32 ^
	-odir %f_out%\dem\by_tile ^
	-kill 200 ^
	-cores %cores%

:: Merge rasters to DEM - 5m
lasgrid -i %f_out%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 1 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\res_1m\DEM.tif ^
	-cores %cores%

:: Merge rasters to DEM - 5m
lasgrid -i %f_out%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 5 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\dem\DEM_20m.tif ^
	-cores %cores%


:: Merge rasters to DEM - 10m
lasgrid -i %f_out%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 10 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\dem\DEM_10m.tif
	-cores %cores%

:: Merge rasters to DEM - 20m
lasgrid -i %f_out%\dem\by_tile\*.bil ^
	-merged ^
	-highest ^
	-step 20 ^
	-otif ^
	-nbits 32 ^
	-epsg 3005 ^
	-o %f_out%\dem\DEM_20m.tif
	-cores %cores%





