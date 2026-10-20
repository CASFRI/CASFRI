# Procedure for converting and translating a new inventory to CASFRI

This guide expands the six numbered steps of the README's [Translate a new inventory](../README.md#translate-a-new-inventory) procedure, with numbered subsections providing the details.

The examples use **NB99**, an invented identifier for a new New Brunswick inventory, and **NBI01**, an existing inventory standard. Replace NB99 with your new inventory's identifier and NBI01 with its actual standard. NB99 is not a dataset included with the project.

Use a Git Bash command window for examples marked `bash`, including conversion, loading, translation scripts, and Git comparisons. Follow subsection 2.2 to open the window and start commands from the correct folder.

- Prefix shell-script paths with `./` in commands, for example `bash ./conversion/sh/load_nb99.sh` from the main folder or `bash ./convert_all.sh` from the `conversion/` folder. The prefix `./` means the current folder; preserve `../` in paths that refer to a parent folder.

- The command `cd` changes folders, and `source` reads a configuration file or script into the current Bash session.

- Parentheses around a group of commands keep its folder changes within that group.

- Text beginning with `$` in Bash examples refers to configuration variables read from `config.sh` or `common.sh`; preserve that notation.

Run examples marked `sql` in a database query window, such as the Query Tool in pgAdmin, connected to the intended development database. Bash examples that start the `psql` program remain Git Bash commands: that program sends SQL to the database for you. SQL examples use the database schemas `public`, `rawfri`, `translation`, `casfri50`, and `casfri50_test`, as the current scripts expect. These are instructions to follow with your own data; no inventory was loaded or translated when this guide was written.

**Files to prepare at each step** - The table below follows the six numbered sections of this guide. Start by documenting the inventory in `metadata/inventory_metadata.csv`, then prepare its conversion script, column mappings, and translation tables. Use those files to translate the inventory, create and check its tests, and share the reviewed changes. Each row identifies the file to create, edit, reuse, or generate and the subsection with the detailed instructions. Some files need changes only when existing translation tables or helper functions cannot handle the new inventory. Prefer the basic helper functions provided by the PostgreSQL Table Translation Framework before writing specialized CASFRI helper functions. Step 4 uses the prepared files without requiring file edits, so it is omitted from this table. The step numbers match the detailed sections below.

| Step and subsection | File or group of files | What to create, edit, or use |
| --- | --- | --- |
| **1. Archive and document the new inventory** — 1.2 | Original inventory files and documentation under `friDir` | Archive the delivery and supporting documents in the prescribed folders. Keep the original files unchanged. |
| 1.3; count updates in 2.7 and 5.1; final review in 6.1 | [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv) | Document the inventory in its dedicated columns and use `COMMENT` for additional explanations, decisions, and test results. Update counts after checking conversion and translation, and complete the documentation at step 6.1. |
| **2. Prepare the environment, convert and load the inventory** — 2.1 | `config.sh`, copied from [config_sample.sh](../config_sample.sh) if needed | Set the local paths, database connection, inventory selection configuration variables, and processing options. |
| 2.5–2.7 | `conversion/sh/load_nb99.sh` | Create the inventory's conversion script from a similar script, run it, and check the loaded records. |
| **3. Prepare and validate the inventory translation** — 3.1 | [metadata/layer_metadata.csv](../metadata/layer_metadata.csv) | Add the inventory's attribute mappings and dependencies for each input layer and a standard row if a new standard is needed. |
| 3.2–3.3 | `translation/tables/nb_nbi01_*.csv` | Reuse existing translation tables as much as possible, making simple modifications when needed. Create new tables only when reuse would require substantial changes. Load the tables before testing them. Here, `*` stands for the CASFRI table names. |
| 3.2–3.3 | [translation/tables/species_code_mapping.csv](../translation/tables/species_code_mapping.csv) and other required lookup CSVs | Add or correct code correspondences when the inventory requires them. |
| 3.2–3.3 | [helperfunctions/helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql) | Use the basic helper functions provided by the PostgreSQL Table Translation Framework wherever possible. Add or modify a specialized CASFRI helper function only when those functions cannot meet the need; load its definition and add or update its tests in [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql). |
| 3.2–3.3 and 5.5 | [helperfunctions/helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql) | Add or update tests when a helper function is new or changed. |
| 3.2 | [helperfunctions/helperFunctionsCasfriUninstall.sql](../helperfunctions/helperFunctionsCasfriUninstall.sql) | Add the corresponding removal command when adding a helper function. |
| 3.4 | `workflow/01_develTranslationTables/NB99.sql` | Create a development script to save the commands used to investigate mappings and validate sample translations. |
| **5. Generate, validate and archive test tables** — 5.2–5.4 | [translation/test/nb_tests_per_layer.csv](../translation/test/nb_tests_per_layer.csv) | Add the number of source records to sample for each required inventory, CASFRI table, and input layer. Adjust those numbers after checking the translated samples. |
| 5.5 | `translation/test/nb99_assertions.sql` | Create specific tests when needed to check cases that random samples do not adequately cover. Run this file separately. |
| 5.3 and 5.6 | `translation/test/tables/*_nb_test.csv` | Generate these files with [./test_translation.sh](../translation/test/test_translation.sh), then compare and review their contents before accepting them as reference results. |
| **6. Record and share the work** — 6.1–6.3 | Inventory metadata and reviewed project files listed above | Complete the inventory documentation in `metadata/inventory_metadata.csv`, then review, commit, and push the relevant changes. Follow 6.2 if additional database products must also be updated. |

The CASFRI tables have short names:

- **HDR** describes the inventory.
- **CAS** identifies each source polygon.
- **LYR** describes forest layers.
- **NFL** describes non-forest land.
- **DST** describes disturbances.
- **ECO** contains ecological information.
- **GEO** stores polygon shapes.

HDR is copied from inventory metadata. The other six tables are produced by translation.

Read the [CASFRI specification](specifications/README.md) for the meaning of each column, the permitted values, and how forest layers are represented.

