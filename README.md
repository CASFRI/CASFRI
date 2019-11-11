# Introduction
Digital Forest Resource Inventories (FRIs) are compiled by provincial and territorial governments and are key inputs into forest management planning. They have also been used widely to model species habitat in the Canadian boreal forest and, in combination with climate and weather data, to model wildfire size and frequency. FRI datasets consist of stand maps interpreted from aerial photography at scales ranging from 1:10,000 to 1:40,000. They are typically conducted on a 10- to 20-year cycle and may be periodically updated to reflect changes such as burned areas, harvesting, insect damage, silviculture, and forest growth. The stand maps estimate the location, extent, condition, composition, and structure of the forest resource. Each jurisdiction has developed its own procedures and standards for forest inventories. 

The Common Attribute Schema for Forest Resource Inventories (CASFRI) standardizes FRI data from each jurisdiction in Canada, allowing a national FRI relational database to be created with continuous coverage. A major challenge in assembling a national coverage of FRI data is reconciling the many differences in variable formats, attributes, and standards among disparate inventories. Standardization is necessary so that models can be developed using data from multiple jurisdictions or inventory versions.

The [CASFRI specifications](https://github.com/edwardsmarc/CASFRI/tree/master/docs/specifications) document the CAS database schema. It focuses on the most common attributes that are consistently recorded in forest inventories across Canada and which are relevant to habitat modeling and state of forest reporting. These attributes include crown closure, species composition, height, mean canopy or stand origin age, stand structure, moisture regime, site class or site index, non-forested cover types, non-vegetated cover types, and disturbance history.

A number of CASFRI instances have been produced since 2009. CASFRI 5.x is the fifth version of CASFRI. It makes a number of significant updates to previous versions:

* Addition of new and more up-to-date inventories.
* Implementation of a new conversion and loading procedure focused around the open source software GDQL/OGR (in place of ArcGIS).
* Implementation of a SQL based translation engine abstracting the numerous issues related to this kind of conversion to simple translation files.
* Implementation of a temporalization procedure to create a temporal database of all available inventories.
* Enhancement of attribute generic and specific error codes.

The three steps involved in the production of the CASFRI 5.x database are:

1. Conversion (from many different FRI file format) and loading (in the database) using Bash files (or Batch files) and ogr2ogr.
2. Translation of in-db FRI to CAS
3. Temporalization of CAS data

Note that forest resource inventories converted and translated by this package are not provided with this project due to the numerous licensing agreements that have to be passed with the different production juridictions.

# Version Releases

CASFRI follows the [Semantic Versioning 2.0.0](https://semver.org/) versioning scheme (major.minor.revision) adapted for a dataset. Increments in revision version numbers are for bug fixes. Increment in minor version numbers are for new features, support for new inventories, additions to the schema (new attributes), and bug fixes. Increments in minor versions do not break backward compatibility with previous CASFRI schemas. Increments in major version number are for schema changes breaking backward compatibility in existing code manipulating the data (e.g. renaming attributes, removing attributes, and inventory support deprecation).

The current version is 5.0.2-beta and is available for download at https://github.com/edwardsmarc/CASFRI/releases/tag/v5.0.2-beta

# Directory structure
<pre>
./                      Sample files for configuring and running scripts

./conversion            Scripts for converting and loading FRI datasets using either .bat or .sh. (1st step)

./docs                  Documentation including CASFRI specifications

./helperfunctions       CASFRI specific helper functions used for table translation

./translation           Translation tables and associated loading scripts (2nd step)

./workflow              Actual SQL translation workflow (3rd step)
</pre>

# Requirements

The production process of CASFRI 5.x requires:

* [GDAL v1.11.4](http://www.gisinternals.com/query.html?content=filelist&file=release-1800-x64-gdal-1-11-4-mapserver-6-4-3.zip) and access to a Bash or a Batch shell to convert and load FRIs into PostgreSQL. IMPORTANT: Some FRIs will not load with GDAL v2.X. This is documented as [issue #34](https://github.com/edwardsmarc/CASFRI/issues/34).

* PostgreSQL 9.6 and PostGIS 2.3.x to store and translate the database. More recent versions should work as well.

* The [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework) to translate the database.

# Vocabulary
*Source data* - Raw FRI data received from jurisdictions.

*Loaded source table* - Raw FRI data converted and loaded into PostgreSQL.

*Target table* - Translated FRI table in the CAS specification.

*Translation table* - User created table detailing the validation and translation rules and interpreted by the translation engine.

*Lookup table* - User created table used in conjunction with the translation tables; for example, to recode provincial species lists to a standard set of 8-character codes.

*Translation engine* - The [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework).

*Helper function* - A set of PL/pgSQL functions used in the translation table to facilitate validation of source values and their translation to target values.

# FRI and Inventory Standard Identifiers
CASFRI 5.x uses a four-code standard for identifying FRIs. Each FRI is coded using two letters for the province or territory, and two numbers that increment for each new FRI added in that province/territory. e.g. BC01.

Inventory standards are the attribute specifications applied to a given inventory. Multiple FRIs from a province/territory can use the same standard, however jurisdictions will occasionally update their standards, and each jurisdiction has their own unique inventory standards. The CASFRI specifications need to apply different sets of translation rules for different standards. Each standard is assigned a code made of three letters representing the standard, and two numbers representing the version of the standard. e.g. VRI01. 

All identifiers are listed in the [FRI inventory list CSV file](https://github.com/edwardsmarc/CASFRI/blob/master/docs/inventory_list_cas05.csv) listing all the forest inventories used as source datasets in this project.

# Conversion and Loading
Conversion and loading happen at the same time and are implemented using the GDAL/OGR ogr2ogr tool. Every source FRI has a single loading script that creates a single target table in PostgreSQL. If a source FRI has multiple files, the conversion/loading scripts append them all into the same target table. Some FRIs are accompanied by an extra shapefile making it possible to associate a photo year with each stand. They are loaded with a second script. Every loading script adds a new "src_filename" attribute to the target table with the name of the source file. This is used when constructing the CAS_ID, a unique row identifier code tracing each target row back to its original row in the source dataset.

Loading scripts are configured by defining local paths and other options in a copy of the configSample.bat and configSample.sh files that you have to name config.bat and config.sh in the same folder. More workflow details are provided below.

### Supported File Types
All conversion/loading scripts are provided as both .sh and .bat files.

Currently supported FRI formats are:

* Geodatabase
* Shapefile
* Arc/Info Binary Coverage

Arc/Info E00 files are not currently supported due to an incomplete support in GDAL/OGR. Source tables in this format should be converted into a supported format before loading, for example a file geodatabase.

### Projection
All source tables are transformed to the Canada Albers Equal Area Conic projection during loading.

# Translation
Translation of loaded source tables into target tables formatted to the CASFRI specification is done using the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework). The translation engine uses a translation table that describes rules to validate each loaded source table and translate each row into a target table. Validation and translation rules are defined using a set of helper functions that both validate the source attributes and translate into the target attributes. For example, a function named Between() validates that the source data is within the expected range of values, and a function named Map() maps a set of source values to a set of target values. A list of all helper functions is available in the PostgreSQL Table Translation Framework [readMe](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework). After the translation engine has run on all loaded source tables, the result is a complete set of target tables, each with matching attributes as defined by the CASFRI standard. 

### Error Codes
Error codes are needed during translation if source values are invalid, null, or missing. In CASFRI 5.x, error codes have been designed to match the attribute type and to reflect the type of error that was encountered. For example, an integer attribute will have error codes reported as integers (e.g. -9999) whereas text attributes will have errors reported as text (e.g. INVALID). Different error codes are reported depending on the rule being invalidated. A full description of possible error codes can be found in the [CASFRI 5.x specification document](https://github.com/edwardsmarc/CASFRI/tree/master/docs/specifications).

### Validating Dependency Tables
Some translations require dependency tables. Examples are species lookup tables used for mapping source species to target species, and photo year geometries used to intersect source geometries and assign photo year values. These tables need to be validated before being used in the translations. This is done using the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework) and some pseudo-translation tables (stored in the dependencyvalidation/tables folder). These pseudo-translation tables are run on the dependency tables themselves and run only validation rules. The engine is therefore only used for its validation capacities and since no real translation is performed, the output of the translation is not saved to tables. If any rows fail a validation rule, the dependency table needs to be fixed before using it in a translation process.

# Workflow

### Installation

* Install the PostgreSQL, PostGIS and GDAL versions specified in the requirement section.
* Install the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework) following the instructions provided in the project readme.

### Converting/Loading FRIs
* Edit the configSample (.bat or .sh) file located in the CASFRI root directory to match your system configuration and save it as config.sh or config.bat in the same folder.
* In an operating system command window, load the necessary inventories by executing the proper conversion scripts located in either the .bat or .sh conversion folder.
* After running each conversion/loading script, the source FRI tables will be added to the PostgreSQL schema specified in the config file ("rawfri" by default).

Conversion and loading scripts are written so that FRIs to convert and load must be stored in a specific folder hierarchy. TO BE PROPERLY EXPLAINED AFTER FIX FOR [ISSUE #40](https://github.com/edwardsmarc/CASFRI/issues/40).

### Loading Translation Tables
* Edit the configSample (.bat or .sh) file located in the CASFRI root directory to match your system configuration and save it as config.sh or config.bat in the same folder.
* In an operating system command window, load the translation files by executing the load_tables (.bat or .sh) script located in the translation folder. 
* The script will load all translation tables and validation tables stored in the "translation/tables" folder and subfolder into the specified schema ("translation" by default).

### Translating
* Validate dependency tables using the loaded validation tables.
* Run the translation engine for each FRI using the loaded source FRI table and the translation table.
* Refer to the files located in the CASFRI/workflow folder for an example of how to run the translation engine. 

# Credits
**Steve Cumming**, Center for forest research, University Laval.

**Pierre Racine**, Center for forest research, University Laval.

**Pierre Vernier**, database designer.

**Marc Edwards**, programmer.

**Mélina Houle**, Center for forest research, University Laval (previous versions of CASFRI).

**Bénédicte Kenmei**, Center for forest research, University Laval (previous versions of CASFRI).

**John Cosco**, Timberline Forest Inventory Consultants (previous versions of CASFRI).
