#!/bin/bash -x

# This script loads the random test tables to test translation against.

# When test tables rightfully differ from original tables they have to be 
# dumped with the dump_test_tables.bat script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../conversion/sh/common.sh

coltypes="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

# ########################################## Process ######################################

# Make schema if it doesn't exist

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE SCHEMA IF NOT EXISTS casfri50_history_test";

# Run ogr2ogr

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_0_without_validity.csv" -nln "casfri50_history_test.test_0_without_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_0_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_0_with_validity.csv" -nln "casfri50_history_test.test_0_with_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_0_with_validity DROP COLUMN ogc_fid"


"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_2_without_validity.csv" -nln "casfri50_history_test.test_2_without_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_2_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_2_with_validity.csv" -nln "casfri50_history_test.test_2_with_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_2_with_validity DROP COLUMN ogc_fid"


"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_3_without_validity.csv" -nln "casfri50_history_test.test_3_without_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_3_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_3_with_validity.csv" -nln "casfri50_history_test.test_3_with_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_3_with_validity DROP COLUMN ogc_fid"


"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_4_without_validity.csv" -nln "casfri50_history_test.test_4_without_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_4_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" "testtables/test_4_with_validity.csv" -nln "casfri50_history_test.test_4_with_validity" $overwrite_tab -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "ALTER TABLE casfri50_history_test.test_4_with_validity DROP COLUMN ogc_fid"

