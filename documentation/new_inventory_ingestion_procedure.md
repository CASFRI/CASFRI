# Procedure for adding a new inventory to CASFRI

This guide explains how to document a new forest inventory, load it into the database, translate its information into the CASFRI format, and check the results. It describes the scripts included in this version of the project.

The examples use **NB99**, an invented identifier for a new New Brunswick inventory, and **NBI01**, an existing inventory standard. Replace NB99 with your new inventory's identifier and NBI01 with its actual standard. NB99 is not a dataset included with the project.

Use a Git Bash command window for examples marked `bash`, including conversion, loading, translation scripts, and Git comparisons. Step 5 explains how to open that window. You can keep the same window open and reuse it throughout the procedure. Start each example from the main CASFRI folder unless a different folder is specified. The command `cd` changes folders, and `source` reads a settings or script file into the current Bash session. Parentheses around a group of commands keep its folder changes within that group. Text beginning with `$` in Bash examples refers to settings read from `config.sh` or `common.sh`; preserve that notation.

Run examples marked `sql` in a database query window, such as the Query Tool in pgAdmin, connected to the intended development database. Bash examples that start the `psql` program remain Git Bash commands: that program sends SQL to the database for you. SQL examples use the database groups `public`, `rawfri`, `translation`, `casfri50`, and `casfri50_test`, as the current scripts expect. These are instructions to follow with your own data; no inventory was loaded or translated when this guide was written.

1) **Understand which files and tables are involved.**

    Conversion reads the original data files and loads them into a table such as `rawfri.nb99`. Translation then checks the source values and converts them to CASFRI's names, categories, units, and missing-value codes. The PostgreSQL Table Translation Framework is the software that turns the written translation rules into database operations. CASFRI adds the translated records to the appropriate result tables.

    | File or group of files | What it is used for |
    | --- | --- |
    | [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv) | Inventory name, source, dates, standard, permissions, priority, selection settings, and expected numbers of records |
    | [metadata/layer_metadata.csv](../metadata/layer_metadata.csv) | Which source columns and forest layers supply information to each CASFRI table |
    | `conversion/sh/load_nb99.sh` | The conversion script to create for the new inventory |
    | `translation/tables/nb_nbi01_*.csv` | Translation rules shared by inventories using NBI01; `*` stands for the different table names |
    | [translation/tables/species_code_mapping.csv](../translation/tables/species_code_mapping.csv) | Correspondences between source species codes and CASFRI species codes |
    | [helperfunctions/helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql) | Database operations used for conversion checks, mapping, translation, and tests |
    | `workflow/01_develTranslationTables/NB99.sql` | Database commands to save for developing and checking this inventory's translation |
    | [translation/test/nb_tests_per_layer.csv](../translation/test/nb_tests_per_layer.csv) | How many source records to sample for each inventory, result table, and input layer |
    | `translation/test/tables/*_nb_test.csv` | Saved test results for New Brunswick, used to compare results before and after a change |

    The result tables have short names: **HDR** describes the inventory; **CAS** identifies each source polygon; **LYR** describes forest layers; **NFL** describes non-forest land; **DST** describes disturbances; **ECO** contains ecological information; and **GEO** stores polygon shapes. HDR is copied from inventory metadata. The other six tables are produced by translation.

    Read the [CASFRI specification](specifications/README.md) for the meaning of each column, the permitted values, and how forest layers are represented.

2) **Choose an inventory identifier and determine which standard applies.**

    Find comparable inventories in `inventory_metadata.csv` and check which identifiers are already used. Choose an unused four-character `INVENTORY_ID`: two letters for the province, territory, or other inventory group, followed by two digits. A higher number does not necessarily mean a more recent inventory. Older data newly added to CASFRI also receive a new identifier.

    Keep the dataset identifier and its standard separate. NB99 identifies one delivered dataset. NBI01 identifies the instructions used to describe and classify its forest information. Several inventories may follow the same standard.

    Compare source manuals, measurement units, species lists, class boundaries, layer definitions, and the meaning of missing values with those of an existing standard. Two columns with similar names can still have different meanings. Reuse existing translation rules only when their meanings agree. Differences in column names can be handled in the mapping file.

    If the meaning of the source information has changed substantially, create a new standard identifier, a corresponding standard row in layer metadata, and a new set of translation tables. Explain the differences in the inventory notes. The [README](../README.md) describes identifier rules and the difference between a new interpretation of the forest and an update recording disturbances.

    Keep older inventories when adding newer deliveries. The README requires an update's publication date to be at least one year later than the previous version for inclusion. Resolve uncertain dates before deciding whether to include the update.

3) **Store the original files and write an inventory description.**

    Use the following folders beneath `friDir`, the setting that identifies where the source inventories are stored:

    ```text
    FRI/NB/NB99/
      data/archive/       Original delivery archives
      data/inventory/     Extracted inventory datasets
      data/coverage/      Coverage or boundary data
      data/photoyear/     Separate photo-year data, when supplied
      doc/archive/        Original documentation archives
      doc/emailexchange/  Acquisition and clarification correspondence
      doc/manual/        Data dictionaries and interpretation standards
      doc/manual/others/ Supporting references
      doc/map/           Reference maps
      license/           License and permission records
      toclassify/        Material awaiting classification
    ```

    Keep the files as originally received. Record filenames, dataset and map-layer names, download addresses or delivery source, acquisition date, publication date, production period, original coordinate reference system, and numbers of records. A coordinate reference system describes how map coordinates correspond to locations on the earth. Record file checksums as well: these are calculated signatures that help detect whether a file has changed.

    Distinguish the year aerial photographs were taken from the years the inventory was updated, published, or downloaded.

    Create a description such as `documentation/inventories/NB99.md` in the project folder. This is a recommended supporting document; the scripts do not read it. Include manual versions and page references, source-column descriptions, preparation decisions, assumptions, known problems, expected record counts, software versions, commands used, and test results.

    Keep restricted source data and private correspondence in their appropriate storage folders. The inventory description can identify where they are kept without reproducing them.

    Decide whether the delivery contains one inventory or several separately identified parts. For example, [load_nb08.sh](../conversion/sh/load_nb08.sh) reads a delivery stored under NB06 and selects records for a particular holder. If doing this, record the shared source location and the exact rule used to select each part.

