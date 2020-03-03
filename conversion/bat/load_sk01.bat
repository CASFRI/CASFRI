:: This script loads the SK UTM Government data (SK01) into PostgreSQL

:: The format of the source dataset is a geodatabase

:: The year of photography is included in the attribute SYR

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Mapsheets with values 0 in the CZONE attribute are not part of the inventory and shold be 
:: removed.

::######################################## Set variables #######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=SK01
SET srcFileName=UTM
SET gdbTableName=fpoly
SET srcFullPath="%friDir%/SK/%inventoryID%/data/inventory/UTM.gdb"

SET fullTargetTableName=%targetFRISchema%.sk01

::########################################## Process ######################################

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f PostgreSQL %pg_connection_string% %srcFullPath% %gdbTableName% ^
-nln %fullTargetTableName% %layer_creation_option% ^
-sql "SELECT *, '%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id FROM '%gdbTableName%' WHERE CZONE NOT LIKE '0'" ^
-progress %overwrite_tab%

ENDLOCAL