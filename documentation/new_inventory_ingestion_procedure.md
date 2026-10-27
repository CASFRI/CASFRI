# Procedure for converting and translating a new inventory to CASFRI

This guide expands the six numbered steps of the README's [Translate a new inventory](../README.md#translate-a-new-inventory) procedure, with numbered subsections providing the details.

In this document, column names are in UPPERCASE and values in lowercase unless their required spelling uses capitals, such as `'LYR'`. Code examples retain their actual spelling.

The examples use **NB99**, an invented identifier for a new New Brunswick inventory, and **NBI01**, an existing inventory standard. Replace NB99 with your new inventory's identifier and NBI01 with its actual standard. NB99 is not a dataset included with the project.

Use a Git Bash command window for examples marked `bash`, including conversion, loading, translation scripts, and Git comparisons. Follow [Open a Git Bash command window](../README.md#open-a-git-bash-command-window) in the [Shared preparation](../README.md#shared-preparation) section from the main README to open the window and start commands from the correct folder.

- Prefix shell-script paths with `./` in commands, for example `bash ./conversion/sh/load_nb99.sh` from the main folder or `bash ./convert_all.sh` from the `conversion/` folder. The prefix `./` means the current folder; preserve `../` in paths that refer to a parent folder.

- The command `cd` changes folders, and `source` reads a configuration file or script into the current Bash session.

- Parentheses around a group of commands keep its folder changes within that group.

- Text beginning with `$` in Bash examples refers to configuration variables read from `config.sh` or `common.sh`; preserve that notation.

Run examples marked `sql` in a database query window, such as the Query Tool in pgAdmin, connected to the intended development database. Bash examples that start the `psql` program remain Git Bash commands: that program sends SQL to the database for you. SQL examples use the database schemas `public`, `rawfri`, `translation`, `casfri50`, and `casfri50_test`, as the current scripts expect. These are instructions to follow with your own data; no inventory was loaded or translated when this guide was written.

## Files to prepare at each step

The table below follows the six numbered sections of this guide. Start by documenting the inventory in `metadata/inventory_metadata.csv`, then prepare its conversion script, column mappings, and translation tables. Use those files to translate the inventory, create and check its tests, and share the reviewed changes. Each row identifies the file to create, edit, reuse, or generate and the subsection where it is used. Some files need changes only when existing translation tables or helper functions cannot handle the new inventory. When writing new validation or translation rules, prefer the basic helper functions provided by the PostgreSQL Table Translation Framework before writing specialized CASFRI helper functions. Step 4 uses the prepared files without requiring file edits, so it is omitted from this table. The step numbers match the detailed sections below.

| Step and subsection | File or group of files | Change required  | What the file contains and how to use or change it |
| --- | --- | --- | --- |
| **1. Archive and document the new inventory** — 1.2 | Original inventory files and documentation under `friDir` | required | Archive the delivery and supporting documents in the prescribed folders. Keep the original files unchanged. |
| 1.3; count updates in 2.7 and 4.4; final review in 6.1 | [metadata/inventory_metadata.csv](../metadata/inventory_metadata.csv) | required | Document the inventory in its dedicated columns and use the `COMMENT` column or the inventory's README for additional explanations, decisions, and test results. Update counts after checking conversion and translation, and complete the documentation at step 6.1. |
| **2. Prepare the environment, convert and load the inventory** — 2.1 | `config.sh`, created from [config_sample.sh](../config_sample.sh) | required | A configured local copy is required. If `config.sh` does not exist, copy `config_sample.sh` to `config.sh` and configure it before running the scripts. Skip this creation step if the file already exists. |
| 2.1 | Existing `config.sh` | optional | Edit only if its paths, database connection, inventory selection configuration variables, or processing options need to change for this inventory. Always check that the existing configuration is correct. |
| 2.5–2.7 | `conversion/sh/load_nb99.sh` | required | Create the inventory's conversion script from a similar script, run it, and check the loaded records. |
| **3. Prepare and validate the inventory translation** — 3.1 | [metadata/layer_metadata.csv](../metadata/layer_metadata.csv) | required | Add the inventory's attribute mappings and dependencies for each input layer and a standard row if a new standard is needed. |
| 3.2–3.3 | `translation/tables/nb_nbi01_*.csv` | optional | Contain the validation and translation rules for each CASFRI attribute, including its name, data type, and rule descriptions. No edit is needed when existing translation tables correctly validate and translate the new inventory. Reuse them as much as possible, making simple modifications when needed. Create new tables when reuse would require substantial changes, no suitable set exists or the new inventory is based on a new standard. Load missing or modified tables before testing them; unchanged versions already in the database need not be reloaded. Here, `*` stands for the CASFRI table names: CAS, DST, LYR, NFL, ECO AND GEO. |
| 3.2–3.3 | [translation/tables/species_code_mapping.csv](../translation/tables/species_code_mapping.csv) and other required lookup CSVs | optional | Contain correspondences between source inventory codes and CASFRI codes, such as species codes. No edit is needed if the existing correspondences correctly cover the inventory's source codes. Add missing correspondences or correct incorrect ones when needed. |
| 3.2 | PostgreSQL Table Translation Framework: [helperFunctions.sql](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework/blob/master/helperFunctions.sql) | optional | Contains basic validation and translation functions for checking missing values, data types, ranges, and code correspondences, and for translating values. Reusing these functions does not require editing this file. Consult it in the separate framework project and use its functions wherever possible before writing specialized CASFRI functions. |
| 3.2–3.3 | [helperfunctions/helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql) | optional | Contains specialized CASFRI validation and translation functions, plus functions for mapping, record-count checks, and running translations and tests. Use the framework's basic helper functions first. No edit is needed if those functions or existing CASFRI functions already perform the required validation and translation. Otherwise, add or modify a specialized CASFRI helper function; load its definition in the database and add or update the associated tests in [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql). |
| 3.2–3.3 and 5.4 | [helperfunctions/helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql) | optional | Contains tests of CASFRI helper functions, with descriptions and pass/fail results. No edit is needed if the existing tests cover the required cases and no helper function changes. Add or update tests when a helper function is new or changed, or when a required case is not covered. Run the helper-function tests even when the test file needs no edit. |
| 3.2 | [helperfunctions/helperFunctionsCasfriUninstall.sql](../helperfunctions/helperFunctionsCasfriUninstall.sql) | optional | Contains SQL commands that remove CASFRI helper functions and related database objects. No edit is needed if the existing removal commands still cover all functions. Add a removal command for each new function, and update the command if a changed function's name or argument types require it. |
| 3.4 | `workflow/01_develTranslationTables/NB99.sql` | required | Create a development script to save the commands used to investigate mappings and validate sample translations. |
| **5. Generate, validate and archive test tables** — 5.1–5.3 | [translation/test/nb_tests_per_layer.csv](../translation/test/nb_tests_per_layer.csv) | required | Defines how many source rows are selected for translation tests for each inventory, CASFRI table, and input layer. Add the required entries and set `NB_TEST_ROWS` to the number of rows. Adjust those numbers after checking that enough translated test rows are produced. |
| 5.2, 5.5 and 6.3 | `translation/test/tables/*_nb_test.csv` | required | Contain the actual translated rows used for testing. Generate these files with [./test_translation.sh](../translation/test/test_translation.sh), then compare and review their contents. The validated files must be archived by committing them to Git and pushing them to GitHub, as described in subsection 6.3, so they remain available as reference results for future tests. |
| **6. Record and share the work** — 6.1–6.3 | Inventory metadata and reviewed project files listed above | required | Complete the inventory documentation in `metadata/inventory_metadata.csv`, then review, commit, and push the relevant changes. Follow 6.2 if additional database products must also be updated. |

In the **Change required** column, `required` means that archiving, creating, updating, or regenerating the file is part of adding an inventory; generated test CSVs are produced by the test script. `optional` means no edit is routinely required, but an edit becomes necessary when the condition in the description applies. For example, changing a helper function requires updating its tests. Original source files must remain unchanged even though archiving them is required.

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

## 1) Archive and document the new inventory

Establish its identity and preserve the source information needed to interpret and process it.

### 1.1 Determine the inventory identifier and standard

Find comparable inventories in `inventory_metadata.csv` and check which identifiers are already used. Find the highest number already used for the jurisdiction and increase it by one. For example, if AB34 is the last identifier used for all inventories from the AB jurisdiction, set `INVENTORY_ID` to `AB35`; do not reuse a gap in the numbering. Keep the four-character format for values in the `INVENTORY_ID` column: two letters for the province, territory, or other inventory group, followed by two digits, and confirm that the new identifier is not already present. A higher number does not necessarily mean a more recent inventory. Older data newly added to CASFRI also receive a new identifier.

Keep the dataset identifier and its standard separate. NB99 identifies one delivered dataset. NBI01 identifies the standard used to describe and classify its forest information. Several inventories may follow the same standard.

Compare source manuals, measurement units, species lists, class boundaries, layer definitions, and the meaning of missing values with those of an existing standard. Two columns with similar names can still have different meanings. Prefer reusing existing translation tables, including with simple modifications that accommodate the new inventory while preserving correct translations of existing inventories. Differences in column names can be handled in the mapping file. Subsection 3.2 explains when to adapt existing tables or create new ones.

If differences in the source information require substantial changes to the translation tables, create a new standard identifier, a corresponding standard row in layer metadata, and a new set of translation tables. Explain the differences in the `COMMENT` column in `metadata/inventory_metadata.csv` or the inventory's README.

Keep older inventories when adding newer deliveries. The README requires an update's publication date to be at least one year later than the previous version for inclusion. Resolve uncertain dates before deciding whether to include the update.

### 1.2 Archive the original files and document their source

Use the following folders beneath `friDir`, the configuration variable that identifies where the source inventories are stored:

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

Keep the files as originally received. Record download addresses or delivery source, acquisition date, publication date, production period, and numbers of records in the dedicated inventory metadata columns.

Distinguish the year aerial photographs were taken from the years the inventory was updated, published, or downloaded.

Record the inventory's metadata in its row in `metadata/inventory_metadata.csv`. Use the dedicated columns for information such as source, standard, dates, permissions, documentation titles, and record counts. Use the `COMMENT` column for additional details, including manual versions and page references, source-column descriptions, preparation decisions, assumptions, known problems, commands used, and test results. If comments become too long, create a `README.md` file in the archived inventory's folder for the detailed explanations. Keep only a summary and a reference to this README in the `COMMENT` column. Explain preparation choices that are not clear from the source files or conversion script, such as why a layer was selected, files were combined or renamed, or a missing or incorrect source coordinate reference system was specified or corrected. Filenames, dataset and map-layer names, and coordinate-system information already preserved in the source files or conversion script do not need to be repeated in inventory metadata.

Keep restricted source data and private correspondence in their appropriate storage folders. The `COMMENT` column or the inventory's README can identify where they are kept without reproducing them.

Decide whether the delivery contains one inventory or several separately identified parts. For example, [load_nb08.sh](../conversion/sh/load_nb08.sh) reads a delivery stored under NB06 and selects records for a particular holder. If doing this, record the shared source location and the exact rule used to select each part.

### 1.3 Document the inventory in inventory_metadata.csv

Add exactly one row to `metadata/inventory_metadata.csv`. Keep the existing column names and order. Preserve quotation marks around values containing commas so those values stay in one column. If using a spreadsheet application, check that saving the CSV has not changed identifiers, dates, or quotation marks.

In the `COMMENT` column or the inventory's README, explain how photograph years are obtained, how missing years are handled, which CASFRI tables should legitimately be empty, and which attributes should receive codes for missing or inapplicable information. Record and justify any substitution of publication year for a missing photograph year there.

#### Required inventory metadata columns

Many columns are required for the whole translation process to work properly. The table below lists every column once, grouped by purpose. The groups are for reading this guide; keep the existing column order in the CSV file.

All columns are loaded by [load_metadata.sh](../metadata/load_metadata.sh). The **Copied to HDR?** column indicates whether [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql) copies the value into the inventory description table, `casfri50.hdr_all`. The **Used by other scripts?** column indicates whether scripts other than this HDR-copying script explicitly use the value. A **No** in that column means no such use was found, even if the value is copied to HDR. When copying inventory metadata into the HDR table, the script allows descriptive values to be empty. Values required by other scripts must still be filled in.

| Group | Column name | What it represents / what to enter | Copied to HDR? | Used by other scripts? | How it is used |
| --- | --- | --- | --- | --- | --- |
| Identification and ownership | `INVENTORY_ID` | Unique four-character identifier, such as `NB99`. Add exactly one metadata row for this identifier. | Yes | Yes | Identifies the source table and inventory in selection, translation, tests, count checks, and historical processing. Its first two letters identify the jurisdiction used to select the translation tables. Also copied to HDR, where it is the primary key. |
| Identification and ownership | `JURISDICTION` | Province, territory, or other jurisdiction responsible for the inventory. | Yes | No | Copied to HDR. Translation obtains its jurisdiction prefix from `INVENTORY_ID`, rather than from this descriptive field. |
| Identification and ownership | `OWNER_TYPE` | Category of owner or responsible organization, using the accepted metadata codes. | Yes | No | Copied to HDR to describe the owner category. |
| Identification and ownership | `OWNER_NAME` | Name of the owner or responsible organization. | Yes | No | Copied to HDR to identify the owner. |
| Inventory standard | `STANDARD_TYPE` | Name or family of the inventory standard, such as AVI. | Yes | No | Copied to HDR to describe the standard. |
| Inventory standard | `STANDARD_VERSION` | Published version of the inventory standard followed by the source data. | Yes | No | Copied to HDR to document the standard version. |
| Inventory standard | `STANDARD_ID` | CASFRI identifier for the applicable standard, such as `NBI01`. | Yes | Yes | `TT_TranslateInventory()` combines it with the jurisdiction prefix and CASFRI table name to select a translation table, such as `nb_nbi01_dst`. Also copied to HDR. |
| Inventory standard | `STANDARD_REVISION` | Revision of the source standard, where a separate revision is documented. | Yes | No | Copied to HDR to document the revision. |
| Inventory standard | `DOCUMENTATION_TITLES` | Titles of manuals and other documents describing the source inventory and its standard. | Yes | No | Copied to HDR as documentation references. |
| Source format and dates | `SRC_DATA_FORMAT` | Original delivery format, using the accepted metadata codes. | Yes | No | Copied to HDR. The inventory's conversion script specifies how to read the actual source files. |
| Source format and dates | `PRODUCTION_YEARS` | Year or period during which the source inventory was produced. | Yes | No | Copied to HDR to document production dates. |
| Source format and dates | `PUBLICATION_DATE` | Date when the source inventory was published or released. | Yes | No | Copied to HDR to document publication. |
| Acquisition and contact | `ACQUISITION_PERSON` | Person who obtained the inventory for the project. | No | No | Documents who acquired the data; not copied to HDR by the current creation script. |
| Acquisition and contact | `ACQUISITION_DATE` | Date when the project obtained the inventory. | Yes | No | Copied to HDR to document acquisition. |
| Acquisition and contact | `ACQUISITION_TYPE` | Method of acquisition, such as a download or direct delivery, using the accepted codes. | Yes | No | Copied to HDR to document how the data were obtained. |
| Acquisition and contact | `ACQUISITION_LINKS` | Download addresses or other references to the source of the delivery. | Yes | No | Copied to HDR as acquisition references. |
| Acquisition and contact | `CONTACT_INFO` | Contact information for the data provider or person able to clarify the inventory. | Yes | No | Copied to HDR as contact information. |
| Access and permissions | `DATA_AVAILABILITY` | Documented availability of the source data, using the accepted codes. | Yes | No | Copied to HDR to describe availability. |
| Access and permissions | `REDISTRIBUTION` | Documented conditions or restrictions on redistributing the data. | Yes | No | Copied to HDR to describe redistribution conditions. |
| Access and permissions | `PERMISSION` | Documented permission or restriction applicable to using the data. | Yes | No | Copied to HDR to record permission information. |
| Access and permissions | `LICENSE_AGREEMENT` | Applicable licence or agreement status, using the accepted codes. | Yes | No | Copied to HDR to record agreement information. |
| Access and permissions | `LICENSE_AGREEMENT_URL` | Address of the applicable licence or agreement. | No | No | Provides a documentation reference; not copied to HDR by the current creation script. |
| Photograph years | `PHOTO_YEAR_SRC` | Source or method used to determine photograph years, such as a source attribute or a spatial match to separate photograph-year data. | Yes | No | Copied to HDR to describe how photograph years were obtained. |
| Photograph years | `PHOTO_YEAR_START` | Earliest photograph year documented for the inventory. | Yes | No | Copied to HDR to describe the inventory's photograph-year range. Historical processing uses the value in each translated polygon's `STAND_PHOTO_YEAR` column to determine its dates. |
| Photograph years | `PHOTO_YEAR_END` | Latest photograph year documented for the inventory. | Yes | No | Copied to HDR to describe the inventory's photograph-year range. Historical processing uses the value in each translated polygon's `STAND_PHOTO_YEAR` column to determine its dates. |
| Historical priority | `PRECEDENCE_RANK` | Whole-number priority based on the documented quality and suitability of the inventory. | No | Yes, for historical processing | `TT_HasPrecedence()`, defined by [01_PrepareGeoHistory.sql](../workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sql), compares ranks when resolving overlaps between inventories. Higher numbers take precedence when this rule applies. |
| Automatic selection | `TRANSLATED_BY_ULAVAL` | YES/NO inventory selection setting for the ULaval processing list. | No | Conditional | Selects inventories marked `YES` when `metadataTableLoadingColumn` names this column. Count-checking functions can also use it to select inventories. |
| Automatic selection | `TRANSLATED_BY_CFS` | YES/NO inventory selection setting for the CFS processing list. | No | Conditional | Selects inventories marked `YES` when `metadataTableLoadingColumn` names this column. Count-checking functions can also use it to select inventories. |
| Automatic selection | `TRANSLATED_BY_CUSTOM` | YES/NO inventory selection setting for a custom processing list. | No | Conditional | Selects inventories marked `YES` when `metadataTableLoadingColumn` names this column. Count-checking functions can also use it to select inventories. |
| Expected record counts | `CONVERTED_STAND_CNT` | Expected number of source stands after conversion and loading. Enter a whole number and confirm it against the loaded data. | No | Yes | `TT_ConvertedStandCount()` compares it with the loaded source-table count. Automatic inventory selection also uses it to order inventories from largest to smallest, as explained below. |
| Expected record counts | `CAS_ROW_CNT` | Expected number of translated CAS records identifying source polygons. Enter a whole number. | No | Yes, for count checks | `TT_TranslatedRowCount()` compares it with the inventory's row count in `casfri50.cas_all`. |
| Expected record counts | `DST_ROW_CNT` | Expected number of translated disturbance records. Enter a whole number. | No | Yes, for count checks | `TT_TranslatedRowCount()` compares it with the inventory's row count in `casfri50.dst_all`. |
| Expected record counts | `ECO_ROW_CNT` | Expected number of translated ecological records. Enter a whole number. | No | Yes, for count checks | `TT_TranslatedRowCount()` compares it with the inventory's row count in `casfri50.eco_all`. |
| Expected record counts | `LYR_ROW_CNT` | Expected number of translated forest-layer records. Enter a whole number. | No | Yes, for count checks | `TT_TranslatedRowCount()` compares it with the inventory's row count in `casfri50.lyr_all`. |
| Expected record counts | `NFL_ROW_CNT` | Expected number of translated non-forest records. Enter a whole number. | No | Yes, for count checks | `TT_TranslatedRowCount()` compares it with the inventory's row count in `casfri50.nfl_all`. |
| Expected record counts | `GEO_ROW_CNT` | Expected number of translated polygon geometry records. Enter a whole number. | No | Yes, for count checks | `TT_TranslatedRowCount()` compares it with the inventory's row count in `casfri50.geo_all`. |
| Additional documentation | `COMMENT` | Additional inventory documentation, including interpretation and preparation decisions, temporary estimates, manual references, test results, and remaining limitations. | No | No | Retains notes for people maintaining the inventory; not copied to HDR by the current creation script. |

The translation and count-checking functions named above are defined in [helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql). The inventory selection configuration variables are used by [define_invlist.sh](../define_invlist.sh) when `fullList` is not already defined; only the column selected by `metadataTableLoadingColumn` in `config.sh` determines which inventories are included.

#### How expected stand counts affect processing order

When inventories to process are selected automatically from metadata, [define_invlist.sh](../define_invlist.sh) sorts those marked `YES` in the selected column by the value in the `CONVERTED_STAND_CNT` column, from largest to smallest. For example, an inventory with an expected count of 500,000 stands is listed before one with 100,000 stands, which is listed before one with 20,000 stands. The conversion and translation scripts use this order to launch their work, subject to the limits on simultaneous processes in `config.sh`; inventories can therefore finish in a different order. Starting larger inventories early can shorten the overall processing time by reducing the wait for one large inventory at the end, while smaller jobs fill the other available processing slots. Stand counts only estimate processing time; geometry complexity and translation rules also affect it. The sorting uses the count recorded in the metadata, without recounting the source data first. Inventories with equal counts have no specified order. If `fullList` is defined directly or inventory identifiers are supplied to the script on the command line, the supplied order is used instead.

Follow the [HDR Attributes section of the specification](specifications/README.md#hdr_attributes) and comparable records for accepted values and codes representing missing information. Do not guess dates or permissions.

Choose the value in the `PRECEDENCE_RANK` column based on the documented quality and suitability of the data. It controls which inventory is preferred when building the geohistory table; it is not simply the next available inventory number. Check the historical-table rules before assigning it.

## 2) Prepare the environment, convert and load the inventory

Prepare the tools and create a checked source table for translation.

### 2.1 Check the environment and database connection

Installing tools and creating or editing `config.sh` are optional if the existing environment and configuration are already suitable. Complete any missing setup and change configuration variables that are incorrect for this inventory, following the [Shared preparation](../README.md#shared-preparation) section from the main README. Always check the database connection and configuration before processing. Select the intended inventories, for example with `fullList=(NB99)`, and set `postProcessingOnly=False` before conversion or translation.

### 2.2 Open a Git Bash command window

Follow [Open a Git Bash command window](../README.md#open-a-git-bash-command-window) in the [Shared preparation](../README.md#shared-preparation) section from the main README before running the Bash examples in this guide.

### 2.3 Install or replace the CASFRI helper functions

Installation or replacement is optional when the required helper functions are already installed and up to date. Install them if missing, or replace them if their definitions have changed, following [Install or replace the CASFRI helper functions](../README.md#install-or-replace-the-casfri-helper-functions) in the [Shared preparation](../README.md#shared-preparation) section from the main README. Run the helper-function tests and resolve failed tests before continuing.

### 2.4 Examine the source inventory files

In Git Bash, use `ogrinfo` to list the available map layers and examine columns, record counts, coordinate reference systems, polygon types, and geographic coverage. Replace `source.gdb` and `SourceLayer` with the actual file and map-layer names:

```bash
source ./common.sh
"$gdalFolder/ogrinfo" "$friDir/NB/NB99/data/inventory/source.gdb"
"$gdalFolder/ogrinfo" -so \
  "$friDir/NB/NB99/data/inventory/source.gdb" SourceLayer
```

If the source inventory uses a relational structure, with polygons and attributes stored in separate related tables, identify the columns used to match each stand's polygon with its attribute records. This matching step is unnecessary when each polygon and all its attributes are already stored in one table. Check for repeated identifiers, multiple source files, missing polygon shapes, and separate photo-year data. When combining tables, determine whether one stand matches one record or several records in the other table. Multiple matches can accidentally duplicate stands.

Record the original numbers of records before selecting subsets or combining tables. In the `COMMENT` column or the inventory's README, explain how selecting or combining source records should change the final count.

Examine the values used for categories, measurement units, missing data, zeroes, accents, and identifiers beginning with zero. SQL distinguishes `NULL` (no stored value) from an empty string (a stored text value with no characters). The source may also use special values such as -9999 for missing information. Confirm each meaning in the manual.

If the input is an unsupported E00 file, retain the original and convert it to a supported format (shp or gdb) before continuing.

### 2.5 Create the conversion and loading script

Copy a script for an inventory with a similar file format and structure to `conversion/sh/load_nb99.sh`. Adjust it for the new data. Follow its existing sequence: read `../../common.sh`; set `inventoryID`, source locations, map-layer names, and `fullTargetTableName`; read `../pre_conversion.sh`; convert and load the source files; then read `../post_conversion.sh`. These paths are relative to the conversion script's folder.

The result, in the database, should be one source table, normally `rawfri.nb99`, containing all information needed for translation. Where the original data use several linked tables, load all the tables in PostgreSQL and combine the necessary tables into a single table using a JOIN query.There are many examples in the .sh scripts. Keep original stand identifiers and add the `SRC_FILENAME` column (the source filename) and the `INVENTORY_ID` column (the uppercase inventory identifier).

Retain the `OGC_FID` column, containing the record identifier used by the loading process, and the `WKB_GEOMETRY` column, containing polygon shapes. The translation and sampling operations depend on these names.

Reuse `$gdalLco` and `$gdalOtherOptions` from `common.sh`. They specify the required column names and transform coordinates to Canada Albers, `ESRI:102001`. Check the original coordinate reference system first. Changing its label without transforming coordinates can place polygons in the wrong location. Follow suitable existing examples when handling polygons with separate pieces or curved boundaries.

If the inventory is split across several files with the same columns and data types, load the first file to create the database table, then append the rows from the other files to that same table. For example, shapefiles covering different map sheets can be combined this way. For linked source tables, record the matching columns and check that combining them neither duplicates nor loses stands. Make sure to keep attributes like the map sheet identifier and the original stand identifier so you can find the source file and record corresponding to each translated row and compare the translated values with the original data if necessary.

Keep the rules that validate and translate values to the CASFRI specification in the translation tables or helper functions.

`post_conversion.sh` creates an index on the `OGC_FID` column, which helps the database find records quickly, and runs `VACUUM ANALYZE` to maintain database performance. If you created the table using SQL, set `createSQLSpatialIndex=True` before the call to `post_conversion.sh` in the conversion script to add a spatial index if needed.

### 2.6 Convert and load the inventory

Choose one of the following three methods to convert and load the inventory dataset in PostgreSQL/PostGIS.

#### Method A: Run the inventory's conversion script directly

First load any required photograph-year or other supporting datasets that will have to be joined with the data loaded in PostgreSQL/PostGIS to produce the final converted table, then run:

```bash
bash ./conversion/sh/load_nb99.sh
```

After loading, manually run `SELECT * FROM TT_ConvertedStandCount(ARRAY['NB99']);` in the database Query Tool to count the loaded records. **Methods B and C are preferred** because they run this count check automatically when `postProcessing=True`.

#### Method B: Use the `config.sh` inventory list

For this method, you must define `fullList` in `config.sh` with only the inventories you want to convert, for example `fullList=(NB99)`. **If `fullList` is left undefined, all inventories marked `YES` in the column specified by `metadataTableLoadingColumn` in `inventory_metadata.csv` will be processed.** After defining `fullList`, run [./convert_all.sh](../conversion/convert_all.sh) from the `conversion/` folder without supplying inventory identifiers. Double check the displayed list before confirming that processing should begin.

```bash
(
  cd conversion
  bash ./convert_all.sh
)
```

Add any new photograph-year shapefile to `photoYearList` in `config.sh`.

#### Method C: Supply inventory identifiers on the command line

To convert only the new inventory, after loading any required supporting datasets, use:

```bash
(
  cd conversion
  bash ./convert_all.sh NB99
)
```

Replace `NB99` with the actual identifier; multiple identifiers can be separated by spaces. Providing identifiers selects those inventories instead of the configured list and skips automatic photograph-year loading.

### 2.7 Check the converted record counts and polygon shapes

Review the count comparison produced by [./convert_all.sh](../conversion/convert_all.sh). With `postProcessing=True`, it compares loaded counts with the value in the `CONVERTED_STAND_CNT` column in inventory metadata at the end of conversion. Rerunning the count check is optional unless it was skipped, expected counts changed, or a discrepancy needs investigation. To run only this check, set `postProcessingOnly=True` in `config.sh` and run the following command from the main CASFRI folder:

```bash
(
  cd conversion
  bash ./convert_all.sh NB99
)
```

Restore `postProcessingOnly=False` before the next conversion or translation. Read the messages and investigate unexpected differences.

Compare counts with the original files and account for every selection or table combination. Examine geographic coverage and any polygon problems. The test sampling method uses numbers between 1 and the source row count to find values in the `OGC_FID` column. Missing numbers or a different numbering range can reduce the sample. Avoid changing those identifiers without assessing the consequences: they also affect values in the `CAS_ID` column and saved test results.

Once counts agree with the source and documented preparation, set `CONVERTED_STAND_CNT` to the confirmed count. Reload metadata and run the comparison:

```bash
bash ./metadata/load_metadata.sh
```

```sql
SELECT * FROM TT_ConvertedStandCount(ARRAY['NB99']);
```

## 3) Prepare and validate the inventory translation

Establish and verify how source values are tranlated to CASFRI values.

### 3.1 Add mapping rows in layer_metadata.csv

See [layer_metadata table](../README.md#2-layer_metadata-table) in the main README for the purpose of this file and a description of its columns.

Add NB99 rows to `metadata/layer_metadata.csv`, using a comparable inventory as a starting point. Create one row per source-layer mapping, with a unique combination of values in the `INVENTORY_ID` and `LAYER` columns.

In inventory rows, the `LAYER` column identifies the source layer whose attributes are mapped; its number may differ from the final CASFRI layer number because translation can reorder forest layers by height or produce several non-forest components from one source record.

Check the mappings against the columns actually loaded into the database.

In the `CASFRI_TABLE` column, list all CASFRI tables translated using that mapping, enclosing the uppercase names together in single quotes, for example `'CAS ECO DST LYR GEO'`, `'LYR'`, or `'NFL'`. A missing name can cause a complete CASFRI table to be skipped without stopping the process. `CAS`, `ECO`, `DST` and `GEO` are generally translated using only the first layer of the source inventory.

The `TTABLE_EXISTS` column name means “a translation table actually exists with these attribute names”. It records the mapping type without checking whether the tables exist in the database:

- **Standard row**, such as `NB_NBI01`: set `TTABLE_EXISTS` to `yes` and `LAYER` to `1`. These rows define the general column names referenced in the translation tables.
- **Inventory row**: set `TTABLE_EXISTS` to `no`. These rows specify the source columns or fixed values supplying the standard's inputs. For example, `l1s1` supplies `species_1`, and `l1pr1` supplies `species_per_1`.

When a mapping lists several source column names, keep the same order as the corresponding column names in the standard row.

When the same input should be supplied for every record in a mapping, enter a **fixed value** instead of a source-column name. Examples:

- NB08 sets `LAYER_RANK` to `1` in its first input-layer mapping.
- SK06 sets `STAND_PHOTO_YEAR` to `2000`, a documented substitute because exact polygon-level photograph years are unknown.
- AB16 uses `'CANFOR'` as one input for constructing values in the `CAS_ID` column.

Enclose fixed text values in single quotes, such as `'CANFOR'`. Leave fixed integers, such as `1` and `2000`, and source-column names unquoted.

Use unquoted `NULL` to supply a missing input instead when there is no equivalent source attribute for this target atttribute. Receiving validation and translation functions should define the expected outcome when an input is `NULL`, and test that the receiving function produces that outcome.

Inspect the mapping view as shown in subsection 3.4 before going further.

Do not try to derive values with formulas in the `layer_metadata.csv` table. This part of the process does not support arbitrary SQL expressions.

### 3.2 Reuse, adapt, or create the translation tables

Editing or creating translation tables, lookup tables, and helper functions is optional when the existing ones correctly handle the new inventory. Review their suitability; make changes only where the existing rules or functions cannot correctly validate and translate its data. Write new CASFRI helper functions when PostgreSQL Table Translation Framework functions can not handle a translation efficiently.

CASFRI uses the firts two letters of the inventory identifier (e.g. `NB`) and the value in the `STANDARD_ID` column of the `metadata/inventory_metadata.csv` table to find the right translation tables in the `translation` schema. For example, NB99, following the NBI01 standard, would use the `nb_nbi01_cas` and `nb_nbi01_lyr` translation tables. Those tables contain the validation and translation rules for producing CAS and LYR rows, respectively; equivalent tables provide the rules for the other CASFRI tables.

Before changing shared conversion scripts, translation tables, lookup tables, or helper functions, generate tests for existing affected inventories and confirm their results match the archived files, following the [test README's development cycle](../translation/test/readme.md#testing-procedure). Compare again after the changes as described in section 5.

Reuse existing translation tables as much as possible. When simple modifications allow them to handle the new inventory, adapt those tables while preserving correct translations of the inventories that already use them. Check those inventories again as described in subsection 5.5.

Create new translation tables when adapting an existing set would require substantial changes, or when no suitable existing set is available. In that case, create a complete set under `translation/tables/`: one table for each of CAS, DST, LYR, NFL, ECO, and GEO. For the example standard, these are `nb_nbi01_cas.csv`, `nb_nbi01_dst.csv`, `nb_nbi01_lyr.csv`, `nb_nbi01_nfl.csv`, `nb_nbi01_eco.csv`, and `nb_nbi01_geo.csv`. To name the new standard, either increment the number part of the exeisting standard (e.g. `NBI02`) or assign it a completely new name (e.g. `BFI`). Set the `CASFRI_TABLE` column in `metadata/layer_metadata.csv` to identify which CASFRI tables are translated from each mapping. Explain why some translated CASFRI tables should contain no rows for this inventory in the `COMMENT` column or the inventory's README.

Translation tables saved as CSV files contain these seven columns; keep their exact names:

```text
rule_id,target_attribute,target_attribute_type,validation_rules,translation_rules,description,desc_uptodate_with_rules
```

| Column | What it describes |
| --- | --- |
| `RULE_ID` | A unique rule number that sets the translated column order required by the CASFRI table |
| `TARGET_ATTRIBUTE` | The target CASFRI column name from the [specification](specifications/README.md), such as `DIST_YEAR_1` in DST. Add one translation-table row per attribute. |
| `TARGET_ATTRIBUTE_TYPE` | The data type required by the [CASFRI specification](specifications/README.md): `text`, `integer`, or `double precision`; `geometry`. |
| `VALIDATION_RULES` | Rules that determine whether source values are valid for translation. If a rule fails, it is translated to one of the codes prescribed by the attribute specification and [Table 2: CASFRI error codes](specifications/README.md#error_codes), distinguishing missing, unknown, invalid, out-of-range, and inapplicable information. Select numeric or text codes according to the translated column's type. |
| `TRANSLATION_RULES` | Rules to translate a valid source value to a CASFRI value |
| `DESCRIPTION` | A plain-language explanation of the rules |
| `DESC_UPTODATE_WITH_RULES` | Whether the explanation is up to date with the encoded current rules |

To filter source rows, add a row to the translation table and set `TARGET_ATTRIBUTE` to `ROW_TRANSLATION_RULE`. Only source rows that pass at least one condition in the `VALIDATION_RULES` column of this row will be translated (logical OR); excluded rows will produce no translated row. For example, exclude stands with no understory information when translating an understory layer. Make sure excluded records will be translated by another mean. See the [PostgreSQL Table Translation Framework](https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework) for details about `ROW_TRANSLATION_RULE`.

Values in the `CAS_ID` column must be 50 characters long, unique for each polygon, and traceable to the source; follow the existing standard's construction rules. All rows produced for the same stand in CAS, LYR, NFL, DST, ECO, and GEO must share this value so they can be linked, including when the stand produces several layer or disturbance rows. Two or more stands from different layers should have the same CAS_ID.

Update `species_code_mapping.csv` and other lookup tables when code correspondences are missing or incorrect. Check that each source code has a documented meaning and maps to a CASFRI code consistent with that meaning, or to the prescribed error code. A change to a shared table can alter older inventories too.

In `VALIDATION_RULES` and `TRANSLATION_RULES` prefer the PostgreSQL Table Translation Framework's basic helper functions. If they cannot perform the required operation, reuse or adapt an existing CASFRI helper function before writing a new one in [helperFunctionsCASFRI.sql](../helperfunctions/helperFunctionsCASFRI.sql). Add or update its tests in [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql), following subsection 5.4. For a new function, add its removal command to [helperFunctionsCasfriUninstall.sql](../helperfunctions/helperFunctionsCasfriUninstall.sql). Explain the inventory interpretation behind the calculation in the `COMMENT` column or the inventory's README.

### 3.3 Load the translation tables and metadata

Loading translation and lookup tables is optional if unchanged versions are already present in the database. Load missing or modified tables with [./load_tables.sh](../translation/load_tables.sh) from the [Shared preparation](../README.md#shared-preparation) section from the main README, using the inventory's CSV files:

```bash
(
  cd translation
  bash ./load_tables.sh nb_nbi01_cas.csv nb_nbi01_dst.csv \
    nb_nbi01_eco.csv nb_nbi01_lyr.csv nb_nbi01_nfl.csv \
    nb_nbi01_geo.csv species_code_mapping.csv
)
```

You can also just reload all translation and lookup tables from `translation/tables/` by omitting the filenames:

```bash
(
  cd translation
  bash ./load_tables.sh
)
```

`load_tables.sh` also reload inventory and layer metadata. If skipping `load_tables.sh`, load new or modified metadata with `bash ./metadata/load_metadata.sh` from the main project folder.

Include any other lookup CSVs required by the rules. If helper functions have been added or modified, load their definitions and run [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql) following subsection 2.3. Resolve failed tests before preparing translation. Confirm that the expected metadata and translation tables are present in the database. Editing a CSV file on your computer does not automatically update its database copy.

### 3.4 Create a development script and validate sample translated rows

Create `workflow/01_develTranslationTables/NB99.sql` using a similar inventory's development script as a starting point. Save the commands used for investigation so another person can rerun them. When copying a development script, update its inventory identifier, standard identifier, and mapping-view names. Open the file in the PostgreSQL Query Tool, run these two queries to create a mapping view from 200 source rows and display its rows:

```sql
SELECT TT_CreateMappingView('rawfri', 'nb99', 1, 'nb_nbi01', 1, 200);
SELECT * FROM rawfri.nb99_l1_to_nb_nbi01_l1_map_200;
```

Inspect as many rows as possible: check the expected column names, compare values with the matching original stands, and verify fixed values and selected records. If the mapping is incorrect, correct `layer_metadata.csv`, reload it with `./metadata/load_metadata.sh`, and recreate the view. Then prepare and run the sample translation:

```sql
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb99_lyr_devel');
SELECT * FROM TT_Translate_nb99_lyr_devel(
  'rawfri', 'nb99_l1_to_nb_nbi01_l1_map_200'
);
```

`TT_CreateMappingView()` prepares a view showing the source columns under the names expected by the chosen standard. `TT_Prepare()` creates the database function that applies the rules in the LYR translation table. The last query displays its translated results. These commands display a sample translation; they do not perform the complete inventory translation described in subsections 4.1 to 4.3.

Repeat this preparation and inspection for every required CASFRI table and input layer. `TT_Prepare()` checks whether the rules are correctly written, but cannot establish whether they correctly interpret the inventory manual.

Compare original and translated values for selected stands, including rare categories and missing information. Use the documented construction of values in the `CAS_ID` column and original identifiers to match records. Do not assume that the last few characters of every value in the `CAS_ID` column identify a source record in the same way.

Pay particular attention to `UNKNOWN_VALUE` (`-8886`), `OUT_OF_RANGE` (`-9999`), `NOT_IN_SET` (`-9998`), `INVALID_VALUE` (`-9997`), and `WRONG_TYPE` (`-9995`). These codes may be produced for valid source values that the existing translation tables or CASFRI helper functions do not yet handle. Compare the affected source values with the inventory manual and correct the rules or functions where needed before accepting the translation.

To inspect all distinct values of a source attribute and how often each occurs, query the full loaded source table so rare values missing from the sample are included. For example, if species codes are stored in the `L1S1` column:

```sql
SELECT l1s1, COUNT(*) AS cnt
FROM rawfri.nb99
GROUP BY l1s1
ORDER BY l1s1;
```

Replace `nb99` and `l1s1` with the actual source table and column names. Compare the values with the inventory manual and the values handled by the translation rules and helper functions.

## 4) Translate the complete inventory

Drop all constraints from the six translated CASFRI tables, replace the inventory's HDR record, translate the tables in parallel, and reapply the standard constraints.

### 4.1 Drop all constraints from the translated CASFRI tables

Keep the existing CASFRI tables. If the database has not yet been initialized, complete the relevant database-creation instructions in [Build the whole database from scratch](../README.md#build-the-whole-database-from-scratch) in a separate empty database before returning to this procedure. Do not run `./01_createCASFRITables.sh` against tables containing results you need to keep: it deletes and recreates HDR and the translated tables, and can remove dependent database objects.

In the database Query Tool, run the following six commands:

```sql
SELECT TT_DropAllConstraints('casfri50', 'cas_all');
SELECT TT_DropAllConstraints('casfri50', 'dst_all');
SELECT TT_DropAllConstraints('casfri50', 'eco_all');
SELECT TT_DropAllConstraints('casfri50', 'lyr_all');
SELECT TT_DropAllConstraints('casfri50', 'nfl_all');
SELECT TT_DropAllConstraints('casfri50', 'geo_all');
```

These commands already appear in a commented block at the end of [01_addConstraints.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addConstraints.sql). Execute the six statements above, rather than the whole file, at this stage. Check that every call returns `true` before starting translation. The function is installed from `helperFunctionsCASFRI.sql` in subsection 2.3.

The function removes primary keys, foreign keys, and constraints that perform value checks from each named table. This removes the links that would otherwise require CAS records to exist before related records can be inserted, allowing all six tables to be translated in parallel. Translation can also be faster because PostgreSQL can check the removed constraints and rebuild primary-key indexes afterward, instead of checking and maintaining them for every inserted row. In PostgreSQL 13, existing column-level `NOT NULL` requirements remain in place. Keep HDR and its primary key; replace the inventory's HDR record as described in subsection 4.2.

Constraint removal applies to all inventories in these tables. The function uses `CASCADE`, so removing a primary key also removes foreign keys that depend on it, including any from other tables. The scripts in subsection 4.4 reapply the standard CASFRI constraints; separately restore any additional constraints defined for your database. The commands and restoration scripts use `casfri50`; adapt both consistently if the translated tables use another schema.

### 4.2 Add the HDR record

Confirm that inventory metadata contains exactly one row for NB99. Delete its existing HDR row, if any, then insert the current metadata using the HDR columns listed in [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql).

```sql
BEGIN;

DELETE FROM casfri50.hdr_all
WHERE inventory_id = 'NB99';

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
WHERE m.inventory_id = 'NB99';

COMMIT;
```

Run the entire block together. `BEGIN` and `COMMIT` keep the delete and insert together so an insert error does not leave the HDR row deleted. If an error occurs, run `ROLLBACK;` before retrying. Check that HDR contains exactly one row for NB99, with values matching its inventory metadata. Keep the explicit column list because the metadata table contains extra columns that HDR does not have.

### 4.3 Translate all CASFRI tables in parallel

Check that `postProcessingOnly=False` and that `maxTranslationsInParallel` allows the intended number of simultaneous translations. Check the displayed database name, inventory list, and processing configuration variables. In Git Bash, run [./02_translateAll.sh](../workflow/02_produceCASFRI/02_translateAll.sh) with the new inventory identifier:

```bash
(
  cd workflow/02_produceCASFRI
  bash ./02_translateAll.sh NB99
)
```

`./02_translateAll.sh` calls `TT_TranslateInventory()` separately for CAS, ECO, DST, NFL, LYR, and GEO for each selected inventory. Each call prepares the appropriate translation function, reads the mapped source data, and inserts translated rows into its CASFRI table. These processes run in parallel, up to `maxTranslationsInParallel`; no table must finish before another starts while constraints are absent. 

Keep `fullList` in `config.sh` consistent with the inventory being added so existing inventories are not unintentionally retranslated. Running `./02_translateAll.sh` without inventory identifiers processes the configured `fullList`, or all inventories marked `YES` in the metadata column selected by `metadataTableLoadingColumn` if `fullList` is undefined; either list may include inventories already translated.

### 4.4 Check completion and reapply the constraints

Wait until every translation process has finished, including any separate command windows. Some missing-data problems are reported as messages followed by an early stop, without a command failure. A command that appears to finish successfully may therefore have translated only part of the inventory.

Check the translated row counts against inventory metadata using either method:

**Method A: Run the bash script** - Set `postProcessingOnly=True` in `config.sh` to check counts without translating again. From the main project folder, run in Git Bash:

```bash
(
  cd workflow/02_produceCASFRI
  bash ./02_translateAll.sh NB99
)
```

Restore `postProcessingOnly=False` before the next conversion or translation.

**Method B: Run the SQL query** - In the database Query Tool, execute:

```sql
SELECT * FROM TT_TranslatedRowCount(ARRAY['NB99']);
```

Expect six rows per trasnlated inventory, one per CASFRI table. The `CAS_TABLE` column identifies the table, and the `COUNTED` column gives its actual row count for NB99. Require a positive count for each table expected to receive rows; zero is acceptable only for tables documented as empty for this inventory. A positive count alone does not establish completeness; resolve unexplained differences between the `EXPECTED` and `COUNTED` columns.

Work out expected counts from the source layers and record-selection rules, then explain differences before changing the expected counts. CAS and GEO often correspond directly to source stands, but some inventories filter records. A stand can have several forest layers or no disturbance record, so LYR, NFL, DST, and ECO counts need not equal the CAS count.

Enter the six confirmed translated counts in inventory metadata. If these expected counts have changed, reload metadata and repeat the comparison using either method above. Record the evidence and reasons for legitimate differences in the inventory's `COMMENT` column or the inventory's README.

If translation stops partway through, determine which tables already contain NB99 before retrying. Remove only the affected NB99 rows, or start again with an empty development database whose results can be discarded. The translation procedure does not automatically replace rows left by an earlier attempt; rerunning without checking can create duplicates.

After all tables have finished translating successfully, open and run [01_addConstraints.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addConstraints.sql) in the database Query Tool. After it completes successfully, run [01_addGeoConstraints.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/01_addGeoConstraints.sql). Keep the constraint-removal block at the end of the first script commented out.

These scripts reapply and test the standard primary keys, foreign keys, required values, and value checks for the translated tables. The first script handles CAS, DST, ECO, LYR, and NFL; the second handles GEO and must run afterward because GEO refers to CAS. Review the `PASSED` column and error messages produced by each script. Correct the data or translation rules responsible for each reported constraint violation, then rerun the affected constraint scripts until they pass. Always create a GitHub issue for every constraint check that fails and remains unresolved, as described in subsection 6.1. These checks cover existing inventories as well as the new inventory.

## 5) Generate, validate and archive test tables

Follow the [translation-test README](../translation/test/readme.md) for the development cycle, sample-size recommendations, and diagnosis of differences; the steps below apply it to the new inventory.

### 5.1 Define the number of rows to test in nb_tests_per_layer.csv

Define the number of random source rows in [translation/test/nb_tests_per_layer.csv](../translation/test/nb_tests_per_layer.csv). Add exactly one row per required inventory/CASFRI-table/input-layer combination from `metadata/layer_metadata.csv`, and set `NB_TEST_ROWS` to the sample size. Keep the header; these values are examples:

```csv
inventory_id, cas_table, layer, nb_test_rows
nb99,cas,1,200
nb99,eco,1,1000
nb99,dst,1,1000
nb99,lyr,1,300
nb99,lyr,2,600
nb99,nfl,3,600
```

Choose sample sizes to meet the translated-row recommendations in the test README, and check the actual results with [validate_number_of_tests.sql](../translation/test/validate_number_of_tests.sql) as explained in subsection 5.3. Because `ROW_TRANSLATION_RULE` filters source rows in tables such as LYR and NFL, you cannot know in advance how many source rows must be sampled to obtain a fixed number of translated test rows. As a result, you may need to repeat this cycle several times: adjust the value in the `NB_TEST_ROWS` column, regenerate the translated test tables as described in subsection 5.2, and check the resulting counts in subsection 5.3 until the required number of translated test rows is reached.

**Do not omit required entries:** a missing sample size selects the full source table; zero selects no rows and must be explained.

Only CAS, ECO, DST, NFL, and LYR are sampled. Check HDR in subsection 4.2 and GEO constraints in subsection 4.4. Those constraints do not verify geographic coverage: display the following translated polygons in your GIS alongside the source polygons and look for missing areas, unexpected gaps, or displaced polygons:

```sql
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB99';
```

### 5.2 Generate and validate the test tables

Preserve accepted CSVs and uncommitted edits before running tests: the script overwrites `translation/test/tables/` and does not compare the results automatically. Reload inventory or layer metadata only if it has changed since subsection 3.3. The script reloads the sample-size CSV automatically. In Git Bash, run:

```bash
(
  cd translation/test
  bash ./test_translation.sh nb
)
```

The argument `nb` selects New Brunswick. All its inventories listed in metadata with available source tables are tested, regardless of the inventory selection configuration variables. All previous New Brunswick inventories represented in the archived test files should therefore be loaded and translated before running the tests: they may share translation tables, lookup tables, or helper functions with NB99 and changes made for the new inventory could therefore alter previously correct translations.

Compare the new test rows with the archived rows to confirm that previously correct translations remain correct and that differences are intended; changes to translation tables or helper functions may also fix previously incorrect translations. Verify these corrections against the source data and CASFRI specification before accepting the new test tables. Missing source tables are skipped, so those inventories have not been retested, even if older test rows remain in the database.

Results are stored in `casfri50_test` and exported to `translation/test/tables/*_nb_test.csv`. These CSVs contain the actual translated test rows. Review messages about missing rows for the inventory's input layers or standard in `metadata/layer_metadata.csv`, failures to prepare translation functions, or unexpectedly empty test tables. Confirm that all required input layers are listed and that NB99 has test rows wherever expected; a missing layer can be skipped without an error message. Do not replace accepted files with incomplete province-wide results.

### 5.3 Check that enough test rows were translated

Once the complete translation and test tables exist, run these New Brunswick checks in the database Query Tool. For other inventories, follow the grouping choices in [validate_number_of_tests.sql](../translation/test/validate_number_of_tests.sql):

```sql
SELECT * FROM TT_CheckNumberOfTests('cas', 'nb', TRUE) WHERE inv = 'NB99';
SELECT * FROM TT_CheckNumberOfTests('dst', 'nb', TRUE) WHERE inv = 'NB99';
SELECT * FROM TT_CheckNumberOfTests('eco', 'nb', FALSE) WHERE inv = 'NB99';
SELECT * FROM TT_CheckNumberOfTests('lyr', 'nb', TRUE) WHERE inv = 'NB99';
SELECT * FROM TT_CheckNumberOfTests('nfl', 'nb', FALSE) WHERE inv = 'NB99';
```

The `CNT` column gives the complete translated count, `SUGGESTED_NBR` the recommended test count, and `TESTED_NB` the actual test count. Check `SUFFICIENT` and review oversized samples flagged by `DIFF_PCT` values of 20 or more, following the test README.

**Do not rely on `SUFFICIENT` alone:** it can report `true` when a group of test rows is missing. For every group requiring tests, verify that `TESTED_NB` is positive and meets the recommendation. Explain any intentionally untested small group and check it directly.

The third argument to `TT_CheckNumberOfTests()` controls grouping by final CASFRI layer. For example, a sample from input layer 3 might produce 180 water rows and 20 rock rows in separate final NFL layers. `TRUE` checks the two counts separately; `FALSE` checks the combined 200. Both components share one source sample size, so combine counts when separate recommendations cannot be met reliably. Set `LAYER` to `3` in the sample-size CSV because it identifies the input layer.

To list NB99's NFL groups with insufficient tests or samples at least 20% above the recommendation, run:

```sql
SELECT *
FROM TT_CheckNumberOfTests('nfl', 'nb', FALSE)
WHERE inv = 'NB99'
  AND (NOT sufficient
       OR (suggested_nbr > 0 AND tested_nb = 0)
       OR diff_pct >= 20);
```

This query should return no rows once the counts are acceptable. The additional zero-count condition catches missing required tests even when `SUFFICIENT` incorrectly reports `true`.

Adjust sample sizes and repeat subsections 5.1–5.3 as needed. Changing a sample size can change all selected records, so finish these adjustments before accepting the comparison files.

### 5.4 Add or update helper-function tests

Adding or updating helper-function tests is optional if no helper function has changed and the required cases are already covered. Otherwise, add or update tests in [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql) for each new or modified CASFRI helper function and any missing cases. These are unit tests: checks of one function at a time. Follow the existing `NUMBER`, `FUNCTION_TESTED`, `DESCRIPTION`, and `PASSED` columns. Update `test_nb`, the list recording the function groups and expected number of tests, so the checks can also detect an operation that unexpectedly returns no result.

Test successful calculations, missing values, and invalid inputs. Use comparisons that explicitly handle NULL. Inspect missing or NULL test results as well as results marked as failed; completion of the SQL command alone is not sufficient.

### 5.5 Compare and archive the validated test tables

Archiving the reviewed test CSVs preserves a reliable reference for future test runs. It lets you detect unintended changes to previously accepted translations and prevents the accepted test results from being lost when the CSVs are regenerated.

Compare all five generated CSVs in `translation/test/tables/` with the accepted versions saved in Git before committing the new results. Choose the comparison method matching how you manage the repository:

**[GitKraken](https://help.gitkraken.com/gitkraken-desktop/diff/)** - Open the CASFRI repository, select the `//WIP` entry showing uncommitted changes in the commit graph, and click each changed CSV under **Unstaged Files** or **Staged Files**. Choose **Split View** for a side-by-side comparison or **Inline View** to see changes within the file.

**[VS Code](https://code.visualstudio.com/docs/sourcecontrol/staging-commits)** - Open the CASFRI folder and its **Source Control** view (`Ctrl+Shift+G`). Click each changed CSV under **Changes** to open its comparison; files already selected for a commit appear under **Staged Changes**. If a CSV appears in both staged and unstaged lists in either application, review both comparisons.

**Git Bash** - Otherwise, open Git Bash in the main project folder and run:

```bash
git diff HEAD -- translation/test/tables/
```

The command compares the current CSVs with the latest committed versions, including both staged and unstaged changes.

A new inventory has no accepted reference results yet. Verify its translated test values against the source data, the specification, and the validated complete translation before accepting them. Check rare or newly supported cases directly as in subsection 3.4, because random samples can miss them.

For existing inventories, accept only intended, explained changes. If results differ, follow the test README's [guide to differences](../translation/test/readme.md#a-key-to-determining-the-cause-of-differences-between-archived-and-new-test-tables). Include every inventory affected by shared conversion scripts, translation tables, lookup tables, or functions, extending tests beyond one jurisdiction when needed. For example, the CASFRI helper `TT_HasNFLInfo()` decides which source records produce NFL rows in British Columbia, Prince Edward Island, Saskatchewan, and Yukon. Changing it to recognize a new inventory's non-forest information could unintentionally include or exclude records in the other jurisdictions, so run and review their tests too. Record untested inventories as not tested, and keep incomplete results separate from accepted files.

Fix unintended changes and rerun the affected tests. With unchanged inputs, software versions, configuration variables, and sample sizes, repeated runs should produce identical CSVs, even on different machines. Record sample sizes and reasons for accepted differences in the `COMMENT` column or the inventory's README.

Archive the accepted CSVs in `translation/test/tables/` together with the related script and table changes by committing and pushing them to GitHub, following subsection 6.3.

## 6) Record and share the work

Complete the inventory documentation and share the reviewed project changes with contributors.

### 6.1 Document final counts, test tables, and remaining problems

Complete the inventory's row in `metadata/inventory_metadata.csv`: enter confirmed counts in their dedicated columns, sample sizes, and remaining limitations in the `COMMENT` column or the inventory's README. Reload metadata after updating it.

Create a GitHub issue for each problem identified during this procedure that could not be fixed. Describe the affected inventory, expected and observed behavior, and how to reproduce the problem.

The inventory is ready when:

- Loaded counts agree with the original data and documented preparation.
- Inventory metadata is complete.
- HDR contains exactly one row for the inventory, with values matching that metadata.
- All expected translated tables exist.
- All primary-key, value, and geometry constraints are satisfied.
- All foreign-key constraints are satisfied.
- Each required inventory/table/layer combination has the recommended number of translated test rows or a documented exception.
- Tests of new or modified helper functions pass.
- Saved comparison results have been reviewed and can be reproduced.

### 6.2 Update derived tables only if required

This step is optional: translation does not update derived products. If these products must include the new inventory, follow steps [12: Produce both denormalized (flat) tables](../README.md#12-produce-both-denormalized-flat-tables), [13: Produce the geo-historical table](../README.md#13-produce-the-geo-historical-table), and [14: Produce inventory coverage maps](../README.md#14-produce-inventory-coverage-maps) in the main README, as needed. For historical results, confirm the values in the `PRECEDENCE_RANK` column of `metadata/inventory_metadata.csv`.

### 6.3 Review, commit, and push the changes to GitHub

A commit saves selected file changes in your computer's Git history, with a message explaining the work. Pushing sends those commits to GitHub. Staging selects the file contents to include in the next commit. These actions share project files; they do not upload the PostgreSQL database.

Confirm the CASFRI repository, current branch, and destination GitHub repository before continuing. A branch keeps a set of changes separate while they are prepared and reviewed. A remote is a named connection to GitHub; `origin` is a common name. Check that the destination is correct and that you have permission to push.

Review changes as described in subsection 5.5 and open new files separately. Include the inventory metadata, conversion script, mappings, translation and lookup tables, functions, documentation, new tests, and accepted test-result CSVs belonging to this update. Leave out unrelated changes, personal working files, source datasets, and local database connection configuration variables. Follow only one of the three alternative methods below, depending on how you manage your repository.

#### Method A: Commit and push with GitKraken

If you manage your repository with GitKraken, follow these steps:

- Open the CASFRI repository and select `//WIP` in the commit graph to view uncommitted changes.
- Review the required files and click **Stage File** for each. Inspect **Staged Files**; **Unstage File** removes an accidental selection while keeping the edits.
- Enter a clear message identifying the inventory and work completed, then click **Commit**.
- Click **Push** in the toolbar. If prompted, select the intended existing GitHub remote and destination branch.

See the GitKraken guides to [committing](https://help.gitkraken.com/gitkraken-desktop/commits/) and [pushing](https://help.gitkraken.com/gitkraken-desktop/pushing-and-pulling/) for interface details.

#### Method B: Commit and push with VS Code

If you manage your repository with VS Code, follow these steps:

- Open the CASFRI folder and **Source Control** (`Ctrl+Shift+G`). Review each required file under **Changes**.
- Click **+** beside each file to select it. Inspect **Staged Changes**; **-** removes an accidental selection without deleting the edits.
- Enter a clear message identifying the inventory and work completed, then click **Commit**.
- In Source Control, select **More Actions (...) > Push**. If the branch has not been published, choose **Publish Branch** and confirm the intended existing remote and branch.

See the VS Code guides to [staging and committing](https://code.visualstudio.com/docs/sourcecontrol/staging-commits) and [pushing](https://code.visualstudio.com/docs/sourcecontrol/repos-remotes#push-commits) for interface details.

#### Method C: Commit and push with Git Bash

If you manage your repository with Git commands, follow this method. Open Git Bash in the main CASFRI folder as explained in the [Shared preparation](../README.md#shared-preparation) section from the main README. Inspect the changed files, branch, destination, and differences:

```bash
git status
git branch --show-current
git remote -v
git diff
```

Open new files separately, because `git diff` does not display files not yet added to Git. Select the required files by their exact paths; adapt this example and include the other changed files and accepted test CSVs:

```bash
git add -- metadata/inventory_metadata.csv metadata/layer_metadata.csv conversion/sh/load_nb99.sh
```

Inspect everything selected for the next commit:

```bash
git diff --cached --stat
git diff --cached
git status
```

If a file was selected by mistake, `git restore --staged -- path/to/file` removes it from the selection while keeping the edits; replace `path/to/file` with its actual path.

Commit with a clear message:

```bash
git commit -m "Add NB99 inventory conversion, translation, and tests"
```

Push to the existing branch on GitHub. Replace `your-branch-name` with the name shown by `git branch --show-current`, and `origin` if your remote has another name:

```bash
git push -u origin your-branch-name
```

**After any of these methods** - Confirm that the push succeeded. Resolve permissions problems or conflicting remote changes without overwriting other contributors' work. Open the branch on GitHub and verify that the expected commit and files are present. If the project uses pull requests, open one for review and describe the inventory, tests performed, and remaining problems.

