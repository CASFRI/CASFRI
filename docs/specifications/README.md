# COMMON ATTRIBUTE SCHEMA (CAS) FOR FOREST INVENTORIES ACROSS CANADA  

Prepared by: John A. Cosco, Chief Inventory Forester, February 2011

Revised by: The CASFRI Project Team, February 03, 2020

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

Canada's vast boreal ecosystem hosts one of the most diverse bird communities in North America. Development pressure within the boreal region is on the increase, and there is an urgent need to understand the impact of changing habitats on boreal bird populations and to make sound management decisions. The Boreal Avian Modeling Project was initiated to help address the lack of basic information on boreal birds and their habitats across boreal forests in Canada. The need to effectively manage bird species and their habitats has resulted in the effort to collect and gather data across Canada to develop models that will predict bird abundance and distribution, and that will clarify population and habitat associations with climate and land cover.  

Current national databases developed from satellite-based products using biophysical variables have limited application at regional levels because many bird species are sensitive to variation in canopy tree species composition, height, and age; vegetation attributes that satellite-based products cannot measure. Because satellite-based land cover maps lack the thematic detail needed to model the processes of stand growth, succession, and regeneration, avian habitat models derived from satellite land cover data cannot be used to link forest management actions to the desired biotic indicators at the scale of forest tenure areas.  

Digital forest inventory data can overcome many of the deficiencies identified with satellitebased land cover data. These data exist for most operational and planned commercial forest tenures in the Canadian boreal forest; however, differences among data formats, attributes, and standards across the various forest inventories make it difficult to develop models that are comparable and can be consistently applied across regions. To do so, it is necessary to address the variation between different forest inventories and bring all available inventories into one explicitly defined database where attributes are consistently defined without loss of precision. The starting point is to review all forest inventory classifications and develop a set of common attributes. This document addresses the inventory review developed for the Boreal Avian Monitoring Project; this review is called the Common Attribute Schema (CAS).  


<a name=CAS></a>
## Common Attribute Schema  

The common attribute schema (CAS) is a comprehensive attribute classification suitable for avian habitat modeling. Its development requires the selection of vegetation cover attributes useful for avian habitat modeling, and the assignment of common codes for each attribute that are broad enough to capture all relevant existing forest inventory attributes. CAS attributes represent the most common attributes that are consistently recorded in forest inventories across Canada including: stand structure (layers), moisture regime, crown closure, species composition, height, age (origin), site class or site index,  
non-forested cover types, non-vegetated cover types, and disturbance history. CAS also includes two attributes of ecological interest: ecosite and wetland. These two attributes are not common to most forest inventories across Canada; however, these attributes are considered important for avian habitat models and can possibly be acquired from other sources or partially or wholly derived from other attributes.  

Development of the CAS attribute codes and rule sets for inventory attribute code conversion to CAS codes required an extensive review of previous and current inventory standards and specifications across Canada. Gillis and Leckie<sup>1</sup> provided a good starting point for review of previous inventory standards. More current and other inventory standards and documents are listed in the bibliography. A summary of recent or current inventories across Canada are presented in Appendix 1. These inventories are the most likely sources for data that can contribute to the avian bird modeling project.  

Based on the review, detailed tables were produced to summarize each inventory standard by province and territory. Two national parks, Wood Buffalo and Prince Albert are included. Conversion rule sets were then produced as part of the detailed tables to identify how each province or territory inventory attribute codes translate into CAS attribute codes. Detailed tables and conversion rule sets for each CAS attribute are presented in Appendices noted in the appropriate sections of this document.  

Although many CAS attributes have a one-to-one conversion, not all do; some are identified by an interval or class that has an upper and lower bound (lower bound is > and the upper bound is <). Interval coding for height, crown closure, age, and similar quantitative attributes is a unique feature of CAS. Crown closure, height, age, and disturbance extent use bounds to define an attribute class. For example, the CAS captures crown closure as an interval providing two values, the lower bound and upper bound. In the Alberta Vegetation Inventory, crown closure is captured in four cover classes: A, B, C and D, while the British Columbia Vegetation Resource Inventory captures crown closure as values ranging from 1 to 100 to the nearest 1 percent. In CAS, an Alberta "B" - value would be represented as an interval: 31 for the lower bound and 50 for the upper bound. A British Columbia crown closure value of 36 would be represented as a CAS value of 36 for both the lower and upper bounds. All of the information contained in the original inventories is preserved and the attributes are not converted to a  
common resolution or set of values.  

Attributes for CAS are stored in six attribute files to facilitate conversion and translation:  

1. Header (HDR) attributes - values assigned to all polygons based on provenance or reference information;  
2. CAS Base Polygon (CAS) attributes - values that identify a polygon and provide a link between the CAS polygon and the original inventory polygon;  
3. Forest-Level (LYR) attributes - values that pertain to the polygon for productive and non-productive forest land;  
4. Non-Forest Land (NFL) attributes - values that pertain to naturally non-vegetated, non-forest anthropogenic, and non-forest vegetated land;  
5. Disturbance history (DST) attributes - values that pertain to any disturbance that has occurred in a polygon including type, year, and extent; and  
6. Ecological specific (ECO) attributes - values representing ecosites and wetlands.  
7. Geometry attributes - values pertaining to polygon geometry.

The main body of this report (Sections 2.1 through 2.3 and Section 3) defines each of the six attribute categories and tabulates the attributes and their characteristics. A summary of the data structure and data dictionary is presented in Appendix 2.  

Each inventory data base has a unique data structure. A conversion procedure must be documented describing how to load the source inventory into CAS. A sample procedure is presented in Appendix 16.  

<sup>1</sup> Gillis, M.D.; Leckie, D.G. 1993. Forest Inventory Mapping Procedures Across Canada. Petawawa National Forestry Institute, Information Report PI-X-114.  



Table 1. CASFRI schema.

| HDR               | CAS               | LYR                 | NFL                 | DST              | ECO              | GEO      |
| ----------------- | ----------------- | ------------------- | ------------------- | ---------------- | ---------------- | -------- |
| INVENTORY_ID      | CAS_ID            | CAS_ID              | CAS_ID              | CAS_ID           | CAS_ID           | CAS_ID   |
| JURISDICTION      | ORIG_STAND_ID     | SOIL_MOIST_REG      | SOIL_MOIST_REG      | DIST_TYPE_1      | WETLAND_TYPE     | GEOMETRY |
| OWNER_TYPE        | STAND_STRUCTURE   | STRUCTURE_PER       | STRUCTURE_PER       | DIST_YEAR_1      | WET_VEG_COVER    |          |
| OWNER_NAME        | NUM_OF_LAYERS     | LAYER               | LAYER               | DIST_EXT_UPPER_1 | WET_LANDFORM_MOD |          |
| STANDARD_TYPE     | IDENTIFICATION_ID | LAYER_RANK          | LAYER_RANK          | DIST_EXT_LOWER_1 | WET_LOCAL_MOD    |          |
| STANDARD_VERSION  | MAP_SHEET_ID      | CROWN_CLOSURE_UPPER | CROWN_CLOSURE_UPPER | DIST_TYPE_2      | ECO_SITE         |          |
| STANDARD_ID       | CASFRI_AREA       | CROWN_CLOSURE_LOWER | CROWN_CLOSURE_LOWER | DIST_YEAR_2      |                  |          |
| STANDARD_REVISION | CASFRI_PERIMETER  | HEIGHT_UPPER        | HEIGHT_UPPER        | DIST_EXT_UPPER_2 |                  |          |
| INVENTORY_MANUAL  | SRC_INV_AREA      | HEIGHT_LOWER        | HEIGHT_LOWER        | DIST_EXT_LOWER_2 |                  |          |
| SRC_DATA_FORMAT   | STAND_PHOTO_YEAR  | PRODUCTIVE_FOR      | NAT_NON_VEG         | DIST_TYPE_3      |                  |          |
| ACQUISITION_DATE  |                   | SPECIES_1 - 10      | NON_FOR_ANTH        | DIST_YEAR_3      |                  |          |
| DATA_TRANSFER     |                   | SPECIES_PER_1 - 10  | NON_FOR_VEG         | DIST_EXT_UPPER_3 |                  |          |
| RECEIVED_FROM     |                   | ORIGIN_UPPER        |                     | DIST_EXT_LOWER_3 |                  |          |
| CONTACT_INFO      |                   | ORIGIN_LOWER        |                     | LAYER            |                  |          |
| DATA_AVAILABILITY |                   | SITE_CLASS          |                     |                  |                  |          |
| REDISTRIBUTION    |                   | SITE_INDEX          |                     |                  |                  |          |
| PERMISSION        |                   |                     |                     |                  |                  |          |
| LICENSE_AGREEMENT |                   |                     |                     |                  |                  |          |
| PHOTO_YEAR_SRC    |                   |                     |                     |                  |                  |          |
| PHOTO_YEAR_START  |                   |                     |                     |                  |                  |          |
| PHOTO_YEAR_END    |                   |                     |                     |                  |                  |          |
| <ul><li>item1</li><li>item2</li></ul>| |                     |                     |                  |                  |          |
| <p style="font-size:1px;">This is demo text</p>|             |                     |                     |                  |                  |          |

 


