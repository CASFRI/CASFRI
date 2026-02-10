#!/bin/bash -x

# This script loads the random test tables to test translation against.

# When test tables rightfully differ from original tables they have to be 
# dumped with the dump_test_tables.bat script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../common.sh

coltypes="row_id=int,id=int,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"

# ########################################## Process ######################################

# Make schema if it doesn't exist

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "CREATE SCHEMA IF NOT EXISTS casfri50_history_test";

# Run ogr2ogr

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_0_without_validity.csv" -nln "casfri50_history_test.test_0_without_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_0_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_0_with_validity.csv" -nln "casfri50_history_test.test_0_with_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_0_with_validity DROP COLUMN ogc_fid"


"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_2_without_validity.csv" -nln "casfri50_history_test.test_2_without_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_2_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_2_with_validity.csv" -nln "casfri50_history_test.test_2_with_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_2_with_validity DROP COLUMN ogc_fid"


"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_3_without_validity.csv" -nln "casfri50_history_test.test_3_without_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_3_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_3_with_validity.csv" -nln "casfri50_history_test.test_3_with_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_3_with_validity DROP COLUMN ogc_fid"


"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_4_without_validity.csv" -nln "casfri50_history_test.test_4_without_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_4_without_validity DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "testtables/test_4_with_validity.csv" -nln "casfri50_history_test.test_4_with_validity" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.test_4_with_validity DROP COLUMN ogc_fid"

