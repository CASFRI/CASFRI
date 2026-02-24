**CASFRI Inventory Update Procedure**

This procedure details the steps necessary to add or replace one or more inventories after you have completed a full translation of the CASFRI database and you do not want to reload or retranslate all the inventories and the historical table already processed.

This procedure assumes that all the functions necessary to produce CASFRI are already installed in the database. This includes the PostgreSQL Table Translation Framework and the CASFRI Helper Functions.

**1. If, and only if, you are replacing a source inventory with another one, you must first drop it from the "rawfri" schema.**

 1.1. DROP or rename each source inventory that have to be replaced from the "rawfri" schema in the database. If you just rename them, make sure to rename the associated indexes as well. If you DROP them, make sure to DROP CASCADE them as some VIEWs might depend on them.

    To drop an inventory (just replace "sk08" with the proper inventory_id):

    ```
    DROP TABLE rawfri.sk08 CASCADE;
    ```

    To rename them:

    ```
    ALTER TABLE rawfri.sk08 RENAME TO rawfri.sk08_old;
    ALTER INDEX sk08_ogc_fid_idx RENAME TO sk08_old_ogc_fid_idx;
    ALTER INDEX sk08_wkb_geometry_geom_idx RENAME TO sk08_old_wkb_geometry_geom_idx;
    ```
    
 1.2. List the inventories you want to load using the "invList" variable in the config.sh script.

 1.3. Open a Bash shell, CD to the CASFRI conversion/sh folder and load all inventories to update using the convert_all.sh script.

 1.4. Check that the count of converted stands in the newly created tables matches the CONVERTED_STAND_CNT column in inventory_metadata.csv.


**2. If you are replacing a source inventory or have modified a helper function or a translation table affecting the translation of some inventories, you must drop associated translated rows.**

 2.1. First drop all the constraints (including primary and foreign keys) on the tables of the "casfri50" schema:

    ```
    SELECT TT_DropAllConstraints('casfri50', 'cas_all');
    SELECT TT_DropAllConstraints('casfri50', 'dst_all');
    SELECT TT_DropAllConstraints('casfri50', 'eco_all');
    SELECT TT_DropAllConstraints('casfri50', 'lyr_all');
    SELECT TT_DropAllConstraints('casfri50', 'nfl_all');
    SELECT TT_DropAllConstraints('casfri50', 'geo_all');
    ```

 2.2. Delete inventories to be replaced from the tables in the "casfri50" schema:

    ```
    DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'SK08';
    DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'SK08';
    ```

 2.3. Delete all the rows in the "casfri50_history" schema gridded version of the geo table for these inventories with queries like this:

    ```
    DELETE FROM casfri50_history.casflat_gridded WHERE inventory_id = 'SK08';
    DELETE FROM casfri50_history.casflat_gridded WHERE inventory_id = 'SK09';
    ```


**3. If the corresponding translation tables have changed, load them using the CASFRI/translation/load_tables.sh script.**
    By default, load_tables.sh reloads all translation tables. You can reload specific tables by appending their names separated by spaces as parameters to the load_tables.sh script. e.g.:
    
```
./load_tables.sh mb_fli01_cas.csv mb_fli01_dst.csv mb_fli01_eco.csv mb_fli01_lyr.csv mb_fli01_nfl.csv mb_fli01_geo.csv
```

**4. If some CASFRI helper function changed, uninstall and reinstall them using the helperFunctionsCasfriUninstall.sql and the helperFunctionsCASFRI.sql scripts.**

**5. Make sure changes in translation tables and helper functions did not have unwanted side effects on other translations by running the translation tests and compare the results with the archived test tables.** 

**6. Translate the new inventories using the CASFRI/workflow/02_produceCASFRI/01_createCASFRITables.sh script**

 6.1. The inventories translated will be those defined by the config.sh "invList" variable.

 6.2. Check that the count of translated rows in the "casfri50" tables matches the count of expected rows in the inventory_metadata.csv table using the TT_TranslatedRowCount() function.

```
SELECT (TT_TranslatedRowCount(ARRAY['SK08', 'SK09'])).*
``` 
 
 6.3. Adjust and run the other scripts in the CASFRI/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/ folder.

**7. Regenerate the flat tables like this:**

```
REFRESH MATERIALIZED VIEW casfri50_flat.cas_flat_all_layers_same_row;
REFRESH MATERIALIZED VIEW casfri50_flat.cas_flat_one_layer_per_row;
```

**8. Generate the gridded version of the flat table for the new inventories with a query like this:**

```
INSERT INTO casfri50_history.casflat_gridded 
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGrid(geometry, 1000)).geom geom
FROM casfri50_flat.cas_flat_all_layers_same_row
WHERE inventory_id = 'SK08' OR inventory_id = 'SK09';
```

**9. Regenerate the table containing the count of row per inventory (this code is in 01_PrepareGeoHistory.sql):**

```
DROP TABLE IF EXISTS casfri50_coverage.inv_counts CASCADE;
CREATE TABLE casfri50_coverage.inv_counts AS
SELECT left(cas_id, 4) inv, count(*) cnt
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);
```

**10. Compute the geometries representing the coverage of the new inventories using the proper lines in the workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sql.**
    Add lines if they don't already exist.

```
SELECT TT_ProduceDerivedCoverages('SK08', TT_SuperUnion('casfri50', 'geo_all', 'cas_id', 'geometry', 'left(cas_id, 4) = ''SK08'''));
SELECT TT_ProduceDerivedCoverages('SK09', TT_SuperUnion('casfri50', 'geo_all', 'cas_id', 'geometry', 'left(cas_id, 4) = ''SK09'''));

```

**11. Determine the inventories affected by the addition of new inventories in the historical table using a query like this:**

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

**13. Set precedences rank values for the new inventories in the PRECEDENCE_RANK column of the metadata/inventory_metadata.csv table if they are missing.**

**14. Recompute the history for all affected historical database inventories using lines from the workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sql**


```
SELECT TT_ProduceInvGeoHistory('SK08');
SELECT TT_ProduceInvGeoHistory('SK09');
SELECT TT_ProduceInvGeoHistory('SK06');
SELECT TT_ProduceInvGeoHistory('AB25');
SELECT TT_ProduceInvGeoHistory('AB29');
```



