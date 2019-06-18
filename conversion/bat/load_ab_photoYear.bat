:: This script loads the Alberta photo year file into PostgreSQL

:: The format of the source dataset is a single shapefile

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
:: Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

::######################################## Set variables #######################################

SETLOCAL

:: load config variables
if exist "%~dp0\..\..\config.bat" ( 
  call "%~dp0\..\..\config.bat"
) else (
  echo ERROR: NO config.bat FILE
  exit /b
)

SET srcFileName=PhotoYear_Update
SET srcFullPath="%friDir%/AB/PhotoYear/%srcFileName%.shp"

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.ab_photoYear


if %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) else (
  SET overwrite_tab=
)

::############################ Script - shouldn't need editing #############################

:: Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";

::Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-progress %overwrite_tab%

ENDLOCAL