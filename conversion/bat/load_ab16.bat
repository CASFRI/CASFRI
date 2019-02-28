:: This script loads the Alberta Canfor FRI data into PostgreSQL

:: The format of the source dataset is ArcInfo Coverages divided into mapsheets.

:: The FRI data is stored in the "forest" feature for each mapsheet.
:: Script loop through each mapsheet and append to the same target table in PostgreSQL.
:: This can be done using the -append argument. Note that -update is also needed in order to 
:: append in PostgreSQL. -addfields is not needed here as columns match in all tables.

:: The year of photography is included as a shapefile. Photo year will be joined to the loaded 
:: table in PostgreSQL.

:: Load into the ab16 target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Workflow as recommended here: https://trac.osgeo.org/gdal/wiki/FAQVector#FAQ-Vector
:: Load the first table normally, then delete all the data. This serves as a template
:: Then loop through all Coverages and append to the template table

::######################################## variables #######################################

SETLOCAL

:: Load config variables from local config file
if exist "%~dp0\..\..\config.bat" ( 
  call "%~dp0\..\..\config.bat"
) else (
  echo ERROR: NO config.bat FILE
  exit /b
)

:: Set unvariable variables

SET srcFirstFileName=t059r04m6
SET srcFullPath=%friDir%\AB\SourceDataset\v00.04\NONGOV\Canfor\

SET prjFile="%~dp0\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.ab16


if %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) else (
  SET overwrite_tab=
)


:: PostgreSQL variables

SET ogrTab='PAL'
SET firstfile="%friDir%\AB\SourceDataset\v00.04\NONGOV\Canfor\t059r04m6\forest"

:: ########################################## Process ######################################

::Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";

::## 1. ##
::make table template
::load first mapsheet. Using precision=NO because the FOREST-ID field is set to NUMERIC(5,0) when imported but data have 6 digits. Causes error.
"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" %srcFullPath%%srcFirstFileName%\forest ^
-nln %fullTargetTableName% ^
-t_srs %prjFile% ^
-lco precision=NO ^
-sql "SELECT *, 'placeholder' as src_filename FROM %ogrTab%" ^
-progress %overwrite_tab%

::delete rows but not table
"%gdalFolder%/ogrinfo" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "DELETE FROM %fullTargetTableName%"

::Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
::Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
::New fields will be added to the right of the table
::Using ogrinfo - add two new integer columns to hold the FOREST# and FOREST-ID integers. Name them forest_id_1 and forest_id_2.
"%gdalFolder%/ogrinfo" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE %fullTargetTableName% ADD forest_id_1 integer;"
"%gdalFolder%/ogrinfo" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE %fullTargetTableName% ADD forest_id_2 integer;"

::2::loop through all mapsheets. Note - can't easily set variables inside loops so provide file paths directly as arguments.
:: /D is used for accessing folder paths in for loop. Only grabs folders beginning with t.
:: -sql statement adds new columns with the values of the invalid columns
for /D %%F IN (%srcFullPath%\t*) DO (
	"%gdalFolder%/ogr2ogr" ^
	-update -append ^
	-f "PostgreSQL" PG:"host=%pghost% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "%%F\forest" ^
	-nln %fullTargetTableName% ^
	-t_srs %prjFile% ^
	-sql "SELECT *, '%%~nF' as src_filename, 'FOREST#' AS 'forest_id_1', 'FOREST-ID' AS 'forest_id_2' FROM %ogrTab%"
)

ENDLOCAL
