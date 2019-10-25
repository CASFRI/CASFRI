:: This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

:: The format of the source dataset is a single .E00 file

:: The year of photography is included as a shapefile. Photo year will be joined to the 
:: loaded table in PostgreSQL

:: Load into the ab06 target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Alberta Gordon Buchanan Tolko FRI was delivered as E00 which can not be loaded 
:: successfully without using ESRI tools, so it was to geodatabase in ArcGIS. This script 
:: will load the resulting geodatabase.

:: #################################### Set variables ######################################

SETLOCAL

:: Load config variables from local config file
IF EXIST "%~dp0\..\..\config.bat" ( 
  CALL "%~dp0\..\..\config.bat"
) ELSE (
  ECHO ERROR: NO config.bat FILE
  EXIT /b
)

:: Set unvariable variables

SET srcFileName=GB_S21_TWP
SET gdbFileName=%srcFileName%
SET srcFullPath="%friDir%\AB\AB06\%srcFileName%.gdb"

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"
SET fullTargetTableName=%targetFRISchema%.ab06


IF %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) ELSE (
  SET overwrite_tab=
)

:: ########################################## Process ######################################

:: Make schema if it doesn't exist

"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "CREATE SCHEMA IF NOT EXISTS casfri50_test";

::Run ogr2ogr

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "data/cas_all_test.csv" -nln "casfri50_test.cas_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,orig_stand_id=text,stand_structure=text,num_of_layers=int,identification_id=int,map_sheet_id=text,casfri_area=double precision,casfri_perimeter=double precision,src_inv_area=double precision,stand_photo_year=int"

"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE casfri50_test.cas_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "data/dst_all_test.csv" -nln "casfri50_test.dst_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,dist_type_1=text,dist_year_1=int,dist_ext_upper_1=int,dist_ext_lower_1=int,dist_type_2=text,dist_year_2=int,dist_ext_upper_2=int,dist_ext_lower_2=int,dist_type_3=text,dist_year_3=int,dist_ext_upper_3=int,dist_ext_lower_3=int,layer=int"

"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE casfri50_test.dst_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "data/eco_all_test.csv" -nln "casfri50_test.eco_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,wetland_type=text,wet_veg_cover=text,wet_landform_mod=text,wet_local_mod=text,eco_site=text"

"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE casfri50_test.eco_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "data/lyr_all_test.csv" -nln "casfri50_test.lyr_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,soil_moist_reg=text,structure_per=int,layer=int,layer_rank=int,crown_closure_upper=int,crown_closure_lower=int,height_upper=double precision,height_lower=double precision,productive_for=text,species_1=text,species_per_1=int,species_2=text,species_per_2=int,species_3=text,species_per_3=int,species_4=text,species_per_4=int,species_5=text,species_per_5=int,species_6=text,species_per_6=int,species_7=text,species_per_7=int,species_8=text,species_per_8=int,species_9=text,species_per_9=int,species_10=text,species_per_10=int,origin_upper=int,origin_lower=int,site_class=text,site_index=double precision"

"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE casfri50_test.lyr_all_test DROP COLUMN ogc_fid"

"%gdalFolder%/ogr2ogr" -f "PostgreSQL" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" "data/nfl_all_test.csv" -nln "casfri50_test.nfl_all_test" %overwrite_tab% -lco COLUMN_TYPES="cas_id=text,soil_moist_reg=text,structure_per=integer,layer=integer,layer_rank=integer,crown_closure_upper=integer,crown_closure_lower=integer,height_upper=double precision,height_lower=double precision,nat_non_veg=text,non_for_anth=text,non_for_veg=text"

"%gdalFolder%/ogrinfo" PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%" -sql "ALTER TABLE casfri50_test.nfl_all_test DROP COLUMN ogc_fid"

ENDLOCAL