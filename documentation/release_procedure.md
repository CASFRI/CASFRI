# CASFRI and PostgreSQL Table Translation Framework release procedure

A complete release includes:

- The complete conversion and translation of all the acquired inventories.
- The stabilization of the code to complete this whole translation.
- A validation of the final completed database.
- The generation of two flat (denormalized) versions of the database.
- The generation of the inventories geographical coverages.
- The generation of a historical version of the translated database.
- The documentation of remaining issues discovered while completing the complete, actual translation.
- The documentation of the release itself.

The whole release process should take about one week... This is necessary to ensure that releases are stable and actually able to do what they are supposed to do without issues.

Note that only major issues preventing the conversion or translation process from working properly should be fixed during the release process. It is better to fix other issues in the context of subsequent releases.

## 1) Prepare the release

### 1.1 Close resolved issues

Make sure every fixed issue has been closed on GitHub.

### 1.2 Create release tracking issues

Create a new issue in both CASFRI and the PostgreSQL Table Translation Framework to associate all commits done during the release process to them and to prepare the texts listing fixed issues for both releases. Simply name those issues "Produce Release vx.y.z". Make sure to associate all commits made to stabilize the releases to those "Produce Release" issues in addition to the number of the issue describing the actual fix committed.

### 1.3 Create release branches

In GitKraken (or your favorite git client), create a branch for both CASFRI and the PostgreSQL Table Translation Framework. Name these branches according to the version-release scheme described in each product's README.md (x.y.z: increment z for bug fixes, y for new features and x when breaking backward compatibility). For the framework, see its [README.md](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/README.md).

### 1.4 Organize release issues

