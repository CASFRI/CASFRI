# COMMON ATTRIBUTE SCHEMA (CAS) FOR FOREST INVENTORIES ACROSS CANADA

Prepared by: John A. Cosco, Chief Inventory Forester, February 2011

Revised by: The CASFRI Project Team, February 2019

# Introduction

Canada’s vast boreal ecosystem hosts one of the most diverse bird communities in North America. Development pressure within the boreal region is on the increase, and there is an urgent need to understand the impact of changing habitats on boreal bird populations and to make sound management decisions. The Boreal Avian Modeling Project was initiated to help address the lack of basic information on boreal birds and their habitats across boreal forests in Canada. The need to effectively manage bird species and their habitats has resulted in the effort to collect and gather data across Canada to develop models that will predict bird abundance and distribution, and that will clarify population and habitat associations with climate and land cover.

Current national databases developed from satellite-based products using biophysical variables have limited application at regional levels because many bird species are sensitive to variation in canopy tree species composition, height, and age; vegetation attributes that satellite-based products cannot measure. Because satellite-based land cover maps lack the thematic detail needed to model the processes of stand growth, succession, and regeneration, avian habitat models derived from satellite land cover data cannot be used to link forest management actions to the desired biotic indicators at the scale of forest tenure areas.

Digital forest inventory data can overcome many of the deficiencies identified with satellitebased land cover data. These data exist for most operational and planned commercial forest tenures in the Canadian boreal forest; however, differences among data formats, attributes, and standards across the various forest inventories make it difficult to develop models that are comparable and can be consistently applied across regions. To do so, it is necessary to address the variation between different forest inventories and bring all available inventories into one explicitly defined database where attributes are consistently defined without loss of precision. The starting point is to review all forest inventory classifications and develop a set of common attributes. This document addresses the inventory review developed for the Boreal Avian Monitoring Project; this review is called the Common Attribute Schema (CAS).

# Common Attribute Schema

The common attribute schema (CAS) is a comprehensive attribute classification suitable for avian habitat modeling. Its development requires the selection of vegetation cover attributes useful for avian habitat modeling, and the assignment of common codes for each attribute that are broad enough to capture all relevant existing forest inventory attributes. CAS attributes represent the most common attributes that are consistently recorded in forest inventories across Canada including: stand structure (layers), moisture regime, crown closure, species composition, height, age (origin), site class or site index,
non-forested cover types, non-vegetated cover types, and disturbance history. CAS also includes two attributes of ecological interest: ecosite and wetland. These two attributes are not common to most forest inventories across Canada; however, these attributes are considered important for avian habitat models and can possibly be acquired from other sources or partially or wholly derived from other attributes.

Development of the CAS attribute codes and rule sets for inventory attribute code conversion to CAS codes required an extensive review of previous and current inventory standards and specifications across Canada. Gillis and Leckie<sup>1</sup> provided a good starting point for review of previous inventory standards. More current and other inventory standards and documents are listed in the bibliography. A summary of recent or current inventories across Canada are presented in Appendix 1. These inventories are the most likely sources for data that can contribute to the avian bird modeling project.

Based on the review, detailed tables were produced to summarize each inventory standard by province and territory. Two national parks, Wood Buffalo and Prince Albert are included. Conversion rule sets were then produced as part of the detailed tables to identify how each province or territory inventory attribute codes translate into CAS attribute codes. Detailed tables and conversion rule sets for each CAS attribute are presented in Appendices noted in the appropriate sections of this document.

