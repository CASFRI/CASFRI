#!/bin/bash -x

# This script loads the Quebec (QC04) into PostgreSQL

# The format of the source dataset is a geodatabase comtaining 4 tables:
	# PEE_MAJ_PROV - this is the main table containing the geometries
	# META_MAJ_PROV - this table contains additional attributes required for translation
	# ETAGE_MAJ_PROV - this table contains species info with multiple species per row
	# ESSENCE_MAJ_PROV - this table also contains species info, but with one row per species

# The year of photography is included as the AN_PRO_ORI attribute in the META_MAJ_PROV table

# The PEE_MAJ_PROV, META_MAJ_PROV, and ETAGE_MAJ_PROV tables need to be loaded and joined on the
# GEOCODE unique identifier. We prefer ETAGE_MAJ_PROV over ESSENCE_MAJ_PROV because we need source
# data with one row per polygon. The same info is contained in both tables so only one is needed.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# QC03, QC04 and QC05 all use the same source inventory table. Here we filter the full table to only
# include rows where ver_prg = 'INITIALE' OR (ver_prg = 'MIXTE' AND in_etage = 'N'). 
# These rows use the IPF04 standard (see issue #429 for details).

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC04
srcFileName=CARTE_ECO_MAJ_PROV_10
srcFullPath="$friDir/QC/$inventoryID/data/inventory/$srcFileName.gdb"

gdbFileName_poly=PEE_MAJ_PROV
gdbFileName_meta=META_MAJ_PROV
gdbFileName_etage=ETAGE_MAJ_PROV

fullTargetTableName=$targetFRISchema.qc04
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta
tableName_etage=${fullTargetTableName}_etage
tableName_full=${fullTargetTableName}_full

########################################## Process ######################################

# Run ogr2ogr for polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbFileName_poly' WHERE no_prg = '4'" \
-progress $overwrite_tab

# Run ogr2ogr for meta table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-sql "SELECT * FROM '$gdbFileName_meta' WHERE no_prg = '4'" \
-progress $overwrite_tab

# Join META and ETAGE tables to polygons using the GEOCODE attribute.
# The ogc_fid attributes are no longer unique identifiers after the 
# join so a new ogc_fid is created.
# Original tables are deleted at the end.

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON $tableName_poly (geocode);

-- drop all ogr_fid columns
ALTER TABLE $tableName_poly DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- drop geometry columns from meta
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS wkb_geometry;

-- rename geocode, no_prg, ver_prg in meta
ALTER TABLE $tableName_meta RENAME COLUMN geocode TO meta_geocode;
ALTER TABLE $tableName_meta RENAME COLUMN no_prg TO meta_no_prg;
ALTER TABLE $tableName_meta RENAME COLUMN ver_prg TO meta_ver_prg;

-- join qc04_poly, qc04_meta
DROP TABLE IF EXISTS  $tableName_full;
CREATE TABLE  $tableName_full AS
SELECT *
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  on poly.geocode = meta.meta_geocode;

-- filter by fourth inventory rows
DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
SELECT *
FROM $tableName_full
WHERE ver_prg = 'INITIALE' OR (ver_prg = 'MIXTE' AND in_etage = 'N');
  
--update ogc_fid
ALTER TABLE $fullTargetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $fullTargetTableName ADD COLUMN ogc_fid INT;
UPDATE $fullTargetTableName SET ogc_fid=temp_key;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS temp_key;

--drop extra geocode attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geocode;

--drop tables
DROP TABLE IF EXISTS $tableName_poly;
DROP TABLE IF EXISTS $tableName_meta;
DROP TABLE IF EXISTS $tableName_full;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh