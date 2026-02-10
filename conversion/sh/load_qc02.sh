#!/bin/bash -x

# This script loads the Quebec (QC02) into PostgreSQL.

# The source dataset is a geodatabase.

# Name of the db: PEE_MAJ_PROV.gdb
# Name of the table: DDE_20K_PEU_ECOFOR_MAJ_VUE_SE

# We also load the DDE_META_MAJ_VUE table from META_PROV.gdb in order to recover
# photo years info. Only the GEOCODE, NO_PRG, VER_PRG, AN_PRO_SOU, AN_SAISIE and
# AN_PRO_ORI attributes are required. All other attributes relate to correction,
# acquisition and production methods.

# All tables are joined using the GEOCODE attribute.

# Load into target schema and table defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI"
# variable in the configuration file.

# QC02, QC06 and QC07 all come from the same FRI. Here we filter the full table
# to rows where VER_PRG IS NULL.
# These rows follow the INI03 standard (see issue #429 for details).

######################################## Set variables #########################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=QC02
srcFileName_poly=PEE_MAJ_PROV
srcFileName_meta=META_PROV

srcFullPath_poly="$friDir/QC/$inventoryID/data/inventory/$srcFileName_poly.gdb"
srcFullPath_meta="$friDir/QC/$inventoryID/data/inventory/$srcFileName_meta.gdb"

gdbFileName_poly=DDE_20K_PEU_ECOFOR_MAJ_VUE_SE
gdbFileName_meta=DDE_META_MAJ_VUE

fullTargetTableName=$targetFRISchema.qc02
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta

########################################## Process #############################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Load the polygon table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath_poly" "$gdbFileName_poly" \
-nln $tableName_poly $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName_poly' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg IS NULL" \
-progress $overwriteTable

# Load the attribute table (meta)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath_meta" "$gdbFileName_meta" \
-nln $tableName_meta $gdalLco $gdalOtherOptions \
-sql "SELECT geocode AS meta_geocode, no_prg AS meta_no_prg, ver_prg AS meta_ver_prg, an_pro_sou, an_saisie, an_pro_ori FROM $gdbFileName_meta WHERE ver_prg IS NULL" \
-progress $overwriteTable

# Join META attributes to polygons using the GEOCODE attribute.
# Only the POLY table's OGC_FID attribute is preserved for inclusion in CAS_ID.
# Split GEOCODE into two columns for use in CAS_ID.
# Intermediate tables are dropped at the end.
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
-- Drop the meta table ogc_fid column as we only need the poly table one
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- Create an index on the joining attribute
CREATE INDEX ON $tableName_meta (meta_geocode);

-- Drop the table if it exists
DROP TABLE IF EXISTS  $fullTargetTableName CASCADE;

-- Join poly and meta into final table
CREATE TABLE  $fullTargetTableName AS
SELECT *, substring(replace(poly.geocode, ',','.'), 1, 10) geocode_1_10,
          substring(replace(poly.geocode, ',','.'), 11, 10) geocode_11_20
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  ON poly.geocode = meta.meta_geocode;
    
-- Drop final table GEOCODE duplicate attribute
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geoc_maj;

-- Drop intermediate tables
DROP TABLE IF EXISTS $tableName_poly CASCADE;
DROP TABLE IF EXISTS $tableName_meta CASCADE;
"

createSQLSpatialIndex=True

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh