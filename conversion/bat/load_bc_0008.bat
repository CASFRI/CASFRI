::This script loads the British Columbia VRI data into PostgreSQL

::The format of the source dataset is a geodatabase

::The year of photography is included in the attributes table (REFERENCE_YEAR)

::Load into a target table in a schema named 'bc'.


::CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID IF NEEDED. CHECK WITH STEVE.

::######################################## variables #######################################

:: PostgreSQL variables
SET pghost=localhost
SET pgdbname=cas
SET pguser=postgres
SET pgpassword=postgres
SET schema=test
SET trgtT=test.BC_0008
SET srcF=C:\Temp\bc_test.gdb
SET fileName=bc_test

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
-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%'"