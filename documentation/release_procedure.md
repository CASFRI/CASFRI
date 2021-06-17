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

The whole release process should take about one week... This is necessary to ensure that release are stables and actually able to do what they are supposed to do without issues. 

Note that only major issues preventing the conversion or the translation process to work properly should be fixed during the release process. Leave other small issues to subsequent releases.

**1. Prepare the release**

1. Make sure every fixed issue has been closed.

2. Create a new issue in both CASFRI and the PostgreSQL Table Translation Framework to associate all commits done during the release process to them and to prepare the texts with the list of fixed issues describing both releases. Simply name those issues "Produce Release vx.y.z". Make sure to associate all commits made to stabilize the releases to those "Produce Release" issues in addition to the number of the issue describing the actual fix committed.

3. In GitKraken (or your favorite git client), create a branch for both CASFRI and the PostgreSQL Table Translation Framework. Name these branches according to the Version Release versioning scheme described in each product Readme (x.y.z: increment z for bug fixes, y for new features and x when breaking backward compatibility).

4. In GitHub, create a new column in each repository [Project](https://github.com/edwardsmarc/CASFRI/projects) named after the release and move all fixed issues to this column. This is to avoid that issues fixed on the trunk, after the creation of the branch, get mixed with issues fixed on the branch.

5. In pgAdmin, create a new PostgreSQL database to test and certify the code found on those two branches. Your goal is to stabilize those branches before creating releases with them.

6. In pgAdmin, create the PostGIS extension in the new database.

**2. Convert the inventories and load the translation tables in the database**

1. Copy the configSample.sh script to config.sh and edit it so the listed shell variables reflect your configuration.

3. Make sure all the inventories to load are listed in your config.sh invList1-5 variables. All inventories pertaining to the same invList1-5 variable are executed in parallel. Different invList1-5 variables are executed sequentially. There are five lists to avoid overloading the system.

3. Open a Bash command window, CD to the CASFRI conversion/sh folder and load all the listed inventories using the load_all.sh script. This script split the loading process in three steps in order to avoid overloading the server. Each inventory conversion trigger the oppening of a new command window. By default all those command windows close by themselves when they are done. You can control this behavior by setting the config.sh "leaveConvShellOpen" variable to True. In this case you will have to close some windows for the loading process to go on.

4. In the same command window, load the translation tables using the CASFRI/translation/load_tables.sh script.

**3. Install and unsintall the PostgreSQL Table Translation Framework and the CASFRI Helper Functions**

1. Copy the configSample.sh (or .bat) script to config.sh (or .bat) and edit it to make the pghome variable point to your PostgreSQL installation directory and the tt_version variable to reflect the proper Framework version number. 

2. In the same command window, install the last version of the PostgreSQL Table Translation Framework extension file using the install.sh (or .bat) script. This step produce a file named table_translation_framework--x.y.z.sql in the PostgreSQL/XX/share/extension folder.

3. In pgAdmin, load the Table Translation Framework and the CASFRI Helper Functions:

    1. CREATE the table_translation_framework extension and test it using the engineTest.sql, helperFunctionsTest.sql and helperFunctionsGISTest.sql scripts. Fix any non passing test (by fixing the function tested or the test itself).

    2. Load the CASFRI Helper Functions with the helperFunctionsCASFRI.sql script and test them using the helperFunctionsCASFRITest.sql. Fix any non passing test.

    3. Check the count of loaded inventory with the checkCounts.sql script. Fix inventories not reporting the right number of rows and add any missing test.

4. In pgAdmin, make sure the uninstall scripts uninstall everything and leave no Table Translation Framework and CASFRI Helper function in the database:

    1. DROP all TT_Translate() functions with "SELECT TT_DropAllTranslateFct();"

    2. Uninstall the CASFRI Helper Functions using the helperFunctionsCASFRIUninstall.sql script.

    3. DROP the table_translation_framework extension.

    4. Make sure all table_translation_framework and all CASFRI Helper Functions were dropped properly by looking for any remaining TT_ functions in the public.function item in the pgAdmin browser. If not, add the undroped ones to the proper uninstall.sql script.

5. Reinstall all the functions as in step 7.

**4. Test the translation**

1. Execute the CASFRI/translation/test/testTranslation.sh script. You can also run each test_cas.sql, test_dst.sql, test_eco.sql, test_lyr.sql and test_nfl.sql in pgAdmin. This will produce a series of table in the CASFRI50_test schema.

2. Dump the produced test tables using the CASFRI/translation/test/dump_test_tables.sh script. You should easily see the differences between the result of the test and the archived reference tables in GitKraken (or any git client able to show differences between the local and the GitHub repositories). Fix any issue in the production of the test tables if they are wrong or commit the new tables if they are right. Update the counts of produced row and the processing time for each group of test at the end of each script.

**5. Run the translation**

1. In the command window, CD to workflow/02_produceCASFRI and execute the 01_translate_all_00.sh and then the 01_translate_all_01.sh scripts one AFTER the other. The first script prepare the target shema and tables and the second actually translate all the inventories listed in the invList1-5 variables.

**6. Validate the translation**

1. In pgAdmin, once all translation scripts are finished, run the workflow\02_produceCASFRI\00_checkCounts.sql script to check if the count of translated rows matches what is expected. You should be able to explain every differences.

2. In pgAdmin, run the 01_addConstraints.sql script to make sure all the translated rows respect the CASFRI specifications. Create a new GitHub issue for any not passing constraint and add a reference to the issue number in the description of the constraint in the script itself. Remove existing reference for fixed, now passing issues.

**7. Generate the flat (denormalized) tables**

Run the workflow\03_flatCASFRI scripts to produce the two different flat versions of the database.

**8. Generate the historical version of the database**

Load the required functions by running geoHistory.sql.

Then, in order, run:

1. the workflow\04_produceHistoricalTable\01_PrepareGeoHistory.sh to prepare the casfri50_history schema, the inv_precedence table where you establish the precedence of the various inventories and some functions.

2. the workflow\04_produceHistoricalTable\02_ProduceGeoHistory.sh to produce the historical tables in parallel.

3. the workflow\04_produceHistoricalTable\03_ProduceInventoryCoverages.sh to produce a set of tables containing the geographical coverage of each inventory.

**9. Merge code modifications to trunk**

Commit all changes you made to stabilize the release and get the complete translation to work to the branch and report all those changes to the trunk. Make sure to associate all those changes to the release issue created at the beginning of the release process and to the issue describing each actual fix.

**10. Document and create the release**

1. List all the issues still in the [Project](https://github.com/edwardsmarc/CASFRI/projects) column created at the beginning of the release process in the issue named after the release. Group them by main feature added or "Other bug fixes". Look at previous releases for reference on how to describe the release.

2. Create a new release in GitHub and copy the description text from the release issue. Close the issue.

Congratulation! You're done!
