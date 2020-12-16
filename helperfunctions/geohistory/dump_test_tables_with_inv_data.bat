:: This script dumps the random test tables from the database.

:: When test tables rightfully differ from original tables they have to be 
:: dumped with this script and pushed back in the source tree.

:: #################################### Set variables ######################################

SETLOCAL

CALL ..\..\conversion\bat\common.bat

:: ########################################## Process ######################################

::Run ogr2ogr

DEL testtables\sampling*.csv

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nb1_history.csv" %pg_connection_string% "geohistory.sampling_area_nb1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nb2_history.csv" %pg_connection_string% "geohistory.sampling_area_nb2_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nt1_history.csv" %pg_connection_string% "geohistory.sampling_area_nt1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nt2_history.csv" %pg_connection_string% "geohistory.sampling_area_nt2_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_bc1_history.csv" %pg_connection_string% "geohistory.sampling_area_bc1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_bc2_history.csv" %pg_connection_string% "geohistory.sampling_area_bc2_history_new"

ENDLOCAL