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

:: NOTE: If pgpassword, as defined in the local config.bat file, contains an exclamation mark,
:: (e.g. psswrd!) you must also define pgpassword4ab16 to the same value and escape the 
:: question mark with a double caret like this: SET pgpassword4ab16=psswrd^^!

::######################################## variables #######################################

SETLOCAL

CALL .\common.bat

SET srcFirstFileName=t059r04m6
SET srcFullPath=%friDir%\AB\AB16\

SET fullTargetTableName=%targetFRISchema%.ab16

SET ogr_options=-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry %overwrite_tab%

IF "%pgpassword4ab16%"=="" SET pgpassword4ab16=%pgpassword%

:: PostgreSQL variables

SET ogrTab=PAL

:: ########################################## Process ######################################

SETLOCAL ENABLEDELAYEDEXPANSION

::Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword4ab16%" -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%"

:: Loop through all mapsheets.
:: For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
:: Set -overwrite for first load if requested in config
:: After first load, remove -overwrite and add -update -append
:: Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
:: Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
:: New fields will be added to the right of the table

FOR /D %%F IN (%srcFullPath%\t*) DO (
  "%gdalFolder%/ogr2ogr" ^
  -f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword4ab16%" "%%F\forest" ^
  -nln %fullTargetTableName% ^
  -t_srs %prjFile% ^
  -sql "SELECT *, '%%~nF' as src_filename, 'FOREST#' AS forest_id_1, 'FOREST-ID' AS forest_id_2 FROM %ogrTab%" ^
  !ogr_options!
  
  SET ogr_options=-update -append
)

ENDLOCAL
