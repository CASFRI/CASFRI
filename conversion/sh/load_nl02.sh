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
srcFullPath_nonforest=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_NonForest/$srcFileNameNonForest.gdb

srcFileNameWater=FFA_LandCover_Waterbody
gdbTableNameWater=Waterbody
srcFullPath_Water=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Waterbody/$srcFileNameWater.gdb

srcFileNameDist=FFA_LandCover_Interpreted_Disturbance
gdbTableNameDist=Interpreted_Disturbance
srcFullPath_Dist=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Interpreted_Disturbance/$srcFileNameDist.gdb

srcFileNameSpecies=FFA_LandCover_Interpreted_species
gdbTableNameSpecies=Interpreted_Species
srcFullPath_Species=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Interpreted_species/$srcFileNameSpecies.gdb

srcFileNameStockCom=FFA_LandCover_Stocked_commercial
gdbTableNameStockCom=Stocked_Commercial_Forest
srcFullPath_StockCom=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Stocked_commercial/$srcFileNameStockCom.gdb

srcFileNameStockNonCom=FFA_LandCover_Stocked_non_commercial
gdbTableNameStockNonCom=Stocked_Non_Commercial_Forest
srcFullPath_StockNonCom=$friDir/NL/$inventoryID/data/inventory/FFA_LandCover_Stocked_non_commercial/$srcFileNameStockNonCom.gdb


# temp table names
fullTargetTableName=$targetFRISchema.nl02
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
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableNameForest" \
# -nln $fullTargetTableName $layer_creation_options $other_options \
# -sql "SELECT *, '$srcFileNameForest' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameForest" \
# -progress $overwrite_tab
# total number of rows: 1407193


# 2.1 Load Forest table into SQL database
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath_nonforest" "$gdbTableNameNonforest" \
# -nln $tableName_nonforest $layer_creation_options $other_options \
# -sql "SELECT *, '$srcFileNameForest' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameNonforest" \
# -progress $overwrite_tab
# total number of rows: 501701

# 2.2 Change table structure 
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# ALTER TABLE $fullTargetTableName ADD COLUMN nfcode varchar;
# "

# 2.3 append Non-Forest table
# "$pgFolder/bin/psql" $connectionParams -c "
# INSERT INTO $fullTargetTableName (nfcode, globalid, shape_length, shape_area, src_filename, inventory_id, wkb_geometry)
# SELECT nfcode, globalid, shape_length, shape_area, src_filename, inventory_id, wkb_geometry
# FROM $tableName_nonforest;
# DROP TABLE $tableName_nonforest;
# "
# total number of rows: 1407193 + 501701 = 1908894

# 3.1 Change table structure and append Waterbody table
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath_Water" "$gdbTableNameWater" \
# -nln $tableName_water $layer_creation_options $other_options \
# -sql "SELECT *, '$srcFileNameForest' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameWater" \
# -progress $overwrite_tab
# total number of rows: 703557

# 3.2 Change table structure 
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# ALTER TABLE $fullTargetTableName ADD COLUMN wbcode VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN name VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN buffwidth INTEGER;
# "

# 3.3 append Non-Forest table
# "$pgFolder/bin/psql" $connectionParams -c "
# INSERT INTO $fullTargetTableName (wbcode, name, buffwidth, globalid, shape_length, shape_area, src_filename, inventory_id, wkb_geometry)
# SELECT wbcode, name, buffwidth, globalid, shape_length, shape_area, src_filename, inventory_id, wkb_geometry
# FROM $tableName_water;
# DROP TABLE $tableName_water;
# "
# total number of rows: 1407193 + 501701 + 703557 = 2612451


# 4.1 Add the temp table "dist"
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath_Dist" "$gdbTableNameDist" \
# -nln $tableName_dist $layer_creation_options $other_options \
# -sql "SELECT * FROM $gdbTableNameDist" \
# -progress $overwrite_tab

# 4.2 Change table structure, add 3 new columns
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# ALTER TABLE $fullTargetTableName ADD COLUMN TYPE_DIST VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN YEAR_DIST INTEGER;
# ALTER TABLE $fullTargetTableName ADD COLUMN rr_subtype INTEGER;
# "

# 4.3 join disturbance table to mother table, delete the inserted table
# "$pgFolder/bin/psql" $connectionParams -c "
# UPDATE $fullTargetTableName f
# SET rr_subtype = d.rr_subtype,
#     type_dist = d.type_dist,
#     year_dist = EXTRACT(YEAR FROM d.year_dist)
# FROM $tableName_dist d
# WHERE f.forestid = d.forestid;
# DROP TABLE $tableName_dist;
# "
# total number of rows: 1407193 + 501701 + 703557 = 2612451


# # 5.1 Add the temp table "species"
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath_Species" "$gdbTableNameSpecies" \
# -nln $tableName_Species $layer_creation_options $other_options \
# -sql "SELECT * FROM $gdbTableNameSpecies" \
# -progress $overwrite_tab
# number of rows: 1067600

