#!/bin/bash -x

# This script loads the random test tables to test translation against.

# When test tables rightfully differ from original tables they have to be 
# dumped with the dump_test_tables.sh script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../common.sh

coltypes="id=text,poly_id=int,isvalid=boolean,wkt_geometry=text,poly_type=text,ref_year=int,valid_year_begin=int,valid_year_end=int,valid_time=text"
coltypes_gridded="id=text,wkt_geometry=text,valid_year_begin=int,valid_year_end=int"

# ########################################## Process ######################################

# Make schema if it doesn't exist

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "CREATE SCHEMA IF NOT EXISTS casfri50_history_test";

# Run ogr2ogr

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nb1_history.csv" -nln "casfri50_history_test.sampling_area_nb1_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nb1_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nb2_history.csv" -nln "casfri50_history_test.sampling_area_nb2_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nb2_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nt1_history.csv" -nln "casfri50_history_test.sampling_area_nt1_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nt1_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nt2_history.csv" -nln "casfri50_history_test.sampling_area_nt2_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nt2_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_bc1_history.csv" -nln "casfri50_history_test.sampling_area_bc1_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_bc1_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_bc2_history.csv" -nln "casfri50_history_test.sampling_area_bc2_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_bc2_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk1_history.csv" -nln "casfri50_history_test.sampling_area_sk1_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk1_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk2_history.csv" -nln "casfri50_history_test.sampling_area_sk2_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk2_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk3_history.csv" -nln "casfri50_history_test.sampling_area_sk3_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk3_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk4_history.csv" -nln "casfri50_history_test.sampling_area_sk4_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk4_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nb1_gridded_history.csv" -nln "casfri50_history_test.sampling_area_nb1_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nb1_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nb2_gridded_history.csv" -nln "casfri50_history_test.sampling_area_nb2_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nb2_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nt1_gridded_history.csv" -nln "casfri50_history_test.sampling_area_nt1_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nt1_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_nt2_gridded_history.csv" -nln "casfri50_history_test.sampling_area_nt2_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_nt2_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_bc1_gridded_history.csv" -nln "casfri50_history_test.sampling_area_bc1_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_bc1_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_bc2_gridded_history.csv" -nln "casfri50_history_test.sampling_area_bc2_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_bc2_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk1_gridded_history.csv" -nln "casfri50_history_test.sampling_area_sk1_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk1_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk2_gridded_history.csv" -nln "casfri50_history_test.sampling_area_sk2_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk2_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk3_gridded_history.csv" -nln "casfri50_history_test.sampling_area_sk3_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk3_gridded_history DROP COLUMN ogc_fid"

"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" "./testtables/sampling_area_sk4_gridded_history.csv" -nln "casfri50_history_test.sampling_area_sk4_gridded_history" $overwriteTable -lco COLUMN_TYPES="$coltypes"_gridded

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE casfri50_history_test.sampling_area_sk4_gridded_history DROP COLUMN ogc_fid"
