#!/bin/bash -x

# This script loads the SK SFVI Industry WEYCO data (SK05) into PostgreSQL

# The format of the source dataset is a geodatabase
# Source data is split into a STAND feature class of polygons, and the following tables
# of attributes: DISTURBANCES, FEATURE_METADATA, HERBS, LAYER_1, LAYER_2, LAYER_3, SHRUBS.

# These tables need to be joined into a single source table in the database.
# crown_closure column is not unique and needs to be renamed to shrubs_crown_closure
# and herbs_crown_closure in the HERBS and SHRUBS tables.
# Empty bounding polygons are removed by dropping columns where FCT code is 9000
# and the NVSL attribute is NULL.

# Common code to do the join is shared between SK02, SK03, SK04 and SK05 and is sourced from
# sk_SFVI_join_code.sh

# The year of photography is included in the attribute FEATURE_SOURCE_DATE

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# The projection of the source data is either in a format unknown to PostGIS, 
# or it is incorrectly identified by PostGIS. For this reason the proj4 string of the source data
# projection needs to be defined using the s_srs option.

######################################## Set variables #######################################

source ./common.sh

inventoryID=SK05
srcFileName=SFVI_WEYCO_PAFMA
fullTargetTableName=$targetFRISchema.sk05

gdbFileName_poly=STAND
gdbFileName_meta=FEATURE_METADATA
gdbFileName_dist=DISTURBANCES
gdbFileName_herbs=HERBS
gdbFileName_l1=LAYER_1
gdbFileName_l2=LAYER_2
gdbFileName_l3=LAYER_3
gdbFileName_shrubs=SHRUBS

TableName_poly=${fullTargetTableName}_poly
TableName_meta=${fullTargetTableName}_meta
TableName_dist=${fullTargetTableName}_dist
TableName_herbs=${fullTargetTableName}_herbs
TableName_l1=${fullTargetTableName}_l1
TableName_l2=${fullTargetTableName}_l2
TableName_l3=${fullTargetTableName}_l3
TableName_shrubs=${fullTargetTableName}_shrubs

srcFullPath="$friDir/SK/$inventoryID/data/inventory/$srcFileName.gdb"

########################################## Process ######################################

# Run ogr2ogr for polygons, don't load non-FRI polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $TableName_poly $layer_creation_option \
-s_srs '+proj=utm +zone=12 +ellps=GRS80 +datum=NAD83 +units=m +no_defs' \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbFileName_poly' \
        WHERE NOT(FCT_CODE = 9000 AND NVSL IS NULL)" \
-progress $overwrite_tab

# Run ogr2ogr for meta data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_meta" \
-nln $TableName_meta $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_meta FROM '$gdbFileName_meta'" \
-progress $overwrite_tab

# Run ogr2ogr for dist data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_dist" \
-nln $TableName_dist $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_dist FROM '$gdbFileName_dist'" \
-progress $overwrite_tab

# Run ogr2ogr for herbs data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_herbs" \
-nln $TableName_herbs $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_herbs, crown_closure AS herbs_crown_closure FROM '$gdbFileName_herbs'" \
-progress $overwrite_tab

# Run ogr2ogr for layer 1 data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_l1" \
-nln $TableName_l1 $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_l1 FROM '$gdbFileName_l1'" \
-progress $overwrite_tab

# Run ogr2ogr for layer 2 data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_l2" \
-nln $TableName_l2 $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_l2 FROM '$gdbFileName_l2'" \
-progress $overwrite_tab

# Run ogr2ogr for layer 3 data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_l3" \
-nln $TableName_l3 $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_l3 FROM '$gdbFileName_l3'" \
-progress $overwrite_tab

# Run ogr2ogr for shrubs data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_shrubs" \
-nln $TableName_shrubs $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_shrubs, crown_closure AS shrubs_crown_closure FROM '$gdbFileName_shrubs'" \
-progress $overwrite_tab

# join tables by sourcing the join code
source ./sk_SFVI_join_code.sh

createSQLSpatialIndex=True

source ./common_postprocessing.sh