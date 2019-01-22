::This script loads the British Columbia VRI data into PostgreSQL

::The format of the source dataset is a single geodatabase

::The year of photography is included in the attributes table (REFERENCE_YEAR)

::Load into a target table in a schema named 'bc'.


::CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID IF NEEDED. CHECK WITH STEVE.

::Create schema if it doesn't exist
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS bc";

::Source file location
SET srcF=C:\Temp\VEG_COMP_LYR_R1_POLY\VEG_COMP_LYR_R1_POLY.gdb

::Filename field. This will be added as a column called src_filename and later used to create the cas_id field
SET fileName=VEG_COMP_LYR_R1_POLY

::Target table name
SET trgtT=bc.BC_0008

::Target projection - Canada Albers Equal Area Conic
:: %~dp0 fetches the directory that contains the batch file. Use this to point to the prj file stored with the scripts
SET batchDir=%~dp0
SET prjF="%batchDir%canadaAlbersEqualAreaConic.prj"

::Run ogr2ogr
ogr2ogr ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%'"

::If later we need to filter, use:
::-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%' WHERE Inventory_Standard_CD='V'"

::Spatial index should be created automatically, if not, un-comment the ogrinfo line
::ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX BC_0008_spatial_index ON bc.BC_0008 USING GIST (wkb_geometry);"