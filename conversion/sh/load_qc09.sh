#!/bin/bash -x

# This script loads the Quebec (QC04) into PostgreSQL

# The format of the source dataset is a geodatabase comtaining 4 tables:
	# PEE_MAJ_PROV - this is the main table containing the geometries
	# META_MAJ_PROV - this table contains additional attributes required for translation
	# ETAGE_MAJ_PROV - this table contains species info with multiple species per row
	# ESSENCE_MAJ_PROV - this table also contains species info, but with one row per species

# The year of photography is included as the AN_PRO_ORI attribute in the META_MAJ_PROV table

# The PEE_MAJ_PROV and META_MAJ_PROV tables need to be loaded and joined on the
# GEOC_MAJ unique identifier. ETAGE_MAJ_PROV and ESSENCE_MAJ_PROV don't need to be loaded since they do not
# apply to that version of the inventory.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable
# in the configuration file.

# QC03, QC04 and QC05 all use the same source inventory table. Here we filter the full table to only
# include rows where ver_prg NOT LIKE '%AIPF%'.
# These rows use the INI04 standard (see issue #429 for details).

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC09
srcFileName=CARTE_ECO_MAJ_PROV_GPKG
srcFullPath="$friDir/QC/QC08/data/inventory/$srcFileName.gpkg"

gdbFileName_poly=pee_maj
gdbFileName_meta=meta_maj

fullTargetTableName=$targetFRISchema.qc09
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta

########################################## Process ######################################

# Run ogr2ogr for polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg NOT LIKE '%AIPF%'" \
-progress $overwrite_tab

# Run ogr2ogr for meta table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbFileName_meta WHERE ver_prg NOT LIKE '%AIPF%'" \
-progress $overwrite_tab

# Join META and ETAGE tables to polygons using the GEOCODE attribute.
# The ogc_fid attributes are no longer unique identifiers after the
# join so a new ogc_fid is created.
# Split geocode into 2 columns for use in cas_id.
# Original tables are deleted at the end.

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON $tableName_poly (geoc_maj);

-- drop all ogr_fid columns
ALTER TABLE $tableName_poly DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- drop geometry columns from meta
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS wkb_geometry;

-- rename geocode, no_prg, ver_prg in meta
ALTER TABLE $tableName_meta RENAME COLUMN geoc_maj TO meta_geoc_maj;
ALTER TABLE $tableName_meta RENAME COLUMN no_prg TO meta_no_prg;
ALTER TABLE $tableName_meta RENAME COLUMN ver_prg TO meta_ver_prg;

-- join qc04_poly, qc04_meta
DROP TABLE IF EXISTS  $fullTargetTableName;
CREATE TABLE  $fullTargetTableName AS
SELECT *, substring(replace(poly.geoc_maj, ',','.'), 1, 10) geoc_maj_1_10, substring(replace(poly.geoc_maj, ',','.'), 11, 10) geoc_maj_11_20
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta
  on poly.geoc_maj = meta.meta_geoc_maj;

--update ogc_fid
ALTER TABLE $fullTargetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $fullTargetTableName ADD COLUMN ogc_fid INT;
UPDATE $fullTargetTableName SET ogc_fid=temp_key;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS temp_key;

--drop extra geocode attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geoc_maj;

--drop tables
DROP TABLE IF EXISTS $tableName_poly;
DROP TABLE IF EXISTS $tableName_meta;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh
