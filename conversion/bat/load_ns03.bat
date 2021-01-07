:: This script loads the Nova Scotia forest inventory (NS03) into PostgreSQL

:: This dataset is split into 20 shapefiles, each representing
:: a different county.

:: The year of photography is included in the attributes table (PHOTOYR)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: All tables have the same core attributes, but some have additional wetland attributes.
:: Annapolis.shp also has AGE and MATURITY.
:: Load Annapolis.shp first since it has the most columns.

:: The combination of FOREST_, FOREST_ID, MAPSHEET and SRC_FILENAME is a unique identifier across all counties 
:: and should be used in the cas_id. All four are needed to create the unique id.
:: ####################################### Set variables #######################################
SETLOCAL

CALL .\common.bat

SET inventoryID=NS03
SET srcFolder="%friDir%/NS/%inventoryID%/data/inventory/"
SET fullTargetTableName=%targetFRISchema%.ns03

SET overwrite_option=%overwrite_tab%

:: ########################################## Process ######################################

SETLOCAL ENABLEDELAYEDEXPANSION

for %%F in (Annapolis Antigonish Cape_Breton Colchester Cumberland Digby Guyborough Halifax_East Halifax_West Hants Inverness Kings Lunenburg Pictou Queens Richmond Shelburne St_Marys Victoria Yarmouth) do (

    SET srcFullPath="%srcFolder%%%F.shp"

    "%gdalFolder%/ogr2ogr" ^
    -f PostgreSQL %pg_connection_string% !srcFullPath! ^
    -nln %fullTargetTableName% ^
    -nlt PROMOTE_TO_MULTI ^
    -sql "SELECT *, '%%~nF' AS src_filename, '%inventoryID%' AS inventory_id FROM %%F" ^
    -progress ^
    !layer_creation_options! %other_options% ^
    !overwrite_option!
	
    SET overwrite_option=-update -append
    SET layer_creation_options=
)			

SET createSQLSpatialIndex=True

CALL .\common_postprocessing.bat

ENDLOCAL