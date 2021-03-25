# Introduction
Digital Forest Resource Inventories (FRIs) are compiled by provincial and territorial governments and are key inputs into forest management planning. They have also been used widely to model species habitat in the Canadian boreal forest and, in combination with climate and weather data, to model wildfire size and frequency. FRI datasets consist of stand maps interpreted from aerial photography at scales ranging from 1:10,000 to 1:40,000. They are typically conducted on a 10- to 20-year cycle and may be periodically updated to reflect changes such as burned areas, harvesting, insect damage, silviculture, and forest growth. The stand maps estimate the location, extent, condition, composition, and structure of the forest resource. Each jurisdiction has developed its own procedures and standards for forest inventories. 

The Common Attribute Schema for Forest Resource Inventories (CASFRI) standardizes FRI data from each jurisdiction in Canada, allowing a national FRI relational database to be created with continuous coverage. A major challenge in assembling a national coverage of FRI data is reconciling the many differences in variable formats, attributes, and standards among disparate inventories. Standardization is necessary so that models can be developed using data from multiple jurisdictions or inventory versions.

The [CASFRI specifications](https://github.com/edwardsmarc/CASFRI/tree/master/docs/specifications) document the CAS database schema. It focuses on the most common attributes that are consistently recorded in forest inventories across Canada and which are relevant to habitat modeling and state of forest reporting. These attributes include crown closure, species composition, height, mean canopy or stand origin age, stand structure, moisture regime, site class or site index, non-forested cover types, non-vegetated cover types, and disturbance history.

A number of CASFRI instances have been produced since 2009. CASFRI 5.x is the fifth version of CASFRI. It makes a number of significant updates to previous versions:

* Addition of new and more up-to-date inventories.
* Implementation of a new conversion and loading procedure focused around the open source software GDAL/OGR (in place of ArcGIS).
* Implementation of an SQL based translation engine abstracting the numerous issues related to this kind of conversion to simple translation files.
* Implementation of a temporalization procedure to create a temporal database of all available inventories.
* Implementation of a descriptive error code system.

The three steps involved in the production of the CASFRI 5.x database are:

1. Conversion (from many different FRI file formats) and loading (into a PostgreSQL database) using Bash files (or Batch files) and ogr2ogr.
2. Translation of the loaded FRIs to the CASFRI schema (inside the PostgreSQL database)
3. Temporalization of CAS data (inside the PostgreSQL database)

Note that forest resource inventories are not provided with this project due to the numerous licensing agreements that have to be passed with the different production juridictions.

# Version Releases

CASFRI follows the [Semantic Versioning 2.0.0](https://semver.org/) versioning scheme (major.minor.revision) adapted for a dataset. Increments in revision version numbers are for bug fixes. Increments in minor version numbers are for new features, support for new inventories, additions to the schema (new attributes), and bug fixes. Increments in minor versions do not break backward compatibility with previous CASFRI schemas. Increments in major version numbers are for schema changes that break backward compatibility with existing code (e.g. renaming attributes, removing attributes, and inventory support deprecation).

The current version is 5.2.0 and is available for download at https://github.com/edwardsmarc/CASFRI/releases/tag/v5.2.0

# Directory structure
<pre>
./                                      Sample files for configuring and running scripts

./conversion                            Scripts for converting and loading FRI datasets using either .bat or .sh

./docs/specifications                   CASFRI specifications document

./docs/inv_coverage                     .sql script for computing CASFRI coverage polygons

./helperfunctions                       CASFRI specific helper functions used in translation tables

./helperfunctions/geohistory            Functions used to build historical database

./summary_statistics                    R scripts to summarize CASFRI output for validation checks

./translation/tables                    Translation tables and associated loading scripts

./translation/test                      Unit tests for CASFRI translations

./workflow/01_develTranslationTables    Translation scripts used for development and testing

./workflow/02_produceCASFRI             Workflow scripts to run all translations

./workflow/03_flatCASFRI                Scripts to build flat (denormalized) version of CASFRI 

./workflow/04_produceHistoricalTable    Scripts to build historical CASFRI database 
</pre>

# Requirements

The production process of CASFRI 5.x requires:

* [GDAL v3.1.x](https://www.gisinternals.com/query.html?content=filelist&file=release-1911-x64-gdal-3-1-4-mapserver-7-6-1.zip) and access to a Bash or a Batch shell to convert and load FRIs into PostgreSQL. IMPORTANT: Some FRIs will not load with GDAL v2.x. This is documented as [issue #34](https://github.com/edwardsmarc/CASFRI/issues/34). Production has also been tested using GDAL 1.11.4.

* PostgreSQL 13 and PostGIS 3.1.1 to store and translate the database (PostgreSQL 9.6/11/12 and PostGIS 2.3.x have also been tested). More recent versions should work as well.

* The [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework) to translate the database.

# Vocabulary
*Source data* - Raw FRI data received from jurisdictions.

*Loaded source table* - Raw FRI data converted and loaded into PostgreSQL.

*Target table* - Translated FRI table into the CASFRI specifications.

*Translation table* - User created table detailing the validation and translation rules and interpreted by the translation engine.

*Lookup table* - User created table used in conjunction with the translation tables; for example, to recode provincial species lists to a standard set of 8-character codes.

*Translation engine* - The [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework).

*Helper function* - A set of PL/pgSQL functions used in the translation table to facilitate validation of source values and their translation to target values.

# FRI and Inventory Standard Identifiers
CASFRI 5.x uses a four-code standard for identifying FRIs. Each FRI is coded using two letters for the province or territory, and two numbers that increment for each new FRI added in that province/territory. e.g. BC01.

Inventory standards are the attribute specifications applied to a given inventory. Multiple FRIs from a province/territory can use the same standard, however jurisdictions will occasionally update their standards, and each jurisdiction has their own unique inventory standards. The CASFRI specifications need to apply different sets of translation rules for different standards. Each standard is assigned a code made of three letters representing the standard, and two numbers representing the version of the standard. e.g. VRI01. 

All identifiers are listed in the [FRI inventory list CSV file](https://github.com/edwardsmarc/CASFRI/blob/master/docs/inventory_list_cas05.csv) that lists all the forest inventories used as source datasets in this project.

# Handling updates
Historical forestry data is of great value which is why CASFRI accommodates updates. One type of update we often see in FRIs is re-inventories, i.e., when old photo-interpretation is updated to modern standards. The other types of update are so-called “depletion updates” related to various disturbances. In many jurisdictions, depletion-updates are produced annually to “cut-in” polygons disturbed by harvesting, wildfire or insects. Both types of updates are incorporated in CASFRI 5.x by loading and translationg the updated dataset and labelling the dataset with an incremented Inventory_ID. Any duplicate records will be dealt with in the temporalization procedure.

For an update to be incorporated in the database, the date of publication should be at least one year apart from a previous version. When data are available online, this information can be found in the metadata. For data received from a collaborator, information on the last version received should be shared in order to identify if ny new datasets meet the 1-year criteria.   

# Conversion and Loading
Conversion and loading happen at the same time and are implemented using the GDAL/OGR ogr2ogr tool. Every source FRI has a single loading script that creates a single target table in PostgreSQL. If a source FRI has multiple files, the conversion/loading scripts append them all into the same target table. Some FRIs are accompanied by an extra shapefile that associates each stand with a photo year. These are loaded with a second script. Every loading script adds a new "src_filename" attribute to the target table with the name of the source file, and an "inventory_id" attribute with the dataset name. These are used when constructing the CAS_ID (a unique row identifier tracing each target row back to its original row in the source dataset).

### Supported File Types
All conversion/loading scripts are provided as both .sh and .bat files.

Currently supported FRI formats are:

* Geodatabase
* Shapefile
* Arc/Info Binary Coverage

Arc/Info E00 files are not currently supported in GDAL/OGR. Source tables in this format should be converted into a supported format before loading (e.g. a file geodatabase).

### Projection
All source tables are transformed to the Canada Albers Equal Area Conic projection during loading.

### Config file
A config file (.bat or .sh) is required in the CASFRI root directory to set local paths and preferences. Template files are provided (configSample.bat and configSample.sh) which can be copied and edited.

### Source data folder structure
Conversion and loading scripts are written so that FRIs to convert and load must be stored in a specific folder hierarchy (using inventory AB06 as an example):

FRI/  
├─AB/  
│ ├─AB06/  
│ │ ├─data/  
│ │ │ ├─archive/  
│ │ │ ├─coverage/  
│ │ │ ├─inventory/  
│ │ │ └─photoyear/  
│ │ ├─doc/  
│ │ │ ├─archive/  
│ │ │ ├─emailexchange/  
│ │ │ ├─manual/  
│ │ │ │ ├─others/  
│ │ │ └─map/  
│ │ ├─license/  
│ │ └─toclassify/  
│ └─AB16/  
│ │ ├─data/  
│ │ ├─doc/  
│ │ ├─.../  
├─BC/  
│ ├─.../  

# Translation
Translation of loaded source tables into target tables formatted to the CASFRI specification is done using the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework). The translation engine uses a translation table that describes rules to validate each loaded source table and translate each row into a target table. Validation and translation rules are defined using a set of helper functions that both validate the source attributes and translate into the target attributes. For example, a function named isBetween() validates that the source data is within the expected range of values, and a function named mapText() maps a set of source values to a set of target values. A list of all helper functions is available in the PostgreSQL Table Translation Framework [readMe](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework). After the translation engine has run on all loaded source tables, the result is a complete set of target tables, each with matching attributes as defined by the CASFRI standard. 

### Translation tables
A detailed description of translation table properties is included in the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework). In short, each translation table lists a set of attribute names, their type in the target table, a set of validation helper functions which any input value has to pass, and a set of translation helper functions to convert the input value to the CASFRI value. A set of generic helper functions are included with the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework), these perform standardized validations and translations that are used in many different translation tables. The CASFRI project also has its own more specific [helper functions](https://github.com/edwardsmarc/CASFRI/tree/master/helperfunctions) that apply more complex translations specific to individual inventories.

CASFRI is split into seven tables as detailed in the [CASFRI specifications](https://github.com/edwardsmarc/CASFRI/tree/master/docs/specifications):
1. Header (HDR) attributes - summarizing reference information for each dataset;  
2. CAS Base Polygon (CAS) attributes - attributes describing the source polygon and any identifiers;  
3. Forest-Level (LYR) attributes - attributes describing productive and non-productive forest land;  
4. Non-Forest Land (NFL) attributes - attributes describing non-forested land;  
5. Disturbance history (DST) attributes - attributes describing the type, year and extent of disturbances;  
6. Ecological specific (ECO) attributes - attributes describing wetlands;  
7. Geometry attributes (GEO) - polygon geometries.

In general, each standard for each jurisdiction uses a single set of translation tables. All source datasets using the same standard should use the same set of translation tables. Differences in attribute names can be accomodated using the workflow scripts described below. In some cases minor differences in attributes between datasets using the same standard can be accomodated by designing translation helper functions that can deal with both formats. An example would be two datasets using different values for graminoids (e.g. 'Grm' in one dataset and 'graminoids' in another). These can be combined into a single translation function to deal with both datasets in the translation table (e.g. mapText(source_value, {'Grm', 'graminoids'}, {'GRAMINOID', 'GRAMINOID'})).

### Row translation rule
An important feature of the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework) is the use of a ROW_TRANSLATION_RULE in the translation table. This allows the loaded source table to be filtered during translation so that only the relavent rows are returned in the target tables. This ensures that the the LYR table for example, only includes rows that contain forest information.

### Error Codes
Error codes are needed during translation if source values are invalid, null, or missing. In CASFRI 5.x, error codes have been designed to match the attribute type and to reflect the type of error that was encountered. For example, an integer attribute will have error codes reported as integers (e.g. -8888) whereas text attributes will have errors reported as text (e.g. NULL_VALUE). Different error codes are reported depending on the rule being invalidated. A full description of possible error codes can be found in the [CASFRI 5.x specification document](https://github.com/edwardsmarc/CASFRI/tree/master/docs/specifications).

### Validating Translations
Validation is performed at multiple stages during and after translation:
#### Validation of source values
All source values are validated before attempting translation using the validation rules described in the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework).
#### Validation of translation tables by the engine
The [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework) validates the translation rules and foratting in each translation table prior to attempting translation.
#### Horizontal review of translation tables
The function TT_StackTranslationRules() creates a table of all translation and validation rules used for all inventories for a given CASFRI table. This allows manual validation of all translation rules and assignment of error codes for a given attribute.
#### Validation of output using summary statistics
The [summary_statistics](https://github.com/edwardsmarc/CASFRI/tree/master/summary_statistics) folder contains scripts (primarily summarize.R) to create summary statistics for all attributes in each source inventory. These scripts use the R programming language and require that R be downloaded (https://www.r-project.org/). The output is a set of html files containing the summary information. These can be used to check for outliers, unexpeted values, correct assignment of errors codes etc.

### Workflow scripts
The translation of each dataset is done using the scripts in the [CASFRI/workflow/02_produceCASFRI/02_perInventory](https://github.com/edwardsmarc/CASFRI/tree/master/workflow/02_produceCASFRI/02_perInventory) folder. The main translation functions are TT_Prepare() which validates and prepares the translation table, and TT_Translate() which runs the translation. These are described in detail in the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework). 

It is important that a single translation table can be used for multiple translations, either for different layers within the same dataset, or for different datasets using the same standard but different attributes names. The workflow scripts accomodate this by combining three elements:

**1. Placeholder names in translation table functions.**
Translation table helper functions use placeholder arguments. Every translation using a common translation table must map the source attributes to these placeholder names so that the translation table can be reused for all translations. Otherwise many translation tables using the same helper functions but with different attribute names would have to be created. In the workflow script we create VIEWs that map the source data attributes to the placeholder names used in the translation table. We can then run the translation using the VIEW and the translation table.

**2. Attribute dependency table.**
This table defines the mapping of attributes from each source table to the placeholder names used in the translation tables. For a given translation table, the attribute dependencies table contains a row for the translation table placeholder names, and rows for each translation that needs to be completed using a source inventory. If there are multiple layers to be translated for an inventory, it will have multiple rows in the attribute dependencies table. The table has the following columns:
* inventory_id - either a name representing the translation table (e.g. AB) or a name matching a source inventory dataset (e.g. AB03)
* layer - a unique integer value incrementing for LYR layers followed by NFL layers.
* ttable_exists - indicates if the row represents a translation table.

All other columns represent target attributes in the CASFRI tables. The values in each cell list the attributes to be mapped to the translation table placeholder names. In the case of the translation table rows, the values must match the placeholder names used in the translation table. In the case of rows representing source datasets, the values represent source attribute names.

**3. TT_CreateMappingView().**
The function TT_CreateMappingView() is used to create the VIEWs used in the workflow by mapping the attributes defined in the attribute dependencies table from the source names to the translation table placeholder names. It has the following arguments:
* schema name: what schema is the source data in
*	from table name (optional): inventory_id of source data row in attribute dependencies table
*	from layer (optional, default 1): matches the layer value in the attribute dependencies table
*	to table: inventory_id of the row containing the translation table plaeholder names
*	to layer (optional, default 1): matches the layer value in the attribute dependencies table (for our purposes this is always set to 1)
*	number of rows (optional, default all rows): number of random rows to select

The function creates a view with a name based on the input arguments:
If only the 'from table name' is provided, a VIEW with a minimal set of attributes and no mappings is created. For example `SELECT TT_CreateMappingView('rawfri', 'ab03', 200);` creates a view named **ab03_min_200**.

If both a 'from' and a 'to' table are provided, the 'from' names (i.e. the source data) are mapped to the 'to' names (i.e. the translation table placeholder names), defaulting to use layer 1. For exampe `SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab');` creates a view name **ab03_l1_to_ab_l1_map**.

If 'layer' integers are provided, the row corresponding to the provided layer number will be used for the mapping. For example `SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1);` creates a view name **ab03_l2_to_bc_l1_map**.

If the 'number of rows' are provided, the view name ends with the number of randomly selected rows. For example `SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1, 200);` creates a view name **ab03_l2_to_ab_l1_map_200**.

The following diagram illustrates the relationship between the translation table, the attribute dependencies table, and TT_CreateMappingView() using a simple attribute - SPECIES_1_PER. The translation rule is a simple copy, but the attribute has a different name for layer 1 and layer 2 in the AB03 source dataset. Each layer is run as a separate translation: for the layer 1 translation the source attribute sp1_per needs to be mapped to the placeholder name (species_per_1), and for the layer 2 translation the understory attribute usp1_per needs to be mapped to the placeholder name (species_per_1). Views are used to map from the source attribute names to the placeholder names used in the translation table.

![Workflow diagram](workflow_diagram.jpg)

# Translation procedure
The steps to produce a complete build of the CASFRI database are detailed in the [release procedure](https://github.com/edwardsmarc/CASFRI/blob/master/docs/release_procedure.md). A subset of these steps can be used to translate a single dataset as follows:

1. Set up the config.sh or config.bat file with you system settings
2. Load the dataset (e.g. AB03) into PostgreSQL by launching either the .bat (conversion/bat/load_ab03.bat) or .sh (conversion/sh/load_ab03.sh) loading script in a Bash or DOS command window.
3. Load the translation tables into PostgreSQL by launching the CASFRI/translation/load_tables.sh (or .bat) script.
4. Install the PostgreSQL Table Translation Framework and the CASFRI Helper Functions
    1. Install the last version of the PostgreSQL Table Translation Framework extension file using the install.sh (or .bat) script. This step produces a file named table_translation_framework--x.y.z.sql in the Postgresql/XX/share/extension folder.
    2. In pgAdmin, load the Table Translation Framework and the CASFRI Helper Functions:
      1. CREATE the table_translation_framework extension and test it using the engineTest.sql, helperFunctionsTest.sql and helperFunctionsGISTest.sql scripts. Fix any non passing test (by fixing the function tested or the test itself).
      2. Load the CASFRI Helper Functions with the helperFunctionsCASFRI.sql script and test them using the helperFunctionsCASFRITest.sql.
5. Run the translation by launching the workflow sql script (CASFRI/workflow/02_produceCASFRI/02_perInventory/02_AB03.sql) in pgAdmin (or a psql window).

Translated data is generally added to the six output tables: cas_all, dst_all, eco_all, lyr_all, nfl_all, geo_all. The scripts in the [CASFRI/workflow/03_flatCASFRI/](https://github.com/edwardsmarc/CASFRI/tree/master/workflow/03_flatCASFRI) can be used to create two different denormalized tables, one where all layers for a given polygon are reported on the same row, and one where all layers for a given polygon are reported on different rows.

The steps to add a new inventory to the CASFRI database are detailed in issue [#471](https://github.com/edwardsmarc/CASFRI/issues/471).

# Temporalization
All translated datasets are combined into a single historical database that allows querying for the best available inventory information at any point in time accross the full CASFRI coverage. The historical database is created using the [produceHistoricalTable.sql](https://github.com/edwardsmarc/CASFRI/tree/master/workflow/04_produceHistoricalTable) script as described in the [release procedure](https://github.com/edwardsmarc/CASFRI/blob/master/docs/release_procedure.md). The output is a historical database that uses the photo year of each polygon as the reference date to determine its valid start and end time. Each polyon is intersected with all it's overlapping polygons and the resulting polygon segments are assigned valid start and end times. In the case of overlaps, the polygon with the most complete information is prioritized, as described below. This results in a database where no polygons overlap in time or space, so for any given location at any time, there is only one valid set of CASFRI records. 

The following diagram illustrates the temporalization procedure for a single polygon:

![Temporalization diagram](temporalization_diagram.jpg)

Valid start and end dates are assigned using the following rules:
* Each polygon is attributed a valid_year_begin year and a valid_year_end based on their stand_photo_year. By default, if the polygon does not overlaps with another one in space and time, valid_year_begin = 1930 and valid_year_end = 2030
* When two polygons overlap:
  * Younger polygons take precedence over older polygons stating at their valid_year_begin (e.g. a polygon from 2010 take precedence over a 2000 polygon stating in 2010. The 2000 polygon has precedence from 1930 until 2009)
  * When both polygons have the same stand_photo_year, polygons with valid values take precedence over polygons with invalid values. All significant attributes most be NULL or empty to consider that a polygon has invalid values. This rarely happens. (e.g. if both polygons have a 2010 stand_photo_year but one polygon has all it's significant attributes set to NULL of empty then the other polygon takes precendence)
  * When both polygons have the same stand_photo_year and valid values but come from different inventories, polygons from higher precedence inventories as established by the TT_HasPrecedence() function and the casfri50_history_test.inv_precedence table takes precedence. (e.g. two 2010 polygons have all their values valid but the first comes from AB10 and the second comes from AB16 then TT_HasPrecedence() states that the AB16 polygon must take precedence)
  * When both polygons have the same stand_photo_year, valid values and the same TT_HasPrecedence() precedence, then both polygons are sorted by their unique identifier (cas_id) and the first one has precedence over the second one.

No interpolation or interpretation of attributes is performed. For this reason the historical database can be queried to recreate the 'state of the inventory' for a given year, but not the 'state of the forest'. The 'state of the inventory' is the best available information for a given point in time, whereas the 'state of the forest' would require modelling the exact forest attributes for every year based on time since disturbance. This is beyond the scope of this project but the historical database could facilitate such modelling exercises for interested end users.

The historical database can be queried using valid_year_begin and valid_year_end. For example, the following query would select the most valid polygon from the historical database for all observation points in a table:
```
SELECT p.id, p.year, p.geom, gh.cas_id
FROM mypointable p, casfri50_history.geo_history gh
WHERE ST_Intersects(gh.geom, p.geom) AND gh.valid_year_begin <= p.year AND p.year <= gh.valid_year_end;
```
The resulting table can then be joined with:
  a) one of the two flat tables from the casfri50_flat schema or
  b) one of the CASFRI normalised tables from the casfri50 schema (hdr_all, cas_all, dst_all, eco_all, lyr_all, nfl_all)

# Update procedure
**To be written**

# Parallelization
The conversion and translation steps are designed to be run in parallel on a single CPU. No work has been done to split the workflow across multiple CPUs because we feel the speed of the full translation process is sufficient for the purposes of CASFRI (i.e. a full translation of the entire database will be rare, and the speed of translation is acceptable under this scenario). The single CPU parallelization of the conversion and translation steps is documented in the [release procedure](https://github.com/edwardsmarc/CASFRI/blob/master/docs/release_procedure.md) and allows all source datasets to be loaded at the same time, and all tranlsation tables to be translated at the same time.

# Translation exceptions
* **Multiple NFL value per row in AB [#526](https://github.com/edwardsmarc/CASFRI/issues/526)** - In general we translate one NFL value per row in CASFRI. If there are multiple NFL values to translate they are reported as different vertical layers. One exception to this is in the AB AVI where the non-forest type _rough pasture_ is always accompanied by a _shrub_ value indicating the height and extent of shrub cover in the _rough pasture_. This combination can also form horizontal structure within a polygon, with a structure percent value indicating how much of the polygon is covered. CASFRI cannot currently represent both horizontal and vertical structure in the same polygon. For this reason we report both the _rough pasture_ (translated to CASFRI value CULTIVATED) and the _shrub_ (translated to CASFRI value TALL_SHRUB or LOW_SHRUB) in the same layer. The workflow is such that this behavior has to applied consistently across the full dataset, meaning that some AB inventories will have cases of multiple NFL values per row.
* **53 rows in PEI are missing SPECIES_3 [#676](https://github.com/edwardsmarc/CASFRI/issues/676)** - species need to be ordered by non-null values, so if SPECIES_3 is missing, SPECIES_4 beomes SPECIES_3. This will be completed but the bug was not found in time for the March 31st release. 
* **Height calculation in BC [#336](https://github.com/edwardsmarc/CASFRI/issues/336)** - Most inventories simply copy the height value for the layer in question, but in BC we calculate the weighted average height because there are multiple height values for different canopy components.
* **Horizontal structure in Parks Canada datasets** - PC01 and PC02 are the only datasets using exclusively horizontal structure. In these cases the CASFRI LAYERs represent different horizontal components. There is no vertical structure captured for these inventories.
* **QC03 photo year issue [#444](https://github.com/edwardsmarc/CASFRI/issues/444)** - Photo year in the QC 3rd inventory standard is not precise.
* **QC 3rd and 4th inventory standards do not include layer 2 info [#287](https://github.com/edwardsmarc/CASFRI/issues/287)** - We know there are 2 LYR layers in many polygons, but there is only forest information for the top layer. This results in many LYR rows in QC01, QC02, QC03, QC04 and QC06 where LAYER is 2 and SPECIES are UNKNOWN_VALUE. 
* **Non-productive rows in LYR tables [#632](https://github.com/edwardsmarc/CASFRI/issues/632)** - Usually we determine the presence of a LYR row using notEmpty() to test if species info is present. This is used for the ROW_TRANSLATION_RULE and for counting layers in LYR LAYER, NFL LAYER, and CAS NUM_OF_LAYERS. Some inventories (MB01, MB05, NB01, NB02, NL01, NS01, NS02, NS03, ON01, ON02, SK01, SK02, SK03, SK04, SK05) can have non-productive forested types (e.g. treed muskeg, alder) that do not include any species info, but still need to be reported as a LYR row using the PRODUCTIVITY_TYPE attribute. In these cases we need to catch the productivity type value in the ROW_TRANSLATION_RULE, and we need custom functions to make sure the row is counted in any layer functions.
* **CAS_ID issues** - In most inventories we are able to build the unique CAS_ID identifier using identifiers from the source data that allow the cas_id to be linked back to the source polygon. In some inventories (e.g. ON [#536](https://github.com/edwardsmarc/CASFRI/issues/536) and QC [#645](https://github.com/edwardsmarc/CASFRI/issues/645)), the unique source identifier is too long to fit in a single CAS_ID slot, so it is split across multiple slots. Additionally, ON01 has 6 cases where the unique identifier does not link back to a single source polygon ([644](https://github.com/edwardsmarc/CASFRI/issues/644)).
* **Multiple inventories in a single source dataset** In some cases a source dataset is received which contains data from multiple standards. In these cases the source data is divided into multiple datasets (one for each standard) during loading. This applies to MB05 and MB06; QC03, QC04, QC05; and QC02, QC06, QC07.  
* **SK01 species percent logic [#275](https://github.com/edwardsmarc/CASFRI/issues/275)** - Assignment of species percent was developed with collaborators based on the species codes present. The logic is included in a document linked to the issue.
* **ON01 species codes [#678](https://github.com/edwardsmarc/CASFRI/issues/678) [#681](https://github.com/edwardsmarc/CASFRI/issues/681)** Species codes appear to be a combination of multiple formats. Fix in [#678](https://github.com/edwardsmarc/CASFRI/issues/678) deals with most of them, but some species codes have a single letter code that is not included in the manual ([#681](https://github.com/edwardsmarc/CASFRI/issues/681)).

# Credits
**Steve Cumming**, Center for forest research, University Laval.

**Pierre Racine**, Center for forest research, University Laval.

**Pierre Vernier**, database designer.

**Marc Edwards**, programmer.

**Mélina Houle**, Center for forest research, University Laval (previous versions of CASFRI).

**Bénédicte Kenmei**, Center for forest research, University Laval (previous versions of CASFRI).

**John Cosco**, Timberline Forest Inventory Consultants (previous versions of CASFRI).
