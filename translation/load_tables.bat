:: Batch file for loading translation tables into PostgreSQL

:: Input tables are format csv

:: User provides the path to a folder, all csv files in the folder are loaded 

:: If overwrite=True any existing tables will be replaced
:: If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

:: #################################### Set variables ######################################

CALL ..\conversion\bat\common.bat


:: Folder containing translation file to be loaded:
SET load_folders=%~dp0tables %~dp0tables\lookup %~dp0..\docs

::##################################### Process ############################################

:: Make schema if it doesn't exist
"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE SCHEMA IF NOT EXISTS %targetTranslationFileSchema%";

:: load all files in the folder
(for %%f IN (%load_folders%) DO (
  if exist %%f (
    for %%g IN (%%f\*.csv) DO (
      echo loading %%~ng
      "%gdalFolder%/ogr2ogr" ^
      -f "PostgreSQL" %pg_connection_string% "%%g" ^
      -nln %targetTranslationFileSchema%.%%~ng ^
      %overwrite_tab%
  )) else (
    echo FOLDER DOESN'T EXIST: %%g
  )
))