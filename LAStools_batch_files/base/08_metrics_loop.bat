
SETLOCAL ENABLEDELAYEDEXPANSION

for /f "delims= " %%g in (metric_names.txt) do (

:: Set global environments
set met=%%g

call :las2

	)
	
:las2