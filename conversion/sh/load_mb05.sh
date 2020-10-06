#!/bin/bash -x

# This script loads the Manitoba FRI forest inventory (MB05) into PostgreSQL

# Both MB05 and MB06 are stored in the same geodatabase table.
# MB05 uses the FRI standard and only includes the rows labelled FRI in the 
# FRI_FLI column. MB06 uses the FLI standard and includes the rows labelled
# FLI in the FRI_FLI column.

# The year of photography is included in the attributes table (YEARPHOTO)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Source data does not have a unique set of identifiers that can trace from the cas_id 
# back to the source polygon.
# We will add a unique ID (poly_id) to the table before loading.

######################################## Set variables #######################################

source ./common.sh

inventoryID=MB05

srcFileName=MFAGeodatabase
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
MB_subFolder=MB/$inventoryID/data/inventory/

gdbTableName=MB_FRIFLI_Updatedto2010FINAL_v6
fullTargetTableName=$targetFRISchema.mb05

########################################## Process ######################################

# Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
# will return an error which can be ignored.
# SQLite is needed to add the id based on rowid.
# Should be activated only at the first load otherwise it would brake the translation tables tests. 
# Only runs once, when flag file poly_id_added.txt does not exist.

if [ ! -e "$friDir/$MB_subFolder/poly_id_added.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -dialect SQLite -sql "UPDATE $gdbTableName set poly_id = rowid"

	echo " " > "$friDir/$MB_subFolder/poly_id_added.txt"
fi

# Run ogr2ogr to load all table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT fid_mb_fri_v11_updatedto2010finalerased,
fri_fli,
mu_id,
yearphoto,
decade,
section,
year_org,
species,
covertype,
subtype,
site,
cut,
crown,
productivity,
cover_type,
wg,
land_type,
subt_desc,
sp_1,
sp_1per,
sp_2,
sp_2per,
sp_3,
sp_3per,
sp_4,
sp_4per,
sp_5,
sp_5per,
sp_6,
sp_6per,
sp_7,
sp_7per,
spper_total,
moist,
lform,
height,
crowncl,
v_type,
ecozone,
ecozone_name,
status_id,
owner_id,
section_new,
section_new_name,
update_2010,
age_2010,
age_2011,
cut_2011,
age_class2010, 
shape_length,
shape_area,
poly_id, 
'$srcFileName' AS src_filename, '$inventoryID' AS inventory_id 
FROM '$gdbTableName' 
WHERE FRI_FLI='FRI'" \
-progress $overwrite_tab

createSQLSpatialIndex=True

source ./common_postprocessing.sh