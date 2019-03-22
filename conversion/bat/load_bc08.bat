:: This script loads the British Columbia VRI forest inventory (BC08) into PostgreSQL

:: The format of the source dataset is a geodatabase

:: The year of photography is included in the attributes table (REFERENCE_YEAR)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID 
:: IF NEEDED USING -sql "SELECT *, '$fileName' as src_filename FROM '$fileName' WHERE Inventory_Standard_CD='V'"

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

SET srcFileName=VEG_COMP_LYR_R1_POLY
SET srcFullPath="%friDir%\BC\SourceDataset\v.00.05\VEG_COMP_LYR_R1_POLY\%srcFileName%.gdb"

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.bc08


IF %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) ELSE (
  SET overwrite_tab=
)

:: ########################################## Process ######################################

:: Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"port=%pgport% host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" PG:"port=%pgport% host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcFullPath% ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-sql "SELECT *, '%srcFileName%' AS src_filename FROM ""%srcFileName%""" ^
-progress %overwrite_tab%

ENDLOCAL
