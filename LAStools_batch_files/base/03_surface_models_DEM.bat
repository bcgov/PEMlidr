
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
