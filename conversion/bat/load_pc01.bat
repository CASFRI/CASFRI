:: This script loads the PC01 FRI data into PostgreSQL

:: The format of the source dataset is a single ArcInfo Coverage.

:: The year of photography is 1968. 

:: Load into the pc01 target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

::######################################## variables #######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=PC01
SET srcFileName=fpoly
SET srcFullPath=%friDir%\PC\%inventoryID%\data\inventory\%srcFileName%

SET fullTargetTableName=%targetFRISchema%.pc01

:: PostgreSQL variables
SET ogrTab=PAL

:: ########################################## Process ######################################

"%gdalFolder%\ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFullPath% ^ 
-nln %fullTargetTableName% %layer_creation_options% %other_options% ^ 
-sql "SELECT *, '%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id FROM %ogrTab%" ^
-progress %overwrite_tab%
  
CALL .\common_postprocessing.bat

ENDLOCAL