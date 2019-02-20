::This script loads the New Brunswick FRI data into PostgreSQL

::The format of the source dataset is four shapefiles named Forest.shp, Non Forest.shp, Waterbody.shp, and wetland.shp
::These four files need to be combined into a single PostgreSQL table
::This can be done using the -append argument. Note that -update is also needed in order to append in PostgreSQL. -addfields is also needed because columns do not match between tables. 

::The year of photography is included in the attributes table (DATAYR)

::Load into a target table in a schema named 'nb'.

::Workflow is to load the first table normally, then append the others
::Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries


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
SET trgtT=NB_0001

SET srcWater=%friDir%\nb_test\Waterbody.shp
SET srcNameWater=Waterbody
SET ogrTabWater=Waterbody

SET srcNonForest="%friDir%\nb_test\Non Forest.shp"
SET srcNameNonForest=NonForest
SET ogrTabNonForest='Non Forest'

SET srcWetland=%friDir%\nb_test\wetland.shp
SET srcNameWetland=wetland
SET ogrTabWetland=wetland

SET srcForest=%friDir%\nb_test\Forest.shp
SET srcNameForest=Forest
SET ogrTabForest=Forest


::##########################################################################################


::############################ Script - shouldn't need editing #############################

::Set schema.table
SET schTab=%schema%.%trgtT%

::Create schema if it doesn't exist
ogrinfo PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %schema%";

::### FILE 1 ###
::Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
::Solution is to load the Waterbody table first with -lco precision=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
ogr2ogr ^
-overwrite ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcWater% ^
-lco precision=NO ^
-nln %schTab% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameWater%' as src_filename FROM '%ogrTabWater%'" ^
-progress

::### FILE 2 ###
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcNonForest% ^
-nln %schTab% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameNonForest%' as src_filename FROM %ogrTabNonForest%" ^
-progress

::### FILE 3 ###
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcWetland% ^
-nln %schTab% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameWetland%' as src_filename FROM '%ogrTabWetland%'" ^
-progress

::## File 4 ###
ogr2ogr ^
-update -append -addfields ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcForest% ^
-nln %schTab% ^
-t_srs %prjF% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameForest%' as src_filename FROM '%ogrTabForest%'" ^
-progress

::unload variables
SET schema=
SET trgtT=
SET srcWater=
SET srcNameWater=
SET ogrTabWater=
SET srcNonForest=
SET srcNameNonForest=
SET ogrTabNonForest=
SET srcWetland=
SET srcNameWetland=
SET ogrTabWetland=
SET srcForest=
SET srcNameForest=
SET ogrTabForest=
SET pghost=
SET pgdbname=
SET pguser=
SET pgpassword=
SET friDir=
SET prjF=