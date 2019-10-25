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

:: Load config variables from local config file
IF EXIST "%~dp0\..\..\config.bat" ( 
  CALL "%~dp0\..\..\config.bat"
) ELSE (
  ECHO ERROR: NO config.bat FILE
  EXIT /b
)

:: Set unvariable variables

SET srcFileName=GB_S21_TWP
SET gdbFileName=%srcFileName%
SET srcFullPath="%friDir%\AB\AB06\%srcFileName%.gdb"

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.ab06


IF %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) ELSE (
  SET overwrite_tab=
)

:: ########################################## Process ######################################

::Run ogr2ogr

DEL data\*.csv

"%gdalFolder%/ogr2ogr" -f "CSV" "data\cas_all_test.csv" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "casfri50_test.cas_all_new"

"%gdalFolder%/ogr2ogr" -f "CSV" "data\dst_all_test.csv" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "casfri50_test.dst_all_new" 

"%gdalFolder%/ogr2ogr" -f "CSV" "data\eco_all_test.csv" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "casfri50_test.eco_all_new" 

"%gdalFolder%/ogr2ogr" -f "CSV" "data\lyr_all_test.csv" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "casfri50_test.lyr_all_new" 

"%gdalFolder%/ogr2ogr" -f "CSV" "data\nfl_all_test.csv" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "casfri50_test.nfl_all_new" 


ENDLOCAL