1) **Archive and document the new inventory** - Establish its identity and preserve the source information needed to interpret and process it.

    **1.1 Determine the inventory identifier and standard** - Find comparable inventories in `inventory_metadata.csv` and check which identifiers are already used. Find the highest number already used for the jurisdiction and increase it by one. For example, if AB34 is the last identifier used, assign AB35; do not reuse a gap in the numbering. Keep the four-character `INVENTORY_ID` format: two letters for the province, territory, or other inventory group, followed by two digits, and confirm that the new identifier is not already present. A higher number does not necessarily mean a more recent inventory. Older data newly added to CASFRI also receive a new identifier.

    Keep the dataset identifier and its standard separate. NB99 identifies one delivered dataset. NBI01 identifies the instructions used to describe and classify its forest information. Several inventories may follow the same standard.

    Compare source manuals, measurement units, species lists, class boundaries, layer definitions, and the meaning of missing values with those of an existing standard. Two columns with similar names can still have different meanings. Prefer reusing existing translation tables, including with simple modifications that accommodate the new inventory while preserving correct translations of existing inventories. Differences in column names can be handled in the mapping file. Subsection 3.2 explains when to adapt existing tables or create new ones.

    If differences in the source information require substantial changes to the translation tables, create a new standard identifier, a corresponding standard row in layer metadata, and a new set of translation tables. Explain the differences in the inventory's `COMMENT` field in `metadata/inventory_metadata.csv`. The [README](../README.md) describes identifier rules and the difference between a new interpretation of the forest and an update recording disturbances.

    Keep older inventories when adding newer deliveries. The README requires an update's publication date to be at least one year later than the previous version for inclusion. Resolve uncertain dates before deciding whether to include the update.

    **1.2 Archive the original files and document their source** - Use the following folders beneath `friDir`, the configuration variable that identifies where the source inventories are stored:

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

    Record all inventory documentation in the inventory's row in `metadata/inventory_metadata.csv`. Use the dedicated columns for information such as source, standard, dates, permissions, documentation titles, and record counts. Use `COMMENT` for additional details, including manual versions and page references, source-column descriptions, preparation decisions, assumptions, known problems, software versions, commands used, and test results.

    Keep restricted source data and private correspondence in their appropriate storage folders. The `COMMENT` field can identify where they are kept without reproducing them.

    Decide whether the delivery contains one inventory or several separately identified parts. For example, [load_nb08.sh](../conversion/sh/load_nb08.sh) reads a delivery stored under NB06 and selects records for a particular holder. If doing this, record the shared source location and the exact rule used to select each part.

    **1.3 Document the inventory in inventory_metadata.csv** - Add exactly one row to `metadata/inventory_metadata.csv`. Keep the existing column names and order. Preserve quotation marks around values containing commas so those values stay in one column. If using a spreadsheet application, check that saving the CSV has not changed identifiers, dates, or quotation marks.

    ### Required inventory metadata columns

    Many columns are required for the whole translation process to work properly. The table below lists every column once, grouped by purpose. The groups are for reading this guide; keep the existing column order in the CSV file.

    All columns are loaded by [load_metadata.sh](../metadata/load_metadata.sh). The **Used by scripts?** column indicates whether later processing explicitly uses the value. **Copied to HDR** means that [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql) copies the column into the inventory description table, `casfri50.hdr_all`. These columns must exist for that script to run, although the copying step does not require every descriptive value to be filled in. **No specific use found** means the value is retained in the metadata for documentation but is not explicitly used by the current processing scripts.

    | Group | Column name | What it represents / what to enter | Used by scripts? | How it is used |
    | --- | --- | --- | --- | --- |
    | Identification and ownership | `INVENTORY_ID` | Unique four-character identifier, such as `NB99`. Add exactly one metadata row for this identifier. | Yes | Identifies the source table and inventory in selection, translation, tests, count checks, and historical processing. Its first two letters identify the jurisdiction used to select the translation tables. Also copied to HDR, where it is the primary key. |
    | Identification and ownership | `JURISDICTION` | Province, territory, or other jurisdiction responsible for the inventory. | Yes | Copied to HDR. Translation obtains its jurisdiction prefix from `INVENTORY_ID`, rather than from this descriptive field. |
    | Identification and ownership | `OWNER_TYPE` | Category of owner or responsible organization, using the accepted metadata codes. | Yes | Copied to HDR to describe the owner category. |
    | Identification and ownership | `OWNER_NAME` | Name of the owner or responsible organization. | Yes | Copied to HDR to identify the owner. |
    | Inventory standard | `STANDARD_TYPE` | Name or family of the inventory standard, such as AVI. | Yes | Copied to HDR to describe the standard. |
    | Inventory standard | `STANDARD_VERSION` | Published version of the inventory standard followed by the source data. | Yes | Copied to HDR to document the standard version. |
    | Inventory standard | `STANDARD_ID` | CASFRI identifier for the applicable standard, such as `NBI01`. | Yes | `TT_TranslateInventory` combines it with the jurisdiction prefix and CASFRI table name to select a translation table, such as `nb_nbi01_dst`. Also copied to HDR. |
    | Inventory standard | `STANDARD_REVISION` | Revision of the source standard, where a separate revision is documented. | Yes | Copied to HDR to document the revision. |
    | Inventory standard | `DOCUMENTATION_TITLES` | Titles of manuals and other documents describing the source inventory and its standard. | Yes | Copied to HDR as documentation references. |
    | Source format and dates | `SRC_DATA_FORMAT` | Original delivery format, using the accepted metadata codes. | Yes | Copied to HDR. The inventory's conversion script specifies how to read the actual source files. |
    | Source format and dates | `PRODUCTION_YEARS` | Year or period during which the source inventory was produced. | Yes | Copied to HDR to document production dates. |
    | Source format and dates | `PUBLICATION_DATE` | Date when the source inventory was published or released. | Yes | Copied to HDR to document publication. |
    | Acquisition and contact | `ACQUISITION_PERSON` | Person who obtained the inventory for the project. | No specific use found | Documents who acquired the data; not copied to HDR by the current creation script. |
    | Acquisition and contact | `ACQUISITION_DATE` | Date when the project obtained the inventory. | Yes | Copied to HDR to document acquisition. |
    | Acquisition and contact | `ACQUISITION_TYPE` | Method of acquisition, such as a download or direct delivery, using the accepted codes. | Yes | Copied to HDR to document how the data were obtained. |
    | Acquisition and contact | `ACQUISITION_LINKS` | Download addresses or other references to the source of the delivery. | Yes | Copied to HDR as acquisition references. |
    | Acquisition and contact | `CONTACT_INFO` | Contact information for the data provider or person able to clarify the inventory. | Yes | Copied to HDR as contact information. |
    | Access and permissions | `DATA_AVAILABILITY` | Documented availability of the source data, using the accepted codes. | Yes | Copied to HDR to describe availability. |
    | Access and permissions | `REDISTRIBUTION` | Documented conditions or restrictions on redistributing the data. | Yes | Copied to HDR to describe redistribution conditions. |
    | Access and permissions | `PERMISSION` | Documented permission or restriction applicable to using the data. | Yes | Copied to HDR to record permission information. |
    | Access and permissions | `LICENSE_AGREEMENT` | Applicable licence or agreement status, using the accepted codes. | Yes | Copied to HDR to record agreement information. |
    | Access and permissions | `LICENSE_AGREEMENT_URL` | Address of the applicable licence or agreement. | No specific use found | Provides a documentation reference; not copied to HDR by the current creation script. |
    | Photograph years | `PHOTO_YEAR_SRC` | Source or method used to determine photograph years, such as a source attribute or a spatial match to separate photograph-year data. | Yes | Copied to HDR to describe how photograph years were obtained. |
    | Photograph years | `PHOTO_YEAR_START` | Earliest photograph year documented for the inventory. | Yes | Copied to HDR to describe the inventory's photograph-year range. Historical processing uses each translated polygon's `STAND_PHOTO_YEAR` to determine its dates. |
    | Photograph years | `PHOTO_YEAR_END` | Latest photograph year documented for the inventory. | Yes | Copied to HDR to describe the inventory's photograph-year range. Historical processing uses each translated polygon's `STAND_PHOTO_YEAR` to determine its dates. |
    | Historical priority | `PRECEDENCE_RANK` | Whole-number priority based on the documented quality and suitability of the inventory. | Yes, for historical processing | `TT_HasPrecedence`, defined by [01_PrepareGeoHistory.sql](../workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sql), compares ranks when resolving overlaps between inventories. Higher numbers take precedence when this rule applies. |
    | Automatic selection | `TRANSLATED_BY_ULAVAL` | YES/NO inventory selection setting for the ULaval processing list. | Conditional | Selects inventories marked `YES` when `metadataTableLoadingColumn` names this column. Count-checking functions can also use it to select inventories. |
    | Automatic selection | `TRANSLATED_BY_CFS` | YES/NO inventory selection setting for the CFS processing list. | Conditional | Selects inventories marked `YES` when `metadataTableLoadingColumn` names this column. Count-checking functions can also use it to select inventories. |
    | Automatic selection | `TRANSLATED_BY_CUSTOM` | YES/NO inventory selection setting for a custom processing list. | Conditional | Selects inventories marked `YES` when `metadataTableLoadingColumn` names this column. Count-checking functions can also use it to select inventories. |
    | Expected record counts | `CONVERTED_STAND_CNT` | Expected number of source stands after conversion and loading. Enter a whole number and confirm it against the loaded data. | Yes | `TT_ConvertedStandCount` compares it with the loaded source-table count. Automatic inventory selection also uses it to order inventories from largest to smallest, as explained below. |
    | Expected record counts | `CAS_ROW_CNT` | Expected number of translated CAS records identifying source polygons. Enter a whole number. | Yes, for count checks | `TT_TranslatedRowCount` compares it with the inventory's row count in `casfri50.cas_all`. |
    | Expected record counts | `DST_ROW_CNT` | Expected number of translated disturbance records. Enter a whole number. | Yes, for count checks | `TT_TranslatedRowCount` compares it with the inventory's row count in `casfri50.dst_all`. |
    | Expected record counts | `ECO_ROW_CNT` | Expected number of translated ecological records. Enter a whole number. | Yes, for count checks | `TT_TranslatedRowCount` compares it with the inventory's row count in `casfri50.eco_all`. |
    | Expected record counts | `LYR_ROW_CNT` | Expected number of translated forest-layer records. Enter a whole number. | Yes, for count checks | `TT_TranslatedRowCount` compares it with the inventory's row count in `casfri50.lyr_all`. |
    | Expected record counts | `NFL_ROW_CNT` | Expected number of translated non-forest records. Enter a whole number. | Yes, for count checks | `TT_TranslatedRowCount` compares it with the inventory's row count in `casfri50.nfl_all`. |
    | Expected record counts | `GEO_ROW_CNT` | Expected number of translated polygon geometry records. Enter a whole number. | Yes, for count checks | `TT_TranslatedRowCount` compares it with the inventory's row count in `casfri50.geo_all`. |
    | Additional documentation | `COMMENT` | Additional inventory documentation, including interpretation and preparation decisions, temporary estimates, manual references, test results, and remaining limitations. | No specific use found | Retains notes for people maintaining the inventory; not copied to HDR by the current creation script. |

    The translation and count-checking functions named above are defined in [helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql). The inventory selection configuration variables are used by [define_invlist.sh](../define_invlist.sh) when `fullList` is not already defined; only the column selected by `metadataTableLoadingColumn` determines which inventories are included.

    **How expected stand counts affect processing order** - When inventories are selected automatically from metadata, [define_invlist.sh](../define_invlist.sh) sorts those marked `YES` in the selected column by `CONVERTED_STAND_CNT`, from largest to smallest. For example, an inventory with an expected count of 500,000 stands is listed before one with 100,000 stands, which is listed before one with 20,000 stands. The conversion and translation scripts use this order to launch their work, subject to the limits on simultaneous processes in `config.sh`; inventories can therefore finish in a different order. The sorting uses the count recorded in the metadata, without recounting the source data first. Inventories with equal counts have no specified order. If `fullList` is defined directly or inventory identifiers are supplied to the script on the command line, the supplied order is used instead.

    Follow the specification and comparable records for accepted values and codes representing missing information. Do not guess dates or permissions. If counts are temporary estimates, say so in the inventory's `COMMENT` field. A temporary zero must not later be mistaken for a confirmed empty table.

    Leave the inventory selection configuration variables at NO while developing the inventory. Select the inventory by name for these first tests.

    Choose `PRECEDENCE_RANK` based on the documented quality and suitability of the data. It controls which inventory is preferred in certain overlaps; it is not simply the next available inventory number. Check the historical-table rules before assigning it.

