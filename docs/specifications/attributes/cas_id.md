# CAS_ID

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

## AB_0006

The AB_0006 inventory has the following variations:

  * Header identifier: "AB_0006"
  * Source file name: "xxxxxGB_S21_TWP"
  * Name of mapsheet: trm_1
  * Object identifier: poly_num

## AB_0016

The AB_0016 inventory has the following variations:

  * Header identifier: "AB_0016"
  * Source file name: "xxxxxxxxxCANFOR"
  * Name of mapsheet: "x" + "T0" + township + "R0" + range + "M" + meridian
  * Object identifier: forest_id

## BC_0008

The BC_0008 inventory has the following variations:

  * Header identifier: "BC_000" + inventory_standard_cd [converter from=c("F","V","I","L"), to=c("4","5","6","7"); Note that "L" appears to be new to the latest version of the inventory (double check).]
  * Source file name: "VEG_COMP_LYR_R1"
  * Name of mapsheet: map_id
  * Object identifier: objectid

## NB_0001

The NB_0001 inventory has the following variations:

  * Header identifier: "NB_0001"
  * Source file name: "xxFOREST_NONFOR"
  * Name of mapsheet: "xxxxxxxxxx"
  * Object identifier: stdlab
