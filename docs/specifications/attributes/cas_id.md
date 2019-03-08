## CAS_ID

Revised: March 4, 2019

A unique identifier (CAS_ID) is generated for each polygon to act as the primary key in the database. The CAS_ID is a fixed length field (53 bytes) composed of five fixed length elements delimited by dash characters ("-"):

  1. Header identifier composed of a 2 letter acronym of the [jurisdiction](jurisdiction.md) and 4 character numeric dataset code separated by an underscore (7 alphanumeric characters)
  2. Source file name (15 alphanumeric characters)
  3. Name of the [mapsheet](map_sheet_id.md) or geographical division (10 alphanumeric characters)
  4. Object identifier used in the source file (10 numeric characters)
  5. Serial number to ensure the uniqueness of the identifier (7 numeric characters)

Examples:
  - ON_0001-xxxxxxxxxMU030L-xxxxxMU030-0030000003-0000001
  - BC_0004-VEG_COMP_LYR_R1-xxx082C095-0000000001-0000001

This naming convention allows manual or automated tracing of any final forest stand stored in the database back to its specific record in the original file within the given SIDS. This fixed length format was designed to ease automated parsing of the identifier using standard string libraries. We assumed that a stand polygon is always assigned to a larger spatial unit, usually survey units such as NTS mapsheets or townships. Finally, we added, at the polygon level, the field HEADER_ID. This acts as the unique identifier of the SIDS within a jurisdiction. It links each polygon to the HDR record corresponding to its SIDS.

The five elements used to construct the CAS_ID may vary by inventory and these variations are described in the following sections.

### Notes:

  * Should we change the header identifier to contain 5 vs 7 characters?

**AB06**

The AB06 inventory has the following variations:

  * Header identifier: "AB06"
  * Source file name: "xxxxxGB_S21_TWP"
  * Name of mapsheet: trm_1
  * Object identifier: poly_num

**AB16**

The AB16 inventory has the following variations:

  * Header identifier: "AB16"
  * Source file name: "xxxxxxxxxCANFOR"
  * Name of mapsheet: "x" + "T0" + township + "R0" + range + "M" + meridian
  * Object identifier: forest_id

**BC08**

The BC08 inventory has the following variations:

  * Header identifier: "BC08"
    - Note: previously, the header identifier included the inventory_standard_cd [converted from=c("F","V","I"), to=c("4","5","6"); this was dropped on the assumption, to be confirmed, that all data have been converted to "V" type.
  * Source file name: "VEG_COMP_LYR_R1"
  * Name of mapsheet: map_id
  * Object identifier: objectid

**NB01**

The NB01 inventory has the following variations:

  * Header identifier: "NB01"
  * Source file name: "xxFOREST_NONFOR"
  * Name of mapsheet: "xxxxxxxxxx"
  * Object identifier: stdlab