Although many CAS attributes have a one-to-one conversion, not all do; some are identified by an interval or class that has an upper and lower bound (lower bound is > and the upper bound is <). Interval coding for height, crown closure, age, and similar quantitative attributes is a unique feature of CAS. Crown closure, height, age, and disturbance extent use bounds to define an attribute class. For example, the CAS captures crown closure as an interval providing two values, the lower bound and upper bound. In the Alberta Vegetation Inventory, crown closure is captured in four cover classes: A, B, C and D, while the British Columbia Vegetation Resource Inventory captures crown closure as values ranging from 1 to 100 to the nearest 1 percent. In CAS, an Alberta “B” - value would be represented as an interval: 31 for the lower bound and 50 for the upper bound. A British Columbia crown closure value of 36 would be represented as a CAS value of 36 for both the lower and upper bounds. All of the information contained in the original inventories is preserved and the attributes are not converted to a
common resolution or set of values.

Attributes for CAS are stored in six attribute files to facilitate conversion and translation:

1)  Header (HDR) attributes - values assigned to all polygons based on provenance or reference information;

2)  CAS Base Polygon (CAS) attributes - values that identify a polygon and provide a link between the CAS polygon and the original inventory polygon;

3)  Forest-Level (LYR) attributes - values that pertain to the polygon for productive and non-productive forest land;

4)  Non-Forest Land (NFL) attributes - values that pertain to naturally non-vegetated, non-forest anthropogenic, and non-forest vegetated land;

5)  Disturbance history (DST) attributes - values that pertain to any disturbance that has occurred in a polygon including type, year, and extent; and

6)  Ecological specific (ECO) attributes - values representing ecosites and wetlands.

The main body of this report (Sections 2.1 through 2.3 and Section 3) defines each of the six attribute categories and tabulates the attributes and their characteristics. A summary of the data structure and data dictionary is presented in Appendix 2.

Each inventory data base has a unique data structure. A conversion procedure must be documented describing how to load the source inventory into CAS. A sample procedure is presented in Appendix 16.

<sup>1</sup> Gillis, M.D.; Leckie, D.G. 1993. Forest Inventory Mapping Procedures Across Canada. Petawawa National Forestry Institute, Information Report PI-X-114.

## Header Information (HDR)

Header information is a primary element of CAS. Header information identifies the source data set including jurisdiction, spatial reference, ownership, tenure type, inventory type, inventory version, inventory start and finish date and the year of acquisition for CAS. These attributes are detailed on the following pages.

### Year of Aerial Photography

Photo Year is the year in which the inventory was considered initiated and completed. An inventory can take several years to complete; therefore, Photo Year Minimum and Maximum dates are included to identify the interval for when the inventory was completed. In some cases inventory reference year and air photo year are the same. Several years of successive or periodic acquisition are possible; therefore, a minimum and a maximum year are recorded.

> Note: can be determined in 3 ways: spatial, tabular, fixed

| PHOTO_YEAR_MIN and PHOTO_YEAR_MAX                          | Attribute Value |
| :------------------------------------------------------------- | :-------------- |
| Photo Year Minimum - earliest year of aerial photo acquisition | 1960 - 2020     |
| Photo Year Maximum - last year of aerial photo acquisition     | 1960 - 2020     |

## CAS Forest and Non-Forest Attributes (LYR)

### Crown Closure

Crown closure is an estimate of the percentage of ground area covered by vertically projected tree crowns, shrubs, or herbaceous cover. Crown closure is usually estimated independently for each layer. Crown closure is commonly represented by classes and differs across Canada; therefore, CAS recognizes an upper and lower percentage bound for each class. The detailed crown closure table is presented in Appendix 5.

| CROWN_CLOSURE_UPPER and CROWN_CLOSURE_LOWER    | Attribute Value |
| :------------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a crown closure class | 0 - 100         |
| Lower Bound - lower bound of a crown closure class | 0 - 100         |
| Blank - no value                                   | NA              |

*Error and missing value codes*

|Error_type | Data_type    | Error_code | Description                       |
| :-------- | :----------- | :--------- | :-------------------------------- |
| INFTY     | int or float | -1         | positive or negative infinity     |
| ERRCODE   | all types    | -9999      | invalid values that are not null  |
| UNDEF     | all types    | -8888      | undefined value - true null value |

