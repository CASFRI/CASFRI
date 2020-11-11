:: This script loads the Canada shapefile

:: #################################### Set variables ######################################

SETLOCAL

CALL ..\..\conversion\bat\common.bat

SET srcFileName=canada_provinces.shp

SET fullTargetTableName=casfri50_coverage.canada_provinces

:: ########################################## Process ######################################

:: Run ogr2ogr
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFileName% ^
-nln %fullTargetTableName% %layer_creation_options% %other_options% ^
-progress %overwrite_tab%

ENDLOCAL