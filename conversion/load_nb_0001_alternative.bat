::This script loads the New Brunswick FRI data into PostgreSQL

::The format of the source dataset is four shapefiles named Forest.shp, Non Forest.shp, Waterbody.shp, and wetland.shp
::These four files need to be combined into a single PostgreSQL table
::This can be done using the -append argument. Note that -update also needed in order to append in PostgreSQL. -addfields is also needed because columns do not match between tables. 

::Load into a target table in a schema named 'nb'.

::Workflow is to load the first table normally, then append the others

::Create schema if it doesn't exist
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS nb";

::Projection file. Canada Albers Equal Area Conic. %~dp0 fetches the directory that contains the batch file.
SET batchDir=%~dp0
SET prjF="%batchDir%canadaAlbersEqualAreaConic.prj"

::Target table name in PostgreSQL
SET trgtT=nb.NB_0001

::Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
::Solution is to load the SHAPE_AREA column alone first with -lco precision=NO. This changes the type from NUMERIC to FLOAT8. We want to change it back to NUMERIC once loaded, then append the rest of the columns.
::Note: it would also be fine to just import everything as float values.

::NOTE - ALTERING TYPE ON IMPORT MIGHT BE POSSIBLE USING CAST - SEE https://www.gdal.org/ogr_sql.html

::Source file location
SET srcF="C:\Temp\NB_source\Waterbody.shp"
::Filename field. This will be added as a column called src_filename and later used to create the cas_id field
SET fileName=Waterbody
ogr2ogr ^
-lco precision=NO ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT shape_area FROM '%fileName%'"

::Alter the column type back to NUMERIC using ogrinfo and an sql query. Change precision, scale from the original 19, 11 that caused the error, to 17,6.
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "ALTER TABLE %trgtT% ALTER shape_area SET DATA TYPE NUMERIC(17,6);"

::Load the rest of the columns from Waterbody
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT objectid, datasrc, water_code, buffer_cod, name, water_name, water_id, shape_len, '%fileName%' as src_filename FROM '%fileName%'"

::APPEND SECOND TABLE - note table name is provided explicitly in -sql statement. This was done so the space can be removed from %fileName%. We don't want spaces in cas_id.
SET srcF="C:\Temp\NB_source\Non Forest.shp"
SET fileName=NonForest
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%fileName%' as src_filename FROM 'Non Forest'"

::APPEND FOURTH TABLE
SET srcF="C:\Temp\NB_source\wetland.shp"
SET fileName=wetland
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%'"

SET srcF=C:\Temp\NB_source\Forest.shp
SET fileName=Forest
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%'"