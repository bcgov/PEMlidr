
:: Set global environments
set f_dir=D:\Kitimat_LiDAR\lidarbc-aoi-2024-03-18
set cores=12

REM :: Convert from 1.2 to 1.4
REM las2las -i %f_dir%\las\*.laz ^
	REM -remove_vlrs_from_to 1 3 ^
    REM -remove_padding ^
    REM -set_version 1.4 ^
    REM -odir %f_dir%\las\00_converted ^
	REM -olaz ^
    REM -cores %cores%

:: Index new .laz files
lasindex -i %f_dir%\las\00_converted\*.laz ^
	-dont_reindex ^
	-cores %cores%

:: Tile 500m - flag buffered points as withheld for simple drop later
lastile -i %f_dir%\las\00_converted\*.laz ^
	-drop_withheld ^
	-buffer 30 ^
	-flag_as_withheld ^
    -tile_size 500 ^
	-cpu64 ^
    -odir %f_dir%\las\01_retiled ^
    -olaz ^
    -cores %cores%

:: Index new .laz files
lasindex -i %f_dir%\las\01_retiled\*.laz ^
	-dont_reindex ^
	-cores %cores%

::Normalize height
lasheight -i %f_dir%\las\01_retiled\*.laz ^
    -replace_z ^
    -odir %f_dir%\las\02_norm ^
    -olaz ^
    -cores %cores%
	
:: Index new .laz files
lasindex -i %f_dir%\las\02_norm\*.laz ^
	-dont_reindex ^
	-cores %cores%