In GitHub, create a new column in each repository [Project](https://github.com/CASFRI/CASFRI/projects) named after the release and move all fixed issues to this column. This is to avoid that issues fixed on the trunk, after the creation of the branch, get mixed with issues fixed on the branch.

### 1.5 Create a test database

In pgAdmin, create a new PostgreSQL database to test and certify the code found on those two branches. Your goal is to stabilize those two branches before creating releases with them.

### 1.6 Enable PostGIS

In pgAdmin, create the PostGIS extension in the new database.

## 2) Convert inventories and load translation tables

### 2.1 Configure CASFRI

Copy the [config_sample.sh](../config_sample.sh) script to `config.sh` and edit it so all the variables reflect your development environment, your PostgreSQL access and the way you want to control all the CASFRI processing scripts.

### 2.2 Select the inventories to translate

Make sure all the inventories to convert and translate are correctly flagged in the proper column (`TRANSLATED_BY_CFS`, `TRANSLATED_BY_ULAVAL` or `TRANSLATED_BY_CUSTOM`) of [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv). See the main [README.md](../README.md) for more details.

### 2.3 Convert the inventories

Open a Bash shell, change to the `conversion/` directory, and run [convert_all.sh](../conversion/convert_all.sh) to convert all inventories flagged in [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv). This script launches a parallel subshell for each inventory to be converted. As soon as an inventory finishes converting, a new subshell should start, maintaining up to a maximum of `maxConversionInParallel` concurrent conversions at the same time, as defined in `config.sh`.

By default all those shells close by themselves when they are done. You can control this behavior by setting the `leaveConversionShellOpen` variable in `config.sh` to True. In this case you will have to close some windows for the next subshells to be launched one at a time.

### 2.4 Load the translation tables

After conversion finishes, change to the `translation/` folder and run [load_tables.sh](../translation/load_tables.sh).

## 3) Install and uninstall the PostgreSQL Table Translation Framework and the CASFRI helper functions

### 3.1 Configure the framework installation

Copy the framework's [PostgreSQL-Table-Translation-Framework/configSample.sh](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/configSample.sh) (or `configSample.bat`) to `PostgreSQL-Table-Translation-Framework/config.sh` (or `config.bat`) and edit it to make the `pghome` variable point to your PostgreSQL installation directory and the `tt_version` variable to reflect the proper PostgreSQL Table Translation Framework version number.

### 3.2 Install the framework extension

In the same shell, install the latest version of the PostgreSQL Table Translation Framework extension using the framework's [PostgreSQL-Table-Translation-Framework/install.sh](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/install.sh) (or `install.bat`). This step produces `table_translation_framework--x.y.z.sql` in the `PostgreSQL/XX/share/extension/` folder.

### 3.3 Install and test the translation functions

In pgAdmin, CREATE the Table Translation Framework extension and execute the CASFRI Helper Functions script:

#### 3.3.1 Install and test the framework functions - Create the `table_translation_framework` extension. Run the framework's [engineTest.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/engineTest.sql), [helperFunctionsTest.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/helperFunctionsTest.sql), and [helperFunctionsGISTest.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/helperFunctionsGISTest.sql). Fix any failed tests by correcting the function or its test.

#### 3.3.2 Install and test CASFRI helper functions - Run [helperfunctions/helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql), followed by [helperfunctions/helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql). Fix any failed tests.

### 3.4 Test the uninstall scripts

In pgAdmin, verify that the uninstall scripts remove the framework and CASFRI helper functions:

#### 3.4.1 Remove translation functions - Run `SELECT TT_DropAllTranslateFct();`.

#### 3.4.2 Remove CASFRI helper functions - Run [helperfunctions/helperFunctionsCasfriUninstall.sql](../helperfunctions/helperFunctionsCasfriUninstall.sql).

#### 3.4.3 Remove the framework extension - DROP the `table_translation_framework` extension.

#### 3.4.4 Check for remaining functions - In pgAdmin, look under `public → Functions` for any remaining `TT_` functions. Add each remaining function to the appropriate uninstall script.

### 3.5 Reinstall the functions

Reinstall all the functions as in step 3.2 and 3.3.

### 3.6 Check converted counts

Check the count of converted inventories with the `TT_ConvertedStandCount()` function like this:

```sql
SELECT (TT_ConvertedStandCount('TRANSLATED_BY_CFS')).*;
```

The expected count of converted stands is in the `CONVERTED_STAND_CNT` column of [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv). If many inventories failed to convert and you want to give them another try, you can list them directly in `config.sh` using the `invList` array variable. If `invList` is set, [conversion/convert_all.sh](../conversion/convert_all.sh) ignores the flags in [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv) and launches a conversion subscript only for those inventories. To see error messages, set the `leaveConversionShellOpen` variable to True.

You can also launch the same procedure by listing the inventories to process directly as parameters to [conversion/convert_all.sh](../conversion/convert_all.sh):

```bash
./convert_all.sh AB03 AB06
```

## 4) Test the translation

### 4.1 Run translation tests

In Git Bash, from the `translation/test/` folder, run [test_translation.sh](../translation/test/test_translation.sh). You can control which tests are run by passing a list of inventories to test to the script:

```bash
./test_translation.sh AB03 BC08
```

Even if you specify a list of inventories, all the inventories pertaining to the same jurisdiction will also be tested. For example, in the example above, all AB and all BC inventories will be tested. This is to ensure that changes made to the translation tables for one inventory do not break the translation of all the other inventories translated using the same translation tables.

### 4.2 Review translation test results

The resulting translation test tables will be dumped automatically at the end of the script. You should easily see the differences between those test tables and the archived reference tables in GitKraken (or any git client able to show differences between the local and the GitHub repositories). Fix any issue in the production of the test tables if they are wrong or commit the new tables if they are right.

More details about the translation tests can be found in [translation/test/readme.md](../translation/test/readme.md).

## 5) Run the translation

In the Bash shell, change to `workflow/02_produceCASFRI/` and run [01_createCASFRITables.sh](../workflow/02_produceCASFRI/01_createCASFRITables.sh), then [02_translateAll.sh](../workflow/02_produceCASFRI/02_translateAll.sh). The first script prepares the target schema and tables; the second translates all inventories flagged for processing in [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv) or listed directly in the `invList` variable.

## 6) Validate the translation

### 6.1 Check translated counts

At the end of [02_translateAll.sh](../workflow/02_produceCASFRI/02_translateAll.sh), a count of translated versus expected translated rows is displayed. The expected row counts for each CASFRI table are listed in the `CAS_ROW_CNT`, `DST_ROW_CNT`, `ECO_ROW_CNT`, `LYR_ROW_CNT`, `NFL_ROW_CNT` and `GEO_ROW_CNT` columns of [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv).

You can also rerun this counting process in pgAdmin or with psql:

```sql
SELECT (TT_TranslatedRowCount('TRANSLATED_BY_CFS')).*
```

You should be able to explain every difference between the expected count and the actual number of translated rows and you should commit new values in `inventory_metadata.csv` only once you can explain them.

### 6.2 Apply constraints, create indexes, and run additional checks

In pgAdmin, run [workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addConstraints.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addConstraints.sql) to make sure all translated rows respect the CASFRI specifications. Create a new GitHub issue for any constraint that does not pass and add a reference to the issue number in the constraint description in the script. Remove references for fixed issues whose constraints now pass. Do the same for the other validation scripts in the same folder: [01_addGeoConstraints.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addGeoConstraints.sql), [02_addIndexes.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/02_addIndexes.sql), and [03_additionalChecks.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/03_additionalChecks.sql).

## 7) Generate the denormalized (flat) tables

Run [workflow/03_flatCASFRI/01_all_layers_same_row.sh](../workflow/03_flatCASFRI/01_all_layers_same_row.sh) and [workflow/03_flatCASFRI/03_one_layer_per_row.sh](../workflow/03_flatCASFRI/03_one_layer_per_row.sh) to produce the two different flat versions of the database. Those two scripts simply run their `.sql` equivalents. You can execute the SQL scripts in pgAdmin or with psql instead. You can also optionally run the test scripts.

## 8) Generate the historical database and inventory coverages

### 8.1 Load geohistory functions

Execute [helperfunctions/geohistory/geohistory.sql](../helperfunctions/geohistory/geohistory.sql) in pgAdmin or using psql to load the required geohistory functions.

### 8.2 Test geohistory functions

Load the test tables, run the geohistory tests, then dump and compare the test results:

#### 8.2.1 Load test tables - From `helperfunctions/geohistory/`, run [load_test_tables.sh](../helperfunctions/geohistory/load_test_tables.sh) and [load_test_tables_with_inv_data.sh](../helperfunctions/geohistory/load_test_tables_with_inv_data.sh).

#### 8.2.2 Run geohistory tests - Run [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), [geohistory_test_with_inv_data.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data.sql), and [geohistory_test_with_inv_data_gridded.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data_gridded.sql) in pgAdmin or `psql`.

#### 8.2.3 Dump and compare test tables - Run [helperfunctions/geohistory/dump_test_tables_with_inv_data.sh](../helperfunctions/geohistory/dump_test_tables_with_inv_data.sh), then compare its output with the archived tables. Archive new tables after reviewing and explaining the differences.

### 8.3 Prepare historical processing

In the Bash shell, execute [workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sh](../workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sh) to prepare the `casfri50_history` schema, generate a gridded version of the `casfri50.geo_all` polygons and define some other functions.

### 8.4 Produce the historical table

Execute [workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh](../workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh) to process all inventories flagged for processing in parallel. The `maxGeoHistoryInParallel` variable in `config.sh` controls how many parallel subshells can be launched at the same time.

### 8.5 Produce inventory coverage tables

Execute [workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh](../workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh) to produce a set of tables containing the geographical coverage of each inventory.

## 9) Merge code modifications into the main branch

Commit all changes you made to stabilize the release and get the complete translation to work to the branch and report all those changes to the trunk. Make sure to associate all those changes to the release issue created at the beginning of the release process and to the issue describing each actual fix.

## 10) Document and create the release

### 10.1 Update the version number

Change the version number in the main [README.md](../README.md).

### 10.2 Document issues included in the release

List all the issues still in the [Project](https://github.com/CASFRI/CASFRI/projects) column created at the beginning of the release process in the issue named after the release. Group them by main feature added or "Other bug fixes". Look at previous releases for reference on how to describe the release.

### 10.3 Create the GitHub release

Create a new release in GitHub and copy the description text from the release issue. Close the issue.

Congratulations! You're done!
