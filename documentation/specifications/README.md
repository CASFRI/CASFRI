# Common Attribute Schema (CAS) for Forest Resource Inventories across Canada  

Prepared by: John A. Cosco, Chief Inventory Forester, February 2011

Revised by: The CASFRI Project Team, March 31, 2021

## Table of contents
<a href="#Intro">Introduction</a>

<a href="#CAS">Common Attribute Schema</a>

<a href="#Error_codes">Error codes</a>

<a href="#HDR_attributes">HDR Attributes</a>

<a href="#CAS_attributes">CAS Attributes</a>

<a href="#LYR_attributes">LYR Attributes</a>

<a href="#NFL_attributes">NFL Attributes</a>

<a href="#DST_attributes">DST Attributes</a>

<a href="#ECO_attributes">ECO Attributes</a>

<a href="#GEO_attributes">GEO Attributes</a>

<a name=Intro></a>
## Introduction  

CASFRI (Common Attribute Schema for Forest Resource Inventories) is a standardised representation of the landcover attributes used in all contemporary Canadian forest resource inventory (FRI) datasets. Its specification focuses on attributes that are: 1) most commonly and consistently recorded among existing inventories and 2) most relevant to ecological modelling and forest management planning. In addition, an approximation of the Canadian Wetland Classification System is derived from FRI attributes, to the extent possible. This document accompanies version 5 of CASFRI and is based on the previous specification document written by Cosco in 2011<sup>1</sup>.

CASFRI version 5 incorporates 49 distinct source inventory datasets and more will be added as they become available. The original development team conducted an extensive review of previous and current inventory standards to tabulate their attributes and attribute codes. These are represented as translation rules between each inventory standard and the CASFRI data model. The translation of each inventory standard is encapsulated in a set of SQL functions and CSV tables that are processed using the <a href="https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework">PostgreSQL-Table-Translation-Framework</a>. The translation scripts have special rules for dealing with missing or invalid attributes values, or undefined attributes. The translation is otherwise lossless. The current version of CASFRI is stored as a partially normalized relational database within a spatial data warehouse managed by PostGIS, an open source Geographic Information System.

<sup>1</sup> Cosco, J. 2011. Common attribute schema (CAS) for forest inventories across Canada.

<a name=CAS></a>
## Common Attribute Schema  

The common attribute schema (CAS) is a comprehensive attribute classification suitable for ecological modelling, forest management planning, and state of the environment reporting. Its development requires the selection of vegetation cover attributes and the assignment of common codes for each attribute that are broad enough to capture all relevant existing forest inventory attributes. CAS attributes represent the most common attributes that are consistently recorded in forest inventories across Canada including: stand structure (layers), moisture regime, crown closure, species composition, height, age (origin), site class or site index, non-forested cover types, non-vegetated cover types, and disturbance history. CAS also includes two attributes of ecological interest: ecosite and wetland. These two attributes are not common to most forest inventories across Canada; however, these attributes are considered important for avian habitat models and can possibly be acquired from other sources or partially or wholly derived from other attributes.  

Development of the CAS attribute codes and rule sets for inventory attribute code conversion to CAS codes required an extensive review of previous and current inventory standards and specifications across Canada (Cosco 2011 <sup>1</sup>). Gillis and Leckie<sup>2</sup> provided a good starting point for review of previous inventory standards. More current and other inventory standards and documents are listed in the bibliography.

Based on the review, detailed tables were produced to summarize each inventory standard by province and territory. Two national parks, Wood Buffalo and Prince Albert are included. Conversion rule sets were then produced as part of the detailed tables to identify how each province or territory inventory attribute codes translate into CAS attribute codes. 

Although many CAS attributes have a one-to-one conversion, not all do; some are identified by an interval or class that has an upper and lower bound (lower bound is > and the upper bound is <). Interval coding for height, crown closure, age, and similar quantitative attributes is a unique feature of CAS. Crown closure, height, age, and disturbance extent use bounds to define an attribute class. For example, CASFRI captures crown closure as an interval providing two values, the lower bound and upper bound. In the Alberta Vegetation Inventory, crown closure is captured in four cover classes: A, B, C and D, while the British Columbia Vegetation Resource Inventory captures crown closure as values ranging from 1 to 100 to the nearest 1 percent. In CAS, an Alberta "B" - value would be represented as an interval: 31 for the lower bound and 50 for the upper bound. A British Columbia crown closure value of 36 would be represented as a CAS value of 36 for both the lower and upper bounds. All of the information contained in the original inventories is preserved and the attributes are not converted to a common resolution or set of values.  

Attributes for CAS are stored in seven attribute files to facilitate conversion and translation:  

1. Header (HDR) attributes - values assigned to all polygons based on provenance or reference information;  
2. CAS Base Polygon (CAS) attributes - values that identify a polygon and provide a link between the CAS polygon and the original inventory polygon;  
3. Forest-Level (LYR) attributes - values that pertain to the polygon for productive and non-productive forest land;  
4. Non-Forest Land (NFL) attributes - values that pertain to naturally non-vegetated, non-forest anthropogenic, and non-forest vegetated land;  
5. Disturbance history (DST) attributes - values that pertain to any disturbance that has occurred in a polygon including type, year, and extent;
6. Ecological specific (ECO) attributes - values representing ecosites and wetlands; and
7. Geometry attributes - values pertaining to polygon geometry.

<sup>1</sup> Cosco, J. 2011. Common attribute schema (CAS) for forest inventories across Canada.

<sup>2</sup> Gillis, M.D.; Leckie, D.G. 1993. Forest Inventory Mapping Procedures Across Canada. Petawawa National Forestry Institute, Information Report PI-X-114.  



Table 1. CASFRI schema.

| <sub>HDR</sub>               | <sub>CAS</sub>               | <sub>LYR</sub>                 | <sub>NFL</sub>                 | <sub>DST</sub>              | <sub>ECO</sub>              | <sub>GEO</sub>             |
| ---------------------------- | ---------------------------- | ------------------------------ | ------------------------------ | --------------------------- | --------------------------- | -------------------------- |
| <sub>INVENTORY_ID (PK)</sub> | <sub>CAS_ID (PK, FK)</sub>   | <sub>CAS_ID (PK, FK)</sub>     | <sub>CAS_ID (PK, FK)</sub>     | <sub>CAS_ID (PK, FK)</sub>  | <sub>CAS_ID (PK, FK)</sub>  | <sub>CAS_ID (PK, FK)</sub> |
| <sub>JURISDICTION</sub>      | <sub>INVENTORY_ID (FK)</sub> | <sub>LAYER (PK)</sub>          | <sub>LAYER (PK)</sub>          | <sub>LAYER (PK)</sub>       | <sub>LAYER</sub>            | <sub>GEOMETRY</sub>        |
| <sub>OWNER_TYPE</sub>        | <sub>ORIG_STAND_ID</sub>     | <sub>LAYER_RANK</sub>          | <sub>LAYER_RANK</sub>          | <sub>DIST_TYPE_1</sub>      | <sub>WETLAND_TYPE</sub>     |                            |
| <sub>OWNER_NAME</sub>        | <sub>STAND_STRUCTURE</sub>   | <sub>SOIL_MOIST_REG</sub>      | <sub>SOIL_MOIST_REG</sub>      | <sub>DIST_YEAR_1</sub>      | <sub>WET_VEG_COVER</sub>    |                            |
| <sub>STANDARD_TYPE</sub>     | <sub>NUM_OF_LAYERS</sub>     | <sub>STRUCTURE_PER</sub>       | <sub>STRUCTURE_PER</sub>       | <sub>DIST_EXT_UPPER_1</sub> | <sub>WET_LANDFORM_MOD</sub> |                            |
| <sub>STANDARD_VERSION</sub>  | <sub>MAP_SHEET_ID</sub>      | <sub>STRUCTURE_RANGE</sub>     | <sub>CROWN_CLOSURE_UPPER</sub> | <sub>DIST_EXT_LOWER_1</sub> | <sub>WET_LOCAL_MOD</sub>    |                            |
| <sub>STANDARD_ID</sub>       | <sub>CASFRI_AREA</sub>       | <sub>CROWN_CLOSURE_UPPER</sub> | <sub>CROWN_CLOSURE_LOWER</sub> | <sub>DIST_TYPE_2</sub>      | <sub>ECO_SITE</sub>         |                            |
| <sub>STANDARD_REVISION</sub> | <sub>CASFRI_PERIMETER</sub>  | <sub>CROWN_CLOSURE_LOWER</sub> |<sub> HEIGHT_UPPER</sub>        | <sub>DIST_YEAR_2</sub>      |                             |                            |
| <sub>DOCUMENTATION_TITLES</sub> | <sub>SRC_INV_AREA</sub>   | <sub>HEIGHT_UPPER</sub>        | <sub>HEIGHT_LOWER</sub>        | <sub>DIST_EXT_UPPER_2</sub> |                             |                            |
| <sub>SRC_DATA_FORMAT</sub>   | <sub>STAND_PHOTO_YEAR</sub>  | <sub>HEIGHT_LOWER</sub>        | <sub>NAT_NON_VEG</sub>         | <sub>DIST_EXT_LOWER_2</sub> |                             |                            |
| <sub>PRODUCTION_YEARS </sub> |                              | <sub>PRODUCTIVITY</sub>        | <sub>NON_FOR_ANTH</sub>        | <sub>DIST_TYPE_3</sub>      |                             |                            |
| <sub>PUBLICATION_DATE</sub>  |                              | <sub>PRODUCTIVITY_TYPE</sub>   | <sub>NON_FOR_VEG</sub>         | <sub>DIST_YEAR_3</sub>      |                             |                            |
| <sub>ACQUISITION_DATE</sub>  |                              | <sub>SPECIES_1 - 10</sub>      |                                | <sub>DIST_EXT_UPPER_3</sub> |                             |                            |
| <sub>ACQUISITION_TYPE</sub>  |                              | <sub>SPECIES_PER_1 - 10</sub>  |                                | <sub>DIST_EXT_LOWER_3</sub> |                             |                            |
| <sub>ACQUISITION_LINKS</sub> |                              | <sub>ORIGIN_UPPER</sub>        |                                |                             |                             |                            |
| <sub>CONTACT_INFO</sub>      |                              | <sub>ORIGIN_LOWER</sub>        |                                |                             |                             |                            |
| <sub>DATA_AVAILABILITY</sub> |                              | <sub>SITE_CLASS</sub>          |                                |                             |                             |                            |
| <sub>REDISTRIBUTION</sub>    |                              | <sub>SITE_INDEX</sub>          |                                |                             |                             |                            |
| <sub>PERMISSION</sub>        |                              |                                |                                |                             |                             |                            |
| <sub>LICENSE_AGREEMENT</sub> |                              |                                |                                |                             |                             |                            |
| <sub>PHOTO_YEAR_SRC</sub>    |                              |                                |                                |                             |                             |                            |
| <sub>PHOTO_YEAR_START</sub>  |                              |                                |                                |                             |                             |                            |
| <sub>PHOTO_YEAR_END</sub>    |                              |                                |                                |                             |                             |                            |

 
<a name=Error_codes></a>
## CASFRI Error Codes  

Error codes are needed during translation to report invalid or missing source inventory values. Error codes have been designed to match the CASFRI attribute type and to reflect the type of error that was encountered in the source inventory. Integer and double precision attributes will have error codes reported as integers (e.g. -9999) whereas text attributes will have errors reported as strings (e.g. 'INVALID_VALUE'). Possible error codes for each CASFRI attribute are listed in the attribute descriptions below.

Table 2. CASFRI error codes

| Class          | Code&nbsp;for&nbsp;attributes of&nbsp;type&nbsp;text | Code&nbsp;for&nbsp;attributes of&nbsp;type&nbsp;int&nbsp;and&nbsp;double | Description |
|:-------------- |:---------:|:------------:|:----------- |
| Missing&nbsp;values | EMPTY_STRING | -8888 | Missing value that is stored as an empty string (e.g. '' or '&#160;'). Source empty strings translated to int or double get assigned -8888 (NULL_VALUE) |
|                | NULL_VALUE        | -8888 | Missing value that is a true null value. |
|                | NOT_APPLICABLE    | -8887 | Target attribute not found in source inventory or attribute does not apply to this record (e.g. the source inventory does not record information for this attribute). |
|                | UNKNOWN_VALUE     | -8886 | Non-null source value indicating that the correct attribute value is not known (e.g. UK) or that the value should exist but can not be determined by the CASFRI translator (e.g. it is not possible to determine the correct value because the source dataset is incomplete). This is different from NOT_APPLICABLE where the value clearly does not exist. |
| Invalid&nbsp;values | OUT_OF_RANGE | -9999 | Value is outside the expected range of valid values (e.g. a percent value that is greater than 100. |
|                | NOT_IN_SET        | -9998 | Non-null value that is not a member of a set or list of expected values (e.g. a source value does not match a list of expected codes for an inventory). |
|                | INVALID_VALUE     | -9997 | Non-null invalid value (e.g. input value does not match expected format). |
|                | WRONG_TYPE        | -9995 | Value is of the wrong data type (e.g. a string or decimal value when an integer is expected). |
| Geometric&nbsp;error | INVALID_GEOMETRY  | -7779 | Invalid geometry in one or more polygons. |
|                | NO_INTERSECT      | -7778 | FRI geometry does not intersect any polygons (e.g. when running a spatial join with a photo year geometry). |
| Translation    | TRANSLATION_ERROR | -3333 | Generic translation error (reported for a failed translation). |



Four types of attribute have been identified in CASFRI and only specific codes are used for each type. They are:

| Attribute&nbsp;type | Description | Possible&nbsp;error&nbsp;code| 
|:-------------- |:--------- |:---------:|
| text | Arbitrary text values. e.g. the MAP_SHEET_ID attribute | NULL_VALUE, EMPTY_STRING, NOT_APPLICABLE, UNKNOWN_VALUE, INVALID_VALUE |
| code | Codified values. e.g. most text CASFRI attributes: SPECIES_X, DIST_TYPE_X and NFL types | NULL_VALUE, EMPTY_STRING, NOT_APPLICABLE, UNKNOWN_VALUE, NOT_IN_SET, INVALID_VALUE |
| number | Numeric values. e.g. LAYER, LAYER_RANK | NULL_VALUE, NOT_APPLICABLE, UNKNOWN_VALUE, INVALID_VALUE |
| range | Bounded numeric values. e.g. all HEIGHT, CROWN_CLOSURE and ORIGIN CASFRI attributes as well as SRC_INV_AREA, STAND_PHOTO_YEAR and SPECIES_PER_X| NULL_VALUE, NOT_APPLICABLE, UNKNOWN_VALUE, INVALID_VALUE, OUT_OF_RANGE, WRONG_TYPE |

* The main difference between the text and the number type is that empty numbers can only be NULLs (NULL_VALUE) whereas empty text values can be either NULLs (NULL_VALUE) or empty strings (EMPTY_STRING).
* The main difference between the text and the code type is that wrong codes are not in the set of acceptable values (NOT_IN_SET). In some cases, some codes, not fulfilling the source specification, might also translate to invalid (INVALID_VALUE).
* The main difference between the number and the range type is that range values can be out of range (OUT_OF_RANGE) while simple numbers cannot since they are not delimited.


<a name=HDR_attributes></a>
## HDR Attributes 

Header information is a primary element of CAS. Header information identifies the source data set including jurisdiction, ownership, tenure type, inventory type, inventory version, inventory start and finish date and the year of acquisition for CAS. These attributes are described below.


### INVENTORY_ID (PK)

The **INVENTORY_ID** attribute is a unique identifier that is assigned to each forest inventory. It is the concatenation of the **JURISDICTION** attribute plus an integer that increments with newer inventories within a jurisdiction.

| Values | Description |
| :----- | :-------------- |
| Alphanumeric string of two characters followed by two digits. e.g., BC08, AB06, AB16, NB01 | Two characters represent the province/territory, two digits increment for each source inventory available from the province/territory |


### JURISDICTION

The **JURISDICTION** attribute identifies the province, territory or national park from which the inventory data came.

| Values | 
| :-------------------------- |
| British Columbia |
| Alberta |
| Saskatchewan |
| Manitoba |
| Ontario |
| Quebec |
| Prince Edward Island |
| New Brunswick |
| Nova Scotia |
| Newfoundland and Labrador |
| Yukon Territory |
| Northwest Territories |
| Wood Buffalo National Park |
| Prince Albert National Park |


### OWNER_TYPE

The **OWNER_TYPE** attribute identifies who owns the inventory data. Ownership of the inventory can be federal, provincial, territory, industry, private, or First Nation.

| Values    | Description |
| :-------- | :-------------- |
| PROV_GOV  | Provincial Government |
| FED_GOV   | Federal Government |
| TERRITORY | Yukon Territory or Northwest Territories |
| FN        | First Nation |
| INDUSTRY  | Industry |
| PRIVATE   | Private |
| UNKNOWN_VALUE | Owner type is unknown |


### OWNER_NAME

The **OWNER_NAME** attribute identifies who owns the land covered by the inventory.

| Values   | Description   |
| :------- | :-------------- |
| Text     | Name of the owner |
| UNKNOWN_VALUE | Owner name is unknown |


### STANDARD_TYPE

The **STANDARD_TYPE** attribute identifies the kind of inventory that was produced for an area. The name, abbreviation, or acronym usually becomes the name used to identify an inventory. For example, Alberta had a series of successive forest inventories called Phase 1, Phase 2, and Phase 3. As inventories became more inclusive of attributes other than just the trees, they became known as vegetation inventories, for example, the Alberta Vegetation Inventory or AVI. The inventory type along with a version number usually identifies an inventory.

| Values         | Description        |
| :------------- | :-------------- |
| Alphanumeric   | Inventory name or type of inventory |
| UNKNOWN_VALUE  | Inventory name or type of inventory is unknown |


### STANDARD_VERSION

The **STANDARD_VERSION** attribute identifies the version number of the standards used to produce the inventory, usually across large land bases and for a relatively long period of time. The inventory type along with a version number usually identifies an inventory.

| Values         | Description        |
| :------------- | :-------------- |
|  Alphanumeric | The standard and version of the standard used to produce the inventory |
| UNKNOWN_VALUE  | Inventory name or type of inventory is unknown |


### STANDARD_ID

The **STANDARD_ID** attribute is the CASFRI unique identifier for the standard used to produce the inventory. If a standard is updated such that a new translation table is required, the **STANDARD_ID** is incremented. The numeric part of the standard id does not necessarily correspond to the version of the standard nor to a chronological order. It is simply a unique identifier.

| Values        | Description   |
| :------------ | :------------ |
| Alphanumeric | The CASFRI unique identifier of the inventory |

### STANDARD_REVISION

The **STANDARD_REVISION** attribute records whether any revisions have been made to the standard.

| Values        | Description        |
| :------------ | :------------ |
| Alphanumeric | List of revisions made to the standard used to produce the inventory |
| UNKNOWN_VALUE | Standard revision is unknown |


### DOCUMENTATION_TITLES

The **DOCUMENTATION_TITLES** attribute identifies titles of documents associated with the standard and the inventory data e.g., metadata, data dictionary, manual, etc.

| Values | Description |
| :----- | :-------------- |
| Text   | Titles of documents associated with the standard and the inventory data |
| UNKNOWN_VALUE | Titles of documents are unknown |


### SRC_DATA_FORMAT

The **SRC_DATA_FORMAT** attribute identifies the format of the inventory data e.g., geodatabase, shapefile, e00 file. When many formats are used, they are separated by a comma.

| Values           | Description      |
| :--------------- | :--------------- |
| ESRI_GEODATABASE | ESRI file geodatabase       |
| SHAPEFILE        | ESRI shapefile              |
| ESRI_E00         | ESRI E00 transfer files     |
| ESRI_COVERAGE    | ESRI Coverage files         |
| ACCESS_DATABASE  | Microsoft Access database   |
| RASTER_TIFF      | TIFF raster file            |
| UNKNOWN_VALUE    | Format of the inventory is unknown |


### PRODUCTION_YEARS

The **PRODUCTION_YEARS** attribute identifies the year or the year interval (e.g. 1998-2003) during which the inventory was produced.

| Values | Description |
| :----- | :-------------- |
| Year   | Year or year interval during which the inventory was produced |
| UNKNOWN_VALUE | Year of production is unknown |


### PUBLICATION_DATE

The **PUBLICATION_DATE**  attribute identifies the date at which the inventory data was published by the producer on the web or internally.

| Values | Description |
| :----- | :-------------- |
| Date   | Date at which the inventory data was published  |
| UNKNOWN_VALUE | Publication date is unknown |

### ACQUISITION_DATE

The **ACQUISITION_DATE** attribute identifies the date at which the inventory data was acquired by the CASFRI project.

| Values | Description |
| :----- | :-------------- |
| Date   | Date at which the inventory data was acquired  |
| UNKNOWN_VALUE | Acquisition date is unknown |


### ACQUISITION_TYPE

The **ACQUISITION_TYPE** attribute identifies the mean by which the inventory data was acquired. This is mainly to identify inventories that were publicly available (online or by other means) when they were acquired by the CASFRI project.

| Values | Description |
| :----- | :-------------- |
| DVD   | Inventory data was acquired on DVD support |
| FTP   | Inventory data was acquired through an FTP site. Link to the FTP site should be provided in the ACQUISITION_LINKS field |
| HTTP   | Inventory data was acquired through a HTTP site. Link to the HTTP site should be provided in the ACQUISITION_LINKS field |
| TEMPORARY_FTP | Inventory data was acquired through a temporary FTP link that is not available anymore |
| TEMPORARY_HTTP | Inventory data was acquired through a temporary HTTP link that is not available anymore |
| EMAIL | Inventory data was acquired through an email exchange with the producer |
| UNKNOWN_VALUE   | Acquisition type is unknown |

### ACQUISITION_LINKS

The **ACQUISITION_LINKS** attribute identifies the HTTP or FTP addresses (there can be many) from which the inventory was downloaded. Temporary addresses are not provided.

| Values | Description |
| :----- | :-------------- |
| Text   | HTTP or FTP addresses (there can be many) from which the inventory was downloaded |
| UNKNOWN_VALUE | Acquisition links are unknown |
| NOT_APPLICABLE | Attribute does not apply to this record. (.g. Acquisition type is not FTP, nor HTTP) |

### CONTACT_INFO

The **CONTACT_INFO** attribute identifies the contact information (name, address, phone, email, etc.) associated with the inventory data.

| Values | Description |
| :----- | :-------------- |
| Text   | Contact information associated with the inventory data   |
| UNKNOWN_VALUE | No contact info was provided |


### DATA_AVAILABILITY

The **DATA_AVAILABILITY** attribute identifies the type of access to the inventory data e.g., direct contact or open access.

| Values | Description |
| :----- | :-------------- |
| DIRECT_CONTACT   | The inventory was acquired through direct contact with an individual part of the production process. The name of this person should be listed in the CONTACT_INFO field |
| OPEN_ACCESS      | The inventory is openly available on the web. Links to the dataset should be provided in the ACQUISITION_LINKS field |
| ADMINISTRATVE_PROCESS | The inventory was acquired through a standardized administrative process |
| UNKNOWN_VALUE | Availability of the inventory is unknown |


### REDISTRIBUTION

The **REDISTRIBUTION** attribute identifies the conditions under which the inventory data can be redistributed to other parties.

| Values | Description |
| :----- | :-------------- |
| OPEN_WITH_ACKNOWLEDGMENT  | Dataset can be redistributed if the source is properly acknowledged |
| OPEN_FOR_BEACON_AND_BAM_PROJECTS  | Dataset can be used only for BEACON and BAM projects |
| REQUIRES_AGREEMENT  | Dataset can be redistributed only following a specific agreement with the provider |
| NOT_SPECIFIED  | The dataset redistribution conditions are not specified |
| UNKNOWN_VALUE  | The dataset redistribution conditions are unknown |


### PERMISSION

The **PERMISSION** attribute identifies the degree of permission to which the data can be used i.e., whether the use of the data is unrestricted, restricted or limited.

| Values       | Description |
| :----------- | :-------------- |
| UNRESTRICTED | Use of the inventory data is unrestricted |
| RESTRICTED   | Use of the inventory data has restrictions |
| LIMITED      | Use of the data has limitations |
| NOT_SPECIFIED | Use of the data is not specified |
| UNKNOWN_VALUE | Use of the data is unknown |


### LICENSE_AGREEMENT

The **LICENSE_AGREEMENT** attribute identifies the type of license associated with the inventory data.

| Values | Description |
| :----- | :-------------- |
| Text   | Type of license associated with the inventory data |


### PHOTO_YEAR_SRC

The **PHOTO_YEAR_SRC** attribute identifies the source data type that is used to define the photo year i.e., the year in which the inventory was considered initiated and completed.

| Values           | Description |
| :-------------   | :-------------- |
| SPATIAL_JOIN     | Photo year is stored as polygons in a separate file that has to be spatially joined to the inventory |
| VALUE_PER_STAND  | Photo year is provided as an attribute in the source inventory |
| RELATIONAL_JOIN  | Photo year is stored in a separate table that has to be joined to the inventory |
| GLOBAL_INVENTORY | Photo year is provided as a single value that applies to the entire inventory |
| UNKNOWN_VALUE    | Photo year source is unknown |


### PHOTO_YEAR_START

The **PHOTO_YEAR_START** attribute identifies the year in which the inventory was considered initiated. An inventory can take several years to complete; therefore, start and end dates are included to identify the interval for when the inventory was completed.

| Values      | Description |
| :---------- | :-------------- |
| 1900&#8209;2020 | Earliest year of aerial photo acquisition |
| -8886 | Earliest year of aerial photo acquisition is unknown |


### PHOTO_YEAR_END

The **PHOTO_YEAR_END** attribute identifies the year in which the inventory was considered completed. An inventory can take several years to complete; therefore, start and end dates are included to identify the interval for when the inventory was completed. 

| Values      | Description |
| :---------- | :-------------- |
| 1900&#8209;2020 | Latest year of aerial photo acquisition |
| -8886 | Latest year of aerial photo acquisition is unknown |


<a name=CAS_attributes></a>
## CAS Attributes

The CAS base polygon data provides polygon specific information and links the original inventory polygon ID to the CAS ID. Identification attributes include original stand ID, CAS Stand ID, Mapsheet ID, and Inventory ID. Polygon attributes include stand structure, polygon area and polygon perimeter. Inventory Reference Year, Photo Year, and Administrative Unit are additional identifiers.

<a name=CAS_ID></a>
### CAS_ID (PK)

The **CAS_ID** attribute is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06 (4 characters)
- Source filename i.e., name of shapefile or geodatabase (15 characters)
- Primary id - Polygon ID linking back to the source polygon, often Map Sheet ID or similar (10 characters)
- Secondary id - Polygon ID linking back to the source polygon, often a unique polygon if from the source data (10 characters)
- Cas id - usually ogc_fid which is added after loading and ensures all rows in the database have a unique identifier (7 characters)

In some inventories the source polygons have a unique identifier with a length of up to 20 characters. In these cases, the unique identifier can be split and used as the Primary id and Secondary id to reconstruct a unique identifier linking back to the source polygon. This happens in QC and ON for example.

| Values               | Description |
| :------------------- | :---------- |
| Alphanumeric string |  CAS stand identification - unique string for each polygon within CAS |

### INVENTORY_ID (FK)

The **INVENTORY_ID** attribute is a unique identifier that is assigned to each forest inventory. It is the concatenation of the **JURISDICTION** attribute plus an integer that increments for newly acquired inventories within a jurisdiction. Note that higher integer values do not necessarily indicate more recent inventories.

| Values | Description |
| :----- | :-------------- |
| Alphanumeric string of two characters followed by two digits. e.g., BC08, AB06, AB16, NB01 | Two characters represent the province/territory, two digits increment for each source inventory available from the province/territory |


### ORIG_STAND_ID

The **ORIG_STAND_ID** attribute is the unique number for each polygon within the original inventory.

| Values       | Description |
| :----------- | :-------------- |
| Integer      | Unique number for each polygon within the original inventory |


### STAND_STRUCTURE

The **STAND_STRUCTURE** attribute identifies the physical arrangement or vertical pattern of organization of the vegetation within a polygon.

A SINGLE_LAYERED stand has stem heights that do not vary significantly and the vegetation has only one main canopy layer.

A MULTI_LAYERED stand can have several distinct forest layers and each layer is significant, has a distinct height difference, and is evenly distributed. Generally, the layers are intermixed and when viewed vertically, one layer is above the other. We do not consider NFL layers to part of a MULTI-LAYERED stand structure in CASFRI due to the wide range of potential NFL types. For this reason, any polygon labelled MULTI-LAYERED must have at least 2 LYR layers.

COMPLEX layered stands exhibit a high variation in tree heights. There is no single definitive forested layer as nearly all height classes (and frequently ages) are represented in the stand. The height is chosen from a stand midpoint usually followed by a height range. COMPLEX stands are usually reported as a single LYR layer but in some cases multiple LYR layers are reported in the source data.

HORIZONTAL structure represents vegetated or non-vegetated land with two or more homogeneous strata located within other distinctly different homogeneous strata within the same polygon, but the included strata are too small to map separately based on minimum polygon size rules. This attribute is also used to identify multi-label polygons identified in biophysical inventories such as Wood Buffalo National Park and Prince Albert National Park. In Prince Albert National Park, there are 64 polygons with both horizontal and vertical structure. Since the schema cannot support both horizontal and vertical structure in a single polygon, the understory information for these were dropped.  

If COMPLEX or HORIZONTAL stand structure is assigned in the source data, it is assigned the same value in CASFRI. SINGLE_LAYERED and MULTI_LAYERED stand structure are assigned values based on the number of canopy layers identified in the LYR table. If there is one layer, SINGLE_LAYERED is assigned, otherwise MULTI_LAYERED.

| Values | Description |
| :------------------- | :-------------- |
| SINGLE_LAYERED       | Vegetation within a polygon where the heights do not vary significantly |
| MULTI_LAYERED        | Two or more distinct layers of vegetation occur. Each layer is significant, clearly observable                          and evenly distributed. Each layer is assigned an independent description |
| COMPLEX              | Stands exhibit a high variation of heights with no single defined canopy layer |
| HORIZONTAL           | Two or more significant strata within the same polygon; at least one of the strata is too small                          to delineate as a separate polygon |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record (e.g. polygon does not have canopy information) |


### NUM_OF_LAYERS  

The **NUM_OF_LAYERS** attribute identifies the number of LYR and NFL layers associated with the stand. Note that NUM_OF_LAYERS is independent from STAND_STRUCTURE since STAND_STRUCTURE is only based on the number of canopy layers in the LYR table. STAND_STRUCTURE could therefore be SINGLE_LAYERED, even when NUM_OF_LAYERS is > 1.

| Values        | Description |
| :------------ | :----- |
| 1&#8209;9     | Number of vegetation or non-vegetation layers assigned to a particular polygon. A maximum of 9 layers can be identified |
| -8886         | Number of layers is unknown (e.g. there is disturbance info, but no reported layers) |


### MAP_SHEET_ID

The **MAP_SHEET_ID** attribute identifies the map sheet to which the polygon in the source inventory belongs.

| Values         | Description        |
| :------------  | :------------ |
| Alphanumeric  | Map sheet to which belong the polygon in the source inventory |
| NULL_VALUE     | Source value is null |
| NOT_APPLICABLE | Attribute does not apply to this record |


### CASFRI_AREA

The **CASFRI_AREA** attribute measures the area of each polygon in hectares (ha). It is measured to 2 decimal places by PostGIS.

| Values        | Description |
| :-----        | :------------ |
| >=0.01        | Polygon (stand) area in hectares (ha) |


### CASFRI_PERIMETER

The **CASFRI_PERIMETER** attribute measures the perimeter of each polygon in metres (m). It is measured to 2 decimal places. This attribute is calculated by PostGIS.

| Values | Description |
| :----- | :-------------- |
| >=0.01 | Polygon (stand) perimeter in metres (m) |


### SRC_INV_AREA

The **SRC_INV_AREA** attribute measures the area of each polygon in hectares (ha). It is calculated by the data providers and may contain missing values. It is reported in CASFRI to 2 decimal places.

| Values | Description        |
| :----- | :------------ |
| >=0.01 | Polygon (stand) area in hectares (ha) |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


### STAND_PHOTO_YEAR

The **STAND_PHOTO_YEAR** attribute identifies the year in which the aerial photography program was conducted for a particular polygon. This is in contrast to photo_year_start and photo_year_end which identify the interval for when the inventory was completed.

| Values      | Description      |
| :---------- | :---------- |
| 1900&#8209;2020 | Identifies the year in which the aerial photography program was conducted |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |

<a name=LYR_attributes></a>
## LYR Attributes

Forest layer attributes.


### CAS_ID (PK, FK)

See <a href="#CAS_ID">CAS_ID</a> in the CAS table.


<a name=LAYER></a>
### LAYER (PK)

Identifies the layer number of the LYR or NFL row within a particular polygon. A maximum of 9 layers can be identified. No two LYR or NFL layers can have the same value within the same polygon.

LAYER is related to STAND_STRUCTURE and NUM_OF_LAYERS and is recorded for all LYR and NFL records. In stands with SINGLE_LAYERED, MULTI_LAYERED or COMPLEX structure, Layer 1 will always be the tallest (uppermost) LYR layer in the stand sequentially followed by layer 2 and so on. All NFL layers are reported below the LYR layers, shrub layers are assumed to be above herb layers in cases where both are available. Any non-vegetated NFL layers are reported last (i.e. highest layer value). Lower layers are assigned the appropriate value based on the presence of higher layers, so if no canopy information exists, an NFL layer will get a value of 1. In stands with HORIZONTAL structure, the LAYER values represent the different horizontal sub-components of the polygon. The maximum number of layers recognized is nine. 

| Values   | Description   |
| :------- | :------- |
| 1&#8209;9 | Layer number of a vegetation or non-vegetation layer within a particular polygon |

Notes:

- LAYER is a CASFRI derived attribute that is computed based on the presence or absence of values for different layers. This is why it cannot be assigned an error code. It does not have any direct relation to any values in the source data.
- The LYR and NFL tables define layers as described above. The LAYER attribute in the DST is always used to associate a DST record with a LYR or NFL layer. DST layer should never have values that don't match an existing LYR or NFL record.
- ECO LAYER is only used in Parks Canada datasets with horizontal structure.

<a name=LAYER_RANK></a>
### LAYER_RANK

Layer rank is an attribute related to LAYER and refers to the layer importance for forest management planning, operational, or silvicultural purposes. Layer rank is always copied from the source data when available. If no rank is assigned in the source data, CASFRI reports an error code. 

Some inventories (AB, NB, NT, ON, SK SKVI, and NS) do not have an explicit rank attribute, but do have attributes repeated for an overstory (or primary) and understory (or secondary) layer. SK SFVI has attributes repeated for three forest layers. In these cases, we assign the overstory (primary) values to LAYER_RANK 1, the understory (secondary) values to LAYER_RANK 2 etc. The overstory (or primary) layer is not always the tallest, so LAYER and LAYER_RANK in these inventories are not always the same.

| Values | Description |
| :----- | :----- |
| 1&#8209;9  | Layer Rank - value assigned sequentially to layer of importance. Rank 1 is the most important layer followed by Rank 2, etc. |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


<a name=STRUCTURE_PER></a>
### STRUCTURE_PER

The **STRUCTURE_PER** attribute identifies the percentage of stand area for HORIZONTAL structured polygons. It is assigned in 10% increments, attributed to each stratum within the entire polygon and must add up to 100%. Any number of horizontal strata can be described per horizontal polygon.

| Values                             | Description  |
| :--------------------------------- | :------ |
| 10, 20, 30, 40, 50, 60, 70, 80, 90 | When **STAND_STRUCTURE** = "HORIZONTAL", used with horizontal stands to identify the percentage, in 10% increments, of strata within the polygon. Must add up to 100%. |
| 100                                | When **STAND_STRUCTURE** = "SINGLE_LAYERED", "MULTI_LAYERED", "COMPLEX", value = 100 i.e., when there is no horizontal structure |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


### STRUCTURE_RANGE

The **STRUCTURE_RANGE** attribute identifies the height range (m) around stand midpoint for COMPLEX structured polygons. For example, height range 6 means that the range around the midpoint height is 3 meters above and 3 meters below the midpoint.

| Values | Description |
| :----- | :----- |
| 1&#8209;99 | When **STAND_STRUCTURE** = "COMPLEX", measures the height range (m) around the midpoint height of the stand. It is calculated as the difference between the mean or median heights of the upper and lower layers within the complex stand |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record  (e.g. when **STAND_STRUCTURE** = "SINGLE_LAYERED", "MULTI_LAYERED", or "HORIZONTAL") |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |

Notes:

- Applies to the following inventories: AB, NT, SK (SFVI), and YT (YVI02).


<a name=SOIL_MOIST_REG></a>
### SOIL_MOIST_REG  

The **SOIL_MOIST_REG** attribute identifies the available moisture supply for plant growth over a period of several years. Soil moisture regime is influenced by precipitation, evapotranspiration, topography, insolation, ground water, and soil texture. The CAS soil moisture regime code represents the similarity of classes across Canada.

| Value          | Description |
| :------------- | :----- |
| DRY            | Soil retains moisture for a negligible period following precipitation with very rapid drained substratum |
| MESIC          | Soils retains moisture for moderately short to short periods following precipitation with moderately well drained substratum |
| MOIST          | Soil retains abundant to substantial moisture for much of the growing season with slow soil infiltration |
| WET            | Poorly drained to flooded where the water table is usually at or near the surface, or the land is covered by shallow water |
| AQUATIC        | Permanent deep-water areas characterized by hydrophytic vegetation (emergent) that grows in or at the surface of water |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record |

Notes: SOIL_MOIST_REG is usually a polygon level attribute and is therefore the same for any LYR and NFL records. AB and NT however report soil moisture separately for the overstory and understory layers which can lead to layer 1 and 2 having different values.


<a name=CROWN_CLOSURE></a>
### CROWN_CLOSURE_UPPER, CROWN_CLOSURE_LOWER 

The **CROWN_CLOSURE_UPPER** and **CROWN_CLOSURE_LOWER** attributes estimate the percentage of ground area covered by vertically projected tree crowns, shrubs, or herbaceous cover. Crown closure is usually estimated independently for each layer. Crown closure is commonly represented by classes and differs across Canada; therefore, CASFRI recognizes an upper and lower percentage bound for each class.

| Values    | Description |
| :-------- | :-------------- |
| 0&#8209;100   | Upper and lower bound of a crown closure class |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record (e.g. not a forested polygon) |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


<a name=HEIGHT></a>
### HEIGHT_UPPER, HEIGHT_LOWER

The **HEIGHT_UPPER** and **HEIGHT_LOWER** attributes are based on an average height of leading species of dominant and co-dominant heights of the vegetation layer and can represent trees, shrubs, or herbaceous cover. Height can be represented by actual values or by height class and its representation is variable across Canada; therefore, CAS will use upper and lower bounds to represent height.

| Values    | Description |
| :-------- | :-------------- |
| &gt;0, &#8804;100   | Upper and lower bound of a height class |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record (e.g. not a forested polygon) |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


Note:
* In BC10, separate heights are assigned for the dominant and co-dominant species in a layer. A weighted average is therefore computed based on the dominant and co-dominant heights, weighted by the percent cover of the dominant and co-dominant species in the layer.


### PRODUCTIVITY
The **PRODUCTIVITY** attribute classifies forested lands into either productive or unproductive for the purpose of forestry operations. This attribute is translated from source information where it exists. Not all inventories classify productivity. Some inventories have a source value that indicates PRODUCTIVE_FOREST, other inventories classify non-productive types in which case NON_PRODUCTIVE_FOREST is assigned and the non-productive code is translated as **PRODUCTIVITY_TYPE**. If any **PRODUCTIVITY** or **PRODUCTIVITY_TYPE** information is available in the source data, unknown rows are assigned UNKNOWN_VALUE. If no information is available in the source data, NOT_APPLICABLE is assigned.

| Values | Description |
| :----- | :------------ |
| NON_PRODUCTIVE_FOREST  | Forested lands that are not capable of producing trees for forest operations. Includes areas that can produce timber, but cannot be harvested for various reasons |
| PRODUCTIVE_FOREST      | Forested lands capable of producing trees for forest operations |
| UNKNOWN_VALUE          | Source value should exist but is unknown |
| NOT_APPLICABLE         | Attribute does not apply to this record |


### PRODUCTIVITY_TYPE

The **PRODUCTIVITY_TYPE** attribute classifies forested lands by their productive or unproductive class, as assigned in the source data. **PRODUCTIVITY_TYPE** is a sub-class of **PRODUCTIVITY**, but both values may not always occur together. For example, a forested polygon could be labelled as non-productive but a type might not always be assigned. Generally, if a non-productive type is assigned, **PRODUCTIVITY** is reported as NON_PRODUCTIVE_FOREST. One exception is if there is another source attribute that directly assigns **PRODUCTIVITY** as is the case in BC which has separate attributes for classifying the harvestable land base, and for labelling non-productive types (note that this can actually lead to confusing assignments where polygons are labelled as non-productive in one attribute, but included in the harvestable land base in another attribute). Generally, HARVESTABLE is assigned along with PRODUCTIVE_FOREST; and PROTECTION_FOREST, TREED_MUSKEG, TREED_ROCK, ALPINE_FOREST, SCRUB_SHRUB and ALDER are assigned along with NON_PRODUCTIVE_FOREST.

This attribute is translated from source information where it exists. Since this attribute only translates information available in the source inventories, there will be unproductive alpine forests identified for BC, but in AB this same forest type will be labelled UNKNOWN_VALUE because the AB source data does not classify it. If any **PRODUCTIVITY** or **PRODUCTIVITY_TYPE** information is available in the source data, unknown rows are assigned UNKNOWN_VALUE. If no information is available in the source data, NOT_APPLICABLE is assigned.

| Values | Description |
| :----- | :------------ |
| HARVESTABLE            | Identified as harvestable by the source jurisdiction |
| PROTECTION_FOREST      | Areas with adequate timber growth that cannot be harvested due to site risk (steep slopes, small islands etc.), or formal protection (recreation sites, shelter belts, small islands, ecological protection) |
| TREED_MUSKEG           | Treed wetland sites |
| TREED_ROCK             | Treed rock sites |
| ALPINE_FOREST          | High elevation forest usually above 1800 m |
| SCRUB_SHRUB            | Various types of scrub and shrub sites |
| ALDER                  | Sites dominated by alder (or willow, or birch), usually associated with water or wetlands |
| UNKNOWN_VALUE          | Source value should exist but is unknown |
| NOT_APPLICABLE         | Attribute does not apply to this record |


### SPECIES_1 - SPECIES_10

The **SPECIES_1** to **SPECIES_10** attributes identify the species composing a forested stand.

Species composition is the percentage of each tree species represented within a forested polygon by layer. In the source data, species are listed in descending order according to their contribution based on crown closure, basal area, or volume depending on the province or territory. In CASFRI we order species by percent value from largest to smallest. A total of ten species can be used per layer. For the first species for example, CASFRI has a SPECIES_1 attribute to record the species name, and a SPECIES_PER_1 attribute to record the percent cover. Species percent will capture percent estimates to the nearest percent; however, most inventories across Canada describe species to the nearest 10%. Species composition for each forest stand and layer must sum to 100%.  

CASFRI v5 adopts the National Forest Inventory species codes for Canada (https://nfi.nfis.org/resources/groundplot/4a-GPDataDictionary5.1.7.pdf). A full list of the CASFRI species codes can be seen in the [species_codes_mapping](https://github.com/edwardsmarc/CASFRI/blob/master/translation/tables/species_code_mapping.csv) table.

| Values         | Description |
| :------------  | :-------------- |
| Species codes  | See casfri_species_codes in [species_codes_mapping](https://github.com/edwardsmarc/CASFRI/blob/master/translation/tables/species_code_mapping.csv) |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record |


### SPECIES_PER_1 - SPECIES_PER_10

The **SPECIES_PER_1** to **SPECIES_PER_10** attributes identify the percentage of each species composing a forested stand. See SPECIES_1 - SPECIES_10 above.

| Values    | Description |
| :-------- | :-------------- |
| 1&#8209;100   | Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100% |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


### ORIGIN_UPPER, ORIGIN_LOWER

The **ORIGIN_UPPER** and **ORIGIN_LOWER** attributes identify the average initiation year of codominant and dominant trees of the leading species within each layer of a polygon. Origin is determined either to the nearest year or decade. An upper and lower bound is used to identify CASFRI origin. Some inventories include origin explicitly, and in some cases we calculate it using photo year and age.

| Values    | Description |
| :-------- | :-------------- |
| 1000&#8209;2020  | Upper and lower bound of an origin class |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


### SITE_CLASS

The **SITE_CLASS** attribute estimates the potential productivity of land for tree growth. Site class reflects tree growth response to soils, topography, climate, elevation, and moisture availability. Site class is copied from the source data when available.

| Values         | Description |
| :-----         | :-------------- |
| UNPRODUCTIVE   | Cannot support a commercial forest |
| POOR           | Poor tree growth based on age height relationship |
| MEDIUM         | Medium tree growth based on age height relationship |
| GOOD           | Good tree growth based on age height relationship |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record |


### SITE_INDEX

The **SITE_CLASS** attribute estimates site productivity for tree growth. It is derived for all forested polygons based on leading species, height, and stand age based on a specified reference age. Site index is not available for most inventories across Canada, it is copied from the source data when available.

| Values    | Description |
| :-------- | :-------------- |
| 0&#8209;99    | Estimate of site productivity for tree growth based on a specified reference age |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


<a name=NFL_attributes></a>
## NFL Attributes

Non-forested attributes.


### CAS_ID (PK, FK)

See <a href="#CAS_ID">CAS_ID</a> in the CAS table.


### LAYER (PK)

See <a href="#LAYER">LAYER</a> in the LYR table.


### LAYER_RANK  
See <a href="#LAYER_RANK">LAYER_RANK</a> in the LYR table.


### SOIL_MOIST_REG

See <a href="#SOIL_MOIST_REG">SOIL_MOIST_REG</a> in the LYR table.


### STRUCTURE_PER

See <a href="#STRUCTURE_PER">STRUCTURE_PER</a> in the LYR table.


### CROWN_CLOSURE_UPPER, CROWN_CLOSURE_LOWER

See <a href="#CROWN_CLOSURE ">CROWN_CLOSURE</a> in the LYR table.

Crown closure defined in the NFL table must be a value explicitly assigned to the NFL layer in the source data.


### HEIGHT_UPPER, HEIGHT_LOWER

See <a href="#HEIGHT ">HEIGHT</a> in the LYR table.

Height defined in the NFL table must be a value explicitly assigned to the NFL layer in the source data.


### NAT_NON_VEG  

The **NAT_NON_VEG** attribute identifies the type of natural land with no vegetation cover. The maximum vegetation cover varies across Canada but is usually less than six or ten percent.

| Values         | Description |
| :------------- | :----- |
| ALPINE         | High elevation exposed land |
| BEACH          | Sand areas adjacent to water bodies |
| EXPOSED_LAND   | Other non-vegetated land |
| FLOOD          | Recent flooding including beaver ponds |
| ISLAND         | Vegetated or non-vegetated islands |
| LAKE           | Ponds, lakes or reservoirs |
| OCEAN          | Coastal waters |
| RIVER          | Double-lined watercourse |
| ROCK_RUBBLE    | Bed rock or talus or boulder field |
| SAND           | Sand dunes, sand hills, non-recent water sediments |
| SLIDE          | Recent slumps or slides with exposed earth |
| SNOW_ICE       | Ice fields, glaciers, permanent snow |
| TIDAL_FLATS    | Non-vegetated feature associated with oceans |
| WATER_SEDIMENT | Recent sand and gravel bars |
| WATERBODY      | Generic waterbody |
| OTHER          | Any other source inventory land type not supported by CASFRI |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record |


### NON_FOR_ANTH

The **NON_FOR_ANTH** attribute identifies the type of non-forested anthropogenic areas influenced or created by humans. These sites may or may not be vegetated.   

| Values         | Description |
| :------------- | :----- |
| BORROW_PIT     | Associated with facility/infrastructure |
| CULTIVATED     | Pasture, crops, orchards, plantations |
| FACILITY_INFRASTRUCTURE | Transportation, transmission, pipeline |
| INDUSTRIAL     | Industrial sites |
| LAGOON         | Water filled, includes treatment sites |
| SETTLEMENT     | Cities, towns, ribbon development |
| OTHER          | Any other source inventory site type not supported by CASFRI |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record |


### NON_FOR_VEG  

The **NON_FOR_VEG** attribute identifies the type of non-forested vegetated areas including all natural lands that have vegetation cover with usually less than 10% tree cover. These cover types can be stand alone or used in multi-layer situations.   

| Values         | Description |
| :------------- | :----- |
| ALPINE_FOREST  | Non productive, high altitude forest |
| BRYOID         | Mosses and lichens |
| FORBS          | Herbaceous plants other than graminoids |
| GRAMINOIDS     | Grasses, sedges, rushes, and reeds |
| HERBS          | Undistinguishable family of herbs |
| LOW_SHRUB      | Shrub lands with shrubs < 2 meters tall |
| OPEN_MUSKEG    | Wetlands with less than 10% tree cover (<25% in NS) |
| TALL_SHRUB     | Shrub lands with shrubs > 2 meters tall |
| TUNDRA         | Flat treeless plains |
| OTHER          | Any other source inventory cover type not supported by CASFRI  |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is clearly invalid |
| NOT_APPLICABLE | Attribute does not apply to this record |


<a name=DST_attributes></a>
## DST Attributes

### CAS_ID (PK, FK)

See <a href="#CAS_ID">CAS_ID</a> in the CAS table.


### LAYER (PK)

The **LAYER** attribute identifies the specific layer to which the disturbance is linked in the source data. It can be assigned to the corresponding LYR or NFL layer in CASFRI (See <a href="#LAYER">LYR table LAYER.</a>). When disturbances are not explicitly linked to a specific layer or when the source inventory arbitrarily assigns all disturbances to layer 1, -8886 (UNKNOWN_VALUE) is assigned to LAYER since the correct layer associated with the disturbance is unknown.

| Values   | Description |
| :------- | :------- |
| 1&#8209;9| Identifies the layer number that the disturbance is associated with |
| -8886 | Source value should exist but is unknown |


### DIST_TYPE_1 - DIST_TYPE_3

The **DIST_TYPE_1** to **DIST_TYPE_3** attributes identify the type of disturbance history that has occurred or is occurring within the polygon. The type of disturbance, the extent of the disturbance and the disturbance year, if known, may be recorded. The disturbance may be natural or human caused. Up to three disturbance events can be recorded with the oldest event described first. Silviculture treatments have been grouped into one category and include any silviculture treatment or treatments recorded for a polygon.  

| Values         | Description |
| :------------- | :-------------- |
| BURN           | Wildfires or escape fires |
| CUT            | Logging with known extent |
| DEAD_UNKNOWN   | Dead or dying trees, cause unknown |
| DISEASE        | Root, stem or branch diseases |
| FLOOD          | Permanent flooding from blockage or damming |
| INSECT         | Root, bark, leader or defoliation insects |
| PARTIAL_CUT    | Portion of forest has been removed, extent known or unknown |
| SILVICULTURE_TREATMENT | Planting, thinning, seed tree |
| SLIDE          | Damage from avalanche, slump, earth or rock slides |
| WEATHER        | Ice, frost, red belt |
| WINDFALL       | Blow down |
| OTHER          | Other type of damage |
| NULL_VALUE     | Source value is NULL |
| EMPTY_STRING   | Source value is a non-NULL empty string |
| UNKNOWN_VALUE  | Source value should exist but is unknown |
| NOT_IN_SET     | Source value is not in the set of expected values for the source inventory |
| INVALID_VALUE  | Source value is not in an acceptable format |
| NOT_APPLICABLE | Attribute does not apply to this record |

Note:
* In some cases disturbance types can occur without years, and years can occur without disturbance types. Any disturbances with unknown years are reported as the oldest disturbance, and any missing disturbance types are reported as UNKNOWN_VALUE.


### DIST_YEAR_1 - DIST_YEAR_3  

The **DIST_YEAR_1** to **DIST_YEAR_3** attributes identify the year a disturbance event occurred. The disturbance year may be unknown. Three disturbance years can be identified, one for each disturbance event.    

| Values       | Description |
| :----------- | :---------- |
|  1000&#8209;2020 | Disturbance Year - year that a disturbance event occurred |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


### DIST_EXT_UPPER_1 - DIST_EXT_UPPER_3, DIST_EXT_LOWER_1 - DIST_EXT_LOWER_3

The **DIST_EXT_UPPER_1** to **DIST_EXT_UPPER_3** and the **DIST_EXT_LOWER_1** to **DIST_EXT_LOWER_3** attributes provide an estimate of the proportion of the polygon that has been affected by the associated disturbance. Extent codes and classes vary across Canada where they occur; therefore, CAS identifies upper and lower bounds for this category. Three disturbance extents can be identified, one for each disturbance event. Usually, extents are reported in increments of 10%, but YT03 uses 5% increments so the lowest possible DIST_EXT_UPPER value is 5%.  

| Values | Description |
| :--------------------------------------------------------------------------------------------------------------- | :-------------- |
| 5&#8209;100 | Upper bound of extent class |
| 1&#8209;95 | Lower bound of extent class |
| -8886 | Source value should exist but is unknown |
| -8887 | Attribute does not apply to this record |
| -8888 | Source value is NULL |
| -9995 | Source value is in a wrong type |
| -9997 | Source value is invalid |
| -9999 | Source value is outside expected range |


<a name=ECO_attributes></a>
## ECO Attributes

Ecological attributes are generally not included or are incompletely recorded in typical forest inventories across Canada. Two attributes have been included for CAS: ecosite and wetland. These attributes are to be translated or derived for CAS from other attributes whenever possible.  


### CAS_ID (PK, FK)

See <a href="#CAS_ID">CAS_ID</a> in the CAS table.


### LAYER (PK)

The **LAYER** attribute identifies the specific layer to which the wetland is linked in the source data. When wetlands are not explicitly linked to a specific layer -8886 (UNKNOWN_VALUE) is assigned. Layer is usually only populated for cases with horizontal structure where multiple wetland sub-components can be included within a single polygon (e.g. PC02). In this case each layer represents a different sub-component of the horizontal structure.

| Values   | Description |
| :------- | :------- |
| 1&#8209;9| Identifies the layer number that the wetland is associated with |
| -8886 | Source value should exist but is unknown |


### WETLAND CLASSIFICATION

The wetland classification scheme used for CAS follows the classes developed by the National Wetlands Working Group<sup>1</sup> and modified by Vitt and Halsey<sup>2,3</sup>. The scheme was further modified to take into account coastal and saline wetlands. The CAS wetland attribute is composed of four parts: wetland type (WETLAND_TYPE), wetland vegetation modifier (WET_VEG_COVER), wetland landform modifier (WET_LANDFORM_MOD), and wetland local modifier (WET_LOCAL_MOD).  

Five major wetland types are recognized based on wetland development from hydrologic, chemical, and biotic gradients that commonly have strong cross-correlations. Two of the types; FEN and BOG, are peat-forming with greater than 40 cm of accumulated organics. The three non-peat forming wetland types are SHALLOW_WATER (shallow open water), MARSH (fresh or salt water), and SWAMP. A NOT_WETLAND type is also included. The Vegetation Modifier is assigned to a wetland type to describe the amount of vegetation cover. The Landform Modifier is a modifier label used when permafrost, patterning, or salinity are present. The Local Landform Modifier is a modifier label used to define the presence or absence of permafrost features or if vegetation cover is shrub or graminoid dominated.  

Not many forest inventories across Canada provide a wetland attribute. Some inventories have complete or partial wetland attributes while others will need to have wetland types derived from other attributes or ecosite information. The level of wetland detail that is possible to describe from a particular inventory database is dependent on the attributes that already exist. The wetland derivation may not be complete nor will it always be possible to derive or record all four wetland attributes in the CAS database. 


### WETLAND_TYPE

| Values | Description |
| :----- | :----- |
| BOG    | > 40 cm peat, receive water from precipitation only, low in nutrients and acid, open or wooded with sphagnum moss |
| ESTUARY | Mixed freshwater/saltwater marsh areas |
| FEN    | > 40 cm peat, groundwater and runoff flow, mineral rich with mostly brown mosses, open, wooded or treed |
| SWAMP  | Woody vegetation with > 30% shrub cover or 6% tree cover. Mineral rich with periodic flooding and near permanent subsurface water. Various mixtures of mineral sediments and peat |
| MARSH  | Emergent vegetation with < 30% shrub cover, permanent or seasonally inundated with nutrient rich water |
| SHALLOW_WATER | Freshwater lakes < 2 m depth |
| TIDAL_FLATS | Ocean areas with exposed flats |
| WETLAND | Wetland without distinction of type |
| NOT_WETLAND | Upland areas |
| NULL_VALUE     | Source value is NULL |
| NOT_APPLICABLE | Attribute does not apply to this record |


### WET_VEG_COVER

| Values | Description |
| :----- | :----- |
| FORESTED | Closed canopy forests > 70% tree cover |
| MUD      | No vegetation cover |
| OPEN_NON_TREED_FRESHWATER | Open canopy forests < 6% tree cover with shrubs |
| OPEN_NON_TREED_COASTAL | Open canopy coastal forests < 6% tree cover, with shrubs |
| WOODED   | Open canopy forests > 6% to 70% tree cover |
| NOT_APPLICABLE | Attribute does not apply to this record |


### WET_LANDFORM_MOD

| Values | Description |
| :----- | :---------- |
| NO_PERMAFROST_PATTERNING | No permafrost or patterning present |
| PATTERNING_PRESENT       | Patterning present |
| PERMAFROST_PRESENT       | Permafrost present |
| SALINE_ALKALINE          | Saline or alkaline present |
| NOT_APPLICABLE | Attribute does not apply to this record |


### WET_LOCAL_MOD

| Values | Description |
| :----- | :----- |
| GRAMINOIDS      | Graminoids with shrub cover < 25%      |
| INT_LAWN_ISLAND | Internal lawn with islands of forested peat plateau |
| INT_LAWN_SCAR   | Collapse scar present in permafrost area |
| INT_LAWN        | Internal lawns present (permafrost was once present) |
| NO_LAWN         | Internal lawns not present |
| SHRUB_COVER     | Shrub cover > 25% |
| NOT_APPLICABLE  | Attribute does not apply to this record |

<sup>1</sup>National Wetlands Working Group 1988. Wetlands of Canada. Ecological Land Classification Series No. 24.  

<sup>2</sup>Alberta Wetland Inventory Standards. Version 1.0. June 1977. L. Halsey and D. Vitt.  

<sup>3</sup> Alberta Wetland Inventory Classification System. Version 2.0. April 2004. Halsey, et. al.  

  
### ECO_SITE

The **ECO_SITE** attribute is a site-level description that provide a linkage between vegetation and soil/moisture and nutrient features on the site. A common attribute structure for ecosite is not provided for CAS because ecosite is not available for most forest inventories across Canada nor can it be derived from existing attributes. The **ECO_SITE** attribute is included in CAS to accommodate inventories that do include ecosite data.

| Values      | Description      |
| :---------- | :---------- |
| Alphanumeric | Combination of site, soil, and vegetation characteristics as influenced by environmental factors |
| NOT_APPLICABLE | Attribute does not apply to this record |


<a name=GEO_attributes></a>
## GEO Attributes 

Geometry attributes are calculated by the translation engine.

### CAS_ID (PK, FK)

See <a href="#CAS_ID">CAS_ID</a> in the CAS table.

### GEOMETRY

The **GEOMETRY** attribute stores the geometry associated with the record.

| Values           | Description      |
| :--------------- | :---------- |
| PostGIS geometry | Polygon associated with each record |




## Bibliography  



### British Columbia

* Ministry of Forests 1982. Forest and Range Inventory Manual, Chapter 3, Forest Classification.  

* Ministry of Forests 1992. Forest Inventory Manual. Volumes 1 - 5.  

* Resource Inventory Committee 2002. Vegetation Resources Inventory, Version 2.4. Photo Interpretation Procedures. Ministry of Sustainable Resource Management. Terrestrial Information Branch (<http://www.for.gov.bc.ca/risc>).  

* Sandvoss, M, B. McClymont and C. Farnden (compilers) 2005. A User's Guide to the Vegetation Resources Inventory. Timberline Forest Inventory Consultants.  

  

### Alberta 

* Alberta Department of Energy and Nat. Res. 1985. Alberta Phase 3 Forest Inventory: An Overview. Rep. No. I/86.  

* Alberta Department of Energy and Nat. Res. 1985. Alberta Phase 3 Inventory: Forest Cover Type Specifications. Rep. No. 58.  

* Alberta Environmental Protection 1991. Alberta Vegetation Inventory Standards Manual, Version 2.1. Resource Data Division. Data Acquisition Branch.  

* Alberta Sustainable Resource development. 2005. Alberta Vegetation Inventory Standards. Version 2.1.1 March 2005. Chapter 3 - Vegetation Inventory Standards and Data Model Documents. Resource Information Branch.  

* Halsey L. and D.H. Vitt. 1977 Alberta Wetland Inventory Standards. Version 1.0. June.  

* Halsey L., D.H. Vitt, D. Beilman, S. Crow, S. Meehelcic, and R. Wells. 2004. Alberta Wetland Inventory Classification System Version 2.0. Alberta Sustainable Resource Development, Resource Data Branch. Pub. No, T/031.  



### Saskatchewan

* Lindenas, D.J. 1985. Specifications for the Interpretation and Mapping of Aerial Photographs in the Forest Inventory Section. Sask. Dept. Parks and Renew. Res. Internal Manual.  
* Saskatchewan Environment 2004. Saskatchewan Forest Vegetation Inventory, Version 4.0.  Forest Service. (www.se.gov.sk.ca/forests/forestmanagement/Sask_Leg_Manuals.htm.  



### Manitoba

* Manitoba Conservation. Prior to 1992. Forest Inventory Manual 1.0 and 1.1. Forest Inventory and Resource Analysis.  

* Manitoba Conservation. 1992 - 1996. Forest Inventory Manual 1.2. Forest Inventory and Resource Analysis.  

* Manitoba Conservation. 1996 - 1997. Forest Inventory Manual 1.3. Forest Inventory and Resource Analysis.  

* Manitoba Conservation. 2001. Forest Lands Inventory Manual 1.1. Forest Inventory and Resource Analysis.


### Ontario 

* Louisiana Pacific Canada Ltd. 2004. FLI User Guide (Draft). Prepared by The Forestry Corp. Ontario

* Ontario Ministry of Natural Resources. 1996. Specifications for Forest Resources Inventory Photo Interpretation. Updated Mar. 1996.  

* Ontario Ministry of Natural Resources. 2001. Specifications for Forest Resources Inventory Photo Interpretation. Updated Sept. 2001.  

* Ontario Ministry of Natural Resources. 2007. Ontario Forest Resources Inventory Photo Interpretation Specifications. Updated Dec_2007.  

* Ontario Ministry of Natural Resources. 2010. Ontario Forest Resources Inventory Photo Interpretation Specifications. Updated Dec_2010.  

* OMNR, April 2001. Forest Information Manual. Toronto: Queen's Printer for Ontario. 400 pp.  

* OMNR, April 2007. Forest Information Manual. Toronto: Queen's Printer for Ontario. 107 pp. (<http://ontariosforests.mnr.gov.on.ca/ontariosforests.cfm>)  

* Pikangikum First Nation. 2003. Whitefeather Forest FRI/FEC Procedures Manual. Internal Document prepared by Timberline Forest Inventory Consultants Ltd.  

* Eabametoong and Mishkeegogamang First Nation. 2007. FRI/FEC Procedures Manual. Internal Document prepared by Timberline Natural Resource Group Ltd.  

  

### Quebec

* Foret Quebec. 2003. Normes de Cartographie Ecoforestiere. Troisieme Inventaire Ecoforestier. Ministere des Ressources Naturelles, de la Faune et des Parcs du Quebec. Direction des Inventaires Forestiers.  

* Foret Quebec. 2008. Norme de Stratification Ecoforestiere. Quatrieme Inventaire Ecoforestier. Direction des Inventaires Forestiers.  

  

### Prince Edward Island

* Prince Edward Island Dept. of Agric. and For. 2001. Photo Interpretation Specifications.  

* Province of Prince Edward Island. Natural Resources Division, Revised 2001.  

  

### New Brunswick

* Dept. of Nat. Resources. 2005. New Brunswick Integrated Land Classification System. Forest Management Branch  

  

### Nova Scotia

* Dept. of Nat. Resources 2006. Photo Interpretation Specifications. Forestry Division. Manual FOR 2006-1.  

  

### Newfoundland and Labrador

* Dept. of Nat. Resources 2006. Photo Interpretation Procedures and Technical Specifications. Forestry Services Branch.  

  

### Yukon Territory

* Yukon Energy, Mines, and Resources. 2006. Yukon Vegetation Inventory Manual. Version 2.1.  

* Forest Management Branch.

* Yukon Energy, Mines, and Resources. 2012. Yukon Vegetation Inventory Manual. Version 3.0.  

* Forest Management Branch.



### Northwest Territories

* Dept. of Energy and Natural Resources 2004. Northwest Territories Forest Vegetation Photo Interpretation, Transfer and Database Standards. Forest Resources, Forest Management Division.  

* Dept. of Energy and Natural Resources. 2006. Northwest Territories Forest Vegetation Inventory Standards with Softcopy Supplements, Version 3.0. Forest Resources, Forest Management Division.  

  

### Prince Albert National Park

* Padbury, G.E., W.K. Head, and W.E. Souster. 1978. Biophysical Resource Inventory of Prince Albert National Park, Saskatchewan. Saskatchewan Institute of Pedology Publication S185, Saskatoon.  

* Fitzsimmons, M. 1998. Prince Albert National Park Forest Cover Data in Vector Format. <http://daac.ornl.gov/boreas/STAFF/panpfcov/comp/PNP_For_Cov.txt>  

  

### Wood Buffalo National Park

* Air Photo Analysis Associates. 1979. Biophysical inventory of Wood Buffalo National Park. Prepared for Department of Indian and Northern Affairs, Parks Canada. Prairie Region.  
* WBNPBiophysical. 2001. SMMS Metadata Report.  

  

### General

* Gillis, M.D.; Leckie, D.G. 1993. Forest Inventory Mapping Procedures Across Canada.  

* Petawawa National Forestry Institute, Information Report PI-X-114.  

* Leckie D.G and Gillis M.D. 1995 Forest Inventory in Canada with emphasis on map production.  

* The Forestry Chronicle 71 (1): 74 - 88.

* Power, K. and Gillis, M. 2006 Canada's Forest Inventory 2001

* National Wetlands Working Group 1988. Wetlands of Canada. Ecological Land Classification Series No. 24.
