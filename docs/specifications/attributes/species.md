
## Species Composition

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

### Species type

**Acceptable
values:**

| SPECIES\_1 - SPECIES\_10                                                                                                | Attribute Value |
| :---------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species (SPECIES\_\#) - Example: Populus tremuloides, Trembling Aspen. Ten species can be listed per layer per polygon. | POPU TREM       |

**Error and missing value
codes:**

| Error\_type    | Description                            | SPECIES\_1-10   |
| :------------- | :------------------------------------- | :-------------- |
| Null value     | Undefined value - true null value      | NULL\_VALUE     |
| Empty string   | Missing that is not null               | EMPTY\_STRING   |
| Not applicable | Target attribute not in source table   | NOT\_APPLICABLE |
| Not in set     | Value is not a member of a set or list | NOT\_IN\_SET    |
| Invalid value  | Invalid value                          | INVALID         |

**Notes:**

### Species percentage

**Acceptable
values:**

| SPECIES\_PER\_1 - SPECIES\_PER\_10                                                                                                                                      | Attribute Value |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species Percent (SPECIES\_PER\_\#) - Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100%. | NA              |

**Error and missing value
codes:**

| Error\_type        | Description                          | SPECIES\_PER\_1-10 |
| :----------------- | :----------------------------------- | -----------------: |
| Null value         | Undefined value - true null value    |             \-8888 |
| Not applicable     | Target attribute not in source table |             \-8886 |
| Out of range       | Value is outside the range of values |             \-9999 |
| Invalid value      | Invalid value                        |             \-9997 |
| Precision too high | Precision is greater than allowed    |             \-9996 |

**Notes:**

  - AB16 uses sp\*\_percnt rather than sp\*\_per that AB6 uses
