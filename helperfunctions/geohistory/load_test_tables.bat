:: This script loads the random test tables to test translation against.

:: When test tables rightfully differ from original tables they have to be 
:: dumped with the dump_test_tables.bat script and pushed back in the source tree.

:: #################################### Set variables ######################################

SETLOCAL

CALL ..\..\conversion\bat\common.bat

IF "%pgversion%"=="" SET pgversion=11

:: ########################################## Process ######################################

:: Make schema if it doesn't exist

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE SCHEMA IF NOT EXISTS geohistory";

::Run ogr2ogr

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_0_without_validity.csv" -nln "geohistory.test_0_without_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_0_without_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_0_with_validity.csv" -nln "geohistory.test_0_with_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_0_with_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_2_without_validity.csv" -nln "geohistory.test_2_without_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_2_without_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_2_with_validity.csv" -nln "geohistory.test_2_with_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_2_with_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_3_without_validity.csv" -nln "geohistory.test_3_without_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_3_without_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_3_with_validity.csv" -nln "geohistory.test_3_with_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_3_with_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_4_without_validity.csv" -nln "geohistory.test_4_without_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_4_without_validity DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./testtables%pgversion%/test_4_with_validity.csv" -nln "geohistory.test_4_with_validity" %overwrite_tab% -lco COLUMN_TYPES="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE geohistory.test_4_with_validity DROP COLUMN ogc_fid"
ENDLOCAL