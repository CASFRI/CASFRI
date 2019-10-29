:: This script loads the New Brunswick FRI data into PostgreSQL

:: The format of the source dataset is four shapefiles named Forest.shp, 
:: Non Forest.shp, Waterbody.shp, and wetland.shp
::
:: These four files are combined into a single PostgreSQL table
:: This is done using the -append argument. Note that -update is also 
:: needed in order to append in PostgreSQL. -addfields is also needed 
:: because columns do not match between tables.

:: The year of photography is included in the attributes table (DATAYR)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Workflow is to load the first table normally, then append the others
:: Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries

:: stdlab attribute needed to make cas id. Only present in forest.shp.
:: add as attribute with 0 for other files

:: #################################### Set variables ######################################

SETLOCAL

:: Load config variables from local config file
IF EXIST "%~dp0\..\..\config.bat" ( 
  CALL "%~dp0\..\..\config.bat"
) ELSE (
  ECHO ERROR: NO config.bat FILE
  EXIT /b
)

:: Set unvariable variables

SET NB_subFolder=NB\NB02\

SET srcNameWater=NBHN_0000_02_Wb
SET srcWaterFullPath="%friDir%\%NB_subFolder%%srcNameWater%.shp"

SET srcNameNonForest=geonb_nonforest-nonforet
SET srcNonForestFullPath="%friDir%\%NB_subFolder%%srcNameNonForest%.shp"

SET srcNameWetland=NBHN_0000_03_wl
SET srcWetlandFullPath="%friDir%\%NB_subFolder%%srcNameWetland%.shp"

SET srcNameForest=geonb_forest-foret
SET srcForestFullPath="%friDir%\%NB_subFolder%%srcNameForest%.shp"

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.nb02


IF %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) ELSE (
  SET overwrite_tab=
)

:: ########################################## Process ######################################

::Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"port=%pgport% host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";

::### FILE 1 ###
::Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
::Solution is to load the Waterbody table first with -lco PRECISION=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcWaterFullPath% ^
-nln %fullTargetTableName% ^
-lco PRECISION=NO ^
-lco GEOMETRY_NAME=wkb_geometry ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameWater%' AS src_filename, 0 AS stdlab FROM ""%srcNameWater%""" ^
-progress %overwrite_tab%

::### FILE 2 ###
"%gdalFolder%/ogr2ogr" ^
-update -append -addfields ^
-f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcNonForestFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameNonForest%' AS src_filename, 0 AS stdlab FROM ""%srcNameNonForest%""" ^
-progress

::### FILE 3 ###
"%gdalFolder%/ogr2ogr" ^
-update -append -addfields ^
-f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcWetlandFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameWetland%' AS src_filename, 0 AS stdlab FROM ""%srcNameWetland%""" ^
-progress

::## File 4 ###
"%gdalFolder%/ogr2ogr" ^
-update -append -addfields ^
-f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcForestFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameForest%' AS src_filename FROM ""%srcNameForest%""" ^
-progress

ENDLOCAL