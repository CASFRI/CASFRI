:: This script loads the Quebec (QC02) into PostgreSQL

:: There is a updated version of this dataset: QC/SourceDataset/v.00.04/PEE_ORI_PROV.gdb
:: However here we load the original to match the CASFRI04 loading script

:: The format of the source dataset is a geodatabase

:: The year of photography is in a photo year shapefile that needs to loaded separately

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: #################################### Set variables ######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=QC02
SET srcFileName=DDE_20K_PEU_ECOFOR_ORI_VUE_SE
SET srcFullPath="%friDir%\QC\%inventoryID%\data\inventory\PEE_ORI_PROV.gdb"

SET fullTargetTableName=%targetFRISchema%.qc02

:: ########################################## Process ######################################

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFullPath% ^
-nln %fullTargetTableName% %layer_creation_options% %other_options% ^
-sql "SELECT *, '%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id FROM ""%srcFileName%""" ^
-progress %overwrite_tab%

CALL .\common_postprocessing.bat

ENDLOCAL