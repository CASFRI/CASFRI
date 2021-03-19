:: Batch file for loading translation tables into PostgreSQL

:: Input tables are format csv

:: User provides the path to a folder, all csv files in the folder are loaded 

:: If overwrite=True any existing tables will be replaced
:: If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

:: #################################### Set variables ######################################

CALL ..\conversion\bat\common.bat

SET tables_to_load=%1

ECHO %tables_to_load%

:: Folder containing translation file to be loaded:
SET load_folders=%~dp0tables %~dp0tables\lookup %~dp0..\docs

::##################################### Process ############################################

:: Make schema if it doesn't exist
"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE SCHEMA IF NOT EXISTS %targetTranslationFileSchema%";

IF "%tables_to_load%" == "" (
  :: load all files in the folder
  FOR %%f IN (%load_folders%) DO (
    FOR %%g IN (%%f\*.csv) DO (
      ECHO loading %%~ng
      "%gdalFolder%/ogr2ogr" ^
      -f "PostgreSQL" %pg_connection_string% "%%g" ^
      -nln %targetTranslationFileSchema%.%%~ng ^
      %overwrite_tab%
    )
  )
) ELSE (
  FOR %%g IN (%tables_to_load%) DO (
    ECHO loading %%~ng
    "%gdalFolder%/ogr2ogr" ^
    -f "PostgreSQL" %pg_connection_string% %~dp0tables/"%%g" ^
    -nln %targetTranslationFileSchema%.%%~ng ^
    %overwrite_tab%
  )
)