# # 5.2 Create pivot table : there is max. 6 species for 1 forestid
# "$pgFolder/bin/psql" $connectionParams -c "
# CREATE TABLE $tableName_Species_pivot AS 
# SELECT 
#     forestid,
#     MAX(CASE WHEN rn = 1 THEN species END) AS "species_1",
#     MAX(CASE WHEN rn = 2 THEN species END) AS "species_2",
#     MAX(CASE WHEN rn = 3 THEN species END) AS "species_3",
#     MAX(CASE WHEN rn = 4 THEN species END) AS "species_4",
#     MAX(CASE WHEN rn = 5 THEN species END) AS "species_5",
#     MAX(CASE WHEN rn = 6 THEN species END) AS "species_6",
#     MAX(CASE WHEN rn = 7 THEN species END) AS "species_7",
#     MAX(CASE WHEN rn = 8 THEN species END) AS "species_8",
#     MAX(CASE WHEN rn = 9 THEN species END) AS "species_9",
#     MAX(CASE WHEN rn = 10 THEN species END) AS "species_10",	
#     MAX(CASE WHEN rn = 1 THEN ba_pct END) AS "species_per_1",
#     MAX(CASE WHEN rn = 2 THEN ba_pct END) AS "species_per_2",
#     MAX(CASE WHEN rn = 3 THEN ba_pct END) AS "species_per_3",
#     MAX(CASE WHEN rn = 4 THEN ba_pct END) AS "species_per_4",
#     MAX(CASE WHEN rn = 5 THEN ba_pct END) AS "species_per_5",
#     MAX(CASE WHEN rn = 6 THEN ba_pct END) AS "species_per_6",
#     MAX(CASE WHEN rn = 7 THEN ba_pct END) AS "species_per_7",
#     MAX(CASE WHEN rn = 8 THEN ba_pct END) AS "species_per_8",
#     MAX(CASE WHEN rn = 9 THEN ba_pct END) AS "species_per_9",
#     MAX(CASE WHEN rn = 10 THEN ba_pct END) AS "species_per_10"	
# FROM (
#     SELECT forestid, species, ba_pct,
#            ROW_NUMBER() OVER (PARTITION BY forestid ORDER BY ba_pct DESC) AS rn
#     FROM $tableName_Species
# ) sub
# GROUP BY forestid;
# "
# number of rows: 686505

# 5.3 Change table structure, add 20 new columns
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# ALTER TABLE $fullTargetTableName ADD COLUMN species_1 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_2 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_3 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_4 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_5 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_6 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_7 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_8 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_9 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_10 text;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_1 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_2 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_3 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_4 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_5 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_6 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_7 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_8 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_9 integer;
# ALTER TABLE $fullTargetTableName ADD COLUMN species_per_10 integer;
# "

# 5.4 join species table to mother table, delete the inserted table
# "$pgFolder/bin/psql" $connectionParams -c "
# UPDATE $fullTargetTableName f
# SET species_1 = p.species_1,
#     species_2 = p.species_2,
#     species_3 = p.species_3,
#     species_4 = p.species_4,
#     species_5 = p.species_5,
#     species_6 = p.species_6,
#     species_7 = p.species_7,
#     species_8 = p.species_8,
#     species_9 = p.species_9,
#     species_10 = p.species_10,
#     species_per_1 = p.species_per_1,
#     species_per_2 = p.species_per_2,
#     species_per_3 = p.species_per_3,
#     species_per_4 = p.species_per_4, 
#     species_per_5 = p.species_per_5,
#     species_per_6 = p.species_per_6,
#     species_per_7 = p.species_per_7,
#     species_per_8 = p.species_per_8, 
#     species_per_9 = p.species_per_9,
#     species_per_10 = p.species_per_10      
# FROM $tableName_Species_pivot p
# WHERE f.forestid = p.forestid;
# DROP TABLE $tableName_Species_pivot;
# DROP TABLE $tableName_Species;
# "
# total number of rows: 2612451

# 6.1 Add the temp table "commercial stock"
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath_StockCom" "$gdbTableNameStockCom" \
# -nln $tableName_StockCom $layer_creation_options $other_options \
# -sql "SELECT * FROM $gdbTableNameStockCom" \
# -progress $overwrite_tab
# number of rows: 686365

# 6.2 Change table structure, add 3 new columns
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# ALTER TABLE $fullTargetTableName ADD COLUMN spcomp VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN stratum VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN age_code VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN hgt_code VARCHAR;
# ALTER TABLE $fullTargetTableName ADD COLUMN cden_code VARCHAR;
# "

# 6.3 join disturbance table to mother table, delete the inserted table
# "$pgFolder/bin/psql" $connectionParams -c "
# UPDATE $fullTargetTableName f
# SET spcomp = sc.spcomp,
#     stratum = sc.stratum,
#     age_code = sc.age_code,
#     hgt_code = sc.hgt_code,
#     cden_code = sc.cden_code  
# FROM $tableName_StockCom sc
# WHERE f.forestid = sc.forestid;
# DROP TABLE $tableName_StockCom;
# "
# total number of rows: 2612451

# 7.1 Add the temp table "commercial stock"
# "$gdalFolder/ogr2ogr" \
# -f "PostgreSQL" "$pg_connection_string" "$srcFullPath_StockNonCom" "$gdbTableNameStockNonCom" \
# -nln $tableName_StockNonCom $layer_creation_options $other_options \
# -sql "SELECT * FROM $gdbTableNameStockNonCom" \
# -progress $overwrite_tab
# number of rows: 647481

# 7.2 Change table structure, add 3 new columns
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# ALTER TABLE $fullTargetTableName ADD COLUMN covertype VARCHAR;
# "

# 6.3 join disturbance table to mother table, delete the inserted table
# "$pgFolder/bin/psql" $connectionParams -c "
# UPDATE $fullTargetTableName f
# SET covertype = snc.covertype,
#     hgt_code = snc.hgt_code,
#     cden_code = snc.cden_code  
# FROM $tableName_StockNonCom snc
# WHERE f.forestid = snc.forestid;
# "
# DROP TABLE $tableName_StockNonCom;
# total number of rows: 2612451




############## Process ########################
# source ./common_postprocessing.sh