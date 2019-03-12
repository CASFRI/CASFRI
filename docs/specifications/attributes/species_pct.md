
## SPECIES\_PER\_1-10

### Acceptable values:

| SPECIES\_PER\_1 - SPECIES\_PER\_10                                                                                                                                      | Attribute Value |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species Percent (SPECIES\_PER\_\#) - Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100%. | NA              |

### Error and missing value codes:

| Error\_type        | Description                            | SPECIES\_PER\_1-10 |
| :----------------- | :------------------------------------- | -----------------: |
| Neg infinity       | Negative infinity                      |                 NA |
| Pos infinity       | Positive infinity                      |                 NA |
| Null value         | Undefined value - true null value      |             \-8888 |
| Empty string       | Missing that is not null               |                 NA |
| Not applicable     | Target attribute not in source table   |             \-8886 |
| Out of range       | Value is outside the range of values   |             \-9999 |
| Not in set         | Value is not a member of a set or list |                 NA |
| Invalid value      | Invalid value                          |             \-9997 |
| Precision too high | Precision is greater than allowed      |             \-9996 |

### Notes:

  - AB16 uses sp\*\_percnt rather than sp\*\_per that AB6 uses
