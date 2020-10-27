:: This script loads the Manitoba FLI forest inventory (MB06) into PostgreSQL

:: Both MB05 and MB06 are stored in the same geodatabase table.
:: MB05 uses the FRI standard and only includes the rows labelled FRI in the 
:: FRI_FLI column. MB06 uses the FLI standard and includes the rows labelled
:: FLI in the FRI_FLI column.

:: The year of photography is included in the attributes table (YEARPHOTO)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: Source data does not have a unique set of identifiers that can trace from the cas_id 
:: back to the source polygon.
:: We will add a unique ID (poly_id) to the table before loading.

:: ######################################## Set variables #######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=MB06

SET srcFileName=MFAGeodatabase
SET srcFullPath="%friDir%/MB/%inventoryID%/data/inventory/%srcFileName%.gdb"
SET MB_subFolder=MB/%inventoryID%/data/inventory/

SET gdbTableName=MB_FRIFLI_Updatedto2010FINAL_v6
SET fullTargetTableName=%targetFRISchema%.mb06

:: ########################################## Process ######################################

:: Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
:: will return an error which can be ignored.
:: SQLite is needed to add the id based on rowid.
:: Should be activated only at the first load otherwise it would brake the translation tables tests. 
:: Only runs once, when flag file poly_id_added.txt does not exist.

if not exist "%friDir%/%MB_subFolder%/%poly_id_added.txt" (
	"%gdalFolder%/ogrinfo" %srcFullPath% %gdbTableName% -sql "ALTER TABLE %gdbTableName% DROP COLUMN poly_id"
	"%gdalFolder%/ogrinfo" %srcFullPath% %gdbTableName% -sql "ALTER TABLE %gdbTableName% ADD COLUMN poly_id integer"
	"%gdalFolder%/ogrinfo" %srcFullPath% %gdbTableName% -dialect SQLite -sql "UPDATE %gdbTableName% set poly_id = rowid"

	echo " " > "%friDir%/%MB_subFolder%/poly_id_added.txt"
)

:: Define the filter query

SET query=SELECT fid_mb_fli_fmu11to14_updatedto2010final, ^
fri_fli, ^
sacov1, ^
saclass1, ^
sacov2, ^
saclass2, ^
covarr, ^
canlay, ^
canrank, ^
canpat, ^
comht, ^
sph, ^
cc, ^
ht, ^
sp1, ^
sp1per, ^
sp2, ^
sp2per, ^
sp3, ^
sp3per, ^
sp4, ^
sp4per, ^
sp5, ^
sp5per, ^
sp6, ^
sp6per, ^
origin, ^
landmod, ^
lmodno, ^
soiltex, ^
topo, ^
slopepos, ^
slper, ^
asp, ^
drainpat, ^
mr, ^
nnf_anth, ^
mod1, ^
ext1, ^
orig1, ^
mod2, ^
ext2, ^
orig2, ^
treatmod, ^
treatext, ^
trorig, ^
weteco1, ^
weteco2, ^
dtype, ^
yearphoto_fli, ^
us2canlay, ^
us2canrank, ^
us2canpat, ^
us2sph, ^
us2cc, ^
us2ht, ^
us2sp1, ^
us2sp1per, ^
us2sp2, ^
us2sp2per, ^
us2sp3, ^
us2sp3per, ^
us2sp4, ^
us2sp4per, ^
us2sp5, ^
us2sp5per, ^
us2sp6, ^
us2sp6per, ^
us2origin, ^
us2nnf_anth, ^
us3canlay, ^
us3canrank, ^
us3canpat, ^
us3sph, ^
us3cc, ^
us3ht, ^
us3sp1, ^
us3sp1per, ^
us3sp2, ^
us3sp2per, ^
us3sp3, ^
us3sp3per, ^
us3sp4, ^
us3sp4per, ^
us3sp5, ^
us3sp5per, ^
us3sp6, ^
us3sp6per, ^
us3origin, ^
us3nnf_anth, ^
us4canlay, ^
us4canrank, ^
us4canpat, ^
us4sph, ^
us4cc, ^
us4ht, ^
us4sp1, ^
us4sp1per, ^
us4sp2, ^
us4sp2per, ^
us4sp3, ^
us4sp3per, ^
us4sp4, ^
us4sp4per, ^
us4sp5, ^
us4sp5per, ^
us4sp6, ^
us4sp6per, ^
us4origin, ^
us4nnf_anth, ^
us5canlay, ^
us5canrank, ^
us5canpat, ^
us5sph, ^
us5cc, ^
us5ht, ^
us5sp1, ^
us5sp1per, ^
us5sp2, ^
us5sp2per, ^
us5sp3, ^
us5sp3per, ^
us5sp4, ^
us5sp4per, ^
us5sp5, ^
us5sp5per, ^
us5sp6, ^
us5sp6per, ^
us5origin, ^
us5nnf_anth, ^
sp1_sum, ^
sp1per_sum, ^
sp2_sum, ^
sp2per_sum, ^
sp3_sum, ^
sp3per_sum, ^
sp4_sum, ^
sp4per_sum, ^
sp5_sum, ^
sp5per_sum, ^
sp6_sum, ^
sp6per_sum, ^
cc_sum, ^
ht_sum, ^
spp_sum, ^
origin_sum, ^
mu_fli, ^
si_jp, ^
si_bs, ^
si_ws, ^
si_ta, ^
si_ba, ^
si_tl, ^
si_wb, ^
si_bf, ^
si_leading, ^
strata_fli, ^
denagg_fli, ^
density_fli, ^
harvest_yr, ^
fire_year, ^
update_2010_fli, ^
covertype_fli, ^
agecl5yr_2010, ^
vol_key, ^
problem, ^
shape_length, ^
shape_area, ^
poly_id,  ^
'%srcFileName%' AS src_filename, '%inventoryID%' AS inventory_id ^
FROM '%gdbTableName%' ^
WHERE FRI_FLI='FLI'


:: Run ogr2ogr to load the table

"%gdalFolder%/ogr2ogr" ^
-f "PostgreSQL" %pg_connection_string% %srcFullPath% %gdbTableName% ^
-nln %fullTargetTableName% %layer_creation_options% %other_options% ^
-sql "%query%" ^
-progress %overwrite_tab%

SET createSQLSpatialIndex=True

CALL .\common_postprocessing.bat