### Height

Stand height is based on an average height of leading species of dominant and co-dominant heights of the vegetation layer and can represent trees, shrubs, or herbaceous cover. Height can be represented by actual values or by height class and its representation is variable across Canada; therefore, CAS will use upper and lower bounds to represent height. The detailed height table is presented in Appendix 6.

| HEIGHT_UPPER and HEIGHT_LOWER              | Attribute Value |
| :------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a height class. | 0 - 100         |
| Lower Bound - lower bound of a height class. | 0 - 100         |

*Error and missing value code*

|Error_type | Data_type    | Error_code | Description                       |
| :-------- | :----------- | :--------- | :-------------------------------- |
| INFTY     | int or float | -1         | positive or negative infinity     |
| ERRCODE   | all types    | -9999      | invalid values that are not null  |
| UNDEF     | all types    | -8888      | undefined value - true null value |

### Species Composition

Species composition is the percentage of each tree species represented within a forested polygon by layer. Species are listed in descending order according to their contribution based on crown closure, basal area, or volume depending on the province or territory. A total of ten species can be used in one label. The CAS attribute will capture estimation to the nearest percent; however, most inventories across Canada describe species to the nearest 10% (in actual percent value or multiples of 10). Species composition for each forest stand and layer must sum to 100%.

The detailed table for species composition is presented in Appendix 7. Some inventories (Alberta Phase 3, Saskatchewan UTM, Quebec TIE, and Newfoundland, and National Parks) do not recognize a percentage breakdown of species but rather group species as contributing a major (greater than 26 percent) or minor (less than 26 percent) amount to the composition. Also included in Appendix 7 is a translation table that assigns a species composition percentage breakdown for those inventories that do not have a percentage breakdown.

CAS species codes are derived from the speciesâ€Ÿ Latin name using the first four letters of the Genus and the first four letters of the Species unless there is a conflict, then the last letter of the species portion of the code is changed. Unique codes are required for generic groups and hybrids. A species list has been developed representing every inventory species identified across Canada including hybrids, exotics and generic groups (Appendix 8). Generic groups represent situations where species were not required to be recognized past the generic name or where photo interpreters could not identify an individual species. A list of species that is represented by the generic groups by province, territory, or Park has also been developed and is presented in Appendix 9.

**Species type**

| SPECIES_1, SPECIES_2, SPECIES_3, SPECIES_4, SPECIES_5, SPECIES_6, SPECIES_7, SPECIES_8, SPECIES_9, SPECIES_10 | Attribute Value |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species (SPECIES_#) - Example: Populus tremuloides, Trembling Aspen. Ten species can be listed per layer per polygon.                                                                             | POPU TREM       |

*Error and missing value codes*

|Error_type       | Data_type    | Error_code  | Description                       |
| :-------------- | :----------- | :---------- | :-------------------------------- |
| ERRCODE         | all types    | -9999       | invalid values that are not null  |
| UNDEF           | all types    | -8888       | undefined value - true null value |
| SPECIES_ERRCODE | string       | "XXXX ERRC" |                                   |
| MISSCODE        | string       | -1111       | empty string ("")                 |

**Species percentage**

| SPECIES_PER_1, SPECIES_PER_2, SPECIES_PER_3, SPECIES_PER_4, SPECIES_PER_5, SPECIES_PER_6, SPECIES_PER_7, SPECIES_PER_8, SPECIES_PER_9, SPECIES_PER_10 | Attribute Value |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species Percent (SPECIES_PER_#) - Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100%.                             | NA              |

*Error and missing value codes*

|Error_type | Data_type    | Error_code | Description                       |
| :-------- | :----------- | :--------- | :-------------------------------- |
| INFTY     | int or float | -1         | positive or negative infinity     |
| ERRCODE   | all types    | -9999      | invalid values that are not null  |
| UNDEF     | all types    | -8888      | undefined value - true null value |

