:: This script loads the random test tables to test translation against.

:: When test tables rightfully differ from original tables they have to be 
:: dumped with the dump_test_tables.bat script and pushed back in the source tree.

:: #################################### Set variables ######################################

SETLOCAL

CALL ..\..\conversion\bat\common.bat

IF "%pgversion%"=="" SET pgversion=11

:: ########################################## Process ######################################

:: Make schema if it doesn't exist

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE SCHEMA IF NOT EXISTS casfri50_test";

::Run ogr2ogr

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./data%pgversion%/cas_all_test.csv" -nln "casfri50_test.cas_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,inventory_id=text,orig_stand_id=text,stand_structure=text,num_of_layers=int,map_sheet_id=text,casfri_area=double precision,casfri_perimeter=double precision,src_inv_area=double precision,stand_photo_year=int"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE casfri50_test.cas_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./data%pgversion%/dst_all_test.csv" -nln "casfri50_test.dst_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,dist_type_1=text,dist_year_1=int,dist_ext_upper_1=int,dist_ext_lower_1=int,dist_type_2=text,dist_year_2=int,dist_ext_upper_2=int,dist_ext_lower_2=int,dist_type_3=text,dist_year_3=int,dist_ext_upper_3=int,dist_ext_lower_3=int,layer=int"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE casfri50_test.dst_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./data%pgversion%/eco_all_test.csv" -nln "casfri50_test.eco_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,wetland_type=text,wet_veg_cover=text,wet_landform_mod=text,wet_local_mod=text,eco_site=text,layer=int"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE casfri50_test.eco_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./data%pgversion%/lyr_all_test.csv" -nln "casfri50_test.lyr_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,soil_moist_reg=text,structure_per=int,structure_range=double precision,layer=int,layer_rank=int,crown_closure_upper=int,crown_closure_lower=int,height_upper=double precision,height_lower=double precision,productivity=text,productivity_type=text,species_1=text,species_per_1=int,species_2=text,species_per_2=int,species_3=text,species_per_3=int,species_4=text,species_per_4=int,species_5=text,species_per_5=int,species_6=text,species_per_6=int,species_7=text,species_per_7=int,species_8=text,species_per_8=int,species_9=text,species_per_9=int,species_10=text,species_per_10=int,origin_upper=int,origin_lower=int,site_class=text,site_index=double precision"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE casfri50_test.lyr_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" %pg_connection_string% "./data%pgversion%/nfl_all_test.csv" -nln "casfri50_test.nfl_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,soil_moist_reg=text,structure_per=integer,layer=integer,layer_rank=integer,crown_closure_upper=integer,crown_closure_lower=integer,height_upper=double precision,height_lower=double precision,nat_non_veg=text,non_for_anth=text,non_for_veg=text"

"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "ALTER TABLE casfri50_test.nfl_all_test DROP COLUMN ogc_fid"

ENDLOCAL