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