4) **Add one row describing the inventory to the metadata file.**

    Add exactly one row to `metadata/inventory_metadata.csv`. Keep the existing column names and order. Preserve quotation marks around values containing commas so those values stay in one column. If using a spreadsheet application, check that saving the CSV has not changed identifiers, dates, or quotation marks.

    | Columns | What to enter |
    | --- | --- |
    | `INVENTORY_ID`, `JURISDICTION`, `OWNER_TYPE`, `OWNER_NAME` | Identifier, province/territory or inventory group, and responsible organization |
    | `STANDARD_TYPE`, `STANDARD_VERSION`, `STANDARD_ID`, `STANDARD_REVISION`, `DOCUMENTATION_TITLES` | Applicable standard and the documents that describe it |
    | `SRC_DATA_FORMAT`, `PRODUCTION_YEARS`, `PUBLICATION_DATE` | Original file format and dates |
    | `ACQUISITION_PERSON`, `ACQUISITION_DATE`, `ACQUISITION_TYPE`, `ACQUISITION_LINKS`, `CONTACT_INFO` | Who obtained the data, when, from where, and whom to contact |
    | `DATA_AVAILABILITY`, `REDISTRIBUTION`, `PERMISSION`, `LICENSE_AGREEMENT`, `LICENSE_AGREEMENT_URL` | Availability and documented permission to use or distribute the data |
    | `PHOTO_YEAR_SRC`, `PHOTO_YEAR_START`, `PHOTO_YEAR_END` | How photograph years are determined and their range |
    | `PRECEDENCE_RANK` | Priority used when inventories cover the same place and time |
    | `TRANSLATED_BY_ULAVAL`, `TRANSLATED_BY_CFS`, `TRANSLATED_BY_CUSTOM` | YES/NO settings used to select inventories for processing |
    | `CONVERTED_STAND_CNT`, `CAS_ROW_CNT`, `DST_ROW_CNT`, `ECO_ROW_CNT`, `LYR_ROW_CNT`, `NFL_ROW_CNT`, `GEO_ROW_CNT` | Expected number of loaded stands and translated rows, confirmed later |
    | `COMMENT` | Explanations, unusual preparation, and the location of the inventory description |

    Follow the specification and comparable records for accepted values and codes representing missing information. Do not guess dates or permissions. If counts are temporary estimates, say so in the inventory description. A temporary zero must not later be mistaken for a confirmed empty table.

    Leave the settings that automatically include the inventory in larger processing jobs at NO while developing it. Select the inventory by name for these first tests.

    Choose `PRECEDENCE_RANK` based on the documented quality and suitability of the data. It controls which inventory is preferred in certain overlaps; it is not simply the next available inventory number. Check the historical-table rules before assigning it.

