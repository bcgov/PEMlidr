
:: make CHM files for each normalized tile
lascanopy -i %f_dir%\las\02_norm\*.laz ^
	-use_tile_bb ^
	-drop_class 7 ^
	-drop_z_above 100 ^
	-drop_z_below 0 ^
	-step 1 ^
	-p 99 ^
	-obil ^
	-odir %f_dir%\chm\by_tile ^
	-cores %cores%