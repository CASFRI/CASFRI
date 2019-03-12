CROWN\_CLOSURE\_UPPER, CROWN\_CLOSURE\_LOWER
================

Revised: March 12, 2019

## Acceptable values:

| CROWN\_CLOSURE\_UPPER and CROWN\_CLOSURE\_LOWER    | Attribute Value |
| :------------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a crown closure class | 0 - 100         |
| Lower Bound - lower bound of a crown closure class | 0 - 100         |
| Blank - no value                                   | NA              |

## Error and missing value codes:

| Error\_type        | Description                            | CROWN\_CLOSURE\_LOWER | CROWN\_CLOSURE\_UPPER |
| :----------------- | :------------------------------------- | --------------------: | --------------------: |
| Neg infinity       | Negative infinity                      |                    NA |                    NA |
| Pos infinity       | Positive infinity                      |                    NA |                    NA |
| Null value         | Undefined value - true null value      |                \-8888 |                \-8888 |
| Empty string       | Missing that is not null               |                    NA |                    NA |
| Not applicable     | Target attribute not in source table   |                \-8886 |                \-8886 |
| Out of range       | Value is outside the range of values   |                \-9999 |                \-9999 |
| Not in set         | Value is not a member of a set or list |                \-9998 |                \-9998 |
| Invalid value      | Invalid value                          |                \-9997 |                \-9997 |
| Precision too high | Precision is greater than allowed      |                \-9996 |                \-9996 |

## Notes:

  - AB16 uses crownclosure rather than density that AB06 uses