5) **Prepare the software, settings, and test database.**

    The required tools are Bash for running scripts, GDAL/OGR for reading and converting spatial files, PostgreSQL for storing tables, PostGIS for working with spatial data inside PostgreSQL, and the PostgreSQL Table Translation Framework for applying translation rules.

    This version of the project's README specifies GDAL 3.10.x, PostgreSQL 13.1+, and PostGIS 3.1+. Record the versions actually used. Different versions can produce small differences in calculated areas or in which records are selected for tests.

    If `config.sh` does not exist, copy [config_sample.sh](../config_sample.sh) to that name and enter your computer's settings. Set `friDir`, database connection details, `gdalFolder`, `psqlCmd`, `bashCmd`, and the limits on how many jobs can run at the same time. Keep `targetFRISchema=rawfri` and `targetTranslationFileSchema=translation`. Other parts of the current database code expect those names, so changing these settings alone will not move the complete process to different database groups.

    To work only on the example inventory, set `fullList=(NB99)` and `postProcessingOnly=False` in `config.sh`. Use the spelling and capitalization shown. The scripts check the latter setting before starting conversion or translation, but the sample settings file does not define it.

    Review `overwriteFRI` before running a loading script. It controls whether existing loaded tables can be replaced. The current metadata and translation-table loading scripts also use the replacement setting derived from `overwriteFRI`; changing `overwriteTTables` alone does not control them.

    Install the translation framework using the instructions provided with that project. It can be installed as the database extension `table_translation_framework` (an added database component), or by loading `engine.sql`, `helperFunctions.sql`, and `helperFunctionsGIS.sql` in that order. Run its checks: `engineTest.sql`, `helperFunctionsTest.sql`, and `helperFunctionsGISTest.sql`.

    **Open a Git Bash command window before running the commands below.** On Windows, open the Start menu, type **Git Bash**, and select the Git Bash application. If the shortcut is unavailable, open File Explorer and double-click `C:\Program Files\Git\git-bash.exe` on this computer. Git Bash is included with Git for Windows; if it is not installed on another computer, install Git for Windows before continuing.

    In the Git Bash window, go to the main CASFRI folder. For this computer, enter the following commands, pressing Enter after each line:

    ```bash
    cd /g/CASFRI/CASFRI
    pwd
    ls README.md common.sh config_sample.sh
    ```

    Git Bash writes the Windows path `G:\CASFRI\CASFRI` as `/g/CASFRI/CASFRI`. If the project is elsewhere, change the path accordingly. Put a path containing spaces in double quotation marks, for example `cd "/g/My Projects/CASFRI"`. The `pwd` command displays the current folder. The `ls` command should list the three named files. If it reports that a file cannot be found, check that you opened the main project folder before proceeding.

    Copy a Bash example into this window using Shift+Insert or the window's Paste command. Copy only the commands, without the surrounding Markdown backticks. For commands spread across several lines, copy the complete block and keep the backslash `\` at each continued line's end. Press Enter if needed to start the last line, then read the messages and wait for the command prompt to return before continuing. Some scripts open additional windows; check their results too.

    Keep the window open for later Bash examples. If you close it, open Git Bash again and repeat the folder-navigation commands above. If you have moved to another folder, use `cd /g/CASFRI/CASFRI` to return before starting the next example. Run any `source ./common.sh` line included in an example as well; it reads settings needed by that example.

    Now run these commands in Git Bash to install and test the CASFRI database functions. The `psql` program sends the SQL files to the database specified in your settings:

    ```bash
    source ./common.sh
    "$psqlCmd" $psqlConnectionString -X -v ON_ERROR_STOP=1 \
      -f helperfunctions/helperFunctionsCASFRI.sql
    "$psqlCmd" $psqlConnectionString -X -v ON_ERROR_STOP=1 \
      -f helperfunctions/helperFunctionsCASFRITest.sql
    ```

    Read the test results, not just the message that the command finished. A check can report a failure without stopping the script. Use the development database because these installation and test files create or replace database tables and functions.

6) **Examine the source data before preparing its conversion.**

    In Git Bash, use `ogrinfo` to list the available map layers and examine columns, record counts, coordinate reference systems, polygon types, and geographic coverage. Replace `source.gdb` and `SourceLayer` with the actual file and map-layer names:

    ```bash
    source ./common.sh
    "$gdalFolder/ogrinfo" "$friDir/NB/NB99/data/inventory/source.gdb"
    "$gdalFolder/ogrinfo" -so \
      "$friDir/NB/NB99/data/inventory/source.gdb" SourceLayer
    ```

    Identify the columns that link each stand to its polygon and to any separate attribute tables. Check for repeated identifiers, multiple source files, missing polygon shapes, and separate photo-year data. When combining tables, determine whether one stand matches one record or several records in the other table. Multiple matches can accidentally duplicate stands.

    Record the original numbers of records before selecting subsets or combining tables. Explain how those operations should change the final count.

    Examine the values used for categories, measurement units, missing data, zeroes, accents, and identifiers beginning with zero. SQL distinguishes `NULL` (no stored value) from an empty string (a stored text value with no characters). The source may also use special values such as -9999 for missing information. Confirm each meaning in the manual.

    If the input is an unsupported E00 file, retain the original and document how to convert it to a supported format before continuing.

7) **Prepare the script that converts and loads the inventory.**

    Copy a script for an inventory with a similar file format and structure to `conversion/sh/load_nb99.sh`. Adjust it for the new data. Follow its existing sequence: read `../../common.sh`; set `inventoryID`, source locations, map-layer names, and `fullTargetTableName`; read `../pre_conversion.sh`; convert and prepare the data; then read `../post_conversion.sh`. These paths are relative to the conversion script's folder.

    The result should be one source table, normally `rawfri.nb99`, containing all information needed for translation. Where the original data use several linked tables, combine the necessary columns into this single table. Keep original stand identifiers and add `src_filename` (the source filename) and `inventory_id` (the uppercase inventory identifier).

    Retain `ogc_fid`, the record identifier used by the loading process, and `wkb_geometry`, the column containing polygon shapes. The translation and sampling operations depend on these names.

    Reuse `$gdalLco` and `$gdalOtherOptions` from `common.sh`. They specify the required column names and transform coordinates to Canada Albers, `ESRI:102001`. Check the original coordinate reference system first. Changing its label without transforming coordinates can place polygons in the wrong location. Follow suitable existing examples when handling polygons with separate pieces or curved boundaries.

    For several compatible source files, load the first and add the others to it. For linked source tables, record the matching columns and check that combining them neither duplicates nor loses stands. Retain enough information to trace each result to its original file and record.

    Decide whether empty text values should be converted to NULL. The option `-emptyStrAsNull` does this and can therefore change the missing-value codes assigned during translation.

    Put preparation steps in the script so another person can repeat them: correcting column types, removing unwanted spaces, selecting records, handling duplicates, repairing shapes, and attaching photograph years. Explain the reason for each step. Keep the rules that assign CASFRI categories in the translation tables or functions.

    `post_conversion.sh` creates an index on `ogc_fid`, which helps the database find records quickly, and runs `VACUUM ANALYZE` to maintain database performance. If SQL commands created the final table and it needs an index for spatial searches, follow the existing `createSQLSpatialIndex=True` setting.

