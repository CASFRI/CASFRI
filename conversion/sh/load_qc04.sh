#!/bin/bash -x

# This script loads the Quebec (QC04) into PostgreSQL.

# The source dataset is a geodatabase containing four tables:

	# PEE_MAJ_PROV - Main table containing the geometries
	# META_MAJ_PROV - Contains additional attributes required for translation
	# ETAGE_MAJ_PROV - Contains species info with multiple species per row
	# ESSENCE_MAJ_PROV - Also contains species info, but with one row per species

# The year of photography is included as the AN_PRO_ORI attribute in the 
# META_MAJ_PROV table

# PEE_MAJ_PROV and META_MAJ_PROV tables are loaded and joined on the
# GEOC_MAJ unique id. ETAGE_MAJ_PROV and ESSENCE_MAJ_PROV are not loaded since 
# they are not related to this version of the inventory.

# Load into target schema and table defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI"
# variable in the configuration file.

# QC03, QC04 and QC05 all come from the same FRI. Here we filter the full table
# to rows where ver_prg NOT LIKE '%AIPF%'.
# These rows follow the INI04 standard (see issue #429 for details).

######################################## Set variables #########################

source ./common.sh

inventoryID=QC04
srcFileName=CARTE_ECO_MAJ_PROV_10
srcFullPath="$friDir/QC/$inventoryID/data/inventory/$srcFileName.gdb"

gdbFileName_poly=PEE_MAJ_PROV
gdbFileName_meta=META_MAJ_PROV

fullTargetTableName=$targetFRISchema.qc04
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta

########################################## Process #############################

# Load the polygon table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg NOT LIKE '%AIPF%'" \
-progress $overwrite_tab

# Load the attribute table (meta)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbFileName_meta WHERE ver_prg NOT LIKE '%AIPF%'" \
-progress $overwrite_tab

# Join META attributes to polygons using the GEOCODE attribute.
# Only the POLY table's OGC_FID attribute is preserved for inclusion in CAS_ID.
# Split GEOCODE into two columns for use in CAS_ID.
# Intermediate tables are dropped at the end.
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
-- Drop the meta table ogc_fid column as we only need the poly table one
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- Drop the geometry column from the meta table as well
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS wkb_geometry;

-- Rename GEOCODE, NO_PRG, VER_PRG in the meta table so they don't conflict after the join.
ALTER TABLE $tableName_meta RENAME COLUMN geoc_maj TO meta_geoc_maj;
ALTER TABLE $tableName_meta RENAME COLUMN no_prg TO meta_no_prg;
ALTER TABLE $tableName_meta RENAME COLUMN ver_prg TO meta_ver_prg;

-- Create an index on the joining attribute
CREATE INDEX ON $tableName_meta (meta_geoc_maj);

-- Drop the table if it exists
DROP TABLE IF EXISTS $fullTargetTableName CASCADE;

-- Join poly and meta into final table
CREATE TABLE $fullTargetTableName AS
SELECT *, substring(replace(poly.geoc_maj, ',','.'), 1, 10) geoc_maj_1_10, 
          substring(replace(poly.geoc_maj, ',','.'), 11, 10) geoc_maj_11_20
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  ON poly.geoc_maj = meta.meta_geoc_maj;

-- Drop final table GEOCODE duplicate attribute
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geoc_maj;

-- Drop intermediate tables
DROP TABLE IF EXISTS $tableName_poly CASCADE;
DROP TABLE IF EXISTS $tableName_meta CASCADE;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh