:: This script dumps the random test tables from the database.

:: When test tables rightfully differ from original tables they have to be 
:: dumped with this script and pushed back in the source tree.

:: #################################### Set variables ######################################

SETLOCAL

CALL ..\..\conversion\bat\common.bat

:: ########################################## Process ######################################

::Run ogr2ogr

DEL testtables\sampling*.csv

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nb1_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nb1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nb2_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nb2_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nt1_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nt1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nt2_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nt2_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_bc1_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_bc1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_bc2_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_bc2_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk1_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk1_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk2_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk2_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk3_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk3_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk4_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk4_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nb1_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nb1_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nb2_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nb2_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nt1_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nt1_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_nt2_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_nt2_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_bc1_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_bc1_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_bc2_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_bc2_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk1_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk1_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk2_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk2_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk3_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk3_gridded_history_new"

"%gdalFolder%/ogr2ogr" -f "CSV" ".\testtables\sampling_area_sk4_gridded_history.csv" %pg_connection_string% -lco STRING_QUOTING=IF_NEEDED "geohistory.sampling_area_sk4_gridded_history_new"

ENDLOCAL