8) **Run conversion and check the loaded records.**

    Load any required photograph-year or supporting datasets first. Then run the new conversion script in Git Bash. The first command checks Bash command syntax without converting data; the second performs conversion:

    ```bash
    bash -n conversion/sh/load_nb99.sh
    bash conversion/sh/load_nb99.sh
    ```

    `conversion/convert_all.sh` can normally start conversion for a list of inventories from the `conversion/` folder. However, this version contains an incorrectly written condition for loading photo-year data: `if [ -z "$invToLoad" &&  ]; then`. Use the direct commands above until that problem has been corrected and checked. Do not assume supporting photograph-year tables were loaded automatically.

    Read the messages and inspect the resulting table. Existing scripts do not always stop after an error. Run these SQL checks:

    ```sql
    SELECT inventory_id, src_filename, count(*)
    FROM rawfri.nb99 GROUP BY inventory_id, src_filename;

    SELECT count(*) AS rows_loaded,
           count(DISTINCT ogc_fid) AS distinct_fids,
           count(*) FILTER (WHERE ogc_fid IS NULL) AS null_fids,
           min(ogc_fid) AS first_fid, max(ogc_fid) AS last_fid
    FROM rawfri.nb99;

    SELECT ST_SRID(wkb_geometry), GeometryType(wkb_geometry), count(*)
    FROM rawfri.nb99 GROUP BY 1, 2;

    SELECT count(*) FILTER (WHERE wkb_geometry IS NULL) AS null_geometries,
           count(*) FILTER (WHERE ST_IsEmpty(wkb_geometry)) AS empty_geometries,
           count(*) FILTER (WHERE NOT ST_IsValid(wkb_geometry)) AS invalid_geometries
    FROM rawfri.nb99;
    ```

    The first query counts records by inventory and source file. The second checks record identifiers: `rows_loaded` and `distinct_fids` should agree, and `null_fids` should be zero. The third lists coordinate-system identifiers and shape types. The fourth counts missing, empty, or invalid shapes; investigate any nonzero counts.

    Compare counts with the original files and account for every selection or table combination. Examine geographic coverage and any polygon problems. The test sampling method uses numbers between 1 and the source row count to find `ogc_fid` values. Missing numbers or a different numbering range can reduce the sample. Avoid changing those identifiers without assessing the consequences: they also affect CAS_IDs and saved test results.

    Once counts agree with the source and documented preparation, enter the confirmed count in `CONVERTED_STAND_CNT`. Reload metadata and run the comparison:

    ```bash
    bash metadata/load_metadata.sh
    ```

    ```sql
    SELECT * FROM TT_ConvertedStandCount(ARRAY['NB99']);
    ```

9) **Record how source columns and layers correspond to CASFRI.**

    Add NB99 rows to `metadata/layer_metadata.csv`, using a comparable inventory as a starting point. Check every entry against the columns actually loaded into the database. There must be only one row for each inventory/layer combination. Add a row for each input layer or separate translation operation.

    In `casfri_table`, list the uppercase result-table names supplied by that row, such as `CAS ECO DST LYR GEO`, `LYR`, or `NFL`. A missing name can cause a complete result table to be skipped without stopping the process. Do not copy unnecessary quote characters from older records.

    A standard row, such as `NB_NBI01` with layer 1 and `ttable_exists=yes`, defines the general column names expected by the translation rules. Inventory rows normally use `ttable_exists=no` and specify the actual source column supplying each value. For example, `l1s1` supplies `species_1`, and `l1pr1` supplies `species_per_1`. Where a cell lists several columns, their order must agree with the corresponding list in the standard row.

    Some entries use a fixed value, such as a layer number, instead of a source column. Follow existing examples for fixed values and `NULL`. Inspect the resulting database view, which is a saved query displaying selected or renamed source columns. Do not assume a formula typed into a CSV cell will be calculated: this part of the software does not support arbitrary SQL expressions.

    Distinguish the layer used to read source columns from the final CASFRI layer number. Translation can reorder forest layers by height or produce several non-forest components from one source record. Document overstory, understory, horizontal components, the layer associated with disturbance or wetland information, and how `NUM_OF_LAYERS` is calculated. Every operation for the same polygon must construct the same CAS_ID.

    Document how the photograph year is obtained and what happens when it is missing. Do not silently replace it with publication year. Explain which result tables should legitimately be empty and which attributes should receive codes for missing or inapplicable information.

10) **Prepare translation rules and code-conversion tables.**

    CASFRI uses the province/group identifier and `STANDARD_ID` to find the rules. NB99 following NBI01 uses `translation.nb_nbi01_cas`, `nb_nbi01_lyr`, and the other relevant tables. Create a new set under `translation/tables/` only when needed. Supply rules for every result table named in layer metadata.

    Translation CSV files contain these seven columns; keep their exact names:

    ```text
    rule_id,target_attribute,target_attribute_type,validation_rules,translation_rules,description,desc_uptodate_with_rules
    ```

    | Column | What it describes |
    | --- | --- |
    | `rule_id` | A unique rule number that also sets the result-column order |
    | `target_attribute` | The result column to produce |
    | `target_attribute_type` | The kind of value expected, such as text, a whole number, or a decimal number |
    | `validation_rules` | Checks the source value must pass |
    | `translation_rules` | How to convert an accepted source value |
    | `description` | A plain-language explanation of the checks and conversion |
    | `desc_uptodate_with_rules` | Whether the explanation agrees with the current rules |

    Match column types and order to the result table. Where needed, use `ROW_TRANSLATION_RULE` to decide which records should be translated. Test records that should be included and records that should be excluded. For example, an absent understory should not produce an extra row filled with missing-value codes.

    Explain each source value's meaning, the order of its checks, accepted values, units, and class boundaries. When a check fails, translation assigns the relevant error or missing-value code. Preserve the distinction between NULL, empty text, unknown values, invalid values, values outside the accepted range, and information that does not apply. The code must suit the result column's type.

    Review polygon identifiers, species and percentages, crown closure, height, origin year, productivity, non-forest classes, disturbances, wetlands, and shapes. CAS_ID must be 50 characters long, unique for each polygon, and traceable to the source. Follow the existing standard's construction rules.

    Update `species_code_mapping.csv` and any other code-conversion tables when needed. These are also called lookup tables. Check that each source code has a clear meaning and an appropriate CASFRI value or documented error outcome. A change to a shared table can alter older inventories too.

    Use existing database functions where possible. If a new function must be written, add it to `helperFunctionsCASFRI.sql`, add the corresponding removal command to `helperFunctionsCasfriUninstall.sql`, and add the tests described in step 18. Document the inventory interpretation that justifies the calculation.
11) **Load the metadata and rules, then try a small sample.**

    In Git Bash, run the following commands to load the relevant CSV files. This script also reloads both metadata files:

    ```bash
    (
      cd translation
      bash load_tables.sh nb_nbi01_cas.csv nb_nbi01_dst.csv \
        nb_nbi01_eco.csv nb_nbi01_lyr.csv nb_nbi01_nfl.csv \
        nb_nbi01_geo.csv species_code_mapping.csv
    )
    ```

    Include any other code-conversion CSVs required by the rules. If database functions have changed, load their updated definitions before preparing translation. Confirm that the expected metadata and translation tables are present in the database. Editing a CSV file on your computer does not automatically update its database copy.

    Save commands used for investigation in `workflow/01_develTranslationTables/NB99.sql` so another person can repeat the checks. Older development examples sometimes use outdated mapping names. The following example uses the current naming format and samples 200 source rows:

    ```sql
    SELECT TT_CreateMappingView('rawfri', 'nb99', 1, 'nb_nbi01', 1, 200);
    SELECT * FROM rawfri.nb99_l1_to_nb_nbi01_l1_map_200 LIMIT 10;

    SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb99_lyr_devel');
    SELECT * FROM TT_Translate_nb99_lyr_devel(
      'rawfri', 'nb99_l1_to_nb_nbi01_l1_map_200'
    );
    ```

    `TT_CreateMappingView` prepares a view showing the source columns under the names expected by the chosen standard. `TT_Prepare` creates the database function that applies the LYR rules. The last query displays its translated results. These commands display a sample translation; they do not perform the complete inventory translation described in step 13.

    Repeat this preparation and inspection for every required result table and input layer. Check that columns are present, fixed values are correct, and the intended records were selected. `TT_Prepare` checks whether the rules are correctly written, but cannot establish whether they correctly interpret the inventory manual.

    Compare original and translated values for selected stands, including rare categories and missing information. Use the documented CAS_ID construction and original identifiers to match records. Do not assume that the last few characters of every CAS_ID identify a source record in the same way. Save expected values and supporting manual/page references in the inventory description.

12) **Prepare the result tables without deleting existing inventory data.**

    If using a new development database whose results can be discarded, run the following in Git Bash after loading metadata and rules:

    ```bash
    (
      cd workflow/02_produceCASFRI
      bash 01_createCASFRITables.sh
    )
    ```

    **This script deletes and recreates HDR and the translated tables. Its `CASCADE` option can also remove database objects that depend on those tables. Do not run it to add one inventory to a database containing results you need to keep.**

    For an existing database, keep its result tables and first add the new inventory description to HDR. The following SQL copies only the required columns, following [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql):

    ```sql
    INSERT INTO casfri50.hdr_all (
      inventory_id, jurisdiction, owner_type, owner_name, standard_type,
      standard_version, standard_id, standard_revision, documentation_titles,
      src_data_format, production_years, publication_date, acquisition_date,
      acquisition_type, acquisition_links, contact_info, data_availability,
      redistribution, permission, license_agreement, photo_year_start,
      photo_year_end, photo_year_src
    )
    SELECT m.inventory_id, m.jurisdiction, m.owner_type, m.owner_name,
           m.standard_type, m.standard_version, m.standard_id, m.standard_revision,
           m.documentation_titles, m.src_data_format, m.production_years,
           m.publication_date, m.acquisition_date, m.acquisition_type,
           m.acquisition_links, m.contact_info, m.data_availability,
           m.redistribution, m.permission, m.license_agreement,
           m.photo_year_start, m.photo_year_end, m.photo_year_src
    FROM public.inventory_metadata m
    WHERE m.inventory_id = 'NB99'
      AND NOT EXISTS (
        SELECT 1 FROM casfri50.hdr_all h WHERE h.inventory_id = m.inventory_id
      );
    ```

    Check that HDR contains exactly one correct NB99 row. The command avoids adding another row if NB99 already exists, but it does not correct an existing row. Update the relevant values separately if needed. Do not replace the column list with `SELECT *`, because the metadata table contains extra columns that HDR does not have.

    Existing databases may have constraints: rules that prevent invalid values or broken links between tables. A foreign-key constraint, for example, can require a polygon's CAS record to exist before its LYR record is added. Load CAS first, then its related tables. The script that starts several translations at once does not guarantee that order.

    Keep existing constraints where possible when adding an inventory.

