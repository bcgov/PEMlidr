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
