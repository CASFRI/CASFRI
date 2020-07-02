:: This script loads the SK SFVI Mystic dataset (SK06) into PostgreSQL

:: The format of the source dataset is a geodatabase
:: Source data is is a single table.
:: Standard is SFVI but the column names have been changed.

:: The year of photography is currently unknown. Issue #317

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

::######################################## Set variables #######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=SK06
SET srcFileName=MistikSFVI
SET fullTargetTableName=%targetFRISchema%.sk06

SET gdbFileName=SFVI

SET srcFullPath="%friDir%/SK/%inventoryID%/data/inventory/%srcFileName%.gdb"

::########################################## Process ######################################

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFullPath% %gdbFileName% ^
-nln %fullTargetTableName% %layer_creation_options% %other_options% ^
-sql "SELECT *, '%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id FROM %gdbFileName%" ^
-progress %overwrite_tab%

CALL .\common_postprocessing.bat

ENDLOCAL