**CASFRI and PostgreSQL Table Translation Framework Release Procedure**

A whole release process includes:

- the complete conversion and translation of all the acquired inventories,
- the stabilization of the code to complete this whole translation,
- a validation of the final completed database,
- the generation of two flat (denormalized) versions of the database,
- the generation of the inventories geographical coverages,
- the generation of a historical version of the translated database,
- the documentation of remaining issues discovered while completing the complete, actual translation,
- the documentation of the release itself.

The whole release process should take about one week... This is necessary to ensure that releases are stable and actually able to do what they are supposed to do without issues. 

Note that only major issues preventing the conversion or translation process from working properly should be fixed during the release process. It is better to fix other issues in the context of subsequent releases.

**1. Prepare the release**

1. Make sure every fixed issue has been closed on GitHub.

2. Create a new issue in both CASFRI and the PostgreSQL Table Translation Framework to associate all commits done during the release process to them and to prepare the texts listing fixed issues for both releases. Simply name those issues "Produce Release vx.y.z". Make sure to associate all commits made to stabilize the releases to those "Produce Release" issues in addition to the number of the issue describing the actual fix committed.

3. In GitKraken (or your favorite git client), create a branch for both CASFRI and the PostgreSQL Table Translation Framework. Name these branches according to the Version Release versioning scheme described in each product Readme (x.y.z: increment z for bug fixes, y for new features and x when breaking backward compatibility).

