#!/bin/bash -x

# This script loads the NWT FVI forest inventory (NT02) into PostgreSQL

# The format of the source dataset is a geodatabase, which contains three files that
# need to be joined: geometries, attributes, photo year.

# 719 geometry polygons have FC_ID values of 1000000 and do not have any associated attributes.
# These are slivers and are removed after loading.

# 2,573 geometry polygons contain duplicate FC_ID values. We assume these are cases where a single
# polygon has been split into multiple polygons during processing. We merge them together.

# 31,617 rows in the attributes table have duplicate FC_IDs. Some of these appear to be errors where
# the same data is duplicated in multiple rows. In other cases the rows have different values.

# 31,547 rows in the attribute table have no FC_ID value.

# The year of photography is included the Inventory_Extent table in the gdb.

# Load the geometries, attributes, and Inventory_Extent tables separately.
# Then use ogrinfo to join them using the FC_ID attribute and a left join.
# Add a new unique ogc_fid column
# Finally delete the attributes, geometries and Inventory_Extent tables from the database.

# Some polygons have multiple attributes rows in the attributes table, this
# results in duplication of these polygons after the join is complete.
# In some case multiple polygons have the same fc_id value that matches only
# one row in the attributes table. In these cases the attributes are duplicated
# accross each polygon.

# If the tables already exists, they can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

srcFileName=NT_FORCOV
gdbFileName_geometry=$srcFileName
gdbFileName_attributes=NT_FORCOV_ATT
gdbFileName_photoyear=Inventory_Extents
srcFullPath="$friDir/NT/NT02/NT_FORCOV.gdb"

targetTableName=$targetFRISchema.nt02
geometryTableName=${targetTableName}_geometry
attributeTableName=${targetTableName}_attributes
photoyearTableName=${targetTableName}_photoyear

########################################## Process ######################################

# Run ogr2ogr for geometries
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_geometry" \
-nln $geometryTableName $layer_creation_option \
-sql "SELECT *, '$srcFileName' AS src_filename FROM '$gdbFileName_geometry'" \
-progress $overwrite_tab

# Run ogr2ogr for attributes
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_attributes" \
-lco PRECISION=NO \
-nln $attributeTableName \
-progress $overwrite_tab

# Run ogr2ogr for photo year
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_photoyear" \
-nln $photoyearTableName $layer_creation_option \
-progress $overwrite_tab

# Join attributes and photo year tables to geometries.
# Some columns need to be dropped before joining.
# The ogc_fid attributes are no longer unique identifiers 
# after the join so a new ogc_fid is created.
# Original tables are deleted at the end.
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $attributeTableName DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $attributeTableName DROP COLUMN IF EXISTS invproj_id;
ALTER TABLE $attributeTableName DROP COLUMN IF EXISTS seam_id;
ALTER TABLE $geometryTableName DROP COLUMN IF EXISTS ogc_fid;

DROP TABLE IF EXISTS ${targetTableName}_geom_merged; 
CREATE TABLE ${targetTableName}_geom_merged AS
WITH dup AS (
  SELECT fc_id::int
  FROM $geometryTableName
  WHERE fc_id != 1000000
  GROUP BY fc_id::int
  HAVING count(*) > 1
)
SELECT a.fc_id::int, 
       min(invproj_id) invproj_id,
       sum(areaha) areaha, 
       ST_Union(wkb_geometry) geom, 
       min(src_filename) src_filename
FROM dup a, $geometryTableName b 
WHERE a.fc_id::int = b.fc_id::int
GROUP BY a.fc_id::int
UNION ALL
SELECT fc_id::int, 
       min(invproj_id) invproj_id,
       sum(areaha) areaha, 
       ST_Union(wkb_geometry) geom, 
       min(src_filename) src_filename
FROM $geometryTableName
GROUP BY fc_id::int
HAVING count(*) = 1;

DROP TABLE IF EXISTS ${targetTableName}_unique_att;
CREATE TABLE ${targetTableName}_unique_att AS
SELECT DISTINCT ON (fc_id) *
FROM $attributeTableName;

CREATE INDEX ON ${targetTableName}_unique_att (fc_id);

DROP TABLE IF EXISTS ${targetTableName}_geom_att;
CREATE TABLE ${targetTableName}_geom_att AS
SELECT a.fc_id afc_id, a.invproj_id, a.geom, a.areaha, a.src_filename, b.*
FROM ${targetTableName}_geom_merged a 
LEFT OUTER JOIN ${targetTableName}_unique_att b USING (fc_id);

DROP TABLE IF EXISTS $targetTableName; 
CREATE TABLE $targetTableName AS
SELECT *
FROM ${targetTableName}_geom_att a
LEFT JOIN (SELECT project_id, project_label FROM $photoyearTableName) b ON a.invproj_id=b.project_id;

ALTER TABLE $targetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $targetTableName ADD COLUMN ogc_fid INT;
UPDATE $targetTableName SET ogc_fid=temp_key;
ALTER TABLE $targetTableName DROP COLUMN IF EXISTS temp_key;

DROP TABLE IF EXISTS $photoyearTableName;
DROP TABLE IF EXISTS $geometryTableName;
DROP TABLE IF EXISTS $attributeTableName;
DROP TABLE IF EXISTS ${targetTableName}_geom_merged; 
DROP TABLE IF EXISTS ${targetTableName}_unique_att;
DROP TABLE IF EXISTS ${targetTableName}_geom_att;
"






