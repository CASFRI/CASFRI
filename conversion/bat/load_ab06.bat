:: This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

:: The format of the source dataset is a single .E00 file

:: The year of photography is included as a shapefile. Photo year will be joined to the 
:: loaded table in PostgreSQL

:: Load into the ab06 target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Alberta Gordon Buchanan Tolko FRI was delivered as E00 which can not be loaded 
:: successfully without using ESRI tools, so it was to geodatabase in ArcGIS. This script 
:: will load the resulting geodatabase.

:: #################################### Set variables ######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=AB06
SET srcFileName=GB_S21_TWP
SET srcFullPath="%friDir%\AB\%inventoryID%\%srcFileName%.gdb"

SET fullTargetTableName=%targetFRISchema%.ab06

:: ########################################## Process ######################################

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFullPath% ^
-nln %fullTargetTableName% %layer_creation_option% ^
-sql "SELECT *, '%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%srcFileName%""" ^
-progress %overwrite_tab%

ENDLOCAL