4. In GitHub, create a new column in each repository [Project](https://github.com/CASFRI/CASFRI/projects) named after the release and move all fixed issues to this column. This is to avoid that issues fixed on the trunk, after the creation of the branch, get mixed with issues fixed on the branch.

5. In pgAdmin, create a new PostgreSQL database to test and certify the code found on those two branches. Your goal is to stabilize those two branches before creating releases with them.

6. In pgAdmin, create the PostGIS extension in the new database.

**2. Convert the inventories and load the translation tables in the database**

1. Copy the [CASFRI/config_sample.sh](https://github.com/CASFRI/CASFRI/blob/master/config_sample.sh) script to CASFRI/config.sh and edit it so all the variables reflect your development environment, your PostgreSQL access and the way you want to control all the CASFRI processing scripts.

2. Make sure all the inventories to convert and translate are well flagged in the proper column (TRANSLATED_BY_CFS, TRANSLATED_BY_ULAVAL or TRANSLATED_BY_CUSTOM) of the ./metadata/inventory_metadata.csv table. See the main README.md file for more details about this.

3. Open a Bash shell, CD to the CASFRI/conversion/sh directory, and run the [convert_all.sh](https://github.com/CASFRI/CASFRI/blob/master/conversion/convert_all.sh) script to convert all inventories flagged in inventory_metadata.csv. This script launches a parallel subshell for each inventory to be converted. As soon as an inventory finishes converting, a new subshell should start, maintaining up to a maximum of "maxConversionInParallel" concurrent conversions at the same time, as defined in config.sh.

    By default all those shells close by themselves when they are done. You can control this behavior by setting the config.sh "leaveConversionShellOpen" variable to True. In this case you will have to close some windows for the next subshells to be launched one at a time.

4. In the same shell, after the whole conversion is finisned, load the translation tables using the [CASFRI/translation/load_tables.sh](https://github.com/CASFRI/CASFRI/blob/master/translation/load_tables.sh) script.

**3. Install and unsintall the PostgreSQL Table Translation Framework and the CASFRI Helper Functions**

1. Copy the [PostgreSQL-Table-Translation-Framework/configSample.sh](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/configSample.sh) (or .bat) script to PostgreSQL-Table-Translation-Framework/config.sh (or .bat) and edit it to make the "pghome" variable point to your PostgreSQL installation directory and the "tt_version" variable to reflect the proper PostgreSQL Table Translation Framework version number. 

2. In the same shell, install the last version of the PostgreSQL Table Translation Framework extension file using the [PostgreSQL-Table-Translation-Framework/install.sh](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/install.sh) (or .bat) script. This step produce a file named table_translation_framework--x.y.z.sql in the PostgreSQL/XX/share/extension folder.

3. In pgAdmin, CREATE the Table Translation Framework extension and execute the CASFRI Helper Functions script:

    1. CREATE the table_translation_framework extension and test it using the [engineTest.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/engineTest.sql), [helperFunctionsTest.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/helperFunctionsTest.sql) and [helperFunctionsGISTest.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/helperFunctionsGISTest.sql) scripts. Fix any non passing test (by fixing the code of the function tested or by fixing the test itself).

    2. Load the CASFRI Helper Functions with the [CASFRI/helperfunctions/helperFunctionsCASFRI.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/helperFunctionsCASFRI.sql) script and test them using the [helperFunctionsCASFRITest.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/helperFunctionsCASFRITest.sql) script. Fix any non passing test.

4. In pgAdmin, make sure the uninstall scripts uninstall everything and leave no Table Translation Framework and CASFRI Helper function in the database:

    1. DROP all TT_Translate() functions with "SELECT TT_DropAllTranslateFct();"

    2. Uninstall the CASFRI Helper Functions using the [CASFRI/helperFunctionsCASFRIUninstall.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/helperFunctionsCasfriUninstall.sql) script.

    3. DROP the table_translation_framework extension.

    4. Make sure all table_translation_framework and all CASFRI Helper Functions were dropped properly by looking for any remaining TT_ functions in the public.function node in the pgAdmin browser. If not, add the undroped ones to the proper uninstall.sql script.

5. Reinstall all the functions as in step 3.

6. Check the count of converted inventories with the TT_ConvertedStandCount() function like this:

```
SELECT (TT_ConvertedStandCount('TRANSLATED_BY_CFS')).*;
```

The expected count of converted stand is in the CONVERTED_STAND_CNT column of the inventory_metadata.csv table. If many inventories failed to convert and you want to give them another try, you can list them directly in the config.sh file using the "invList" array variable. If "invList" is set, the conver_all.sh script will ignore the flags set in inventory_metadata.csv and will launch a conversion subscript only for those inventories. If you want to see the error message, set the "leaveConversionShellOpen" variable to True.

You can also launch the same procedure by listing the inventories to process directly as convert.sh parameters:

```
./convert_all.sh AB03 AB06
```

**4. Test the translation**

1. In the Bash shell, execute the [CASFRI/translation/test/test_translation.sh](https://github.com/CASFRI/CASFRI/blob/master/translation/test/test_translation.sh) script. You can control which tests are run by passing a list of inventory ot test to the script:

```
./test_translation.sh AB03 BC08
```

Even if you specify a list of inventories, all the inventories pertaining to the same jurisdiction will also be tested. For example, in the example above, all AB and all BC inventories will be tested. This is to ensure that changes made to the translation tables for one inventory do not break the translation of all the other inventories translated using the same translation tables.

1. The resulting translation test tables will be dumped automatically at the end of the script. You should easily see the differences between those test tables and the archived reference tables in GitKraken (or any git client able to show differences between the local and the GitHub repositories). Fix any issue in the production of the test tables if they are wrong or commit the new tables if they are right.
   
More details about the translation tests can be found in the [CASFRI/translation/test/readme.md](https://github.com/CASFRI/CASFRI/blob/master/translation/test/readme.md) file.

**5. Run the translation**

In the Bash shell, CD to CASFRI/workflow/02_produceCASFRI and execute the 01_createCASFRITables.sh and then the 02_translateAll.sh scripts one AFTER the other. The first script prepares the target shema and tables and the second actually translates all the inventories flagged for processing in the inventory_metadata.csv table or directly in the "invList" variable.

**6. Validate the translation**

1. At the end of the 02_translateAll.sh script, a count of translated vs expected translated row is displayed. The counts of expected translated row for each CASFRI tables are listed in the CAS_ROW_CNT, DST_ROW_CNT, ECO_ROW_CNT, LYR_ROW_CNT, NFL_ROW_CNT and GEO_ROW_CNT columns of the inventory_metadata.csv table.

You can also rerun this counting process in pgAdmin or with psql:

```
SELECT (TT_TranslatedRowCount('TRANSLATED_BY_CFS')).*
``` 

You should be able to explain every difference between the expected count and the actual number of translated rows and you should commit new values in inventory_metadata.csv only once you can explain them.

1. In pgAdmin, run the [CASFRI/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addConstraints.sql](https://github.com/CASFRI/CASFRI/blob/master/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addConstraints.sql) script to make sure all the translated rows respect the CASFRI specifications. Create a new GitHub issue for any not passing constraint and add a reference to the issue number in the constraint description within the script. Remove existing reference for fixed, now passing issues. Do the same for the remaining validation scripts located in the same folder ([01_addGeoConstraints.sql](https://github.com/CASFRI/CASFRI/blob/master/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addGeoConstraints.sql), [CASFRI/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/02_addIndexes.sql](https://github.com/CASFRI/CASFRI/blob/master/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/02_addIndexes.sql) and [03_additionalChecks.sql](https://github.com/CASFRI/CASFRI/blob/master/workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/03_additionalChecks.sql)). 

**7. Generate the flat (denormalized) tables**

Run the [CASFRI/workflow/03_flatCASFRI/01_all_layers_same_row.sh](https://github.com/CASFRI/CASFRI/blob/master/workflow/03_flatCASFRI/01_all_layers_same_row.sh) and the [CASFRI/workflow/03_flatCASFRI/03_one_layer_per_row.sh](https://github.com/CASFRI/CASFRI/blob/master/workflow/03_flatCASFRI/03_one_layer_per_row.sh) scripts found in the [CASFRI/workflow/03_flatCASFRI/](https://github.com/CASFRI/CASFRI/tree/master/workflow/03_flatCASFRI) folder to produce the two different flat versions of the database. Those two script simply run their .sql equivalent. You can execute those .sql scripts in pgAdmin or with psql instead. You can also optionally run the tests scripts.

**8. Generate the historical version of the database**

1. Execute the [CASFRI/helperfunctions/geohistory/geoHistory.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/geohistory.sql) script in pgAdmin or using psql to load the required geohistory functions.

2. Test the geohistory functions by first loading the test tables with the [CASFRI/helperfunctions/geohistory/load_test_tables.sh](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/load_test_tables.sh) and the [CASFRI/helperfunctions/geohistory/load_test_tables_with_inv_data.sh](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/geohistory_test_with_inv_data.sql) scripts and then executing [CASFRI/helperfunctions/geohistory/geohistory_test.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/geohistory_test.sql), [CASFRI/helperfunctions/geohistory/geohistory_test_with_inv_data.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/geohistory_test_with_inv_data.sql) and [CASFRI/helperfunctions/geohistory/geohistory_test_with_inv_data_gridded.sql](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/geohistory_test_with_inv_data_gridded.sql). Dump the test tables using the [CASFRI/helperfunctions/geohistory/dump_test_tables.sh](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/dump_test_tables.sh) and the [CASFRI/helperfunctions/geohistory/dump_test_tables_with_inv_data.sh](https://github.com/CASFRI/CASFRI/blob/master/helperfunctions/geohistory/dump_test_tables_with_inv_data.sh) scripts and compare them with the archived tables using your favorite differentiation software. Archive the new tables if you can explain all the differences.

3. In the Bash shell, execute [CASFRI/workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sh](https://github.com/CASFRI/CASFRI/blob/master/workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sh) to prepare the casfri50_history schema, generate a gridded version of the casfri50.geo_all polygons and define some other functions.

4. Execute the [CASFRI/workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh](https://github.com/CASFRI/CASFRI/blob/master/workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh) script to process all the inventories flagged for processing in parallel. The "maxGeoHistoryInParallel" variable in config.sh controls how many parallel subshells can be launched at the same time.

5. Execute the [CASFRI/workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh](https://github.com/CASFRI/CASFRI/blob/master/workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh) to produce a set of tables containing the geographical coverage of each inventory.

**9. Merge code modifications to trunk**

Commit all changes you made to stabilize the release and get the complete translation to work to the branch and report all those changes to the trunk. Make sure to associate all those changes to the release issue created at the beginning of the release process and to the issue describing each actual fix.

**10. Document and create the release**

1. Change the version number in the main readme.md file.

2. List all the issues still in the [Project](https://github.com/CASFRI/CASFRI/projects) column created at the beginning of the release process in the issue named after the release. Group them by main feature added or "Other bug fixes". Look at previous releases for reference on how to describe the release.

3. Create a new release in GitHub and copy the description text from the release issue. Close the issue.

Congratulations! You're done!