13) **Translate all records in the inventory.**

    In a new development database where table-link constraints do not impose an order, run this in Git Bash:

    ```bash
    (
      cd workflow/02_produceCASFRI
      bash 02_translateAll.sh NB99
    )
    ```

    Check the displayed database name, inventory list, and processing settings before continuing. The list in `config.sh` can replace inventory names supplied on the command line because the script reads that settings file. Keep the settings and command consistent.

    To translate one table at a time, particularly when existing table-link constraints require CAS first, run these SQL commands in order:

    ```sql
    CALL TT_TranslateInventory('NB99', 'T', 'cas');
    CALL TT_TranslateInventory('NB99', 'T', 'eco');
    CALL TT_TranslateInventory('NB99', 'T', 'dst');
    CALL TT_TranslateInventory('NB99', 'T', 'nfl');
    CALL TT_TranslateInventory('NB99', 'T', 'lyr');
    CALL TT_TranslateInventory('NB99', 'T', 'geo');
    ```

    `CALL` starts the named database procedure. Each command prepares the appropriate rules, reads the mapped source information, and adds translated rows to its result table. The procedure does **not** automatically replace rows left by an earlier attempt.

    If translation stops partway through, first determine which tables already contain NB99. Before retrying, remove only the affected NB99 rows, deleting related LYR/NFL/DST/ECO/GEO rows before their CAS rows where links require that order. Alternatively, start again with an empty development database whose results can be discarded. Rerunning without checking can create duplicate records.

    Save the messages and check each expected result table. Some missing-data problems are reported as messages followed by an early stop, without a command failure. A command that appears to finish successfully may therefore have translated only part of the inventory.

14) **Check the complete results and confirm the expected row counts.**

    Run this comparison of translated counts with inventory metadata:

    ```sql
    SELECT * FROM TT_TranslatedRowCount(ARRAY['NB99']);
    ```

    Work out expected counts from the source layers and record-selection rules, then explain differences before changing the expected counts. CAS and GEO often correspond directly to source stands, but some inventories filter records. A stand can have several forest layers or no disturbance record, so LYR, NFL, DST, and ECO counts need not equal the CAS count.

    Check that identifiers are unique, related records link to an existing CAS polygon, shapes are valid, years and units make sense, and layers are in the correct order. Examine how often error or missing-value codes occur. The following queries provide several checks:

    ```sql
    SELECT layer, count(*) FROM casfri50.lyr_all
    WHERE left(cas_id, 4) = 'NB99' GROUP BY layer ORDER BY layer;

    SELECT cas_id, count(*) FROM casfri50.cas_all
    WHERE inventory_id = 'NB99' GROUP BY cas_id HAVING count(*) <> 1;

    SELECT cas_id, layer, count(*) FROM casfri50.lyr_all
    WHERE left(cas_id, 4) = 'NB99'
    GROUP BY cas_id, layer HAVING count(*) <> 1;

    SELECT l.cas_id FROM casfri50.lyr_all l
    LEFT JOIN casfri50.cas_all c USING (cas_id)
    WHERE left(l.cas_id, 4) = 'NB99' AND c.cas_id IS NULL;

    SELECT cas_id FROM casfri50.geo_all
    WHERE left(cas_id, 4) = 'NB99'
      AND (geometry IS NULL OR ST_IsEmpty(geometry) OR NOT ST_IsValid(geometry));
    ```

    In order, these queries show counts by forest layer, duplicate CAS identifiers, duplicate LYR identifiers within a layer, LYR records with no matching CAS record, and missing/empty/invalid shapes. The first is a summary to inspect. The other four should return no rows once problems are resolved.

    Repeat checks of links and duplicates for the other relevant tables. Check that every expected CAS identifier appears in GEO and every GEO identifier appears in CAS. Equal counts alone do not prove that the two tables contain the same polygons. Inspect geographic coverage, coordinate reference systems, example shapes, and the units used for areas.

    In a new validation database, run `01_addConstraints.sql`, `01_addGeoConstraints.sql`, `02_addIndexes.sql`, and `03_additionalChecks.sql` from [03_ConstraintsChecksAndIndexes](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes). Read each `passed` result and use the supplied investigation queries when a check fails. Constraints enforce data rules; indexes speed up database searches.

    These scripts change database objects. Before applying them to an existing installation, check which constraints and indexes are already present. An error saying an object already exists does not necessarily mean the inventory data are wrong.

    Use [summary_statistics/summarize.R](../summary_statistics/summarize.R) and related R scripts after adjusting their database and output settings. R is the software used here to produce statistical summaries. Compare frequencies and ranges with the source data and comparable inventories. A table containing only permitted missing-value codes can pass basic checks while still indicating an incorrect column mapping.

    Enter the six confirmed translated counts in inventory metadata, reload it, and repeat the count comparisons. Record the evidence and reasons for legitimate differences in the inventory description.

