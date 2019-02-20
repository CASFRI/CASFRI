::This script loads the British Columbia VRI data into PostgreSQL

::The format of the source dataset is a geodatabase

::The year of photography is included in the attributes table (REFERENCE_YEAR)

::Load into a target table in a schema named 'bc'.

::If table already exists it will be overwritten.

::CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID IF NEEDED USING -sql "SELECT *, '$fileName' as src_filename FROM '$fileName' WHERE Inventory_Standard_CD='V'"

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
SET trgtT=bc_0008

SET srcF="%friDir%\bc_test.gdb"
SET srcName=bc_test
SET ogrTab=bc_test

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
-sql "SELECT *, '%srcName%' as src_filename FROM '%ogrTab%'" ^
-progress -overwrite

::unload variables
SET schema=
SET trgtT=
SET srcF=
SET srcName=
SET ogrTab=
SET pghost=
SET pgdbname=
SET pguser=
SET pgpassword=
SET friDir=
SET prjF=