2) **Prepare the environment, convert and load the inventory** - Prepare the tools and create a checked source table for translation.

    **2.1 Check shared preparation and configure the database connection** - Complete [Shared preparation](../README.md#shared-preparation) for the database that will receive the inventory, preserving its existing data. The required tools are Bash for running scripts, GDAL/OGR for reading and converting spatial files, PostgreSQL for storing tables, PostGIS for working with spatial data inside PostgreSQL, and the PostgreSQL Table Translation Framework for applying translation rules.

    This version of the project's README specifies GDAL 3.10.x, PostgreSQL 13.1+, and PostGIS 3.1+. Record the versions actually used. Different versions can produce small differences in calculated areas or in which records are selected for tests.

    If `config.sh` does not exist, copy [config_sample.sh](../config_sample.sh) to that name and set the configuration variables for your computer. The configuration script is self-explanatory: its comments describe the configuration variables and how to use them. Set `friDir`, database connection details, `gdalFolder`, `psqlCmd`, `bashCmd`, and the limits on how many jobs can run at the same time. Keep `targetFRISchema=rawfri` and `targetTranslationFileSchema=translation` unchanged as other parts of code have those names hardcoded, so changing these variables alone will not move the data to different schemas.

    To work only on the example inventory, set `fullList=(NB99)` in `config.sh`. Keep `postProcessingOnly=False`, which is now included by default in `config_sample.sh`, to run conversion or translation. Setting it to `True` skips those operations and runs only the script's final processing steps, such as count checks. Use the spelling and capitalization shown.

    Review `overwriteFRI` before running a loading script. It controls whether existing loaded tables can be replaced. The current metadata and translation-table loading scripts also use the replacement setting derived from `overwriteFRI`; changing `overwriteTTables` alone does not control them.

    For a database that does not yet have PostGIS, execute `CREATE EXTENSION postgis;` in its pgAdmin Query Tool. Install the PostgreSQL Table Translation Framework using its `./install.sh` script from the framework project folder, following that project's configuration instructions. The installer places `table_translation_framework--x.y.z.sql` in PostgreSQL's `share/extension` folder. Enable it in the target database with `CREATE EXTENSION table_translation_framework;` if it is not already installed. Run the framework's `engineTest.sql`, `helperFunctionsTest.sql`, and `helperFunctionsGISTest.sql` and resolve failed checks.

    **2.2 Open a Git Bash command window** - On Windows, open the Start menu, type **Git Bash**, and select the Git Bash application. If the shortcut is unavailable, open File Explorer and double-click `C:\Program Files\Git\git-bash.exe` on this computer. Git Bash is included with Git for Windows; if it is not installed on another computer, install Git for Windows before continuing.

    In the Git Bash window, go to the main CASFRI folder. For this computer, enter the following commands, pressing Enter after each line:

    ```bash
    cd /g/CASFRI/CASFRI
    pwd
    ls README.md common.sh config_sample.sh
    ```

    Git Bash writes the Windows path `G:\CASFRI\CASFRI` as `/g/CASFRI/CASFRI`. If the project is elsewhere, change the path accordingly. Put a path containing spaces in double quotation marks, for example `cd "/g/My Projects/CASFRI"`. The `pwd` command displays the current folder. The `ls` command should list the three named files. If it reports that a file cannot be found, check that you opened the main project folder before proceeding.

    Copy a Bash example into this window using Shift+Insert or the window's Paste command. Copy only the commands, without the surrounding Markdown backticks. For commands spread across several lines, copy the complete block and keep the backslash `\` at each continued line's end. Press Enter if needed to start the last line, then read the messages and wait for the command prompt to return before continuing. Some scripts open additional windows; check their results too.

    Keep the window open for later Bash examples. Start each example from the main CASFRI folder unless a different folder is specified. If you close the window, open Git Bash again and repeat the folder-navigation commands above. If you have moved to another folder, use `cd /g/CASFRI/CASFRI` to return before starting the next example. Run any `source ./common.sh` line included in an example as well; it reads the configuration variables needed by that example.

    **2.3 Install or replace the CASFRI helper functions** - For a first installation, use the installation and test commands below. To replace an existing installation, wait until no translation is running and keep PostGIS and the Table Translation Framework installed. In the Query Tool connected to the target database, execute `SELECT TT_DropAllTranslateFct();`, then open and execute the entire [helperFunctionsCasfriUninstall.sql](../helperfunctions/helperFunctionsCasfriUninstall.sql) file. These operations remove translation functions and procedures, CASFRI helper functions, and supporting and test views, including dependent objects where specified by the script. Check for errors before reinstalling.

    Run these commands in Git Bash to install or reinstall the CASFRI helper functions and test them. The `psql` program sends the SQL files to the database specified by your configuration variables:

    ```bash
    source ./common.sh
    "$psqlCmd" $psqlConnectionString -X -v ON_ERROR_STOP=1 \
      -f helperfunctions/helperFunctionsCASFRI.sql
    "$psqlCmd" $psqlConnectionString -X -v ON_ERROR_STOP=1 \
      -f helperfunctions/helperFunctionsCASFRITest.sql
    ```

    Read the test results, not just the message that the command finished. A check can report a failure without stopping the script. Use the development database because these installation and test files create or replace database tables and functions.

    **2.4 Examine the source inventory files** - In Git Bash, use `ogrinfo` to list the available map layers and examine columns, record counts, coordinate reference systems, polygon types, and geographic coverage. Replace `source.gdb` and `SourceLayer` with the actual file and map-layer names:

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

    **2.5 Create the conversion and loading script** - Copy a script for an inventory with a similar file format and structure to `conversion/sh/load_nb99.sh`. Adjust it for the new data. Follow its existing sequence: read `../../common.sh`; set `inventoryID`, source locations, map-layer names, and `fullTargetTableName`; read `../pre_conversion.sh`; convert and prepare the data; then read `../post_conversion.sh`. These paths are relative to the conversion script's folder.

    The result should be one source table, normally `rawfri.nb99`, containing all information needed for translation. Where the original data use several linked tables, combine the necessary columns into this single table. Keep original stand identifiers and add `src_filename` (the source filename) and `inventory_id` (the uppercase inventory identifier).

    Retain `ogc_fid`, the record identifier used by the loading process, and `wkb_geometry`, the column containing polygon shapes. The translation and sampling operations depend on these names.

    Reuse `$gdalLco` and `$gdalOtherOptions` from `common.sh`. They specify the required column names and transform coordinates to Canada Albers, `ESRI:102001`. Check the original coordinate reference system first. Changing its label without transforming coordinates can place polygons in the wrong location. Follow suitable existing examples when handling polygons with separate pieces or curved boundaries.

    For several compatible source files, load the first and add the others to it. For linked source tables, record the matching columns and check that combining them neither duplicates nor loses stands. Retain enough information to trace each result to its original file and record.

    Decide whether empty text values should be converted to NULL. The option `-emptyStrAsNull` does this and can therefore change the missing-value codes assigned during translation.

    Put preparation steps in the script so another person can repeat them: correcting column types, removing unwanted spaces, selecting records, handling duplicates, repairing shapes, and attaching photograph years. Explain the reason for each step. Keep the rules that assign CASFRI categories in the translation tables or functions.

    `post_conversion.sh` creates an index on `ogc_fid`, which helps the database find records quickly, and runs `VACUUM ANALYZE` to maintain database performance. If SQL commands created the final table and it needs an index for spatial searches, follow the existing `createSQLSpatialIndex=True` setting.

    **2.6 Convert and load the inventory** - Choose one of the following three methods. To run the new conversion script directly, first load any required photograph-year or other supporting datasets, then run:

    ```bash
    bash ./conversion/sh/load_nb99.sh
    ```

    Alternatively, use [./convert_all.sh](../conversion/convert_all.sh) from the `conversion/` folder with the configuration variables prepared in subsection 2.1.

    To convert the inventories selected by `fullList` in `config.sh`, or by the metadata selection column when `fullList` is not defined, use:

    ```bash
    (
      cd conversion
      bash ./convert_all.sh
    )
    ```

    With no inventory identifiers on the command line, the script first loads every supporting photograph-year dataset listed in `photoYearList` and waits for those loading commands to finish before starting inventory conversion. Check that `photoYearList` contains the required datasets and that their source files are available. Supporting datasets not included in `photoYearList` must be loaded separately.

    To convert only the new inventory, after loading any required supporting datasets, use:

    ```bash
    (
      cd conversion
      bash ./convert_all.sh NB99
    )
    ```

    Replace `NB99` with the actual identifier; multiple identifiers can be separated by spaces. Providing identifiers selects those inventories instead of the configured list and skips automatic photograph-year loading.

    **2.7 Check the converted record counts and polygon shapes** - Read the messages and inspect the resulting table. Existing scripts do not always stop after an error. Run these SQL checks:

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
    bash ./metadata/load_metadata.sh
    ```

    ```sql
    SELECT * FROM TT_ConvertedStandCount(ARRAY['NB99']);
    ```

3) **Prepare and validate the inventory translation** - Establish and verify how source information becomes CASFRI values.

    **3.1 Add mapping rows in layer_metadata.csv** - Add NB99 rows to `metadata/layer_metadata.csv`, using a comparable inventory as a starting point. Check every entry against the columns actually loaded into the database. There must be only one row for each inventory/layer combination. Add a row for each input layer or separate translation operation.

    In `casfri_table`, list the uppercase CASFRI table names supplied by that row, such as `CAS ECO DST LYR GEO`, `LYR`, or `NFL`. A missing name can cause a complete CASFRI table to be skipped without stopping the process. Do not copy unnecessary quote characters from older records.

    A standard row, such as `NB_NBI01` with layer 1 and `ttable_exists=yes`, defines the general column names referenced in the translation tables. Inventory rows normally use `ttable_exists=no` and specify the actual source column supplying each value. For example, `l1s1` supplies `species_1`, and `l1pr1` supplies `species_per_1`. Where a cell lists several columns, their order must agree with the corresponding list in the standard row.

    Some entries use a fixed value, such as a layer number, instead of a source column. Follow existing examples for fixed values and `NULL`. Inspect the resulting database view, which is a saved query displaying selected or renamed source columns. Do not assume a formula typed into a CSV cell will be calculated: this part of the software does not support arbitrary SQL expressions.

    Distinguish the layer used to read source columns from the final CASFRI layer number. Translation can reorder forest layers by height or produce several non-forest components from one source record. Document overstory, understory, horizontal components, the layer associated with disturbance or wetland information, and how `NUM_OF_LAYERS` is calculated. Every operation for the same polygon must construct the same CAS_ID.

    Document how the photograph year is obtained and what happens when it is missing. Do not silently replace it with publication year. Explain which CASFRI tables should legitimately be empty and which attributes should receive codes for missing or inapplicable information.

    **3.2 Reuse, adapt, or create the translation tables** - CASFRI uses the province/group identifier and `STANDARD_ID` to find the translation tables. NB99 following NBI01 uses `translation.nb_nbi01_cas`, `nb_nbi01_lyr`, and the other relevant tables. Reuse existing translation tables as much as possible. When simple modifications allow them to handle the new inventory, adapt those tables while preserving correct translations of the inventories that already use them. Check those inventories again as described in subsection 5.6. Create new translation tables when adapting an existing set would require substantial changes, or when no suitable existing set is available. In that case, create a complete set under `translation/tables/`: one table for each of CAS, DST, LYR, NFL, ECO, and GEO. For the example standard, these are `nb_nbi01_cas.csv`, `nb_nbi01_dst.csv`, `nb_nbi01_lyr.csv`, `nb_nbi01_nfl.csv`, `nb_nbi01_eco.csv`, and `nb_nbi01_geo.csv`. Use layer metadata and row-selection rules to describe which tables receive records; document any legitimately empty results.

    Translation tables saved as CSV files contain these seven columns; keep their exact names:

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

    Match column types and order to the CASFRI table. Where needed, use `ROW_TRANSLATION_RULE` to decide which records should be translated. Test records that should be included and records that should be excluded. For example, an absent understory should not produce an extra row filled with missing-value codes.

    Explain each source value's meaning, the order of its checks, accepted values, units, and class boundaries. When a check fails, translation assigns the relevant error or missing-value code. Preserve the distinction between NULL, empty text, unknown values, invalid values, values outside the accepted range, and information that does not apply. The code must suit the result column's type.

    Review polygon identifiers, species and percentages, crown closure, height, origin year, productivity, non-forest classes, disturbances, wetlands, and shapes. CAS_ID must be 50 characters long, unique for each polygon, and traceable to the source. Follow the existing standard's construction rules.

    Update `species_code_mapping.csv` and any other code-conversion tables when needed. These are also called lookup tables. Check that each source code has a clear meaning and an appropriate CASFRI value or documented error outcome. A change to a shared table can alter older inventories too.

    First use the basic helper functions provided by the PostgreSQL Table Translation Framework wherever possible. If they cannot perform the required operation, check whether an existing specialized CASFRI helper function can be reused or adapted before writing a new one. When adding or modifying a specialized CASFRI helper function in [helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql), add or update its tests in [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql), following subsection 5.5. For a new function, also add the corresponding removal command to [helperFunctionsCasfriUninstall.sql](../helperfunctions/helperFunctionsCasfriUninstall.sql). Document the inventory interpretation that justifies the calculation.

    **3.3 Load the translation tables and metadata** - In Git Bash, run the following commands to load the relevant CSV files. This script also reloads both metadata files:

    ```bash
    (
      cd translation
      bash ./load_tables.sh nb_nbi01_cas.csv nb_nbi01_dst.csv \
        nb_nbi01_eco.csv nb_nbi01_lyr.csv nb_nbi01_nfl.csv \
        nb_nbi01_geo.csv species_code_mapping.csv
    )
    ```

    Include any other code-conversion CSVs required by the rules. If helper functions have been added or modified, load their definitions and run [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql) using the commands in subsection 2.3. Resolve failed tests before preparing translation. Confirm that the expected metadata and translation tables are present in the database. Editing a CSV file on your computer does not automatically update its database copy.

    **3.4 Create a development script and validate sample translated rows** - Create `workflow/01_develTranslationTables/NB99.sql` using a similar inventory's development script as a starting point. Save the commands used for investigation so another person can repeat the checks. Older development examples sometimes use outdated mapping names. The following example uses the current naming format and samples 200 source rows:

    ```sql
    SELECT TT_CreateMappingView('rawfri', 'nb99', 1, 'nb_nbi01', 1, 200);
    SELECT * FROM rawfri.nb99_l1_to_nb_nbi01_l1_map_200 LIMIT 10;

    SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb99_lyr_devel');
    SELECT * FROM TT_Translate_nb99_lyr_devel(
      'rawfri', 'nb99_l1_to_nb_nbi01_l1_map_200'
    );
    ```

    `TT_CreateMappingView` prepares a view showing the source columns under the names expected by the chosen standard. `TT_Prepare` creates the database function that applies the rules in the LYR translation table. The last query displays its translated results. These commands display a sample translation; they do not perform the complete inventory translation described in subsections 4.2 and 4.3.

    Repeat this preparation and inspection for every required CASFRI table and input layer. Check that columns are present, fixed values are correct, and the intended records were selected. `TT_Prepare` checks whether the rules are correctly written, but cannot establish whether they correctly interpret the inventory manual.

    Compare original and translated values for selected stands, including rare categories and missing information. Use the documented CAS_ID construction and original identifiers to match records. Do not assume that the last few characters of every CAS_ID identify a source record in the same way. Save expected values and supporting manual/page references in the inventory's `COMMENT` field in `metadata/inventory_metadata.csv`.

4) **Translate the complete inventory** - Add the inventory to the CASFRI tables using one of the two execution methods below.

    **4.1 Add the HDR record** - Keep the existing CASFRI tables. If the database has not yet been initialized, complete the relevant database-creation instructions in [Build the whole database from scratch](../README.md#build-the-whole-database-from-scratch) in a separate empty database before returning to this procedure. Do not run `./01_createCASFRITables.sh` against tables containing results you need to keep: it deletes and recreates HDR and the translated tables, and can remove dependent database objects.

    Add the new inventory's metadata to HDR before translating its records. The following SQL copies only the required columns, following [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql):

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

    **4.2 Translate the complete inventory using SQL** - After adding the HDR record, run the following commands in order, waiting for each to finish. CAS comes first to respect the table relationships explained in subsection 4.1:

    ```sql
    CALL TT_TranslateInventory('NB99', 'T', 'cas');
    CALL TT_TranslateInventory('NB99', 'T', 'eco');
    CALL TT_TranslateInventory('NB99', 'T', 'dst');
    CALL TT_TranslateInventory('NB99', 'T', 'nfl');
    CALL TT_TranslateInventory('NB99', 'T', 'lyr');
    CALL TT_TranslateInventory('NB99', 'T', 'geo');
    ```

    `CALL` starts the named database procedure. Each command prepares a translation function from the appropriate translation table, reads the mapped source information, and adds translated rows to its CASFRI table. The procedure does **not** automatically replace rows left by an earlier attempt.

    **4.3 Translate the complete inventory using Git Bash** - Use [./02_translateAll.sh](../workflow/02_produceCASFRI/02_translateAll.sh) with the inventory identifier when parallel translation is suitable:

    ```bash
    (
      cd workflow/02_produceCASFRI
      bash ./02_translateAll.sh NB99
    )
    ```

    This script can start translations of different CASFRI tables at the same time. If CAS must finish first (subsection 4.1), use the sequential SQL commands in subsection 4.2. Check the displayed database name, inventory list, and processing configuration variables before continuing. Keep `fullList` in `config.sh` consistent with the inventory being added so existing inventories are not unintentionally retranslated.

    **4.4 Check completion before repeating a translation** - If translation stops partway through, first determine which tables already contain NB99. Before retrying, remove only the affected NB99 rows, deleting related LYR/NFL/DST/ECO/GEO rows before their CAS rows where links require that order. Alternatively, start again with an empty development database whose results can be discarded. Rerunning without checking can create duplicate records.

    Save the messages and check each expected CASFRI table. Some missing-data problems are reported as messages followed by an early stop, without a command failure. A command that appears to finish successfully may therefore have translated only part of the inventory.

5) **Generate, validate and archive test tables** - Establish reviewed reference results and check whether the changes affect existing inventories.

    **5.1 Validate the complete translation used to check the test tables** - Before accepting sample test tables, check the complete translation for the new inventory. These checks establish the counts and values against which the samples will be assessed. Run this comparison with inventory metadata:

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

    For additional database-wide validation in a separate validation database, the full-build procedure provides `01_addConstraints.sql`, `01_addGeoConstraints.sql`, `02_addIndexes.sql`, and `03_additionalChecks.sql` in [03_ConstraintsChecksAndIndexes](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes). Creating constraints and indexes again is not a routine requirement for adding an inventory to an existing database. Where these scripts are needed, inspect the reported results and use the investigation queries when a check fails. Constraints enforce data rules; indexes speed up database searches.

    These scripts change database objects. Before applying them to an existing installation, check which constraints and indexes are already present. An error saying an object already exists does not necessarily mean the inventory data are wrong.

    When a broader review of translated values is needed, use [summary_statistics/summarize.R](../summary_statistics/summarize.R) and related R scripts after adjusting their database and output configuration variables. R is the software used here to produce statistical summaries. Compare frequencies and ranges with the source data and comparable inventories. A table containing only permitted missing-value codes can pass basic checks while still indicating an incorrect column mapping.

    Enter the six confirmed translated counts in inventory metadata, reload it, and repeat the count comparisons. Record the evidence and reasons for legitimate differences in the inventory's `COMMENT` field.

    **5.2 Configure sample sizes in nb_tests_per_layer.csv** - Regression tests check whether a change has unexpectedly altered results that were previously accepted. CASFRI translates samples of source records and saves the results for comparison. This is quicker than translating every inventory in full.

    Add rows to `translation/test/nb_tests_per_layer.csv` for every required combination of inventory, CASFRI table, and **input layer used by the mapping**. Use the existing lowercase names and header:

    ```csv
    inventory_id, cas_table, layer, nb_test_rows
    nb99,cas,1,200
    nb99,eco,1,1000
    nb99,dst,1,1000
    nb99,lyr,1,300
    nb99,lyr,2,600
    nb99,nfl,3,600
    ```

    Follow the recommended translated test-row counts in [translation/test/readme.md](../translation/test/readme.md), then use [validate_number_of_tests.sql](../translation/test/validate_number_of_tests.sql) as explained in subsection 5.4 to check that the actual samples are sufficient. The sample sizes above are examples, not verified settings for your inventory. Use the actual input layers listed in layer metadata. `nb_test_rows` is the number of source records to sample before translation decides which records belong in the result. For example, sampling 1,000 stands might yield only a few disturbance records if disturbances are uncommon.

    For the README's instruction to add one sample setting per inventory/CASFRI-table/layer, use the tables supported by the sample test script: CAS, ECO, DST, NFL, and LYR. Do not add HDR or GEO sample entries to this file; the standard script does not test them. Validate the HDR record and GEO results with the complete-data checks and, where needed, the specific tests described in subsection 5.5.

    **A missing sample entry does not mean skip this case.** The current procedure treats an absent size as a request to use the full source table. A size of zero produces no sampled rows and must be explained. Include exactly one entry for each required inventory/table/input-layer combination.

    Reload inventory and layer metadata before running these tests. Naming an inventory directly can skip the scripts' automatic metadata-loading step. The test execution script does load the sample-size CSV itself.

    **5.3 Generate and validate the test tables** - Keep copies of previously accepted test CSVs and any edits not yet saved in Git's history. The test execution script deletes and rewrites CSV files in `translation/test/tables/`. It produces results but does not compare them with earlier results or decide whether they are correct. Run the following commands in Git Bash:

    ```bash
    (
      cd translation/test
      bash ./test_translation.sh NB99
    )
    ```

    This command selects **New Brunswick**, not just NB99. For each CASFRI table, the script uses `TT_RunAllTests` to look through New Brunswick inventories in metadata and test those whose source tables are present. The metadata's inventory selection configuration variables do not limit that list.

    If the database contains only NB99, the tests cannot check the other New Brunswick inventories. To replace the accepted New Brunswick test files with complete new results, use a database containing the required other inventories too.

    Results are stored in `casfri50_test.cas_nb`, `eco_nb`, `dst_nb`, `nfl_nb`, and `lyr_nb`, then exported in a fixed row order to the corresponding `*_nb_test.csv` files. Read messages about missing source tables, missing mappings, preparation failures, and unexpectedly empty results. Check that NB99 appears in every table where records are expected. Compare the results for existing inventories in subsection 5.6.

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

    **5.4 Check that enough test rows were translated** - Once complete translation results and sample results both exist, run:

    ```sql
    SELECT * FROM TT_CheckNumberOfTests('cas', 'nb', TRUE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('dst', 'nb', TRUE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('eco', 'nb', FALSE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('lyr', 'nb', TRUE) WHERE inv = 'NB99';
    SELECT * FROM TT_CheckNumberOfTests('nfl', 'nb', FALSE) WHERE inv = 'NB99';
    ```

    These commands compare the number of translated test rows with the number recommended for each CASFRI table. They use the grouping choices currently used for New Brunswick. Consult [validate_number_of_tests.sql](../translation/test/validate_number_of_tests.sql) for other inventories.

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

    **5.5 Add specific tests when needed** - Use these additional checks when validating sample results reveals cases that random samples do not adequately cover, or when new or changed helper functions need testing. Relevant cases can include ordinary values, NULL, empty text, unknown category codes, class boundaries, values outside permitted ranges, absent/present understory, changed layer order, forest/non-forest classification, disturbances, missing photograph years, and new species codes. Record the applicable cases in a table of expected results.

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

    **5.6 Compare and archive the validated test tables** - In Git Bash, run these Git commands from the main project folder to see which test files changed and what changed inside two of them:

    ```bash
    git diff --stat -- translation/test/tables
    git diff -- translation/test/tables/cas_nb_test.csv
    git diff -- translation/test/tables/lyr_nb_test.csv
    ```

    `git diff --stat` summarizes changes by file. `git diff` shows changed lines; removed lines begin with `-` and added lines with `+`. Review the ECO, DST, and NFL files too.

    If translation tables were modified to accommodate the new inventory, compare the test rows for the other inventories in the same jurisdiction, as required by the README. If shared translation tables have not changed, adding NB99 should generally add NB99 results. Investigate changes to older inventories. Possible causes include a different sample, changed record identifiers, changed selection rules, a different row order, small differences in calculated geometry measurements, or an actual change in translation. [translation/test/readme.md](../translation/test/readme.md) explains these causes.

    A new inventory has no previously accepted test results. Manually review representative new records and run any applicable specific tests from subsection 5.5 before accepting the first saved files as a reference for future comparisons.

    Reject unexplained missing results for older inventories. If source tables were absent, follow the database preparation requirement in subsection 5.3 before generating replacement files. Keep incomplete files separately for investigation without replacing the accepted reference results.

    If the changes also affect shared lookup tables or database functions used outside that jurisdiction, extend the comparisons to the other affected inventories. This additional scope applies when those shared components change. Record which affected inventories could not be tested; a skipped inventory has not passed.

    Run the tests again with the same inputs, software versions, configuration variables, and sample sizes. The saved files should be identical. Investigate unexplained differences before saving the accepted results in Git's history. Record file checksums, how record identifiers were assigned, software versions, sample sizes, and the reasons for accepted changes in the inventory's `COMMENT` field.

6) **Record and share the work** - Complete the inventory documentation and share the reviewed project changes with contributors.

    **6.1 Document final counts, test tables, and remaining problems** - Complete the inventory's row in `metadata/inventory_metadata.csv`: enter confirmed counts in their dedicated columns and record the commands used, check results, sample sizes, manually reviewed examples, and remaining limitations in `COMMENT`. When ready, set the intended inventory selection configuration variables to YES to include the inventory in larger processing jobs, and reload metadata.

    The inventory is ready when loaded counts agree with the original data and documented preparation; metadata and HDR are correct; all expected translated tables exist; identifiers, values, shapes, and links between tables pass their checks; samples are adequate; any applicable specific tests pass; and saved comparison results have been reviewed and can be reproduced.

    **6.2 Update derived tables only if required** - If denormalized (flat) tables, coverage maps, or historical results must also include the new inventory, update the affected inventories using `workflow/03_flatCASFRI/` and `workflow/04_produceHistoricalTable/`. Confirm inventory priorities and rebuild historical results for overlapping affected inventories as well as NB99, without rerunning full-build initialization or deleting unrelated results. Completing translation does not automatically update these additional products.

    **6.3 Review, commit, and push the changes to GitHub** - A commit saves a selected set of file changes in your computer's Git history, with a message explaining the work. Pushing sends those commits to GitHub so other project contributors can access them. These commands share project files; they do not upload the PostgreSQL database itself.

    Open Git Bash in the main CASFRI folder as explained in subsection 2.2. Check which files have changed, which branch you are using, and where Git will send the changes:

    ```bash
    git status
    git branch --show-current
    git remote -v
    ```

    A branch keeps a set of changes separate while they are being prepared and reviewed. A remote is a named connection to a repository on GitHub; `origin` is a common name. Confirm that the listed destination is the intended GitHub repository and that you have permission to push to it.

    Use the branch agreed with the project team. If a new branch is needed, create one with a descriptive name, replacing NB99 with your inventory identifier:

    ```bash
    git switch -c add-nb99-inventory
    ```

    Review the changes with `git diff`. Open new files separately as well, because files not yet added to Git are not shown by that command. Include the inventory metadata, conversion script, mapping changes, translation tables, code-conversion tables, functions, documentation, and reviewed test results that belong to this update. Leave unrelated changes, personal working files, source datasets, and local database connection configuration variables out of the commit.

    Use `git add` to select files for the commit. This is called staging. The following example selects three files; adapt it to the files you actually changed:

    ```bash
    git add -- metadata/inventory_metadata.csv metadata/layer_metadata.csv conversion/sh/load_nb99.sh
    ```

    Add the other required files by their exact paths in the same way, including new test files and accepted test-result CSVs. Then inspect everything selected:

    ```bash
    git diff --cached --stat
    git diff --cached
    git status
    ```

    The `--cached` commands show the changes selected for the next commit. Check that all required files are included and that their contents match the results you reviewed. If a file was selected by mistake, `git restore --staged -- path/to/file` removes it from the selection while keeping your edits on disk; replace `path/to/file` with its actual path.

    Save the selected changes with a clear message identifying the inventory and the work completed:

    ```bash
    git commit -m "Add NB99 inventory conversion, translation, and tests"
    ```

    Push the commit to GitHub. This example uses the branch created above; replace the remote or branch name if yours differs:

    ```bash
    git push -u origin add-nb99-inventory
    ```

    Read the result to confirm that the push succeeded. If Git reports a permissions problem or conflicting remote changes, resolve that problem before treating the work as shared; do not overwrite other contributors' work. Open the branch on GitHub and verify that the expected commit and files are present. If the project uses pull requests, open one to request review and inclusion of the branch's changes, and describe the inventory added, the tests performed, and any remaining problems.
