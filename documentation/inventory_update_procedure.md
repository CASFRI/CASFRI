**CASFRI Inventory Update Procedure**

This procedure details the steps necessary to add or replace one or more inventories after you have completed a full translation of the CASFRI database and you do not want to reload/retranslate all the inventories and the historical table already processed.

This procedure assume that all the functions necessary to produce CASFRI are already installed in the database. This includes the PostgreSQL Table Translation Framework and the CASFRI Helper Functions.

**1. If, and only if, you are replacing a source inventory with another one, you must drop it from the "rawfri" schema.**

 1. DROP or rename each source inventories that have to be replaced from the "rawfri" schema in the database. If you just rename them, make sure to rename the associated indexes as well. If you DROP them, make sure to DROP CASCADE them as some VIEWs might depend on them.

    To drop an inventory (just replace "sk08" with the proper inventory_id):

    ```
    DROP CASCADE rawfri.sk08;
    ```

    To rename them:

    ```
    ALTER TABLE rawfri.sk08 RENAME TO rawfri.sk08_old;
    ALTER INDEX sk08_ogc_fid_idx RENAME TO sk08_old_ogc_fid_idx;
    ALTER INDEX sk08_wkb_geometry_geom_idx RENAME TO sk08_old_wkb_geometry_geom_idx;
    ```
    
 2. List the inventories you want to load using the invList1 variable in your config.sh script. Make sure to comment out the other unused invList2-5 variables.

 3. Open a Bash command window, CD to the CASFRI conversion/sh folder and load all inventories to update using the load_all.sh script.
    Check that the count of rows in the newly created tables matches the number of rows in the source table.


**2. If you are replacing a source inventory or have modified a helper function or a translation table affecting the translation of some inventories, you must drop the associated translated rows.**

 1. First drop all the constraints (including prmiry and foreign keys) on the tables of the "casfri50" schema

    ```
    SELECT TT_DropAllConstraints('casfri50', 'cas_all');
    SELECT TT_DropAllConstraints('casfri50', 'dst_all');
    SELECT TT_DropAllConstraints('casfri50', 'eco_all');
    SELECT TT_DropAllConstraints('casfri50', 'lyr_all');
    SELECT TT_DropAllConstraints('casfri50', 'nfl_all');
    SELECT TT_DropAllConstraints('casfri50', 'geo_all');
    ```

 2. Delete inventories to be replaced from the tables in the "casfri50" schema:

    ```
    DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'SK08';
    ```

 3. Delete all the rows in the "casfri50_history" schema gridded version of the geo table for these inventories with queries like this:

    ```
    DELETE FROM casfri50_history.casflat_gridded WHERE inventory_id = 'SK08';
    DELETE FROM casfri50_history.casflat_gridded WHERE inventory_id = 'SK09';
    ```


**3. If the corresponding translation tables have changed, load them using the CASFRI/translation/load_tables.sh script.**
    By default, load_tables.sh reload all translation tables. You can reload specific tables by appending their names separated by spaces as parameters to the load_tables.sh script. e.g.:
    
```
./load_tables.sh mb_fli01_cas.csv mb_fli01_dst.csv mb_fli01_eco.csv mb_fli01_lyr.csv mb_fli01_nfl.csv mb_fli01_geo.csv
```

**4. If some CASFRI helper function changed, uninstall and reinstall them using the helperFunctionsCasfriUninstall.sql and the helperFunctionsCASFRI.sql scripts.**

**5. Make sure changes in translation tables and helper functions did not have unwanted side effect on other translations by running the translation tests and compare the results with the archived test tables.** 

**6. Translate the new inventories using the proper workflow/02_produceCASFRI/02_perInventory scripts.**

 1. Copy and adjust an existing script if none exists for the new inventories.
 
 2. Launch the script

 3. Check that the count of translated rows in the "casfri50.cas_all" tables matches the number of rows in the rawfri tables using or adjusting the workflow\02_produceCASFRI\03_ConstraintsChecksAndIndexes/00_checkCounts.sql script.
 
 4. Adjust and run all the scripts in the CASFRI/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/ folder.

**7. Regenerate the flat tables like this:**

```
REFRESH MATERIALIZED VIEW casfri50_flat.cas_flat_all_layers_same_row;
REFRESH MATERIALIZED VIEW casfri50_flat.cas_flat_one_layer_per_row;
```

**8. Generate the gridded version of the flat table for the new inventories with queries like this:**

```
INSERT INTO casfri50_history.casflat_gridded 
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGrid(geometry, 1000)).geom geom
FROM casfri50_flat.cas_flat_all_layers_same_row
WHERE inventory_id = 'SK08' OR inventory_id = 'SK09';
```

**9. Regenerate the table containing the count of row per inventory (this code is in 01_PrepareGeoHistory.sql):**

```
DROP TABLE IF EXISTS casfri50_coverage.inv_counts;
CREATE TABLE casfri50_coverage.inv_counts AS
SELECT left(cas_id, 4) inv, count(*) cnt
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);
```

**10. Compute the geometries representing the coverage of the new inventories using the proper lines in the workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sql.**
    Add lines if they don't already exist.

```
SELECT TT_ProduceDerivedCoverages('SK08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK08'''));
SELECT TT_ProduceDerivedCoverages('SK09', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK09'''));
```

**11. Determine the inventories affected by the addition of new inventories in the historical database using a query like this:**

```
SELECT DISTINCT left(cas_id, 4) inv
FROM casfri50_history.geo_history h, 
     casfri50_coverage.detailed c
WHERE (c.inv = 'SK08' OR c.inv = 'SK09') AND ST_Intersects(h.geom, c.geom)
ORDER BY inv;
```

**12. Delete all the rows in the historical table for the inventories affected by the addition of new inventories with queries like this:**

```
DELETE FROM casfri50_history.geo_history WHERE left(cas_id, 4) = 'SK08';
DELETE FROM casfri50_history.geo_history WHERE left(cas_id, 4) = 'SK09';
```    

**13. Set precedences for the new inventories in the casfri50_history.inv_precedence table defined in workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sql if they are missing.**

**14. Recompute the history for all affected historical database inventories using lines from the workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sql**


```
SELECT TT_ProduceInvGeoHistory('SK08');
SELECT TT_ProduceInvGeoHistory('SK09');
SELECT TT_ProduceInvGeoHistory('SK06');
SELECT TT_ProduceInvGeoHistory('AB25');
SELECT TT_ProduceInvGeoHistory('AB29');
```



