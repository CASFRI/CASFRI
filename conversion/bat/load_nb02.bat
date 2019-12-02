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

:: there is no unique id across all 4 tables that we can use in the cas_id to trace back 
:: to the original source polygons.
:: We will add a unique ID (poly_id) to each shapefile before loading.

:: Note that the name of the Nonforest.shp was originally 'Non Forest.shp'.
:: The space was removed to avoid loading issues.

:: #################################### Set variables ######################################

SETLOCAL

CALL .\common.bat

SET add_unique_source_id=false

SET inventoryID=NB02
SET NB_subFolder=NB\%inventoryID%\data\inventory\

SET srcNameWater=NBHN_0000_02_Wb
SET srcWaterFullPath="%friDir%\%NB_subFolder%%srcNameWater%.shp"

SET srcNameNonForest=geonb_nonforest_nonforet
SET srcNonForestFullPath="%friDir%\%NB_subFolder%%srcNameNonForest%.shp"

SET srcNameWetland=NBHN_0000_03_wl
SET srcWetlandFullPath="%friDir%\%NB_subFolder%%srcNameWetland%.shp"

SET srcNameForest=geonb_forest_foret
SET srcForestFullPath="%friDir%\%NB_subFolder%%srcNameForest%.shp"

SET fullTargetTableName=%targetFRISchema%.nb02

:: ########################################## Process ######################################

:: Add unique poly_id to each shp
:: Standard SQL code used to add and drop columns in shapefiles. If column is not present the DROP command
:: will return an error which can be ignored.
:: SQLite is needed to add the id based on rowid.
:: Only needed the first time data is loaded. No need to re-add the id on every load. 
:: Use add_unique_source_id = true to add the source poly_id.

if %add_unique_source_id% == true (

	:: Waterbody
	"%gdalFolder%\ogrinfo" %srcWaterFullPath% -sql "ALTER TABLE %srcNameWater% DROP COLUMN poly_id"
	"%gdalFolder%\ogrinfo" %srcWaterFullPath% -sql "ALTER TABLE %srcNameWater% ADD COLUMN poly_id integer"
	"%gdalFolder%\ogrinfo" %srcWaterFullPath% -dialect SQLite -sql "UPDATE %srcNameWater% set poly_id = rowid+1"

	:: Non forest
	"%gdalFolder%\ogrinfo" %srcNonForestFullPath% -sql "ALTER TABLE %srcNameNonForest% DROP COLUMN poly_id"
	"%gdalFolder%\ogrinfo" %srcNonForestFullPath% -sql "ALTER TABLE %srcNameNonForest% ADD COLUMN poly_id integer"
	"%gdalFolder%\ogrinfo" %srcNonForestFullPath% -dialect SQLite -sql "UPDATE %srcNameNonForest% set poly_id = rowid+1"

	:: wetland
	"%gdalFolder%\ogrinfo" %srcWetlandFullPath% -sql "ALTER TABLE %srcNameWetland% DROP COLUMN poly_id"
	"%gdalFolder%\ogrinfo" %srcWetlandFullPath% -sql "ALTER TABLE %srcNameWetland% ADD COLUMN poly_id integer"
	"%gdalFolder%\ogrinfo" %srcWetlandFullPath% -dialect SQLite -sql "UPDATE %srcNameWetland% set poly_id = rowid+1"

	:: Forest
	"%gdalFolder%\ogrinfo" %srcForestFullPath% -sql "ALTER TABLE %srcNameForest% DROP COLUMN poly_id"
	"%gdalFolder%\ogrinfo" %srcForestFullPath% -sql "ALTER TABLE %srcNameForest% ADD COLUMN poly_id integer"
	"%gdalFolder%\ogrinfo" %srcForestFullPath% -dialect SQLite -sql "UPDATE %srcNameForest% set poly_id = rowid+1"
)

::### FILE 1 ###
::Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
::Solution is to load the Waterbody table first with -lco PRECISION=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
"%gdalFolder%\ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcWaterFullPath% ^
-nln %fullTargetTableName% %layer_creation_option% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameWater%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%srcNameWater%""" ^
-progress %overwrite_tab%

::### FILE 2 ###
"%gdalFolder%\ogr2ogr" ^
-update -append -addfields ^
-f "PostgreSQL" %pg_connection_string% %srcNonForestFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameNonForest%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%srcNameNonForest%""" ^
-progress

::### FILE 3 ###
"%gdalFolder%\ogr2ogr" ^
-update -append -addfields ^
-f "PostgreSQL" %pg_connection_string% %srcWetlandFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameWetland%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%srcNameWetland%""" ^
-progress

::## File 4 ###
"%gdalFolder%\ogr2ogr" ^
-update -append -addfields ^
-f "PostgreSQL" %pg_connection_string% %srcForestFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-nlt PROMOTE_TO_MULTI ^
-sql "SELECT *, '%srcNameForest%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%srcNameForest%""" ^
-progress

ENDLOCAL