15) **Choose the source samples used to check future changes.**

    Regression tests check whether a change has unexpectedly altered results that were previously accepted. CASFRI translates samples of source records and saves the results for comparison. This is quicker than translating every inventory in full.

    Add rows to `translation/test/nb_tests_per_layer.csv` for every required combination of inventory, result table, and **input layer used by the mapping**. Use the existing lowercase names and header:

    ```csv
    inventory_id, cas_table, layer, nb_test_rows
    nb99,cas,1,200
    nb99,eco,1,1000
    nb99,dst,1,1000
    nb99,lyr,1,300
    nb99,lyr,2,600
    nb99,nfl,3,600
    ```

    The sample sizes above are examples, not verified settings for your inventory. Use the actual input layers listed in layer metadata. `nb_test_rows` is the number of source records to sample before translation decides which records belong in the result. For example, sampling 1,000 stands might yield only a few disturbance records if disturbances are uncommon.

    The standard test execution script checks CAS, ECO, DST, NFL, and LYR. It does not include HDR and GEO in these saved sample results. Check those tables using the complete-data checks and the specific tests in step 18.

    **A missing sample entry does not mean skip this case.** The current procedure treats an absent size as a request to use the full source table. A size of zero produces no sampled rows and must be explained. Include exactly one entry for each required inventory/table/input-layer combination.

    Reload inventory and layer metadata before running these tests. Naming an inventory directly can skip the scripts' automatic metadata-loading step. The test execution script does load the sample-size CSV itself.

16) **Run the sample tests and check that the intended cases were included.**

    Keep copies of previously accepted test CSVs and any edits not yet saved in Git's history. The test execution script deletes and rewrites CSV files in `translation/test/tables/`. It produces results but does not compare them with earlier results or decide whether they are correct. Run the following commands in Git Bash:

    ```bash
    (
      cd translation/test
      bash test_translation.sh NB99
    )
    ```

    This command selects **New Brunswick**, not just NB99. For each result table, the script uses `TT_RunAllTests` to look through New Brunswick inventories in metadata and test those whose source tables are present. The metadata's normal processing-selection settings do not limit that list.

    If the database contains only NB99, the tests cannot check the other New Brunswick inventories. To replace the accepted New Brunswick test files with complete new results, use a database containing the required other inventories too.

    Results are stored in `casfri50_test.cas_nb`, `eco_nb`, `dst_nb`, `nfl_nb`, and `lyr_nb`, then exported in a fixed row order to the corresponding `*_nb_test.csv` files. Read messages about missing source tables, missing mappings, preparation failures, and unexpectedly empty results. Check that NB99 appears in every table where records are expected, and that existing inventories have not disappeared.

    After the sample-size table has been loaded, use the following SQL to find missing or duplicated sample settings. It should return no rows:

    ```sql
    WITH expected AS (
      SELECT lower(m.inventory_id) AS inventory_id,
             t.cas_table, m.layer::int AS layer
      FROM public.layer_metadata m
      CROSS JOIN (VALUES ('cas'), ('eco'), ('dst'), ('lyr'), ('nfl')) t(cas_table)
      WHERE m.inventory_id = 'NB99'
        AND strpos(m.casfri_table, upper(t.cas_table)) > 0
    )
    SELECT e.*, count(n.inventory_id) AS matching_sample_entries
    FROM expected e
    LEFT JOIN casfri50_test.nb_tests_per_layer n
      ON n.inventory_id = e.inventory_id
     AND n.cas_table = e.cas_table
     AND n.layer::int = e.layer
    GROUP BY e.inventory_id, e.cas_table, e.layer
    HAVING count(n.inventory_id) <> 1;
    ```

    Also check for missing or negative sample sizes and inspect the actual number of test results. Correct settings do not by themselves prove that any records were tested.

17) **Adjust sample sizes using the complete translation as a reference.**

    Once complete translation results and sample results both exist, run:

    ```sql
    SELECT * FROM TT_CheckNumberOfTests('cas', 'nb', TRUE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('dst', 'nb', TRUE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('eco', 'nb', FALSE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('lyr', 'nb', TRUE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('nfl', 'nb', FALSE) WHERE inv = 'NB99';
    ```

    These commands compare the number of translated test rows with the number recommended for each result table. They use the grouping choices currently used for New Brunswick. Consult [validate_number_of_tests.sql](../translation/test/validate_number_of_tests.sql) for other inventories.

    Some checks group results by final CASFRI layer; others combine layers. Check each layer separately when its sample can be adjusted independently. Combining layers can be more practical when one source record produces several non-forest result rows. The input layer listed in the sample-size CSV may differ from the final layer number shown here.

    | Result column | What to look for |
    | --- | --- |
    | `cnt` | Number of rows in the complete translation for that inventory or layer |
    | `suggested_nbr` | Recommended number of translated test rows |
    | `tested_nb` | Actual number of translated test rows; verify this directly |
    | `sufficient` | Whether the function reports enough test rows; do not rely on this alone |
    | `diff_pct` | Difference from the recommended sample size, expressed as a percentage |

    Recommended sizes range from zero for groups with fewer than 20 translated rows to 1,000 in the largest supported group. Use the function's recommendation rather than guessing at size boundaries.

    There is a limitation in the current check: it can report `sufficient=true` even when no matching group of test results exists. Independently require a positive, adequate `tested_nb` wherever records should have been tested. If a tiny or intentionally empty group is excluded from random sampling, explain why and check it directly.

    Increase the source sample when too few records remain after selection during translation. Reduce unnecessarily large samples where practical; the project's check also identifies `diff_pct >= 20` for review. Reload settings and rerun until each expected table/layer has adequate checks.

    Complete these adjustments before accepting the saved test files. Changing the sample size also changes which source records are selected, so it can change many rows in the comparison files.

