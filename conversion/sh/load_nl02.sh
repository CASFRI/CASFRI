#!/bin/bash -x

# The source dataset is downloaded in geodtabase format.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=NL02

# 7 different gdb files listed below to be joined in the same table
srcFileNameForest=FFA_LandCover_Forest
gdbTableNameForest=Forest
srcFullPath=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Forest/$srcFileNameForest.gdb

srcFileNameNonForest=FFA_LandCover_NonForest
gdbTableNameNonforest=Non_Forest
srcFullPathNonForest=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_NonForest/$srcFileNameNonForest.gdb

srcFileNameWater=FFA_LandCover_Waterbody
gdbTableNameWater=Waterbody
srcFullPathWater=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Waterbody/$srcFileNameWater.gdb

srcFileNameDist=FFA_LandCover_Interpreted_Disturbance
gdbTableNameDist=Interpreted_Disturbance
srcFullPathDist=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Interpreted_Disturbance/$srcFileNameDist.gdb

srcFileNameSpecies=FFA_LandCover_Interpreted_species
gdbTableNameSpecies=Interpreted_Species
srcFullPathSpecies=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Interpreted_species/$srcFileNameSpecies.gdb

srcFileNameStockCom=FFA_LandCover_Stocked_commercial
gdbTableNameStockCom=Stocked_Commercial_Forest
srcFullPathStockCom=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Stocked_commercial/$srcFileNameStockCom.gdb

srcFileNameStockNonCom=FFA_LandCover_Stocked_non_commercial
gdbTableNameStockNonCom=Stocked_Non_Commercial_Forest
srcFullPathStockNonCom=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Stocked_non_commercial/$srcFileNameStockNonCom.gdb

# Table names
fullTargetTableName=$targetFRISchema.nl02
tableNameTemp=${fullTargetTableName}_temp
tableNameDist=${fullTargetTableName}_dist
tableNameSpecies=${fullTargetTableName}_species
tableNameSpeciesPivot=${fullTargetTableName}_species_pivot
tableNameStockcom=${fullTargetTableName}_stockcom
tableNameStockNonCom=${fullTargetTableName}_stocknoncom

########################################## Process #############################

################################################################################
#if false; then
# 1 - Load Forest table (1407193 rows)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableNameForest" \
-nln $tableNameTemp $layer_creation_options $other_options \
-sql "SELECT *, 'forest' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameForest" \
-progress $overwrite_tab

################################################################################ 
# 2 - Load Non-Forest table (501701 rows)
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPathNonForest" "$gdbTableNameNonforest" \
-nln $tableNameTemp $layer_creation_options $other_options \
-sql "SELECT *, 'nonforest' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameNonforest" \
-progress

# Total number of rows: 1407193 + 501701 = 1908894

################################################################################
# 3 - Load Water table (703557 rows)
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPathWater" "$gdbTableNameWater" \
-nln $tableNameTemp $layer_creation_options $other_options \
-sql "SELECT *, 'waterbody' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameWater" \
-progress

# Total number of rows: 1407193 + 501701 + 703557 = 2612451

################################################################################
# 4 - Add the temp table "dist"
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPathDist" "$gdbTableNameDist" \
-nln $tableNameDist $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbTableNameDist" \
-progress $overwrite_tab

################################################################################
# 5.1 - Add the temp table "species"
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPathSpecies" "$gdbTableNameSpecies" \
-nln $tableNameSpecies $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbTableNameSpecies" \
-progress $overwrite_tab

# 5.2 - Pivot the table : there is max. 6 species per forestid (686505 rows)
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
DROP TABLE IF EXISTS $tableNameSpeciesPivot CASCADE;

