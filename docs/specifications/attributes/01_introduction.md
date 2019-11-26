# COMMON ATTRIBUTE SCHEMA (CAS) FOR FOREST INVENTORIES ACROSS CANADA  

Prepared by: John A. Cosco, Chief Inventory Forester, February 2011

Revised by: The CASFRI Project Team, November 2019

  


## 1.0 Introduction  

Canada's vast boreal ecosystem hosts one of the most diverse bird communities in North America. Development pressure within the boreal region is on the increase, and there is an urgent need to understand the impact of changing habitats on boreal bird populations and to make sound management decisions. The Boreal Avian Modeling Project was initiated to help address the lack of basic information on boreal birds and their habitats across boreal forests in Canada. The need to effectively manage bird species and their habitats has resulted in the effort to collect and gather data across Canada to develop models that will predict bird abundance and distribution, and that will clarify population and habitat associations with climate and land cover.  

Current national databases developed from satellite-based products using biophysical variables have limited application at regional levels because many bird species are sensitive to variation in canopy tree species composition, height, and age; vegetation attributes that satellite-based products cannot measure. Because satellite-based land cover maps lack the thematic detail needed to model the processes of stand growth, succession, and regeneration, avian habitat models derived from satellite land cover data cannot be used to link forest management actions to the desired biotic indicators at the scale of forest tenure areas.  

Digital forest inventory data can overcome many of the deficiencies identified with satellitebased land cover data. These data exist for most operational and planned commercial forest tenures in the Canadian boreal forest; however, differences among data formats, attributes, and standards across the various forest inventories make it difficult to develop models that are comparable and can be consistently applied across regions. To do so, it is necessary to address the variation between different forest inventories and bring all available inventories into one explicitly defined database where attributes are consistently defined without loss of precision. The starting point is to review all forest inventory classifications and develop a set of common attributes. This document addresses the inventory review developed for the Boreal Avian Monitoring Project; this review is called the Common Attribute Schema (CAS).  



### 1.1 Common Attribute Schema  

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

### 1.2 Error and Missing Value Codes  

Error codes are needed during translation if source values are invalid, null, or missing. In CASFRI v5, error codes have been designed to match the attribute type and to reflect the type of error that was encountered. For example, an integer attribute will have error codes reported as integers (e.g. -9999) whereas text attributes will have errors reported as text (e.g. INVALID). Different error codes are reported depending on the cause.  [Click here to view specific error codes for individual attritubes](https://edwardsmarc.github.io/CASFRI/specifications/errors/errors_specific.csv).

| Class          | Type               | Description                              | Text code         | Numeric code |
| -------------- | ------------------ | ---------------------------------------- | ----------------- | ------------ |
| Special values | -Infinity          | Negative infinity                        | MINUS_INF         | -2222        |
|                | +Infinity          | Positive infinity                        | PLUS_INF          | -2221        |
| Missing values | Empty string       | Missing that is not null                 | EMPTY_STRING      | -8889        |
|                | Null               | Undefined value - true null value        | NULL_VALUE        | -8888        |
|                | Not applicable     | Target attribute not in source table     | NOT_APPLICABLE    | -8887        |
|                | Unknown value      | Non-null value that is not known         | UNKNOWN_VALUE     | -8886        |
|                | Unused value       | Non-null value that is not used in CAS   | UNUSED_VALUE      | -8885        |
| Invalid values | Out of range       | Value is outside the range of values     | OUT_OF_RANGE      | -9999        |
|                | Not member of set  | Value is not a member of a set or list   | NOT_IN_SET        | -9998        |
|                | Invalid value      | Invalid value                            | INVALID_VALUE     | -9997        |
|                | Precision too high | Precision is greater than allowed        | WRONG_PRECISION   | -9996        |
|                | Wrong data type    | Value is of the wrong data type          | WRONG_TYPE        | -9995        |
| Generic        | Translation error  | Generic translation error                | TRANSLATION_ERROR | -3333        |
| Geometry       | Invalid geometry   | Invalid geometry in one or more polygons | INVALID_GEOMETRY  | -7779        |
|                | No intersect       | FRI does not intersect any polygons      | NO_INTERSECT      | -7778        |