18) **Write specific tests for unusual cases and new calculations.**

    Random samples can miss rare conditions. Prepare a table of cases to check, including ordinary values, NULL, empty text, unknown category codes, class boundaries, values outside permitted ranges, absent/present understory, changed layer order, forest/non-forest classification, disturbances, missing photograph years, and new species codes.

    For each case, record the source values, the expected result, and the manual or specification reference that justifies it. Calculate the expected result independently before comparing it with the software output.

    If a database function is new or changed, add tests to [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql). These are unit tests: checks of one function at a time. Follow the existing columns `number`, `function_tested`, `description`, and `passed`. Update `test_nb`, the list recording the function groups and expected number of tests, so the checks can also detect an operation that unexpectedly returns no result.

    Test successful calculations, missing values, and invalid inputs. Use comparisons that explicitly handle NULL. Inspect missing or NULL test results as well as results marked as failed; completion of the SQL command alone is not sufficient.

    For selected stands, also check the final translated tables. Save these tests in a file such as `translation/test/nb99_assertions.sql`. An assertion is a check that reports failure when the result differs from what was expected. **The standard test execution script does not automatically run this new file; run it separately.**

    Identify the stands using their original files and identifiers, then record their expected CAS_IDs. Check that the correct number of rows exists as well as checking their values. The example below requires exactly one layer-1 row with the expected species and percentage. Replace the example CAS_ID and values with a reviewed case before running it:

    ```sql
    DO $$
    DECLARE
      matching_rows integer;
      correct_rows integer;
    BEGIN
      SELECT count(*),
             count(*) FILTER (
               WHERE species_1 IS NOT DISTINCT FROM 'PICE_GLAU'
                 AND species_per_1 IS NOT DISTINCT FROM 70
             )
      INTO matching_rows, correct_rows
      FROM casfri50.lyr_all
      WHERE cas_id = '<reviewed 50-character NB99 CAS_ID>' AND layer = 1;

      IF matching_rows <> 1 OR correct_rows <> 1 THEN
        RAISE EXCEPTION 'NB99 species fixture failed: rows=%, correct=%',
          matching_rows, correct_rows;
      END IF;
    END;
    $$;
    ```

    The SQL counts matching rows and rows with the correct values. If either count is not one, it reports an error. `IS NOT DISTINCT FROM` makes the value comparison explicit even when NULL is involved.

    Add checks for records that should be excluded, missing-value codes, multiple layers, and the link between CAS and GEO. For shapes, compare the intended location, shape, area, or other relevant measurements. Different software versions may store an equivalent shape differently, so exact comparison of stored bytes is not always useful. Explain any allowed measurement difference in terms of units and required precision.

    In Git Bash, run the specific tests against the complete translation:

    ```bash
    source ./common.sh
    "$psqlCmd" $psqlConnectionString -X -v ON_ERROR_STOP=1 \
      -f translation/test/nb99_assertions.sql
    ```

    Where practical, temporarily enter a deliberately wrong expected value to confirm that a test reports failure, then restore the correct value. Do not simply copy unreviewed translation output into the expected-result column: that would preserve a mistake rather than detect it.

19) **Compare the new test files with the previously accepted results.**

    In Git Bash, run these Git commands from the main project folder to see which test files changed and what changed inside two of them:

    ```bash
    git diff --stat -- translation/test/tables
    git diff -- translation/test/tables/cas_nb_test.csv
    git diff -- translation/test/tables/lyr_nb_test.csv
    ```

    `git diff --stat` summarizes changes by file. `git diff` shows changed lines; removed lines begin with `-` and added lines with `+`. Review the ECO, DST, and NFL files too.

    If shared rules have not changed, adding NB99 should generally add NB99 results. Investigate changes to older inventories. Possible causes include a different sample, changed record identifiers, changed selection rules, a different row order, small differences in calculated geometry measurements, or an actual change in translation. [translation/test/readme.md](../translation/test/readme.md) explains these causes.

    A new inventory has no previously accepted test results. Manually review representative new records and run the specific tests from step 18 before accepting the first saved files as a reference for future comparisons.

    Do not accept the disappearance of older inventories merely because their source tables were absent from the test database. Produce complete replacement files using a database with the required inventories, or keep the incomplete files separately for investigation without replacing the accepted reference results.

    If shared rules, code-conversion tables, or database functions changed, test every inventory that uses them. A general-purpose function can affect several provinces or territories. Record which inventories could not be tested; a skipped inventory has not passed.

    Run the tests again with the same inputs, software versions, and settings. The saved files should be identical. Investigate unexplained differences before saving the accepted results in Git's history. Record file checksums, how record identifiers were assigned, software versions, sample sizes, and the reasons for accepted changes.

20) **Finish the documentation and prepare the inventory for use.**

    Review the inventory description, metadata, conversion script, column/layer mappings, translation rules, code-conversion tables, changed functions, and all tests together. Record commands used, confirmed counts, check results, sample sizes, manually reviewed examples, and remaining limitations. When ready, enable the intended YES/NO settings that include the inventory in larger processing jobs, and reload metadata.

    The inventory is ready when loaded counts agree with the original data and documented preparation; metadata and HDR are correct; all expected translated tables exist; identifiers, values, shapes, and links between tables pass their checks; samples are adequate; specific tests pass; and saved comparison results have been reviewed and can be reproduced. Check that the file changes do not accidentally include source datasets, computer-specific settings, or unrelated inventories.

    If the required output also includes combined tables, maps of inventory coverage, or historical tables showing which inventory applies at each place and time, continue through `workflow/03_flatCASFRI/` and `workflow/04_produceHistoricalTable/`. Confirm inventory priorities and rebuild historical results for overlapping affected inventories as well as NB99. Completing translation does not automatically update these additional products.