<a name=Error_codes></a>
## Error Codes  

Error codes are needed during translation if source values are invalid, null, or missing. In CASFRI v5, error codes have been designed to match the attribute type and to reflect the type of error that was encountered. For example, an integer attribute will have error codes reported as integers (e.g. -9999) whereas text attributes will have errors reported as text (e.g. INVALID). Different error codes are reported depending on the cause. Individual error codes are reported for each attribute in the specifications below.

| Class          | Type               | Description                                                  | Text code         | Numeric code |
| -------------- | ------------------ | ------------------------------------------------------ | ----------------- | ---------- |
| Missing values | Empty string       | Missing value that is entered as an empty                                                                                             string (e.g. '' or ' ')                                | EMPTY_STRING        | -8889    |
|                | Null               | Missing value that is a true null value                | NULL_VALUE        | -8888    |
|                | Not applicable     | Target attribute not in source table or does                                                                                           not apply to this record (e.g. the source                                                                                             inventory does not record information for the                                                                                         attribute                                              | NOT_APPLICABLE    | -8887    |
|                | Unknown value      | Non-null value that is not known (e.g. if the                                                                                         source data we have is incomplete and we can't                                                                                         be sure of the attributes value without a complete                                                                                     dataset)                                               | UNKNOWN_VALUE     | -8886    |
| Invalid values | Out of range       | Value is outside the range of values (e.g. a                                                                                           percent value that is >100                             | OUT_OF_RANGE      | -9999    |
|                | Not member of set  | Value is not a member of a set or list (e.g. when                                                                                     a source value does not match a list of expected                                                                                       strings)                                               | NOT_IN_SET        | -9998    |
|                | Invalid value      | Invalid value (e.g. input value does match expected                                                                                   format)                                                | INVALID_VALUE     | -9997    |
|                | Wrong data type    | Value is of the wrong data type (e.g. a text string                                                                                   when we expect an integer)                             | WRONG_TYPE        | -9995    |
|                | Unused value       | Non-null value that is not used in CAS                 | UNUSED_VALUE      | -9994    |
|                | Not unique         | Source table values are not unique (e.g. a lookup                                                                                     table that lists a source value twice)                 | NOT_UNIQUE        | -9993    |
| Generic        | Translation error  | Generic translation error (reported for a failed                                                                                       translation)                                           | TRANSLATION_ERROR | -3333    |
| Geometry       | Invalid geometry   | Invalid geometry in one or more polygons               | INVALID_GEOMETRY  | -7779    |
|                | No intersect       | FRI geometry does not intersect any polygons (e.g.                                                                                     when running a spatial join with a photo year geometry)| NO_INTERSECT      | -7778    |


<a name=HDR_attributes></a>
## HDR Attributes 

Header information is a primary element of CAS. Header information identifies the source data set including jurisdiction, ownership, tenure type, inventory type, inventory version, inventory start and finish date and the year of acquisition for CAS. These attributes are described below.


### INVENTORY_ID

The attribute **INVENTORY_ID** is a unique identifier that is assigned to each forest inventory. It is the concatenation of the **JURISDICTION** attribute plus an integer that increments with newer inventories within a jurisdiction.

| Values | Desription |
| :----- | :-------------- |
| Alpha numeric string of two characters followed by two digits. e.g., BC08, AB06, AB16, NB01 | Two characters represent the province/territory, two digits increment for each source inventory available from the province/territory |


### JURISDICTION

The attribute **JURISDICTION** identifies the province, territory or national park from which the inventory data came.

| Values | Description |
| :-------------------------- | :-------------- |
| BC | British Columbia |
| AB | Alberta |
| SK | Saskatchewan |
| MB | Manitoba |
| ON | Ontario |
| QC | Quebec |
| PE | Prince Edward Island |
| NB | New Brunswick |
| NS | Nova Scotia |
| NL | Newfoundland and Labrador |
| YK | Yukon Territory |
| NT | Northwest Territories |
| WB | Wood Buffalo National Park |
| PA | Prince Albert National Park |


### OWNER_TYPE

The attribute **OWNER_TYPE** identifies who owns the inventory data. Ownership of the inventory can be federal, provincial, territory, industry, private, or First Nation.

| Values    | Description |
| :-------- | :-------------- |
| PROV_GOV  | Provincial Government |
| FED_GOV   | Federal Government |
| TERRITORY | Yukon Territory or Northwest Territories |
| FN        | First Nation |
| INDUSTRY  | Industry |
| PRIVATE   | Private |


### OWNER_NAME

The attribute **OWNER_NAME** identifies who owns the land that the inventory covers, and degree of permission to which the data can be used. Ownership of the land is identified as being crown, private, military, or First Nation.

| Values   | Description   |
| :------- | :-------------- |
| CROWN    | Crown |
| PRIVATE  | Private |
| MILITARY | Military |
| FN       | First Nation |


### STANDARD_TYPE

The attribute **STANDARD_TYPE** identifies the kind of inventory that was produced for an area. The name, abbreviation, or acronym usually becomes the name used to identify an inventory. For example, Alberta had a series of successive forest inventories called Phase 1, Phase 2, and Phase 3. As inventories became more inclusive of attributes other than just the trees, they became known as vegetation inventories, for example, the Alberta Vegetation Inventory or AVI. The inventory type along with a version number usually identifies an inventory.

| Values         | Description        |
| :------------- | :-------------- |
|  Alpha numeric | Inventory name or type of inventory |


### STANDARD_VERSION

The attribute **STANDARD_VERSION** identifies the standards used to produce a consistent inventory, usually across large land bases and for a relatively long period of time. The inventory type along with a version number usually identifies an inventory.

| Values         | Description        |
| :------------- | :-------------- |
|  Alpha numeric | The standard and version of the standard used to create the inventory |


### STANDARD_ID

The attribute **STANDARD_ID** identifies the version of the standard within CASFRI. If a standard is updated such that a new translation table is required, the **STANDRAD_ID** will be incremented.

| Values        | Description   |
| :------------ | :------------ |
| Alpha numeric | The standard and version of the standard used to create the inventory |


### STANDARD_REVISION

The attribute **STANDARD_REVISION** records whether any revisions have been made to the standard.

| Values        | Description        |
| :------------ | :------------ |
| Alpha numeric | The standard and version of the standard used to create the inventory |


### INVENTORY_MANUAL

The attribute **INVENTORY_MANUAL** identifies the documentation associated with the inventory data e.g., metadata, data dictionary, manual, etc.

| Values | Description |
| :----- | :-------------- |
| Text   | Documentation associated with the inventory data |


### SRC_DATA_FORMAT

The attribute **SRC_DATA_FORMAT** identifies the format of the inventory data e.g., geodatabase, shapefile, e00 file.

| Values          | Description      |
| :-------------- | :-------------- |
| Geodatabase     | ESRI file geodatabase       |
| Shapefile       | ESRI shapefile              |
| E00             | ESRI e00 transfer files     |
| ESRI Coverage   | ESRI Coverage files         |
| mdb             | Microsoft Access database   |


### ACQUISITION_DATE

The attribute **ACQUISITION_DATE** identifies the date at which the inventory data was acquired.

| Values | Description |
| :----- | :-------------- |
| Date   | Date at which the inventory data was acquired  |


### DATA_TRANSFER

The attribute **DATA_TRANSFER** identifies the procedure with which the inventory data was acquired. Examples include direct download, ftp transfer, on DVD, etc.

| Values | Description |
| :----- | :-------------- |
| Text   | Procedure with which the inventory data was acquired |


### RECEIVED_FROM

The attribute **RECEIVED_FROM** identifies the person, entity, or website from which the inventory data was obtained.

| Values | Description |
| :----- | :-------------- |
| Text   | Person, entity, or website from which the data was obtained |


### CONTACT_INFO

The attribute **CONTACT_INFO** identifies the contact information (name, address, phone, email, etc.) associated with the inventory data.

| Values | Description |
| :----- | :-------------- |
| Text   | Contact information associated with the inventory data   |


### DATA_AVAILABILITY

The attribute **DATA_AVAILABILITY** identifies the type of access to the inventory data e.g., direct contact or open access.

| Values | Description |
| :----- | :-------------- |
| Text   | Type of access to the inventory data |


### REDISTRIBUTION

The attribute **REDISTRIBUTION** identifies the conditions under which the inventory data can be redistributed to other parties.

| Values | Description |
| :----- | :-------------- |
| Text   | Conditions under which the inventory data can be redistributed |


### PERMISSION

The attribute **PERMISSION** identifies the degree of permission to which the data can be used i.e., whether the use of the data is unrestricted, restricted or limited..

| Values | Description |
| :----- | :-------------- |
| UNRESTRICTED | Use of the inventory data is unrestricted |
| RESTRICTED | Use of the inventory data has restrictions |
| LIMITED | Use of the data has limitations |


### LICENSE_AGREEMENT

The attribute **LICENSE_AGREEMENT** identifies the type of license associated with the inventory data.

| Values | Description |
| :----- | :-------------- |
| Text   | Type of license associated with the inventory data |


### PHOTO_YEAR_SRC

The attribute **PHOTO_YEAR_SRC** identifies the source data type that is used to define the photo year i.e., the year in which the inventory was considered initiated and completed.

| Values           | Description |
| :-------------   | :-------------- |
| SPATIAL_JOIN     | Photo year is stored as polygons in a separate file that needs to be spatially joined to the data |
| VALUE_PER_STAND  | Photo year is provided as an attribute in the source data |
| RELATIONAL_JOIN  | Photo year is stored in a separate table that needs to be joined to the data |
| GLOBAL_INVENTORY | Photo year is a single value that applies to the entire dataset |


### PHOTO_YEAR_START

The attribute **PHOTO_YEAR_START** identifies the year in which the inventory was considered initiated. An inventory can take several years to complete; therefore, start and end dates are included to identify the interval for when the inventory was completed.

| Values      | Description |
| :---------- | :-------------- |
| 1900 - 2020 | Earliest year of aerial photo acquisition |


### PHOTO_YEAR_END

The attribute **PHOTO_YEAR_END** identifies the year in which the inventory was considered completed. An inventory can take several years to complete; therefore, start and end dates are included to identify the interval for when the inventory was completed. 

| Values      | Description |
| :---------- | :-------------- |
| 1900 - 2020 | Latest year of aerial photo acquisition |


<a name=CAS_attributes></a>
## CAS Attributes

The CAS base polygon data provides polygon specific information and links the original inventory polygon ID to the CAS ID. Identification attributes include original stand ID, CAS Stand ID, Mapsheet ID, and Identification ID. Polygon attributes include stand structure, polygon area and polygon perimeter. Inventory Reference Year, Photo Year, and Administrative Unit are additional identifiers.


### CAS_ID

The attribute **CAS_ID** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| Values               | Description |
| :------------------- | :---------- |
| Alpha numeric string |  CAS stand identification - unique string for each polygon within CAS |
| NULL_VALUE           |  One of the source attributes is null |
| EMPTY_STRING         |  One of the source attributes is an empty string |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 



### ORIG_STAND_ID

Original stand identification - unique number for each polygon within the original inventory.

| Values       | Description |
| :----------- | :-------------- |
| Integer      | Unique number for each polygon within the original inventory |
| NULL_VALUE   |  Source attribute is null |
| WRONG_TYPE   |  Source attribute is wrong type (e.g. an integer was expected) |
| OUT_OF_RANGE |  Source attribute is out of expected range (e.g. an integer greater than zero was expected) |


### STAND_STRUCTURE

Structure is the physical arrangement or vertical pattern of organization of the vegetation within a polygon. A stand can be identified as single layered, multilayered, complex, or horizontal. 

A single layered stand has stem heights that do not vary significantly and the vegetation has only one main canopy layer.

**Original documentation**:
`A multilayered stand can have several distinct layers and each layer is significant, has a distinct height difference, and is evenly distributed. Generally the layers are intermixed and when viewed vertically, one layer is above the other. Layers can be treed or non-treed. Up to 9 layers are allowed; most inventories recognize only one or two layers. The largest number of layers recognized is in the British Columbia VRI with 9 followed by Saskatchewan SFVI with 7 and Manitoba FLI with 5. Each layer is assigned an independent description with the tallest layer described in the upper portion of the label. The number of layers and a ranking of the layers can also be assigned. Some inventories (e.g. Saskatchewan UTM, Quebec TIE, Prince Edward Island, and Nova Scotia) can imply that a second layer exists; however, the second layer is not described or only a species type is indicated.`

**Proposed new documentation**
A multilayered stand can have several distinct layers and each layer is significant, has a distinct height difference, and is evenly distributed. Generally the layers are intermixed and when viewed vertically, one layer is above the other.

Complex layered stands exhibit a high variation in tree heights. There is no single definitive forested layer as nearly all height classes (and frequently ages) are represented in the stand. The height is chosen from a stand midpoint usually followed by a height range.

Horizontal structure represents vegetated or non-vegetated land with two or more homogeneous strata located within other distinctly different homogeneous strata within the same polygon but the included strata are too small to map separately based on minimum polygon size rules. This attribute is also used to identify multi- label polygons identified in biophysical inventories such as Wood Buffalo National Park and Prince Albert National Park. The detailed table for stand structure is presented in Appendix 3.

If Complex or Horizontal stand structure is assigned in the source data, it is assigned the same value in CASFRI. **Single and Multi-layered stand structure are assigned based on the number of canopy layers identified in the LYR table. If there is one layer, Single-layered is assigned, otherwise Multi-layered.**

| Values | Description |
| :------------------- | :-------------- |
| S                    | Single layered - vegetation within a polygon where the heights do not vary significantly |
| M                    | Multilayered - two or more distinct layers of vegetation occur. Each layer is significant, clearly observable                          and evenly distributed. Each layer is assigned an independent description |
| C                    | Complex - stands exhibit a high variation of heights with no single defined canopy layer |
| H                    | Horizontal - two or more significant strata within the same polygon; at least one of the strata is too small                          to delineate as a separate polygon |
| NOT_APPLICABLE       | No stand structure value is applicable (e.g. polygon does not have canopy information) |

Notes:
* In BC08 we do not have the complete dataset so different rules are used for LAYER assignment (see below). The documentation for the BC08 Rank 1 data state that all Rank 1 layers identified in the inventory are from multi-layered stands. We therefore assign M in all cases, even though the LYR table will only contain at most one layer for BC08.


### NUM_OF_LAYERS  

**Old definition:**
`Number of Layers is an attribute related to stand structure and identifies how many layers have been identified for a particular polygon.`

**Proposed new defintion**
Number of layers counts all CASFRI layers from the the LYR and NFL tables. **Note that NUM_OF_LAYERS is independant of  STAND_STRUCTURE since STAND_STRUCTURE is only based on the number of canopy layers in the LYR table. Stand structure could therefore be S, even when the number of layers is >1.**

| Values        | Description |
| :----         | :----- |
| 1 - 9         | Identifies the number of vegetation or non vegetation layers assigned to a particular polygon. A maximum of 9 layers                   can be identified |
| -8886         | The number of layers is not known (e.g. if there is disturbance info, but not reported layers) |

Notes:

- In BC08 we do not have the complete source data, only the rank 1 layer. NUM_OF_LAYERS in this case is still assigned as a count of the CASFRI layers available, but it does not represent the count of layers from the full source dataset. 


### MAP_SHEET_ID

Map sheet identification according to original naming convention for an inventory.

| Values         | Description        |
| :------------  | :------------ |
| Alpha numeric  | Map sheet identification according to original naming convention for an inventory |
| NULL_VALUE     | Source value is null |
| NOT_APPLICABLE | Attribute does not exist in source data |


### CASFRI_AREA

The attribute **CASFRI_AREA** measures the area of each polygon in hectares (ha). It is calculated by PostgreSQL during the conversion phase. It is measured to 2 decimal places. This attribute is calculated by PostGIS.

| Values        | Description |
| :-----        | :------------ |
| >=0.01        | Polygon (stand) area in hectares (ha) |
| -7779         | Source geometry is not valid |


### CASFRI_PERIMETER

The attribute **CASFRI_PERIMETER** measures the perimeter of each polygon in metres (m). It is calculated by PostgreSQL during the conversion phase. It is measured to 2 decimal places. This attribute is calculated by PostGIS.

| Values | Description |
| :----- | :-------------- |
| >=0.01 | Polygon (stand) perimeter in metres (m) |
| -7779  | Source geometry is not valid |


### SRC_INV_AREA

The attribute **SRC_INV_AREA** measures the area of each polygon in hectares (ha). It is calculated by the data providers and may contain missing values. It is measured to 2 decimal places.

| Values | Description        |
| :----- | :------------ |
| >=0.01 | Polygon (stand) area in hectares (ha) |
| -8888  | Source value is null |
| -9995  | Source value is not the expected type (e.g. not a numeric) |
| -9999  | Source value is outside expected range (e.g. it is zero) |
| -8887  | Attribute does not exist in source data |


### STAND_PHOTO_YEAR

The attribute **STAND_PHOTO_YEAR** is a identifies the year in which the aerial photography was conducted for a particular polygon. This is in contrast to photo_year_start and photo_year_end which identify the interval for when the inventory was completed.

| Values      | Description      |
| :---------- | :---------- |
| 1900 - 2020 | Identifies the year in which the aerial photography was conducted |
| -8888  | Source value is null |
| -9995  | Source value is not the expected type (e.g. not an integer) |
| -9999  | Source value is outside expected range (e.g. not between 1900 and 2020) |
| -7779  | Source geometry is not valid |
| -7778  | Source geometry does not intersect the provided geometry (e.g. source polygon does not intersect the photo year geometry) |


<a name=LYR_attributes></a>
## LYR Attributes

Forest layer attributes.


### CAS_ID

The attribute **CAS_ID** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| Values               | Description |
| :------------------- | :---------- |
| Alpha numeric string |  CAS stand identification - unique string for each polygon within CAS |
| NULL_VALUE           |  One of the source attributes is null |
| EMPTY_STRING         |  One of the source attributes is an empty string |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 


<a name=STRUCTURE_PER></a>
### STRUCTURE_PER

The attribute **STRUCTURE_PER** is assigned when a horizontal structured polygon is identified. It is used with horizontal stands and identifies the percentage of stand area, assigned in 10% increments, attributed by each stratum within the entire polygon and must add up to 100%. Any number of horizontal strata can be described per horizontal polygon.

| Values                             | Description  |
| :--------------------------------- | :------ |
| 10, 20, 30, 40, 50, 60, 70, 80, 90 | When **STAND_STRUCTURE** = "H", used with horizontal stands to identify the percentage, in 10%                                        increments, strata within the polygon. Must add up to 100%. Only two strata represented by each                                        homogeneous descriptions are allowed per polygon |
| 100                                | When **STAND_STRUCTURE** = "S", "M", "C", value = 100 i.e., when there is no horizontal                                                structure |
| -9998                              | Source value is not an expected value (e.g. in cases where structure percent is a coded alpha                                          numeric with an expected list of codes) |
| -8888                              | Source value is null |
| -9995                              | Source value is not the expected type (e.g. not an integer) |
| -9999                              | Source value is outside expected range (e.g. not between 0 and 9) |


### STRUCTURE_RANGE

The attribute **STRUCTURE_RANGE** is assigned when a complex structured polygon is identified. It is used with complex stands and represents the height range (m) around the stand midpoint. For example, height range 6 means that the range around the midpoint height is 3 meters above and 3 meters below the midpoint.

| Values | Description |
| :----- | :----- |
| 1 - 99 | When **STAND_STRUCTURE** = "C", measures the height range (m) around the midpoint height of the stand. It is calculated as            the difference between the mean or median heights of the upper and lower layers within the complex stand |
| -8887  | Translation is not applicable (e.g. when **STAND_STRUCTURE** = "S", "M", or "H") |

Notes:

- Applies to the following inventories: AB, NB, NT, (Wood Buffalo?)


<a name=LAYER></a>
### LAYER

LAYER is related to stand structure and number of layers and is recorded for all LYR and NFL records. Layer 1 will always be the top (uppermost) layer in the stand sequentially followed by Layer 2 and so on. The maximum number of layers recognized is nine. The uppermost layer may also be a veteran (V) layer. A veteran layer refers to a treed layer with a crown closure of 1 to 5 percent and must occur with at least one other layer; it typically includes the oldest trees in a stand.

LAYER is calculated for CASFRI based on the presence of forest and non-forest information in the source data. Layer is assigned sequentially starting at 1 for the tallest overstory layer, followed by lower canopy layers. NFL layers are then assigned, shrub layers are assumed to be above herb layers in cases where both are available (e.g. SFVI in SK). Lower layers are assigned the appropriate value based on the presence of higher layers, so if no canopy information exsists, an NFL layer will get a value of 1.

| Values   | Description   |
| :------- | :------- |
| 1 - 9, V | Identifies the layer number of a vegetation or non vegetation layer within a particular polygon. A maximum of 9 layers                can be identified. No two layers can have the same value within the same polygon |

Notes:

- LAYER is a CASFRI specific attribute that we compute based on the presence or absence of values for different layers.
- One exception is the BC08 inventory where we do not have access to the complete dataset. Only the rank 1 data is available which could represent any canopy layer from the full source inventory. We therefore copy the layer info from the source data in this case so as not to mis-represent the source data by assigning layer 1 to a layer that is not actually the top layer. 


<a name=LAYER_RANK></a>
### LAYER_RANK

Layer rank is an attribute related to LAYER and refers to the layer importance for forest management planning, operational, or silvicultural purposes. Layer rank is always copied from the source data when available. If no rank is assigned in the source data, CASFRI reports an error code.  

| Values | Description |
| :----- | :----- |
| 1 - 9  | Layer Rank - value assigned sequentially to layer of importance. Rank 1 is the most important layer followed by Rank 2,                etc.  |
| -8888  | Source value is null |
| -8887  | Translation is not applicable (e.g. no source attribute) |


<a name=SOIL_MOIST_REG></a>
### SOIL_MOIST_REG  

Soil moisture regime describes the available moisture supply for plant growth over a period of several years. Soil moisture regime is influenced by precipitation, evapotranspiration, topography, insolation, ground water, and soil texture. The CAS soil moisture regime code represents the similarity of classes across Canada. *The detailed soil moisture regime table and CAS conversion is presented in Appendix 4*.  

| Value      | Description |
| :--------- | :----- |
| D          | Dry - Soil retains moisture for a negligible period following precipitation with very rapid drained substratum |
| F          | Mesic - Soils retains moisture for moderately short to short periods following precipitation with moderately well                      drained substratum |
| M          | Moist - Soil retains abundant to substantial moisture for much of the growing season with slow soil infiltration |
| W          | Wet - Poorly drained to flooded where the water table is usually at or near the surface, or the land is covered by                    shallow water |
| A          | Aquatic - Permanent deep water areas characterized by hydrophytic vegetation (emergent) that grows in or at the surface                of water |
| NULL_VALUE | Source value is null |
| NOT_IN_SET | Source value is not in list of expected values |
| NOT_APPLICABLE | Source value does not occur |


<a name=CROWN_CLOSURE></a>
### CROWN_CLOSURE_UPPER, CROWN_CLOSURE_LOWER 

Crown closure is an estimate of the percentage of ground area covered by vertically projected tree crowns, shrubs, or herbaceous cover. Crown closure is usually estimated independently for each layer. Crown closure is commonly represented by classes and differs across Canada; therefore, CASFRI recognizes an upper and lower percentage bound for each class. The detailed crown closure table is presented in Appendix 5.  

| Values    | Description |
| :-------- | :-------------- |
| 0 - 100   | Upper and lower bound of a crown closure class |
| -8888     | Source value is null |
| -8889     | Source value is empty string (e.g. '') |
| -9995     | Source value is not the expected type (e.g. not an integer) |
| -9999     | Source value is outside expected range (e.g. not between 0 and 100) |
| -8887     | Source value is not applicable (e.g. not a forested polygon) |


<a name=HEIGHT></a>
### HEIGHT_UPPER, HEIGHT_LOWER

Stand height is based on an average height of leading species of dominant and co-dominant heights of the vegetation layer and can represent trees, shrubs, or herbaceous cover. Height can be represented by actual values or by height class and its representation is variable across Canada; therefore, CAS will use upper and lower bounds to represent height. The detailed height table is presented in Appendix 6. 

| Values    | Description |
| :-------- | :-------------- |
| 0 - 100   | Upper and lower bound of a height class |
| -8888     | Source value is null |
| -8889     | Source value is empty string (e.g. '') |
| -9995     | Source value is not the expected type (e.g. not an integer) |
| -9999     | Source value is outside expected range (e.g. not between 0 and 100) |
| -8887     | Source value is not applicable (e.g. not a forested polygon) |

Note:
* In BC10, separate heights are assigned for the dominant and co-dominant species in a layer. We therefore compute a weighted average based on the dominant and co-dominant heights, weighted by the percent cover of the dominant and co-dominant species in the layer.


### PRODUCTIVE_FOR

Unproductive forest is forest land not capable of producing trees for forest operations. They are usually wetlands, very dry sites, exposed sites, rocky sites, higher elevation sites, or those sites with shallow or poor soils. The detailed table, CAS codes, and conversion rule sets are presented in Appendix 12.  

| Values | Description |
| :----- | :-------------- |
| TM     | Treed Muskeg - treed wetland sites |
| AL     | Alpine forest - high elevation forest usually above 1800 m |
| SD     | Scrub Deciduous - scrub deciduous trees on poor sites |
| SC     | Scrub Coniferous - scrub coniferous trees on poor sites |
| NP     | Non Productive forest - poor forest types on rocky or wet sites |
| PP     | Potentially Productive forest - forest previously affected by some disturbance |
| PF     | Productive Forest - any other forest |

Notes:

- This attribute needs an overhaul. #181, #295


### SPECIES_1 - SPECIES_10

Species composition is the percentage of each tree species represented within a forested polygon by layer. Species are listed in descending order according to their contribution based on crown closure, basal area, or volume depending on the province or territory. A total of ten species can be used in one label. For the first species for example, CASFRI has a SPECIES_1 attribute to record the species name, and a SPECIES_PER_1 attribute to record the percent cover. Species percent will capture percent estimates to the nearest percent; however, most inventories across Canada describe species to the nearest 10% (in actual percent value or multiples of 10). Species composition for each forest stand and layer must sum to 100%.  

The detailed table for species composition is presented in Appendix 7. Some inventories (Alberta Phase 3, Saskatchewan UTM, Quebec TIE, and Newfoundland, and National Parks) do not recognize a percentage breakdown of species but rather group species as contributing a major (greater than 26 percent) or minor (less than 26 percent) amount to the composition. Also included in Appendix 7 is a translation table that assigns a species composition percentage breakdown for those inventories that do not have a percentage breakdown.  

CAS species codes are derived from the species' Latin name using the first four letters of the Genus and the first four letters of the Species unless there is a conflict, then the last letter of the species portion of the code is changed. Unique codes are required for generic groups and hybrids. A species list has been developed representing every inventory species identified across Canada including hybrids, exotics and generic groups (Appendix 8). Generic groups represent situations where species were not required to be recognized past the generic name or where photo interpreters could not identify an individual species. A list of species that is represented by the generic groups by province, territory, or Park has also been developed and is presented in Appendix 9.  Error and missing value codes:*  

| Values         | Description |
| :------------  | :-------------- |
| Species codes  | **Link to possible values after #211** |
| NOT_NULL       | Source value is null |
| NOT_EMPTY      | Source value is and empty string (e.g. '') |
| NOT_IN_SET     | Source value is not in list of expected values |
| INVALID_VALUE  | Soure value is invalid (e.g. code is not the expected format) |


### SPECIES_PER_1 - SPECIES_PER_10

| Values     | Description |
| :--------- | :-------------- |
| 1 - 100    | Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add                up to 100% |
| -8888     | Source value is null |
| -9995     | Source value is not the expected type (e.g. not an integer) |
| -9999     | Source value is outside expected range (e.g. not between 0 and 100) |
| -9997     | Soure value is invalid (e.g. code is not the expected format) |
| -8887     | Soure value is not applicable (e.g. no forest info) |



### ORIGIN_UPPER, ORIGIN_LOWER

Stand origin is the average initiation year of codominant and dominant trees of the leading species within each layer of a polygon. Origin is determined either to the nearest year or decade. An upper and lower bound is used to identify CAS origin. The detailed stand origin table is presented in Appendix 10. 

| Values    | Description |
| :-------- | :-------------- |
| 0 - 2020  | Upper and lower bound of an age class |
| -8888     | Source value is null |
| -9995     | Source value is not the expected type (e.g. not an integer) |
| -9999     | Source value is outside expected range (e.g. not between 0 and 2020) |
| -9997     | Source value is invalid (e.g. not the correct format) |


### SITE_CLASS

Site class is an estimate of the potential productivity of land for tree growth. Site class reflects tree growth response to soils, topography, climate, elevation, and moisture availability. See Appendix 11 for the detailed site table.  

| Values | Description |
| :----- | :-------------- |
| U      | Unproductive - cannot support a commercial forest |
| P      | Poor - poor tree growth based on age height relationship |
| M      | Medium - medium tree growth based on age height relationship |
| G      | Good - medium tree growth based on age height relationship |
| NOT_NULL | Source value is null |
| NOT_EMPTY | Source value is an empty string (e.g. '') |
| NOT_IN_SET | Source value is not in list of expected values |
| NOT_APPLICABLE | Source value does not occur |


### SITE_INDEX

Site Index is an estimate of site productivity for tree growth. It is derived for all forested polygons based on leading species, height, and stand age based on a specified reference age. Site index is not available for most inventories across Canada. See Appendix 11 for the detailed site table.  

| Values   | Description |
| :-------- | :-------------- |
| 0 - 99 | Estimate of site productivity for tree growth based on a specified reference age |
| -8888     | Source value is null |
| -9995     | Source value is not the expected type (e.g. not a number) |
| -9999     | Source value is outside expected range (e.g. not between 1 and 99) |
| -8887     | Source value does not occur |


<a name=NFL_attributes></a>
## NFL Attributes

Non-forested attributes.


### CAS_ID

The attribute **CAS_ID** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| Values               | Description |
| :------------------- | :---------- |
| Alpha numeric string |  CAS stand identification - unique string for each polygon within CAS |
| NULL_VALUE           |  One of the source attributes is null |
| EMPTY_STRING         |  One of the source attributes is an empty string |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 


### SOIL_MOIST_REG

See <a href="#SOIL_MOIST_REG">SOIL_MOIST_REG</a> in the LYR table.

Soil moisture regime defined in the NFL table must be a value explicitly assigned to the NFL layer in the source data.

| Value      | Description |
| :--------- | :----- |
| D          | Dry - Soil retains moisture for a negligible period following precipitation with very rapid drained substratum |
| F          | Mesic - Soils retains moisture for moderately short to short periods following precipitation with moderately well                      drained substratum |
| M          | Moist - Soil retains abundant to substantial moisture for much of the growing season with slow soil infiltration |
| W          | Wet - Poorly drained to flooded where the water table is usually at or near the surface, or the land is covered by                    shallow water |
| A          | Aquatic - Permanent deep water areas characterized by hydrophytic vegetation (emergent) that grows in or at the surface                of water |
| NULL_VALUE | Source value is null |
| NOT_IN_SET | Source value is not in list of expected values |
| NOT_APPLICABLE | Source value does not occur |

Notes:
* When would NFL be different to LYR? https://github.com/edwardsmarc/CASFRI/issues/328


### STRUCTURE_PER

See <a href="#STRUCTURE_PER">STRUCTURE_PER</a> in the LYR table.

| Values                             | Description  |
| :--------------------------------- | :------ |
| 10, 20, 30, 40, 50, 60, 70, 80, 90 | When **STAND_STRUCTURE** = "H", used with horizontal stands to identify the percentage, in 10%                                        increments, strata within the polygon. Must add up to 100%. Only two strata represented by each                                        homogeneous descriptions are allowed per polygon |
| 100                                | When **STAND_STRUCTURE** = "S", "M", "C", value = 100 i.e., when there is no horizontal                                                structure |
| -9998                              | Source value is not an expected value (e.g. in cases where structure percent is a coded alpha                                          numeric with an expected list of codes) |
| -8888                              | Source value is null |
| -9995                              | Source value is not the expected type (e.g. not an integer) |
| -9999                              | Source value is outside expected range (e.g. not between 0 and 9) |



### LAYER

See <a href="#LAYER">LAYER</a> in the LYR table.

| Values   | Description   |
| :------- | :------- |
| 1 - 9, V | Identifies the layer number of a vegetation or non vegetation layer within a particular polygon. A maximum of 9 layers                can be identified. No two layers can have the same value within the same polygon |



### LAYER_RANK  
See <a href="#LAYER_RANK">LAYER_RANK</a> in the LYR table.

| Values | Description |
| :----- | :----- |
| 1 - 9  | Layer Rank - value assigned sequentially to layer of importance. Rank 1 is the most important layer followed by Rank 2,                etc.  |
| -8888  | Source value is null |
| -8887  | Translation is not applicable (e.g. no source attribute) |



### CROWN_CLOSURE 
See <a href="#CROWN_CLOSURE ">CROWN_CLOSURE</a> in the LYR table.

Crown closure defined in the NFL table must be a value explicitly assigned to the NFL layer in the source data.

| Values    | Description |
| :-------- | :-------------- |
| 0 - 100   | Upper and lower bound of a crown closure class |
| -8888     | Source value is null |
| -8889     | Source value is empty string (e.g. '') |
| -9995     | Source value is not the expected type (e.g. not an integer) |
| -9999     | Source value is outside expected range (e.g. not between 0 and 100) |
| -8887     | Source value is not applicable (e.g. not a forested polygon) |



### HEIGHT
See <a href="#HEIGHT ">HEIGHT</a> in the LYR table.

Height defined in the NFL table must be a value explicitly assigned to the NFL layer in the source data.

| Values    | Description |
| :-------- | :-------------- |
| 0 - 100   | Upper and lower bound of a height class |
| -8888     | Source value is null |
| -8889     | Source value is empty string (e.g. '') |
| -9995     | Source value is not the expected type (e.g. not an integer) |
| -9999     | Source value is outside expected range (e.g. not between 0 and 100) |
| -8887     | Source value is not applicable (e.g. not a forested polygon) |



### NAT_NON_VEG  

The Naturally Non-Vegetated class refers to land types with no vegetation cover. The maximum vegetation cover varies across Canada but is usually less than six or ten percent. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 12.  

| Values         | Description |
| :------------- | :----- |
| AP             | Alpine - high elevation exposed land     |
| LA             | Lake - ponds, lakes or reservoirs     |
| RI             | River - double-lined watercourse     |
| OC             | Ocean - coastal waters     |
| RK             | Rock or Rubble - bed rock or talus or boulder field     |
| SA             | Sand - sand dunes, sand hills, non recent water sediments     |
| SI             | Snow/Ice - ice fields, glaciers, permanent snow     |
| SL             | Slide - recent slumps or slides with exposed earth     |
| EX             | Exposed Land - other non vegetated land     |
| BE             | Beach - adjacent to water bodies     |
| WS             | Water Sediments - recent sand and gravel bars     |
| FL             | Flood - recent flooding including beaver ponds     |
| IS             | Island - vegetated or non vegetated     |
| TF             | Tidal Flats - non vegetated feature associated with oceans     |
| NOT_NULL       | Source value is null |
| NOT_EMPTY      | Source value is an empty string (e.g. '') |
| NOT_IN_SET     | Source value is not in list of expected values |
| NOT_APPLICABLE | Source value is not applicable (e.g. no NFL values to report) |
| INVALID_VALUE  | Source value is invalid (e.g. the combination of source attribute values does not have a valid translation rule                       defined) |


### NON_FOR_ANTH

Non-forested anthropogenic areas are influenced or created by humans. These sites may or may not be vegetated. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 12.  

| Values         | Description |
| :------------- | :----- |
| IN             | Industrial - industrial sites     |
| FA             | Facility/Infrastructure - transportation, transmission, pipeline     |
| CL             | Cultivated - pasture, crops, orchards, plantations     |
| SE             | Settlement - cities, towns, ribbon development     |
| LG             | Lagoon - water filled, includes treatment sites     |
| BP             | Borrow Pit - associated with facility/infrastructure     |
| OT             | Other - any not listed     |
| NOT_NULL       | Source value is null |
| NOT_EMPTY      | Source value is an empty string (e.g. '') |
| NOT_IN_SET     | Source value is not in list of expected values |
| NOT_APPLICABLE | Source value is not applicable (e.g. no NFL values to report) |
| INVALID_VALUE  | Source value is invalid (e.g. the combination of source attribute values does not have a valid translation rule                        defined) |



### NON_FOR_VEG  

Non-forested vegetated areas include all natural lands that have vegetation cover with usually less than 10% tree cover. These cover types can be stand alone or used in multi-layer situations. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 12.    

| Values         | Description |
| :------------- | :----- |
| ST             | Tall Shrub - shrub lands with shrubs > 2 meters tall     |
| SL             | Low Shrub - shrub lands with shrubs < 2 meters tall     |
| HF             | Forbs - herbaceous plants other than graminoids     |
| HE             | Herbs - no distinction between forbs and graminoids     |
| HG             | Graminoids - grasses, sedges, rushes, and reeds     |
| BR             | Bryoid - mosses and lichens     |
| OM             | Open Muskeg - wetlands less than 10% tree cover     |
| TN             | Tundra - flat treeless plains     |
| NOT_NULL       | Source value is null |
| NOT_EMPTY      | Source value is an empty string (e.g. '') |
| NOT_IN_SET     | Source value is not in list of expected values |
| NOT_APPLICABLE | Source value is not applicable (e.g. no NFL values to report) |
| INVALID_VALUE  | Source value is invalid (e.g. the combination of source attribute values does not have a valid translation rule                        defined) |


<a name=DST_attributes></a>
## DST Attributes

### CAS_ID

The attribute **CAS_ID** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| Values               | Description |
| :------------------- | :---------- |
| Alpha numeric string |  CAS stand identification - unique string for each polygon within CAS |
| NULL_VALUE           |  One of the source attributes is null |
| EMPTY_STRING         |  One of the source attributes is an empty string |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 



### DIST_TYPE_1 - DIST_TYPE_3

Disturbance identifies the type of disturbance history that has occurred or is occurring within the polygon. The type of disturbance, the extent of the disturbance and the disturbance year, if known, may be recorded. The disturbance may be natural or human -caused. Up to three disturbance events can be recorded with the oldest event described first. Silviculture treatments have been grouped into one category and include any silviculture treatment or treatments recorded for a polygon. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 13.  

| Values         | Description |
| :------------- | :-------------- |
| CO             | Cut - logging with known extent |
| PC             | Partial Cut - portion of forest has been removed, extent known or unknown |
| BU             | Burn - wildfires or escape fires |
| WF             | Windfall - blow down |
| DI             | Disease - root, stem, branch diseases |
| IK             | Insect - root, bark, leader, or defoliation insects |
| FL             | Flood - permanent flooding from blockage or damming |
| WE             | Weather - ice, frost, red belt |
| SL             | Slide - damage from avalanche, slump, earth or rock slides |
| OT             | Other - unknown or other damage |
| DT             | Dead Tops or Trees - dead or dying trees, cause unknown |
| SI             | Silviculture Treatments - Planting, Thinning, Seed Tree |
| NOT_NULL       | Source value is null |
| NOT_EMPTY      | Source value is an empty string (e.g. '') |
| NOT_IN_SET     | Source value is not in list of expected values |
| INVALID_VALUE  | Source value is invalid (e.g. the disturbance code does not match the expected format) |


### DIST_YEAR_1 - DIST_YEAR_3  

Disturbance year is the year a disturbance event occurred. The disturbance year may be unknown. Three disturbance years can be identified, one for each disturbance event.    

| Values       | Description |
| :----------- | :---------- |
|  1900 - 2020 | Disturbance Year - year that a disturbance event occurred |
| -8888        | Source value is null |
| -9995        | Source value is not the expected type (e.g. not an integer) |
| -9999        | Source value is outside expected range (e.g. not between 0 and 100) |
| -9997        | Source value is not valid (e.g. disturbance code is not the expected length) |


### DIST_EXT_UPPER_1 - DIST_EXT_UPPER_3, DIST_EXT_LOWER_1 - DIST_EXT_LOWER_3

Disturbance extent provides an estimate of the proportion of the polygon that has been affected by the disturbance listed. Extent codes and classes vary across Canada where they occur; therefore, CAS identifies upper and lower bounds for this category. Three disturbance extents can be identified, one for each disturbance event.    

| Values | Description |
| :--------------------------------------------------------------------------------------------------------------- | :-------------- |
| 10 - 100 | Upper and lower bound of extent class |
| -8888    | Source value is null |
| -9995    | Source value is not the expected type (e.g. not an integer) |
| -9999    | Source value is outside expected range (e.g. not between 0 and 100) |
| -9998    | Source value is not in the list of expected values |
| -8887    | Source value is not applicable (e.g. value does not occur in the source data) |

### LAYER

If a disturbance is linked to a specific layer in the source data, it can be assigned to the corresponding layer in CASFRI (See <a href="#LAYER">LYR table LAYER.</a>). If disturbances are not linked to a specific layer, a CASFRI error code is assigned. In some cases the source inventory may arbitrarily assign all disturbances to layer 1. If this is the case, and it is documented as such in the source data specifications, an error code will be assigned in CASFRI since the true layers associated with disturbance are unknown.

| Values   | Description |
| :------- | :------- |
| 1 - 9, V | Identifies the layer number of a vegetation or non vegetation layer within a particular polygon. A maximum of 9 layers                can be identified. No two layers can have the same value within the same polygon |

Note:
Update possible values after #272


<a name=ECO_attributes></a>
## ECO Attributes

Ecological attributes are generally not included or are incompletely recorded in typical forest inventories across Canada. Two attributes have been included for CAS: ecosite and wetland. These attributes are to be translated or derived for CAS from other attributes whenever possible.  


### CAS_ID
The attribute **CAS_ID** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| Values               | Description |
| :------------------- | :---------- |
| Alpha numeric string |  CAS stand identification - unique string for each polygon within CAS |
| NULL_VALUE           |  One of the source attributes is null |
| EMPTY_STRING         |  One of the source attributes is an empty string |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 


### WETLAND_TYPE

The wetland classification scheme used for CAS follows the classes developed by the National Wetlands Working Group<sup>2</sup> and modified by Vitt and Halsey<sup>3,4</sup>. The scheme was further modified to take into account coastal and saline wetlands. The CAS wetland attribute is composed of four parts: wetland class, wetland vegetation modifier, wetland landform modifier, and wetland local modifier.  

Five major wetland classes are recognized based on wetland development from hydrologic, chemical, and biotic gradients that commonly have strong cross-correlations. Two of the classes; fen and bog, are peat-forming with greater than 40 cm of accumulated organics. The three non-peat forming wetland types are shallow open water, marsh (fresh or salt water), and swamp. A non-wetland class is also included. The Vegetation Modifier is assigned to a wetland class to describe the amount of vegetation cover. The Landform Modifier is a modifier label used when permafrost, patterning, or salinity are present. The Local Landform Modifier is a modifier label used to define the presence or absence of permafrost features or if vegetation cover is shrub or graminoid dominated.  

The detailed wetland table, CAS code set, and CAS translation rule set are presented in Appendix 14. Not many forest inventories across Canada provide a wetland attribute. Some inventories have complete or partial wetland attributes while others will need to have wetland classes derived from other attributes or ecosite information. The level of wetland detail that is possible to describe from a particular inventory database is dependent on the attributes that already exist. A rule set for each province or territory that identifies a method to derive wetland attributes using forest attributes or ecosite data is presented in Appendix 15. The wetland derivation may not be complete nor will it always be possible to derive or record all four wetland attributes in the CAS database. 

| Values | Description |
| :----- | :----- |
| B      | Bog - > 40 cm peat, receive water from precipitation only, low in nutrients and acid, open or wooded with sphagnum moss |
| F      | Fen - > 40 cm of peat, groundwater and runoff flow, mineral rich with mostly brown mosses, open, wooded or treed |
| S      | Swamp - woody vegetation with > 30 shrub cover or 6% tree cover. Mineral rich with periodic flooding and near permanent                subsurface water. Various mixtures of mineral sediments and peat |
| M      | Marsh - emergent vegetation with < 30% shrub cover, permanent or seasonally inundated with nutrient rich water |
| O      | Shallow Open Water - freshwater lakes < 2 m depth |
| T      | Tidal Flats - ocean areas with exposed flats |
| E      | Estuary - mixed freshwater/saltwater marsh areas |
| W      | Wetland - no distinction of class |
| Z      | Not Wetland - upland areas |


### WET_VEG_COVER

| Values | Description |
| :----- | :----- |
| F      | Forested - closed canopy > 70% tree cover |
| T      | Wooded - open canopy > 6% to 70% tree cover |
| O      | Open Non-Treed Freshwater - < 6% tree cover with shrubs |
| C      | Open Non-Treed Coastal - < 6% tree cover, with shrubs |
| M      | Mud - no vegetation cover |


### WET_LANDFORM_MOD

| Values | Description |
| :----- | :----- |
| X      | Permafrost Present |
| P      | Patterning Present |
| N      | No Permafrost or Patterning Present |
| A      | Saline or Alkaline Present |


### WET_LOCAL_MOD

| Values | Description |
| :----- | :----- |
| C      | Collapse Scar Present in permafrost area |
| R      | Internal Lawn With Islands of Forested Peat Plateau |
| I      | Internal Lawns Present (permafrost was once present) |
| N      | Internal Lawns Not Present |
| S      | Shrub Cover > 25% |
| G      | Graminoids With Shrub Cover < 25%      |
  

<sup>2</sup>National Wetlands Working Group 1988. Wetlands of Canada. Ecological Land Classification Series No. 24.  

<sup>3</sup>Alberta Wetland Inventory Standards. Version 1.0. June 1977. L. Halsey and D. Vitt.  

<sup>4</sup> Alberta Wetland Inventory Classification System. Version 2.0. April 2004. Halsey, et. al.  

  

### ECOSITE

Ecosites are site-level descriptions that provide a linkage between vegetation and soil/moisture and nutrient features on the site. The detailed ecosite table is presented in Appendix 16. A common attribute structure for ecosite is not provided for CAS because ecosite is not available for most forest inventories across Canada nor can it be derived from existing attributes. An ecosite field is included in CAS to accommodate inventories that do include ecosite data. The original inventory attribute value is captured in CAS. For example some codes:  Quebec = MS25S, Ontario = ES11 or 044 or S147N and Alberta = UFb1.2.    

| Values      | Description      |
| :---------- | :---------- |
| A-Z / 0-199 | Ecosite - an area defined by a specific combination of site, soil, and vegetation characteristics as influenced by                     environmental factors |

<a name=GEO_attributes></a>
## GEO Attributes 

Geometry attributes are calculated by the translation engine.

### CAS_ID

The attribute **CAS_ID** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| Values               | Description |
| :------------------- | :---------- |
| Alpha numeric string |  CAS stand identification - unique string for each polygon within CAS |
| NULL_VALUE           |  One of the source attributes is null |
| EMPTY_STRING         |  One of the source attributes is an empty string |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 


### GEOMETRY

The attribute **GEOMETRY** returns the geometry and validates if necessary. If valid geometry cannot be made error code is returned.

| Values                | Description      |
| :-------------------- | :---------- |
| postgreSQL geometries | Records the polygon associated with each cas_id |




## Bibliography  



### British Columbia

Ministry of Forests 1982. Forest and Range Inventory Manual, Chapter 3, Forest Classification.  

Ministry of Forests 1992. Forest Inventory Manual. Volumes 1 - 5.  

Resource Inventory Committee 2002. Vegetation Resources Inventory, Version 2.4. Photo Interpretation Procedures. Ministry of Sustainable  
Resource Management. Terrestrial Information Branch (<http://www.for.gov.bc.ca/risc>).  

Sandvoss, M, B. McClymont and C. Farnden (compilers) 2005. A User’s Guide to the Vegetation Resources Inventory. Timberline Forest Inventory  
Consultants.  

  

### Alberta 

Alberta Department of Energy and Nat. Res. 1985. Alberta Phase 3 Forest Inventory: An Overview. Rep. No. I/86.  

Alberta Department of Energy and Nat. Res. 1985. Alberta Phase 3 Inventory: Forest Cover Type Specifications. Rep. No. 58.  

Alberta Environmental Protection 1991. Alberta Vegetation Inventory Standards Manual, Version 2.1. Resource Data Division. Data Acquisition  
Branch.  

Alberta Sustainable Resource development. 2005. Alberta Vegetation Inventory Standards. Version 2.1.1 March 2005. Chapter 3 - Vegetation  
Inventory Standards and Data Model Documents. Resource Information Branch.  

Halsey L. and D.H. Vitt. 1977 Alberta Wetland Inventory Standards. Version 1.0. June.  

Halsey L., D.H. Vitt, D. Beilman, S. Crow, S. Meehelcic, and R. Wells. 2004. Alberta Wetland Inventory Classification System Version 2.0.  
Alberta Sustainable Resource Development, Resource Data Branch. Pub. No, T/031.  



### Saskatchewan

Lindenas, D.J. 1985. Specifications for the Interpretation and Mapping of Aerial Photographs in the Forest Inventory Section. Sask. Dept. Parks and Renew. Res. Internal Manual.  

Saskatchewan Environment 2004. Saskatchewan Forest Vegetation Inventory, Version 4.0.  

Forest Service.  
(www.se.gov.sk.ca/forests/forestmanagement/Sask_Leg_Manuals.htm.  

  

### Manitoba

Manitoba Conservation. Prior to 1992. Forest Inventory Manual 1.0 and 1.1. Forest Inventory and Resource Analysis.  

Manitoba Conservation. 1992 - 1996. Forest Inventory Manual 1.2. Forest Inventory and Resource Analysis.  

Manitoba Conservation. 1996 - 1997. Forest Inventory Manual 1.3. Forest Inventory and Resource Analysis.  

Manitoba Conservation. 2001. Forest Lands Inventory Manual 1.1. Forest Inventory and Resource Analysis.  

Louisiana Pacific Canada Ltd. 2004. FLI User Guide (Draft). Prepared by The Forestry Corp. Ontario  

Ontario Ministry of Natural Resources. 1996. Specifications for Forest Resources Inventory Photo Interpretation. Updated Mar. 1996.  

Ontario Ministry of Natural Resources. 2001. Specifications for Forest Resources Inventory Photo Interpretation. Updated Sept. 2001.  

Ontario Ministry of Natural Resources. 2007. Ontario Forest Resources Inventory Photo Interpretation Specifications. Updated Dec_2007.  

Ontario Ministry of Natural Resources. 2010. Ontario Forest Resources Inventory Photo Interpretation Specifications. Updated Dec_2010.  

OMNR, April 2001. Forest Information Manual. Toronto: Queen’s Printer for Ontario. 400 pp.  

OMNR, April 2007. Forest Information Manual. Toronto: Queen’s Printer for Ontario. 107 pp.  
(<http://ontariosforests.mnr.gov.on.ca/ontariosforests.cfm>)  

Pikangikum First Nation. 2003. Whitefeather Forest FRI/FEC Procedures Manual. Internal Document prepared by Timberline Forest Inventory  
Consultants Ltd.  

Eabametoong and Mishkeegogamang First Nation. 2007. FRI/FEC Procedures Manual. Internal Document prepared by Timberline Natural Resource Group  
Ltd.  

  

### Quebec

Foret Quebec. 2003. Normes de Cartographie Ecoforestiere. Troisieme Inventaire Ecoforestier. Ministere des Ressources Naturelles, de la  
Faune et des Parcs du Quebec. Direction des Inventaires Forestiers.  

Foret Quebec. 2008. Norme de Stratification Ecoforestiere. Quatrieme Inventaire Ecoforestier.  

Direction des Inventaires Forestiers.  

  

### Prince Edward Island

Prince Edward Island Dept. of Agric. and For. 2001. Photo Interpretation Specifications.  

Province of Prince Edward Island. Natural Resources Division, Revised 2001.  

  

### New Brunswick

Dept. of Nat. Resources. 2005. New Brunswick Integrated Land Classification System. Forest Management Branch  

  

### Nova Scotia

Dept. of Nat. Resources 2006. Photo Interpretation Specifications. Forestry Division. Manual FOR 2006-1.  

  

### Newfoundland and Labrador

Dept. of Nat. Resources 2006. Photo Interpretation Procedures and Technical Specifications.  

Forestry Services Branch.  

  

### Yukon Territory

Yukon Energy, Mines, and Resources. 2006. Yukon Vegetation Inventory Manual. Version 2.1.  

Forest Management Branch.  



### Northwest Territories

Dept. of Energy and Natural Resources 2004. Northwest Territories Forest Vegetation Photo Interpretation, Transfer and Database Standards. Forest Resources, Forest Management Division.  

Dept. of Energy and Natural Resources. 2006. Northwest Territories Forest Vegetation Inventory Standards with Softcopy Supplements, Version  
3.0. Forest Resources, Forest Management Division.  

  

### Prince Albert National Park

Padbury, G.E., W.K. Head, and W.E. Souster. 1978. Biophysical Resource Inventory of Prince Albert National Park, Saskatchewan. Saskatchewan  
Institute of Pedology Publication S185, Saskatoon.  

Fitzsimmons, M. 1998. Prince Albert National Park Forest Cover Data in Vector Format.  
<http://daac.ornl.gov/boreas/STAFF/panpfcov/comp/PNP_For_Cov.txt>  

  

### Wood Buffalo National Park

Air Photo Analysis Associates. 1979. Biophysical inventory of Wood Buffalo National Park.  

Prepared for Department of Indian and Northern Affairs, Parks Canada. Prairie Region.  

WBNPBiophysical. 2001. SMMS Metadata Report.  

  

### General

Gillis, M.D.; Leckie, D.G. 1993. Forest Inventory Mapping Procedures Across Canada.  

Petawawa National Forestry Institute, Information Report PI-X-114.  

Leckie D.G and Gillis M.D. 1995 Forest Inventory in Canada with emphasis on map production.  

The Forestry Chronicle 71 (1): 74 - 88.  

National Wetlands Working Group 1988. Wetlands of Canada. Ecological Land Classification Series No. 24.  



##  Appendices  



The appendices are listed below and can be viewed or edited using the cas_appendices.xlsx workbook located in the github specifications folder.  

 - Appendix 1 Current Canadian Inventories  
 - Appendix 2 Data Structure and Data Dictionary  
 - Appendix 3 Stand Structure - Summary of Canadian Forest Inventories  
 - Appendix 4 Soil Moisture Regime - Summary of Canadian Forest Inventories and CAS Conversion  
 - Appendix 5 Crown Closure - Summary of Canadian Forest Inventories  
 - Appendix 6 Stand Height - Summary of Canadian Forest Inventories  
 - Appendix 7a Species Composition - Summary of Canadian Forest Inventories  
 - Appendix 7b CAS Species Percent Translation (For Forest Inventories that do not provide species percent)  
 - Appendix 8 CAS Species List and Codes  
 - Appendix 9 CAS Generic Species Group List  
 - Appendix 10 Stand Origin (Age) - Summary of Canadian Forest Inventories  
 - Appendix 11 Site Class and Site Index and CAS Conversion  
 - Appendix 12a Non-Forested, Non-Vegetated, and Unproductive Forest - Summary of Canadian Forest Inventories  
 - Appendix 12b CAS Codes Non-Forested, Non-Vegetated, and Unproductive Forest Codes  
 - Appendix 12c CAS Non-Forested, Non-Vegetated, and Unproductive Forest Conversion  
 - Appendix 13a Disturbance History - Summary of Canadian Forest Inventories  
 - Appendix 13b Disturbance History - CAS Disturbance History Codes  
 - Appendix 13c Disturbance History - CAS Conversion  
 - Appendix 14a Wetland - Summary of Canadian Forest Inventories  
 - Appendix 14b Wetland - CAS Wetland Conversion  
 - Appendix 14c Wetland - CAS Wetland Codes  
 - Appendix 15 Procedures for CAS Wetland Derivation  
 - Appendix 16 Ecosite - Summary of Canadian Forest Inventories  
 - Appendix 17 Sample of Export Procedure  
