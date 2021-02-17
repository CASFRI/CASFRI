Release Procedure

1 - In GitKraken, create a branch for both CASFRI and the PostgreSQL Table Translation Framework. Name these branches according to the Version Release versioning scheme (x.y.z: increment z for bug fixes, y for new features and x when breaking backward compatibility).

2 - In pgAdmin, create a new PostgreSQL database to test and certify what is on those branches. Your goal is to stabilize those branches before creating releases with them.

3 - In pgAdmin, create the PostGIS extension in the database.

4 - Open a DOS or a Bash shell, CD to the CASFRI conversion folder and load all the necessary inventories using the load_all.sh or the load_all.bat script.

5 - In the same shell, load the translation tables using the CASFRI/translation/load_tables.sh (or .bat) script.

6 - In the same shell, install the last version of the PostgreSQL Table Translation Framework extension file using the install.sh (or .bat) script. This step produce a file named table_translation_framework--x.y.z.sql in the Postgresql/XX/share/extension folder.

7 - In pgAdmin, load the Table Translation Framework and the CASFRI Helper Functions:

7.1 - CREATE the table_translation_framework extension and test it using the engineTest.sql, helperFunctionsTest.sql and helperFunctionsGISTest.sql scripts. Fix any non passing test (by fixing the function tested or the test itself).

7.2 - Load the CASFRI Helper Functions with the helperFunctionsCASFRI.sql script and test them using the helperFunctionsCASFRITest.sql. Fix any non passing test.

7.3 - Check the count of loaded inventory with the checkCounts.sql script. Fix inventories not reporting the right number of rows and add any missing test.

8 - In pgAdmin, check that the unsinstall scripts uninstall everything:

8.1 - DROP all TT_Translate functions with "SELECT TT_DropAllTranslateFct();"

8.1 - Uninstall the CASFRI Helper Functions using the helperFunctionsCASFRIUninstall.sql script.

8.2 - DROP the table_translation_framework extension.

8.3 - Make sure all table_translation_framework and all CASFRI Helper Functions were DROPed properly by looking for any remaining TT_ functions in the public.function item in the pgAdmin browser. If not, add the unDROPed ones to the proper uninstall.sql script.

9 - Reinstall everything as in step 7.

10 - Test the translations:

10.1 - Execute the CASFRI/translation/test/testTranslation.sh (or .bat) script. You can also run each test_cas.sql, test_dst.sql, test_eco.sql, test_lyr.sql and test_nfl.sql in pgAdmin. This will produce a series of table in the CASFRI50_test schema.

10.2 - Dump the produced test tables using the CASFRI/translation/test/dump_test_tables.sh (or .bat) script. You should easily see the differences between the result of the test and the archived reference tables in GitKraken (or any git client able to show differences between the local and the GitHub repositories). Fix any issue in the production of the test tables if they are wrong or commit the new tables if they are right. Update the counts of produced row and the processing time for each group of test at the ned of each script.

11 - Run the translations:

11.1 - If necessary, edit the workflow/02_produceCASFRI/01_translate_all_0X.sh (or .bat) scripts to translate only the inventories you want to translate.

11.2 - In the shell, CD to workflow/02_produceCASFRI and execute the 01_translate_all_0X.sh (or .bat) scripts one AFTER the other in order to not overload your system. 01_translate_all_00.sh initialise the database. 01_translate_all_01.sh and 01_translate_all_02.sh are for bigger inventories and 01_translate_all_03.sh and 01_translate_all_04.sh are for smaller inventories.

12 - In pgAdmin, run the workflow\02_produceCASFRI\03_ConstraintsChecksAndIndexes SQL script one after the other. Fix any resolved constraint and create a new issue for any not passing constraint. Add a reference to the issue number in the description of the constraint in the script itself.

13 - Run the workflow\03_flatCASFRI script to produce the flat version of the database.

14 - Run the docs\inv_coverage\produce_inv_coverage.sql to produce the coverage of each inventory.

15 - Run the workflow\04_produceHistoricalTable\produceHistoricalTable.sql to produce a historical version of the database resolving all overlaps in space and time.

16 - Commit all the changes you made to get the complete translation to work to the branch and report all those changes to the trunc.