:: This script loads the British Columbia VRI forest inventory (BC08) into PostgreSQL

:: The format of the source dataset is a geodatabase

:: The year of photography is included in the attributes table (REFERENCE_YEAR)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID 
:: IF NEEDED USING -sql "SELECT *, '$fileName' AS src_filename FROM '$fileName' WHERE inventory_standard_cd='V'"

:: #################################### Set variables ######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=BC09
SET srcFileName=VEG_COMP_LYR_R1_POLY
SET gdbFileName=WHSE_FOREST_VEGETATION_2018_VEG_COMP_LYR_R1_POLY
SET srcFullPath="%friDir%\BC\%inventoryID%\data\inventory\%srcFileName%.gdb"

SET fullTargetTableName=%targetFRISchema%.bc09

:: ########################################## Process ######################################

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFullPath% ^
-nln %fullTargetTableName% %layer_creation_options% %other_options% ^
-sql "SELECT *, '%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%gdbFileName%""" ^
-progress %overwrite_tab%

CALL .\common_postprocessing.bat

ENDLOCAL
