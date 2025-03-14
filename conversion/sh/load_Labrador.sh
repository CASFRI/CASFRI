#!/bin/bash -x

# The source dataset is downloaded in geodtabase format.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=Labrador

# 7 different gdb files listed below to be joined in the same table
srcFileNameForest=Forest
shpFileNameForest=Forest
srcFullPath=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameForest/$shpFileNameForest.shp

srcFileNameNonForest=Non_Forest
shpFileNameNonForest=Non_Forest
srcFullPath_nonforest=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameNonForest/$shpFileNameNonForest.shp

srcFileNameWater=Waterbody
shpFileNameWater=Waterbody
srcFullPath_Water=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameWater/$shpFileNameWater.shp

srcFileNameDist=Interpreted_Disturbance
shpFileNameDist=Interpreted_Disturbance
srcFullPath_Dist=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameDist/$shpFileNameDist.shp

srcFileNameSpecies=Interpreted_Species
shpFileNameSpecies=Interpreted_Species
srcFullPath_Species=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameSpecies/$shpFileNameSpecies.shp

srcFileNameStockCom=Stocked_Commercial_Forest
shpFileNameStockCom=Stocked_Commercial_Forest
srcFullPath_StockCom=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameStockCom/$shpFileNameStockCom.shp

srcFileNameStockNonCom=Stocked_Non_Commercial_Forest
shpFileNameStockNonCom=Stocked_Non_Commercial_Forest
srcFullPath_StockNonCom=$friDir/$inventoryID/$inventoryID/data/inventory/$srcFileNameStockNonCom/$shpFileNameStockNonCom.shp


# temp table names
fullTargetTableName=$targetFRISchema.$inventoryID
tableName_nonforest=${fullTargetTableName}_nonforest
tableName_water=${fullTargetTableName}_water
tableName_dist=${fullTargetTableName}_dist
tableName_Species=${fullTargetTableName}_species
tableName_Species_pivot=${fullTargetTableName}_species_pivot
tableName_StockCom=${fullTargetTableName}_StockCom
tableName_StockNonCom=${fullTargetTableName}_StockNonCom

overwrite_option="$overwrite_tab"

connectionParams="-d $pgdbname -U $pguser -h $pghost -p $pgport"

########################################## Process ######################################

# 1. Load Forest table into SQL database
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileNameForest' AS src_filename, '$inventoryID' AS inventory_id FROM $shpFileNameForest" \
-progress $overwrite_tab
# total number of rows: 344722


# 2.1 Load NonForest table into SQL database
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_nonforest" \
-nln $tableName_nonforest $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileNameForest' AS src_filename, '$inventoryID' AS inventory_id FROM $shpFileNameNonForest" \
-progress $overwrite_tab
# total number of rows: 79219

# 2.2 Change table structure 
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $fullTargetTableName ADD COLUMN nfcode varchar;
"

# 2.3 append Non-Forest table
"$pgFolder/bin/psql" $connectionParams -c "
INSERT INTO $fullTargetTableName (nfcode, globalid, shape__len, shape__are, src_filename, inventory_id, wkb_geometry)
SELECT nfcode, globalid, shape__len, shape__are, src_filename, inventory_id, wkb_geometry
FROM $tableName_nonforest;
DROP TABLE $tableName_nonforest;
"
# total number of rows: 344722 + 79219 = 423941

# 3.1 Change table structure and append Waterbody table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_Water" \
-nln $tableName_water $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileNameForest' AS src_filename, '$inventoryID' AS inventory_id FROM $shpFileNameWater" \
-progress $overwrite_tab
# total number of rows: 55417

# 3.2 Change table structure 
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $fullTargetTableName ADD COLUMN wbcode VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN name VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN buffwidth INTEGER;
"

# 3.3 append Water table
"$pgFolder/bin/psql" $connectionParams -c "
INSERT INTO $fullTargetTableName (wbcode, name, buffwidth, globalid, shape__len, shape__are, src_filename, inventory_id, wkb_geometry)
SELECT wbcode, name, CAST(buffwidth AS INTEGER), globalid, shape__len, shape__are, src_filename, inventory_id, wkb_geometry
FROM $tableName_water;
DROP TABLE $tableName_water;
"
# total number of rows: 344722 + 79219 + 55417 = 479358


# 4.1 Add the temp table "dist"
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_Dist" \
-nln $tableName_dist $layer_creation_options $other_options \
-sql "SELECT * FROM $shpFileNameDist" \
-progress $overwrite_tab

# 4.2 Change table structure, add 3 new columns
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $fullTargetTableName ADD COLUMN type_dist VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN year_dist INTEGER;
ALTER TABLE $fullTargetTableName ADD COLUMN rr_subtype INTEGER;
"

