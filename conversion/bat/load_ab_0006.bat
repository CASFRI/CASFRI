:: This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

:: The format of the source dataset is a single .E00 file

:: The year of photography is included as a shapefile. Photo year will be joined to the 
:: loaded table in PostgreSQL

:: Load into the ab06 target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Alberta Gordon Buchanan Tolko FRI was delivered as E00 which can not be loaded 
:: successfully without using ESRI tools, so it was to geodatabase in ArcGIS. This script 
:: will load the resulting geodatabase.

:: #################################### Set variables ######################################

SETLOCAL

:: Load config variables from local config file
if exist "%~dp0\..\..\config.bat" ( 
  call "%~dp0\..\..\config.bat"
) else (
  echo ERROR: NO config.bat FILE
  exit /b
)

:: Set unvariable variables

SET srcFileName=GB_S21_TWP
SET srcFullPath="%friDir%\AB\SourceDataset\v00.04\CROWNFMA\GordonBuchananTolko\S21_Gordon_Buchanan_Tolko\GB_S21_TWP\gdb\%srcFileName%.gdb"

SET prjFile="%~dp0\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.ab06


if %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) else (
  SET overwrite_tab=
)

:: ########################################## Process ######################################

::Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";

::Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-sql "SELECT *, '%srcFileName%' AS src_filename FROM ""%srcFileName%""" ^
-progress %overwrite_tab%

ENDLOCAL