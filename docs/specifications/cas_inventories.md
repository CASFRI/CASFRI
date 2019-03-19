CAS Inventories
================

  - [Alberta](#alberta)
      - [AB06](#ab06)
      - [AB16](#ab16)
  - [British Columbia](#british-columbia)
      - [BC08](#bc08)
  - [New Brunswick](#new-brunswick)
      - [NB01](#nb01)

# Alberta

## AB06

CAS\_ID

The AB06 inventory has the following variations: \* Header identifier:
“AB06” \* Source file name: “xxxxxGB\_S21\_TWP” \* Name of mapsheet:
trm\_1 \* Object identifier: poly\_num

Crown Closure

  - AB06 uses density rather than crownclosure that AB16 uses

Species percent

  - AB06 uses sp\*\_per rather than sp\*\_percnt that AB16 uses

## AB16

CAS\_ID

The AB16 inventory has the following variations:

  - Header identifier: “AB16”
  - Source file name: “xxxxxxxxxCANFOR”
  - Name of mapsheet: “x” + “T0” + township + “R0” + range + “M” +
    meridian
  - Object identifier: forest\_id

Crown closure

  - AB16 uses crownclosure rather than density that AB06 uses

Species percent

  - AB16 uses sp\*\_percnt rather than sp\*\_per that AB06 uses

# British Columbia

## BC08

General

  - All inventory standards appear to be incorporated into latest file
    geodatabase
  - TFL 48 is not included except for a few polygons (recent
    disturbances?)

CAS\_ID

The BC08 inventory has the following variations:

  - Header identifier: “BC08”
      - Note: previously, the header identifier included the
        inventory\_standard\_cd \[converted from=c(“F”,“V”,“I”),
        to=c(“4”,“5”,“6”); this was dropped on the assumption, to be
        confirmed, that all data have been converted to “V” type.
  - Source file name: “VEG\_COMP\_LYR\_R1”
  - Name of mapsheet: map\_id
  - Object identifier: objectid

Crown Closure

  - The crown\_closure field is an integer ranging from 1-100
  - The crown\_closure\_class\_cd field is an integer ranging from 0-10
  - It appears that some values are true integers ranging from 1-100
    while others have been converted from classes probably due to
    different inventory types
  - The perl code however seems to assume that it is translating from
    0-10 to 1-100
  - CROWN\_CLOSURE\_UPPER and CROWN\_CLOSURE\_LOWER should be the same
    value in CAS v4 but this is not the case

Height

  - The proj\_height\_1 field is a float ranging from 0.1 up
  - The proj\_height\_class\_cd\_1 field is an integer ranging from 1-8
  - The proj\_height\_1 field appears to be a mix of true values and
    values converted from classes

# New Brunswick

## NB01

CAS\_ID

The NB01 inventory has the following variations:

  - Header identifier: “NB01”
  - Source file name: “xxFOREST\_NONFOR”
  - Name of mapsheet: “xxxxxxxxxx”
  - Object identifier: stdlab
