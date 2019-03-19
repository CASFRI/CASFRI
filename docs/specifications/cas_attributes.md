
  - [Introduction](#introduction)
  - [Common Attribute Schema](#common-attribute-schema)
      - [Error and Missing Value Codes](#error-and-missing-value-codes)
      - [Header Information (HDR)](#header-information-hdr)
          - [CASFRI Identification](#casfri-identification)
      - [CASFRI Identification](#casfri-identification-1)
          - [CAS\_ID](#cas_id)
          - [Year of Aerial Photography](#year-of-aerial-photography)
      - [CAS Forest and Non-Forest Attributes
        (LYR)](#cas-forest-and-non-forest-attributes-lyr)
          - [Crown Closure](#crown-closure)
          - [Height](#height)
          - [Species Composition](#species-composition)

<center>

<br><br><b><font size=+2>COMMON ATTRIBUTE SCHEMA (CAS)<br>FOR FOREST
INVENTORIES ACROSS CANADA</font></b> <br><br><br> Prepared by: John A.
Cosco, Chief Inventory Forester, February 2011<br> Revised by: The
CASFRI Project Team, March 2019

</center>

<br><br>

# Introduction

Canada’s vast boreal ecosystem hosts one of the most diverse bird
communities in North America. Development pressure within the boreal
region is on the increase, and there is an urgent need to understand the
impact of changing habitats on boreal bird populations and to make sound
management decisions. The Boreal Avian Modeling Project was initiated to
help address the lack of basic information on boreal birds and their
habitats across boreal forests in Canada. The need to effectively manage
bird species and their habitats has resulted in the effort to collect
and gather data across Canada to develop models that will predict bird
abundance and distribution, and that will clarify population and habitat
associations with climate and land cover.

Current national databases developed from satellite-based products using
biophysical variables have limited application at regional levels
because many bird species are sensitive to variation in canopy tree
species composition, height, and age; vegetation attributes that
satellite-based products cannot measure. Because satellite-based land
cover maps lack the thematic detail needed to model the processes of
stand growth, succession, and regeneration, avian habitat models derived
from satellite land cover data cannot be used to link forest management
actions to the desired biotic indicators at the scale of forest tenure
areas.

Digital forest inventory data can overcome many of the deficiencies
identified with satellitebased land cover data. These data exist for
most operational and planned commercial forest tenures in the Canadian
boreal forest; however, differences among data formats, attributes, and
standards across the various forest inventories make it difficult to
develop models that are comparable and can be consistently applied
across regions. To do so, it is necessary to address the variation
between different forest inventories and bring all available inventories
into one explicitly defined database where attributes are consistently
defined without loss of precision. The starting point is to review all
forest inventory classifications and develop a set of common attributes.
This document addresses the inventory review developed for the Boreal
Avian Monitoring Project; this review is called the Common Attribute
Schema (CAS).

# Common Attribute Schema

The common attribute schema (CAS) is a comprehensive attribute
classification suitable for avian habitat modeling. Its development
requires the selection of vegetation cover attributes useful for avian
habitat modeling, and the assignment of common codes for each attribute
that are broad enough to capture all relevant existing forest inventory
attributes. CAS attributes represent the most common attributes that are
consistently recorded in forest inventories across Canada including:
stand structure (layers), moisture regime, crown closure, species
composition, height, age (origin), site class or site index,
non-forested cover types, non-vegetated cover types, and disturbance
history. CAS also includes two attributes of ecological interest:
ecosite and wetland. These two attributes are not common to most forest
inventories across Canada; however, these attributes are considered
important for avian habitat models and can possibly be acquired from
other sources or partially or wholly derived from other attributes.

Development of the CAS attribute codes and rule sets for inventory
attribute code conversion to CAS codes required an extensive review of
previous and current inventory standards and specifications across
Canada. Gillis and Leckie<sup>1</sup> provided a good starting point for
review of previous inventory standards. More current and other inventory
standards and documents are listed in the bibliography. A summary of
recent or current inventories across Canada are presented in Appendix 1.
These inventories are the most likely sources for data that can
contribute to the avian bird modeling project.

Based on the review, detailed tables were produced to summarize each
inventory standard by province and territory. Two national parks, Wood
Buffalo and Prince Albert are included. Conversion rule sets were then
produced as part of the detailed tables to identify how each province or
territory inventory attribute codes translate into CAS attribute codes.
Detailed tables and conversion rule sets for each CAS attribute are
presented in Appendices noted in the appropriate sections of this
document.

Although many CAS attributes have a one-to-one conversion, not all do;
some are identified by an interval or class that has an upper and lower
bound (lower bound is \> and the upper bound is \<). Interval coding for
height, crown closure, age, and similar quantitative attributes is a
unique feature of CAS. Crown closure, height, age, and disturbance
extent use bounds to define an attribute class. For example, the CAS
captures crown closure as an interval providing two values, the lower
bound and upper bound. In the Alberta Vegetation Inventory, crown
closure is captured in four cover classes: A, B, C and D, while the
British Columbia Vegetation Resource Inventory captures crown closure as
values ranging from 1 to 100 to the nearest 1 percent. In CAS, an
Alberta â€œBâ€ - value would be represented as an interval: 31 for the
lower bound and 50 for the upper bound. A British Columbia crown closure
value of 36 would be represented as a CAS value of 36 for both the lower
and upper bounds. All of the information contained in the original
inventories is preserved and the attributes are not converted to a
common resolution or set of values.

Attributes for CAS are stored in six attribute files to facilitate
conversion and translation:

1)  Header (HDR) attributes - values assigned to all polygons based on
    provenance or reference information;

2)  CAS Base Polygon (CAS) attributes - values that identify a polygon
    and provide a link between the CAS polygon and the original
    inventory polygon;

3)  Forest-Level (LYR) attributes - values that pertain to the polygon
    for productive and non-productive forest land;

4)  Non-Forest Land (NFL) attributes - values that pertain to naturally
    non-vegetated, non-forest anthropogenic, and non-forest vegetated
    land;

5)  Disturbance history (DST) attributes - values that pertain to any
    disturbance that has occurred in a polygon including type, year, and
    extent; and

6)  Ecological specific (ECO) attributes - values representing ecosites
    and wetlands.

The main body of this report (Sections 2.1 through 2.3 and Section 3)
defines each of the six attribute categories and tabulates the
attributes and their characteristics. A summary of the data structure
and data dictionary is presented in Appendix 2.

Each inventory data base has a unique data structure. A conversion
procedure must be documented describing how to load the source inventory
into CAS. A sample procedure is presented in Appendix 16.

<sup>1</sup> Gillis, M.D.; Leckie, D.G. 1993. Forest Inventory Mapping
Procedures Across Canada. Petawawa National Forestry Institute,
Information Report PI-X-114.

## Error and Missing Value Codes

Error codes are needed during translation if source values are invalid,
null, or missing. In CASFRI v5, error codes have been designed to match
the attribute type and to reflect the type of error that was
encountered. For example, an integer attribute will have error codes
reported as integers (e.g. -9999) whereas text attributes will have
errors reported as text (e.g. INVALID). Different error codes are
reported depending on the
cause.

``` r
knitr::kable(x1)
```

| Class          | Type               | Description                            | Function                                           | Text.message     | Small.int.code | Large.int.code |  Double.code |
| :------------- | :----------------- | :------------------------------------- | :------------------------------------------------- | :--------------- | -------------: | -------------: | -----------: |
| Special values | \-Infinity         | Negative infinity                      | NO FUNCTION                                        | MINUS\_INF       |         \-2222 |    \-222222222 | \-2147483648 |
|                | \+Infinity         | Positive infinity                      | NO FUNCTION                                        | PLUS\_INF        |         \-2221 |    \-222222221 |   2147483647 |
| Missing values | Null               | Undefined value - true null value      | TT\_NotNull()                                      | NULL\_VALUE      |         \-8888 |    \-888888888 | \-2147483647 |
|                | Empty string       | Missing that is not null               | TT\_NotEmpty()                                     | EMPTY\_STRING    |             NA |             NA |           NA |
|                | Not applicable     | Target attribute not in source table   | TT\_False()                                        | NOT\_APPLICABLE  |         \-8887 |    \-888888887 | \-2147483645 |
| Invalid values | Out of range       | Value is outside the range of values   | TT\_Between(); TT\_GreaterThan(); TT\_LesserThan() | OUT\_OF\_RANGE   |         \-9999 |    \-999999999 | \-2147483644 |
|                | Not member of set  | Value is not a member of a set or list | TT\_Match()                                        | NOT\_IN\_SET     |         \-9998 |    \-999999998 | \-2147483643 |
|                | Invalid value      | Invalid value                          | NO FUNCTION                                        | INVALID          |         \-9997 |    \-999999997 | \-2147483642 |
|                | Precision too high | Precision is greater than allowed      | NO FUNCTION                                        | WRONG\_PRECISION |         \-9996 |    \-999999996 | \-2147483641 |
|                | Wrong data type    | Value is of the wrong data type        | TT\_IsInt(); TT\_IsNumeric(); TT\_IsString()       | WRONG\_TYPE      |         \-9995 |    \-999999995 | \-2147483640 |

## Header Information (HDR)

Header information is a primary element of CAS. Header information
identifies the source data set including jurisdiction, spatial
reference, ownership, tenure type, inventory type, inventory version,
inventory start and finish date and the year of acquisition for CAS.
These attributes are detailed on the following pages.

### CASFRI Identification

## CASFRI Identification

Revised: March 19, 2019

### CAS\_ID

The CAS\_ID is a unique identifier that is generated for each polygon
and acts as the primary key in the database. The CAS\_ID is a fixed
length field (53 bytes) composed of five elements delimited by dash
characters (“-”):

1.  Header identifier composed of a 2 letter acronym of the
    [jurisdiction](jurisdiction.md) and 4 character numeric dataset code
    separated by an underscore (7 alphanumeric characters)
2.  Source file name (15 alphanumeric characters)
3.  Name of the [mapsheet](map_sheet_id.md) or geographical division (10
    alphanumeric characters)
4.  Object identifier used in the source file (10 numeric characters)
5.  Serial number to ensure the uniqueness of the identifier (7 numeric
    characters)

Examples:

  - ON\_0001-xxxxxxxxxMU030L-xxxxxMU030-0030000003-0000001
  - BC\_0004-VEG\_COMP\_LYR\_R1-xxx082C095-0000000001-0000001

This naming convention allows manual or automated tracing of any final
forest stand stored in the database back to its specific record in the
original file within the given SIDS. This fixed length format was
designed to ease automated parsing of the identifier using standard
string libraries. We assumed that a stand polygon is always assigned to
a larger spatial unit, usually survey units such as NTS mapsheets or
townships. Finally, we added, at the polygon level, the field
HEADER\_ID. This acts as the unique identifier of the SIDS within a
jurisdiction. It links each polygon to the HDR record corresponding to
its SIDS.

The five elements used to construct the CAS\_ID may vary by inventory
and these variations are described in the following sections.

**Acceptable
values:**

| CAS\_ID                                                              | Attribute Value |
| :------------------------------------------------------------------- | :-------------- |
| CAS stand identification - unique number for each polygon within CAS | Alpha Numeric   |

**Error and missing value
codes:**

| Error\_type    | Description                          | CAS\_ID         |
| :------------- | :----------------------------------- | :-------------- |
| Null value     | Undefined value - true null value    | NULL\_VALUE     |
| Empty string   | Missing that is not null             | EMPTY\_STRING   |
| Not applicable | Target attribute not in source table | NOT\_APPLICABLE |
| Invalid value  | Invalid value                        | INVALID         |

**Notes:**

  - Should we change the header identifier to contain 5 vs 7 characters?

*AB06*

The AB06 inventory has the following variations:

  - Header identifier: “AB06”
  - Source file name: “xxxxxGB\_S21\_TWP”
  - Name of mapsheet: trm\_1
  - Object identifier: poly\_num

*AB16*

The AB16 inventory has the following variations:

  - Header identifier: “AB16”
  - Source file name: “xxxxxxxxxCANFOR”
  - Name of mapsheet: “x” + “T0” + township + “R0” + range + “M” +
    meridian
  - Object identifier: forest\_id

*BC08*

The BC08 inventory has the following variations:

  - Header identifier: “BC08”
      - Note: previously, the header identifier included the
        inventory\_standard\_cd \[converted from=c(“F”,“V”,“I”),
        to=c(“4”,“5”,“6”); this was dropped on the assumption, to be
        confirmed, that all data have been converted to “V” type.
  - Source file name: “VEG\_COMP\_LYR\_R1”
  - Name of mapsheet: map\_id
  - Object identifier: objectid

*NB01*

The NB01 inventory has the following variations:

  - Header identifier: “NB01”
  - Source file name: “xxFOREST\_NONFOR”
  - Name of mapsheet: “xxxxxxxxxx”
  - Object identifier: stdlab

### Year of Aerial Photography

Photo Year is the year in which the inventory was considered initiated
and completed. An inventory can take several years to complete;
therefore, Photo Year Minimum and Maximum dates are included to identify
the interval for when the inventory was completed. In some cases
inventory reference year and air photo year are the same. Several years
of successive or periodic acquisition are possible; therefore, a minimum
and a maximum year are
recorded.

| PHOTO\_YEAR\_MIN and PHOTO\_YEAR\_MAX                          | Attribute Value |
| :------------------------------------------------------------- | :-------------- |
| Photo Year Minimum - earliest year of aerial photo acquisition | 1960 - 2020     |
| Photo Year Maximum - last year of aerial photo acquisition     | 1960 - 2020     |

## CAS Forest and Non-Forest Attributes (LYR)

### Crown Closure

Crown closure is an estimate of the percentage of ground area covered by
vertically projected tree crowns, shrubs, or herbaceous cover. Crown
closure is usually estimated independently for each layer. Crown closure
is commonly represented by classes and differs across Canada; therefore,
CAS recognizes an upper and lower percentage bound for each class. The
detailed crown closure table is presented in Appendix 5.

| CROWN\_CLOSURE\_UPPER and CROWN\_CLOSURE\_LOWER    | Attribute Value |
| :------------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a crown closure class | 0 - 100         |
| Lower Bound - lower bound of a crown closure class | 0 - 100         |
| Blank - no value                                   | NA              |

*Error and missing value
codes:*

| Error\_type        | Description                            | CROWN\_CLOSURE\_LOWER | CROWN\_CLOSURE\_UPPER |
| :----------------- | :------------------------------------- | --------------------: | --------------------: |
| Null value         | Undefined value - true null value      |                \-8888 |                \-8888 |
| Not applicable     | Target attribute not in source table   |                \-8886 |                \-8886 |
| Out of range       | Value is outside the range of values   |                \-9999 |                \-9999 |
| Not in set         | Value is not a member of a set or list |                \-9998 |                \-9998 |
| Invalid value      | Invalid value                          |                \-9997 |                \-9997 |
| Precision too high | Precision is greater than allowed      |                \-9996 |                \-9996 |

### Height

Stand height is based on an average height of leading species of
dominant and co-dominant heights of the vegetation layer and can
represent trees, shrubs, or herbaceous cover. Height can be represented
by actual values or by height class and its representation is variable
across Canada; therefore, CAS will use upper and lower bounds to
represent height. The detailed height table is presented in Appendix 6.

| HEIGHT\_UPPER and HEIGHT\_LOWER              | Attribute Value |
| :------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a height class. | 0 - 100         |
| Lower Bound - lower bound of a height class. | 0 - 100         |

*Error and missing value
codes:*

| Error\_type        | Description                          | HEIGHT\_LOWER | HEIGHT\_UPPER |
| :----------------- | :----------------------------------- | ------------: | ------------: |
| Neg infinity       | Negative infinity                    |        \-2222 |        \-2222 |
| Pos infinity       | Positive infinity                    |        \-2221 |        \-2221 |
| Null value         | Undefined value - true null value    |        \-8888 |        \-8888 |
| Not applicable     | Target attribute not in source table |        \-8886 |        \-8886 |
| Out of range       | Value is outside the range of values |        \-9999 |        \-9999 |
| Invalid value      | Invalid value                        |        \-9997 |        \-9997 |
| Precision too high | Precision is greater than allowed    |        \-9996 |        \-9996 |

### Species Composition

Species composition is the percentage of each tree species represented
within a forested polygon by layer. Species are listed in descending
order according to their contribution based on crown closure, basal
area, or volume depending on the province or territory. A total of ten
species can be used in one label. The CAS attribute will capture
estimation to the nearest percent; however, most inventories across
Canada describe species to the nearest 10% (in actual percent value or
multiples of 10). Species composition for each forest stand and layer
must sum to 100%.

The detailed table for species composition is presented in Appendix 7.
Some inventories (Alberta Phase 3, Saskatchewan UTM, Quebec TIE, and
Newfoundland, and National Parks) do not recognize a percentage
breakdown of species but rather group species as contributing a major
(greater than 26 percent) or minor (less than 26 percent) amount to the
composition. Also included in Appendix 7 is a translation table that
assigns a species composition percentage breakdown for those inventories
that do not have a percentage breakdown.

CAS species codes are derived from the species’ Latin name using the
first four letters of the Genus and the first four letters of the
Species unless there is a conflict, then the last letter of the species
portion of the code is changed. Unique codes are required for generic
groups and hybrids. A species list has been developed representing every
inventory species identified across Canada including hybrids, exotics
and generic groups (Appendix 8). Generic groups represent situations
where species were not required to be recognized past the generic name
or where photo interpreters could not identify an individual species. A
list of species that is represented by the generic groups by province,
territory, or Park has also been developed and is presented in Appendix
9.

**Species
type**

| SPECIES\_1, SPECIES\_2, SPECIES\_3, SPECIES\_4, SPECIES\_5, SPECIES\_6, SPECIES\_7, SPECIES\_8, SPECIES\_9, SPECIES\_10 | Attribute Value |
| :---------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species (SPECIES\_\#) - Example: Populus tremuloides, Trembling Aspen. Ten species can be listed per layer per polygon. | POPU TREM       |

*Error and missing value
codes:*

| Error\_type    | Description                            | SPECIES\_1-10   |
| :------------- | :------------------------------------- | :-------------- |
| Null value     | Undefined value - true null value      | NULL\_VALUE     |
| Empty string   | Missing that is not null               | EMPTY\_STRING   |
| Not applicable | Target attribute not in source table   | NOT\_APPLICABLE |
| Not in set     | Value is not a member of a set or list | NOT\_IN\_SET    |
| Invalid value  | Invalid value                          | INVALID         |

**Species
percentage**

| SPECIES\_PER\_1, SPECIES\_PER\_2, SPECIES\_PER\_3, SPECIES\_PER\_4, SPECIES\_PER\_5, SPECIES\_PER\_6, SPECIES\_PER\_7, SPECIES\_PER\_8, SPECIES\_PER\_9, SPECIES\_PER\_10 | Attribute Value |
| :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :-------------- |
| Species Percent (SPECIES\_PER\_\#) - Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100%.   | NA              |

*Error and missing value
codes:*

| Error\_type        | Description                          | SPECIES\_PER\_1-10 |
| :----------------- | :----------------------------------- | -----------------: |
| Null value         | Undefined value - true null value    |             \-8888 |
| Not applicable     | Target attribute not in source table |             \-8886 |
| Out of range       | Value is outside the range of values |             \-9999 |
| Invalid value      | Invalid value                        |             \-9997 |
| Precision too high | Precision is greater than allowed    |             \-9996 |
