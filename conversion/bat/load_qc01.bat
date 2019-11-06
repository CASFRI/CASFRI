:: This script loads the QC_01 FRI data into PostgreSQL

:: The format of the source dataset is shapefiles divided into NTS tile names.

:: Each tile name has a different folder, the data are contained in a shapefile
:: named c08peefo.shp in each tile folder.

:: Script loops through each tile and appends to the same target table in PostgreSQL.
:: Done using the -append argument. 
:: Note that -update is also needed in order to append in PostgreSQL. 
:: -addfields is not needed here as columns match in all tables.

:: Sheets starting with '11' do not have all matching attributes. They are loaded as 
:: a second step. 

:: The year of photography is included as a shapefile. 

:: Load into the qc01 target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: ######################################## variables #######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=QC01
SET srcFullPath=%friDir%\QC\%inventoryID%

SET fullTargetTableName=%targetFRISchema%.qc01

:: PostgreSQL variables
SET ogrTab=c08peefo

:: ########################################## Process ######################################

SETLOCAL ENABLEDELAYEDEXPANSION

:: Loop through all tiles.
:: For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
:: Set -overwrite for first load if requested in config
:: After first load, remove -overwrite and add -update -append

SET ogr_options=-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry %overwrite_tab%

ECHO OFF
FOR /D %%F IN (%srcFullPath%\*) DO (

  SET filename=%%~nF
  SET filename=!filename:~0,2!

  IF not !filename!==11 (
    ECHO ***********************************************************************
    ECHO *********************** Loading  %%~nF... ****************************
    ECHO

    "%gdalFolder%/ogr2ogr" ^
    -f "PostgreSQL" %pg_connection_string% "%%F\%ogrTab%.shp" ^
    -nln %fullTargetTableName% ^
    -t_srs %prjFile% ^
    -sql "SELECT *, '%%~nF' as src_filename, '%inventoryID%' AS inventory_id FROM %ogrTab%" ^
    -progress !ogr_options!

    SET ogr_options=-update -append
  ) ELSE (
    ECHO ***********************************************************************
    ECHO *********************** Skipping %%~nF... ****************************
    ECHO
  )
)

FOR /D %%F IN (%srcFullPath%\11*) DO (
    ECHO ***********************************************************************
    ECHO *********************** Loading  %%~nF... ****************************
    ECHO

    "%gdalFolder%/ogr2ogr" ^
    -f "PostgreSQL" %pg_connection_string% "%%F\%ogrTab%.shp" ^
    -nln %fullTargetTableName% ^
    -t_srs %prjFile% ^
    -sql "SELECT *, '%%~nF' as src_filename, '%inventoryID%' AS inventory_id FROM %ogrTab%" ^
    -progress !ogr_options!
)

ENDLOCAL
