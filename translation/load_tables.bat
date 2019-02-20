:: Batch file for loading translation tables into PostgreSQL

:: Input tables are format csv

:: User provides the path to a folder, all csv files in the folder are loaded 

:: If overwrite=True any existing tables will be replaced
:: If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

::#####################################################################################################################################################################
::#####################################################################################################################################################################
::#####################################################################################################################################################################
:: Variables
:: target schema name
SET schema=translation_tables

:: postgres variables
SET pghost=localhost
SET pgdbname=cas
SET pguser=postgres
SET pgpassword=postgres

:: overwrite existing tables? True/False
SET overwrite=True

:: a folder containing csv's to be loaded:
SET load_folder="C:\Users\MarcEdwards\Documents\CASFRI v5\git\CASFRI\translation\tables"



::#####################################################################################################################################################################
::#####################################################################################################################################################################
::#####################################################################################################################################################################
:: do not edit...
if %overwrite% == True (
  SET overwrite_tab=-overwrite -progress
) else (
  SET overwrite_tab=-progress
)

:: make schema if it doesn't exist
ogrinfo PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %schema%";

:: load all files in the folder
if exist %load_folder% (
  for %%F IN (%load_folder%\*.csv) DO (
	echo loading %%~nF
	ogr2ogr ^
	-f "PostgreSQL" "PG:host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "%%F" ^
	-nln %schema%.%%~nF ^
	%overwrite_tab%
)) else ( 
  echo FOLDER DOESN'T EXIST: %load_folder%
)