# 4.3 join disturbance table to mother table, delete the inserted table
"$pgFolder/bin/psql" $connectionParams -c "
UPDATE $fullTargetTableName f
SET rr_subtype = d.rr_subtype,
    type_dist = d.type_dist,
    year_dist = EXTRACT(YEAR FROM d.year_dist)
FROM $tableName_dist d
WHERE f.forestid = d.forestid;
DROP TABLE $tableName_dist;
"
# total number of rows: 344722 + 79219 + 55417 = 479358


# # 5.1 Add the temp table "species"
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_Species" \
-nln $tableName_Species $layer_creation_options $other_options \
-sql "SELECT * FROM $shpFileNameSpecies" \
-progress $overwrite_tab
# number of rows: 255840

# 5.2 Create pivot table : there is max. 6 species for 1 forestid
"$pgFolder/bin/psql" $connectionParams -c "
CREATE TABLE $tableName_Species_pivot AS 
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
    FROM $tableName_Species
) sub
GROUP BY forestid;
"
number of rows: 186977

# 5.3 Change table structure, add 20 new columns
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $fullTargetTableName ADD COLUMN species_1 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_2 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_3 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_4 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_5 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_6 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_7 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_8 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_9 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_10 text;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_1 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_2 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_3 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_4 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_5 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_6 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_7 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_8 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_9 integer;
ALTER TABLE $fullTargetTableName ADD COLUMN species_per_10 integer;
"

5.4 join species table to mother table, delete the inserted table
"$pgFolder/bin/psql" $connectionParams -c "
UPDATE $fullTargetTableName f
SET species_1 = p.species_1,
    species_2 = p.species_2,
    species_3 = p.species_3,
    species_4 = p.species_4,
    species_5 = p.species_5,
    species_6 = p.species_6,
    species_7 = p.species_7,
    species_8 = p.species_8,
    species_9 = p.species_9,
    species_10 = p.species_10,
    species_per_1 = p.species_per_1,
    species_per_2 = p.species_per_2,
    species_per_3 = p.species_per_3,
    species_per_4 = p.species_per_4, 
    species_per_5 = p.species_per_5,
    species_per_6 = p.species_per_6,
    species_per_7 = p.species_per_7,
    species_per_8 = p.species_per_8, 
    species_per_9 = p.species_per_9,
    species_per_10 = p.species_per_10      
FROM $tableName_Species_pivot p
WHERE f.forestid = p.forestid;
DROP TABLE $tableName_Species_pivot;
DROP TABLE $tableName_Species;
"
# total number of rows: 479358

# 6.1 Add the temp table "commercial stock"
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_StockCom" \
-nln $tableName_StockCom $layer_creation_options $other_options \
-sql "SELECT * FROM $shpFileNameStockCom" \
-progress $overwrite_tab
# number of rows: 188767

# 6.2 Change table structure, add 3 new columns
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $fullTargetTableName ADD COLUMN spcomp VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN stratum VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN age_code VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN hgt_code VARCHAR;
ALTER TABLE $fullTargetTableName ADD COLUMN cden_code VARCHAR;
"

# 6.3 join commercial stock table to mother table, delete the inserted table
"$pgFolder/bin/psql" $connectionParams -c "
UPDATE $fullTargetTableName f
SET spcomp = sc.spcomp,
    stratum = sc.stratum,
    age_code = sc.age_code,
    hgt_code = sc.hgt_code,
    cden_code = sc.cden_code  
FROM $tableName_StockCom sc
WHERE f.forestid = sc.forestid;
DROP TABLE $tableName_StockCom;
"
# total number of rows: 479358

# 7.1 Add the temp table "Noncommercial stock"
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_StockNonCom" \
-nln $tableName_StockNonCom $layer_creation_options $other_options \
-sql "SELECT * FROM $shpFileNameStockNonCom" \
-progress $overwrite_tab
# number of rows: 154230

# 7.2 Change table structure, add 3 new columns
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
ALTER TABLE $fullTargetTableName ADD COLUMN covertype VARCHAR;
"

7.3 join Noncommercial stock table to mother table, delete the inserted table
"$pgFolder/bin/psql" $connectionParams -c "
UPDATE $fullTargetTableName f
SET covertype = snc.covertype,
    hgt_code = snc.hgt_code,
    cden_code = snc.cden_code  
FROM $tableName_StockNonCom snc
WHERE f.forestid = snc.forestid;
DROP TABLE $tableName_StockNonCom;
"
# total number of rows: 479358

############## Process ########################
source ./common_postprocessing.sh