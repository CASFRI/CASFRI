:: Batch file for loading translation tables into PostgreSQL

:: Input tables are format csv

:: User provides the path to a folder, all csv files in the folder are loaded 

:: If overwrite=True any existing tables will be replaced
:: If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

:: #################################### Set variables ######################################

:: Load config variables from local config file
if exist "%~dp0\..\config.bat" ( 
  call "%~dp0\..\config.bat"
) else (
  echo ERROR: NO config.bat FILE
  exit /b
)

:: Folder containing translation file to be loaded:
::SET load_folder="%~dp0tables"
SET load_folders=%~dp0tables %~dp0tables\lookup

::######################################################################################################

:: Do not edit...
if %overwriteTTables% == True (
  SET overwrite_tab=-overwrite
) else (
  SET overwrite_tab=
)

:: Make schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetTranslationFileSchema%";

:: load all files in the folder
(for %%f IN (%load_folders%) DO (
	if exist %%f (
		for %%g IN (%%f\*.csv) DO (
			echo loading %%~ng
			"%gdalFolder%/ogr2ogr" ^
			-f "PostgreSQL" "PG:host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "%%g" ^
			-nln %targetTranslationFileSchema%.%%~ng ^
			%overwrite_tab% -progress
	)) else (
		echo FOLDER DOESN'T EXIST: %%g
	)
))