CREATE TABLE $tableNameSpeciesPivot AS 
SELECT 
    forestid,
    MAX(CASE WHEN rn = 1 THEN species END) AS "species_1",
    MAX(CASE WHEN rn = 2 THEN species END) AS "species_2",
    MAX(CASE WHEN rn = 3 THEN species END) AS "species_3",
    MAX(CASE WHEN rn = 4 THEN species END) AS "species_4",
    MAX(CASE WHEN rn = 5 THEN species END) AS "species_5",
    MAX(CASE WHEN rn = 6 THEN species END) AS "species_6",
    MAX(CASE WHEN rn = 7 THEN species END) AS "species_7",
    MAX(CASE WHEN rn = 8 THEN species END) AS "species_8",
    MAX(CASE WHEN rn = 9 THEN species END) AS "species_9",
    MAX(CASE WHEN rn = 10 THEN species END) AS "species_10",	
    MAX(CASE WHEN rn = 1 THEN ba_pct END) AS "species_per_1",
    MAX(CASE WHEN rn = 2 THEN ba_pct END) AS "species_per_2",
    MAX(CASE WHEN rn = 3 THEN ba_pct END) AS "species_per_3",
    MAX(CASE WHEN rn = 4 THEN ba_pct END) AS "species_per_4",
    MAX(CASE WHEN rn = 5 THEN ba_pct END) AS "species_per_5",
    MAX(CASE WHEN rn = 6 THEN ba_pct END) AS "species_per_6",
    MAX(CASE WHEN rn = 7 THEN ba_pct END) AS "species_per_7",
    MAX(CASE WHEN rn = 8 THEN ba_pct END) AS "species_per_8",
    MAX(CASE WHEN rn = 9 THEN ba_pct END) AS "species_per_9",
    MAX(CASE WHEN rn = 10 THEN ba_pct END) AS "species_per_10"	
FROM (
    SELECT forestid, species, ba_pct,
           ROW_NUMBER() OVER (PARTITION BY forestid ORDER BY ba_pct DESC) AS rn
    FROM $tableNameSpecies
) sub
GROUP BY forestid;

CREATE INDEX ON ${tableNameSpeciesPivot} (forestid);
"

################################################################################
# 6 - Add the temp table "commercial stock" (686365 rows)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPathStockCom" "$gdbTableNameStockCom" \
-nln $tableNameStockcom $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbTableNameStockCom" \
-progress $overwrite_tab

################################################################################
# 7 - Add the temp table "Non commercial stock" (647481 rows)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPathStockNonCom" "$gdbTableNameStockNonCom" \
-nln $tableNameStockNonCom $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbTableNameStockNonCom" \
-progress $overwrite_tab
#fi
################################################################################
# 8 - Join everything into the final table (2612451 rows)
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON ${tableNameStockcom} (forestid);
CREATE INDEX ON ${tableNameStockNonCom} (forestid);

DROP TABLE IF EXISTS $fullTargetTableName CASCADE;

CREATE TABLE $fullTargetTableName AS
WITH unique_stockcom AS (
    SELECT DISTINCT ON (forestid) *
    FROM $tableNameStockcom
    ORDER BY forestid, spcomp DESC
), unique_stocknoncom AS (
    SELECT DISTINCT ON (forestid) *
    FROM $tableNameStockNonCom
    ORDER BY forestid, covertype DESC
)
SELECT tt.*,
       d.rr_subtype, d.type_dist, EXTRACT(YEAR FROM d.year_dist) year_dist,
       sp.species_1, sp.species_2, sp.species_3, sp.species_4, sp.species_5, sp.species_6, sp.species_7, sp.species_8, sp.species_9, sp.species_10,
       sp.species_per_1, sp.species_per_2, sp.species_per_3, sp.species_per_4, sp.species_per_5, sp.species_per_6, sp.species_per_7, sp.species_per_8, sp.species_per_9, sp.species_per_10,
       sc.spcomp, sc.stratum, sc.age_code,
       snc.covertype,
       coalesce(sc.hgt_code, snc.hgt_code) hgt_code,
       coalesce(sc.cden_code, snc.cden_code) cden_code
FROM $tableNameTemp tt
LEFT JOIN $tableNameDist d ON tt.forestid = d.forestid
LEFT JOIN $tableNameSpeciesPivot sp ON tt.forestid = sp.forestid
LEFT JOIN unique_stockcom sc ON tt.forestid = sc.forestid 
LEFT JOIN unique_stocknoncom snc ON tt.forestid = snc.forestid;

DROP TABLE IF EXISTS $tableNameTemp CASCADE;
DROP TABLE IF EXISTS $tableNameDist CASCADE;
DROP TABLE IF EXISTS $tableNameSpeciesPivot CASCADE;
DROP TABLE IF EXISTS $tableNameSpecies CASCADE;
DROP TABLE IF EXISTS $tableNameStockcom CASCADE;
DROP TABLE IF EXISTS $tableNameStockNonCom CASCADE;
"

############################## Post Process ####################################
createSQLSpatialIndex=True

source ./common_postprocessing.sh