# Intro
Digital Forest Resource Inventories (FRIs) are compiled by provincial and territorial governments and are key inputs into forest management planning. They have also been used widely to model species habitat in the Canadian boreal forest, and in combination with climate and weather data to model wildfire size and frequency. FRI datasets consist of stand maps interpreted from aerial photography at scales ranging from 1:10,000 to 1:40,000, which are typically conducted on a 10- to 20-year cycle, and may be periodically updated to reflect changes such as burned areas, harvesting, insect damage, silviculture, and forest growth. The stand maps estimate the location, extent, condition, composition, and structure of the forest resource. Each jurisdiction has developed its own procedures and standards for forest inventories. 

The Common Attribute Schema for Forest Resource Inventories (CASFRI) standardizes FRI data from each jurisdication in Canada allowing a national FRI dataset to be created with continuous coverage. A major challenge in assembling a national coverage of FRI data is reconciling the many differences in variable formats, attributes, and standards among disparate inventories. Standardization is necessary so that models can be developed using data from multiple jurisdictions or inventory versions.

The CASFRI specifications focus on the most common attributes that are consistently recorded in forest inventories across Canada and which are relevant to habitat modeling. These attributes included crown closure, species composition, height, mean canopy or stand origin age, stand structure, moisture regime, site class or site index, non-forested cover types, non-vegetated cover types, and disturbance history.

CASFRI version 5 makes a number of updates to previous versions:
* Addition of new inventories
* Implimentation of a new extract, load, transform procedure focused around PostgreSQL and a small number of open source dependencies.
* Implimentation of a temporalization procedure to create a temporal database of all available inventories.

# Directory structure
./  Sample files for configuring and running scripts

./conversion  Scripts for converting and loading FRI datasets using either .bat or .sh

./docs  Documentation including CASFRI specifications

./helperfunctions  CASFRI specific helper functions used for table translation

./translation  Translation tables and associated loading scripts

# Requirements
CASFRI v5 was made using PostgreSQL 9.6 and PostGIS v2.3.7.

Loading scripts require GDAL v1.11.4.

Table translation requires the PostTranslationEngine v0.1beta

# FRI and standard codes
CASFRI v5 uses a four code standard for identifying FRIs. Each FRI is coded using two letters for the province or territory, and two numbers that increment for each new FRI added in that province/territory. e.g. BC01.

Inventory standards are the attribute specifications applied to a given inventory. Multiple FRIs from a province/territory can use the same standard, however jurisdictions will occasionally update their standards, and each jurisdiction has their own unique inventory standards. The CASFRI specifications need to apply different sets of translation rules for different standards. Each standard is applied an id made of three letters representing the standard, and two numbers representing the version of the standard. e.g. VRI01.

# Conversion and loading

The first step in building CASFRI v5 is to convert and load the source data. CASFRI 4 was made using the following steps:
* Conversion - Python and arcpy used to convert source files into shapefiles and csv tables containing attributes.
* Translation - translation rules implimented using Perl scripts
* Loading into PostgreSQL using shp2pgsql
* Topological correction inside database using PostGIS SQL scripts

This is an extract, transform, load procedure (ETL). CASFRI v5 will switch to an extract, load, transform model (ELT). This allows the bulk of the processing to be done inside the database using a single programming language that we already have expertise in. The new model uses the following steps:
* Conversion/loading
* Transformation
* Tological correction and temporalization

Conversion and loading now happens at the same time and is implimented using GDAL/OGR. This removes dependancies on Python and Arcpy. Every source FRI has a single loading script that creates a single target table in PostgreSQL. If a source FRI has multiple files, the conversion/loading scripts append them all into the same target table. FRIs with shapefiles detailing the photo year have a second loading script for the photo year file. Every loading script adds a new attribute to the target table with the name of the source file. This is used when constructing the CAS_ID, a unique row identifier code.

## Supported file types
All conversion/loading scripts are provided a both .sh files and .bat files.

Currently supported FRI formats are:
* Geodatabase
* Shapefile
* ESRI Coverage

E00 files are not currently supported. FRIs of this format should converted into a supported format before loading.

## Projection

# Translation
* Describe loading tables used by the engine
* Describe how specs document is changing
## Error codes
