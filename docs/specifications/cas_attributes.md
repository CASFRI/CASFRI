# CASFRI Attributes

## Header Information (HDR)

### CAS_ID

```
The CAS_ID is a concatenation of four attributes:
  * inventory name
  * header id - unique number associated with the inventory (e.g., inventory_standard_cd in BC)
  * map id - mapsheet id based on regular grid
  * SOURCE_OBJECTID and OBJECTID; the latter is from the source dataset but not sure about the former?
```

### MAP_SHEET_ID

Notes:

  * BC: copy values from MAP_ID

| MAP_SHEET_ID                                                                      | Attribute Value |
| :-------------------------------------------------------------------------------- | :-------------- |
| Map sheet identification according to original naming convention for an inventory | Alpha Numeric   |


### IDENTIFICATION_ID

Notes:

  * BC - this comes from INVENTORY_STANDARD_CD
  * BC - CAS_04 only had 3 types (FLV) whereas the latest inventory has 4 types (FIVL)
  * BC - map values from=c("F","V","I","L"), to=c("4","5","6","7"); PV made up L to 7


| IDENTIFICATION_ID                                | Attribute Value |
| :----------------------------------------------- | :-------------- |
| Unique number for a particular inventory section | 1 - 1000        |


### PHOTO_YEAR

Notes:

  * This can be determined in 3 ways: spatial, tabular, fixed
  * The CAS_04 only has PHOTO_YEAR not MIN and MAX: is this what we want?
  * BC - copy values from REFERENCE_YEAR

| PHOTO_YEAR_MIN and PHOTO_YEAR_MAX                              | Attribute Value |
| :------------------------------------------------------------- | :-------------- |
| Photo Year Minimum - earliest year of aerial photo acquisition | 1960 - 2020     |
| Photo Year Maximum - last year of aerial photo acquisition     | 1960 - 2020     |


## CAS Forest and Non-Forest Attributes (LYR)

### CROWN_CLOSURE_UPPER, CROWN_CLOSURE_LOWER

*Acceptable values:*

| CROWN_CLOSURE_UPPER and CROWN_CLOSURE_LOWER        | Attribute Value |
| :------------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a crown closure class | 0 - 100         |
| Lower Bound - lower bound of a crown closure class | 0 - 100         |
| Blank - no value                                   | NA              |

*Error and missing value codes:*

|Error_type | Data_type    | CAS04_code | Description                       | CAS05_code |
| :-------- | :----------- | :--------- | :-------------------------------- | :--------- |
| INFTY     | integer      | -1         | positive or negative infinity     | -Inf/+Inf  |
| ERRCODE   | integer      | -9999      | invalid values that are not null  | -9999      |
| UNDEF     | integer      | -8888      | undefined value - true null value | -8888      |


### HEIGHT_UPPER, HEIGHT_LOWER

| HEIGHT_UPPER and HEIGHT_LOWER                | Attribute Value |
| :------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a height class. | 0 - 100         |
| Lower Bound - lower bound of a height class. | 0 - 100         |

*Error and missing value code:*

|Error_type | Data_type    | CAS04_code | Description                       | CAS05_code |
| :-------- | :----------- | :--------- | :-------------------------------- | :--------- |
| INFTY     | integer      | -1         | positive or negative infinity     | -Inf/+Inf  |
| ERRCODE   | integer      | -9999      | invalid values that are not null  | -9999      |
| UNDEF     | integer      | -8888      | undefined value - true null value | -8888      |


### SPECIES_X

| SPECIES_1 - SPECIES_10                                                                                                | Attribute Value |
| :-------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species (SPECIES_#) - Example: Populus tremuloides, Trembling Aspen. Ten species can be listed per layer per polygon. | POPU TREM       |

*Error and missing value codes:*

|Error_type       | Data_type    | CAS04_code  | Description                       | CAS05_code  |
| :-------------- | :----------- | :---------- | :-------------------------------- | :---------- |
| ERRCODE         | string       | -9999       | invalid values that are not null  | "Invalid"   |
| UNDEF           | string       | -8888       | undefined value - true null value | "Null"      |
| SPECIES_ERRCODE | string       | "XXXX ERRC" | species error code                | "XXXX ERRC" |
| MISSCODE        | string       | -1111       | empty string ("")                 | "Missing"   |


### SPECIES_PER_X

| SPECIES_PER_1 - SPECIES_PER_10                                                                                  | Attribute Value |
| :-------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species Percent (SPECIES_PER_#) - Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100%. | NA              |

*Error and missing value codes:*

|Error_type | Data_type    | CAS04_code | Description                       | CAS05_code |
| :-------- | :----------- | :--------- | :-------------------------------- | :--------- |
| INFTY     | integer      | -1         | positive or negative infinity     | -Inf/+Inf  |
| ERRCODE   | integer      | -9999      | invalid values that are not null  | -9999      |
| UNDEF     | integer      | -8888      | undefined value - true null value | -8888      |
