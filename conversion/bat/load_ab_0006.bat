::This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

::The format of the source dataset is a single .E00 file

::The year of photography is included as a shapefile. Photo year will be joined to the loaded table in PostgreSQL

::Load into a target table in a schema named 'ab'.

::Could not load E00 with attributes successfully without using ESRI tools.

::Converted E00 to geodatabase in ArcGIS. This script will load the geodatabase.

::######################################## variables #######################################

:: PostgreSQL variables
SET pghost=localhost
SET pgdbname=cas
SET pguser=postgres
SET pgpassword=postgres
SET schema=test
SET trgtT=test.AB_0006
SET srcF=C:\Temp\ab_0006.gdb
SET fileName=ab_0006

:: path variables
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
-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%'"