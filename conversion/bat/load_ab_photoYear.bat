::This script loads the Alberta photo year file into PostgreSQL

::The format of the source dataset is a single shapefile

::Load into a target table in a schema named 'ab'.

::If table already exists it will be overwritten.

::Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
::Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

::######################################## variables #######################################

:: load config variables
if exist "%~dp0\config.bat" ( 
  call "%~dp0\config.bat"
) else (
  echo ERROR: NO config.bat FILE
  exit /b
)

:: PostgreSQL variables
SET schema=test
SET trgtT=ab_photoyear

SET srcF="%friDir%\PhotoYear_Update.shp"

::##########################################################################################


::############################ Script - shouldn't need editing #############################

::Set schema.table
SET schTab=%schema%.%trgtT%

::Create schema if it doesn't exist
ogrinfo PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %schema%";

::Run ogr2ogr
ogr2ogr ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcF% ^
-nln %schTab% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-progress -overwrite

::unload variables
SET schema=
SET trgtT=
SET srcF=
SET pghost=
SET pgdbname=
SET pguser=
SET pgpassword=
SET friDir=
SET prjF=