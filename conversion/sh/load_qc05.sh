#!/bin/bash -x

# This script loads the Quebec (QC05) into PostgreSQL.

# The source dataset is a geodatabase containing four tables:

	# PEE_MAJ_PROV - Main table containing the geometries
	# META_MAJ_PROV - Contains additional attributes required for translation
	# ETAGE_MAJ_PROV - Contains species info with multiple species per row
	# ESSENCE_MAJ_PROV - Also contains species info, but with one row per species

# The year of photography is included as the AN_PRO_ORI attribute in the 
# META_MAJ_PROV table

# PEE_MAJ_PROV, META_MAJ_PROV, and ETAGE_MAJ_PROV tables are loaded
# and joined on the GEOC_MAJ unique id. We prefer ETAGE_MAJ_PROV over
# ESSENCE_MAJ_PROV because we need the source data to have one row per polygon.
# The same info is contained in both tables. Only one is needed.

# Load into target schema and table defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI"
# variable in the configuration file.

# QC03, QC04 and QC05 all come from the same FRI. Here we filter the full table
# to rows where ver_prg LIKE '%AIPF%'.
# These rows follow the IPF05 standard (see issue #429 for details).

######################################## Set variables #########################

source ./common.sh

inventoryID=QC05
srcFileName=CARTE_ECO_MAJ_PROV_10
srcFullPath="$friDir/QC/$inventoryID/data/inventory/$srcFileName.gdb"

gdbFileName_poly=PEE_MAJ_PROV
gdbFileName_meta=META_MAJ_PROV
gdbFileName_etage=ETAGE_MAJ_PROV

fullTargetTableName=$targetFRISchema.qc05
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta
tableName_etage=${fullTargetTableName}_etage
tableName_sup=${fullTargetTableName}_etage_sup
tableName_inf=${fullTargetTableName}_etage_inf
tableName_full=${fullTargetTableName}_full

########################################## Process #############################

# Load the polygon table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg LIKE '%AIPF%'" \
-progress $overwrite_tab

# Load the attribute table (meta)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbFileName_meta WHERE ver_prg LIKE '%AIPF%'" \
-progress $overwrite_tab

# Run ogr2ogr for etage table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_etage" \
-nln $tableName_etage $layer_creation_options $other_options \
-progress $overwrite_tab

# Join the POLY, META and ETAGE tables using the GEOCODE attribute.
# Only the POLY table's OGC_FID attribute is preserved for inclusion in CAS_ID.
# Etage table has two rows per polygon in cases with two layers. This is stored as a
# SUP and an INF row in the etage attribute. We split these into a SUP table and 
# a INF table before joining in order to preserve a 1 to 1 relationship. There 
# are therefore four tables to join at the end: poly, meta, sup and inf.
# We also split GEOCODE into two columns for use in cas_id.
# Intermediate tables are deleted at the end.

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
-- Create an intermediate table with SUP rows
DROP TABLE IF EXISTS $tableName_sup CASCADE;

CREATE TABLE $tableName_sup AS
SELECT geoc_maj sup_geoc_maj, 
       etage sup_etage, 
       ty_couv_et sup_ty_couv_et,
       densite sup_densite,
       hauteur sup_hauteur,
       cl_age_et sup_cl_age_et,
       eta_ess_pc sup_eta_ess_pc
FROM $tableName_etage 
WHERE etage = 'SUP';

-- Create an intermediate table with INF rows
DROP TABLE IF EXISTS $tableName_inf CASCADE;

CREATE TABLE $tableName_inf AS
SELECT geoc_maj inf_geoc_maj, 
	     etage inf_etage, 
	     ty_couv_et inf_ty_couv_et,
	     densite inf_densite,
	     hauteur inf_hauteur,
	     cl_age_et inf_cl_age_et,
	     eta_ess_pc inf_eta_ess_pc
FROM $tableName_etage 
WHERE etage = 'INF';

-- Drop the meta table OGC_FID attribute as we only need the poly table one
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- Drop the geometry column from the meta table as well
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS wkb_geometry;

-- Rename GEOCODE, NO_PRG, VER_PRG in the meta table so they don't conflict after the join.
ALTER TABLE $tableName_meta RENAME COLUMN geoc_maj TO meta_geoc_maj;
ALTER TABLE $tableName_meta RENAME COLUMN no_prg TO meta_no_prg;
ALTER TABLE $tableName_meta RENAME COLUMN ver_prg TO meta_ver_prg;

-- Join qc05_poly, qc05_meta, qc05_etage_sup and qc05_etage_inf into qc05.
CREATE INDEX ON $tableName_meta (meta_geoc_maj);
CREATE INDEX ON $tableName_sup (sup_geoc_maj);
CREATE INDEX ON $tableName_inf (inf_geoc_maj);

-- Drop the table if it exists
DROP TABLE IF EXISTS $fullTargetTableName CASCADE;

-- Join the three tables into the final table
CREATE TABLE $fullTargetTableName AS
SELECT *, substring(replace(poly.geoc_maj, ',','.'), 1, 10) geoc_maj_1_10, 
          substring(replace(poly.geoc_maj, ',','.'), 11, 10) geoc_maj_11_20
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  ON poly.geoc_maj = meta.meta_geoc_maj
LEFT join $tableName_sup AS sup 
  ON poly.geoc_maj = sup.sup_geoc_maj
LEFT join $tableName_inf AS inf 
  ON poly.geoc_maj = inf.inf_geoc_maj
ORDER BY poly.geoc_maj;

-- Drop intermediate tables GEOCODE attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS sup_geoc_maj;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS inf_geoc_maj;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geoc_maj;

-- Drop intermediate tables
DROP TABLE IF EXISTS $tableName_poly CASCADE;
DROP TABLE IF EXISTS $tableName_meta CASCADE;
DROP TABLE IF EXISTS $tableName_etage CASCADE;
DROP TABLE IF EXISTS $tableName_sup CASCADE;
DROP TABLE IF EXISTS $tableName_inf CASCADE;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh