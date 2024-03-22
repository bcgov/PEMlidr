set f_in=D:\Kitimat_LiDAR\test_folder\las
set f_out=D:\Kitimat_LiDAR\test_folder\las
set cores=12

REM :: Convert from 1.2 to 1.4
REM las2las -i %f_in%\*.laz ^
	REM -remove_vlrs_from_to 1 3 ^
	REM -remove_padding ^
	REM -set_version 1.4 ^
	REM -odir %f_out%\00_converted ^
	REM -olaz ^
	REM -cores %cores%

:: Index new .laz files
lasindex -i %f_in%\00_converted\*.laz ^
	-dont_reindex ^
	-cores %cores%

:: Tile 500m - flag buffered points as withheld for simple drop later
lastile -i %f_out%\00_converted\*.laz ^
	-drop_withheld ^
	-buffer 30 ^
	-flag_as_withheld ^
	-tile_size 500 ^
	-cpu64 ^
	-odir %f_out%\01_retiled ^
	-olaz ^
	-unindexed ^
	-cores %cores%
	
:: Index new .laz files
lasindex -i %f_in%\01_retiled\*.laz ^
	-dont_reindex ^
	-cores %cores%
	
::Normalize height
lasheight -i %f_out%\01_retiled\*.laz ^
	-replace_z ^
	-odir %f_out%\02_norm ^
	-olaz ^
	-cores %cores%
	
:: Index new .laz files
lasindex -i %f_in%\02_norm\*.laz ^
	-dont_reindex ^
	-cores %cores%

pause