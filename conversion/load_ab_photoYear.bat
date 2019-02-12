::This script loads the Alberta photo year file into PostgreSQL

::The format of the source dataset is a single shapefile

::Load into a target table in a schema named 'ab'.

::Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
::Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

::Create schema if it doesn't exist
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS ab";

::Source file location
SET srcF=C:\Temp\AB_Photo_Year\PhotoYear_Update.shp

::Target table name
SET trgtT=ab.AB_PhotoYear

::Projection file. Canada Albers Equal Area Conic. %~dp0 fetches the directory that contains the batch file.
SET batchDir=%~dp0
SET prjF="%batchDir%canadaAlbersEqualAreaConic.prj"

::Run ogr2ogr
ogr2ogr ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-overwrite

::Spatial index should be created automatically, if not, un-comment the ogrinfo line
::ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX AB_PhotoYear_spatial_index ON ab.AB_PhotoYear USING GIST (wkb_geometry);"