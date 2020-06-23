#!/bin/bash -x

# This script loads the SK SFVI Government Forest Island dataset (SK02) into PostgreSQL

# The format of the source dataset is a geodatabase
# Source data is split into a STAND feature class of polygons, and the following tables
# of attributes: DISTURBANCES, FEATURE_METADATA, HERBS, LAYER_1, LAYER_2, LAYER_3, SHRUBS,
# WETLAND.

# These tables need to be joined into a single source table in the database. All columns
# are unique. Polygons with type = OTH and no entries for all of SMR, LUC and TRANSP_CLASS
# are empty polygons forming the bounding extent of the dataset. These should be removed.

# The year of photography is included in the attribute FEATURE_SOURCE_DATE

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=SK02
srcFileName=SFVI_Island_Forest
fullTargetTableName=$targetFRISchema.sk02
tempTableName=${fullTargetTableName}_temp

gdbFileName_poly=STAND
gdbFileName_meta=FEATURE_METADATA
gdbFileName_dist=DISTURBANCES
gdbFileName_herbs=HERBS
gdbFileName_l1=LAYER_1
gdbFileName_l2=LAYER_2
gdbFileName_l3=LAYER_3
gdbFileName_shrubs=SHRUBS
gdbFileName_wetland=WETLAND

TableName_poly=${tempTableName}_poly
TableName_meta=${tempTableName}_meta
TableName_dist=${tempTableName}_dist
TableName_herbs=${tempTableName}_herbs
TableName_l1=${tempTableName}_l1
TableName_l2=${tempTableName}_l2
TableName_l3=${tempTableName}_l3
TableName_shrubs=${tempTableName}_shrubs
TableName_wetland=${tempTableName}_wetland

srcFullPath="$friDir/SK/$inventoryID/data/inventory/$srcFileName.gdb"

########################################## Process ######################################

# Run ogr2ogr for polygons, don't load non-FRI polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $TableName_poly $layer_creation_option \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbFileName_poly' \
        WHERE NOT(TYPE = 'OTH' AND SMR = ' ' AND LUC = ' ' AND TRANSP_CLASS = ' ')" \
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
-sql "SELECT *, poly_id AS poly_id_herbs FROM '$gdbFileName_herbs'" \
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
-sql "SELECT *, poly_id AS poly_id_shrubs FROM '$gdbFileName_shrubs'" \
-progress $overwrite_tab

# Temporarily swap fullTargetTableName with tempTableName
swap=$fullTargetTableName
fullTargetTableName=$tempTableName

# Join tables by sourcing the join code
source ./sk_SFVI_join_code.sh

fullTargetTableName=$swap

# Now load and join the wetland table. This table only occurs in SK02.

# Run ogr2ogr for wetland data
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_wetland" \
-nln $TableName_wetland $layer_creation_option \
-sql "SELECT *, poly_id AS poly_id_wetland FROM '$gdbFileName_wetland'" \
-progress $overwrite_tab


# Join wetland to the temp table and save as fullTargetTableName.
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
-- delete ogc and poly_id, joins don't work with matching names
ALTER TABLE $TableName_wetland 
DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id;

-- Join
DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
WITH I AS(
  SELECT wetland_veg, wetland_class, wetland_landform, poly_id_wetland 
  FROM $TableName_wetland 
  GROUP BY wetland_veg, wetland_class, wetland_landform, poly_id_wetland)
SELECT * FROM $tempTableName A 
LEFT JOIN I ON A.poly_id = I.poly_id_wetland;

--drop tables
DROP TABLE IF EXISTS $TableName_wetland;
DROP TABLE IF EXISTS $tempTableName;

-- drop duplicate poly_ids
ALTER TABLE $fullTargetTableName  
  DROP COLUMN poly_id_wetland;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh