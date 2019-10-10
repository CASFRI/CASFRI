:: This script loads the Quebec (QC03) into PostgreSQL

# This script loads the Quebec (QC03) into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is in a photo year shapefile that needs to loaded separately

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

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

SET srcFileName=PEE_MAJ_PROV
SET gdbFileName=%srcFileName%
SET srcFullPath="%friDir%\QC\QC03\CARTE_ECO_MAJ_PROV_10.gdb"

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.qc03


IF %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) ELSE (
  SET overwrite_tab=
)

:: ########################################## Process ######################################

::Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";

::Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcFullPath% "%gdbFileName%" ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-sql "SELECT *, '%srcFileName%' AS src_filename FROM ""%gdbFileName%""" ^
-progress %overwrite_tab%

ENDLOCAL