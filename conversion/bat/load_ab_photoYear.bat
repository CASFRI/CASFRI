::This script loads the Alberta photo year file into PostgreSQL

::The format of the source dataset is a single shapefile

::Load into a target table in a schema named 'ab'.

::Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
::Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

::######################################## variables #######################################
:: PostgreSQL variables
SET pghost=localhost
SET pgdbname=cas
SET pguser=postgres
SET pgpassword=postgres
SET schema=test
SET trgtT=test.AB_photoyear
SET srcF="C:\Temp\AB_Photo_Year\PhotoYear_Update.shp"

::path variables
SET batchDir=%~dp0
SET prjF="%batchDir%canadaAlbersEqualAreaConic.prj"
::##########################################################################################


::############################ Script - shouldn't need editing #############################

::Create schema if it doesn't exist
ogrinfo PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %schema%";

::Run ogr2ogr
ogr2ogr ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-overwrite