# CROWN_CLOSURE_UPPER, CROWN_CLOSURE_LOWER

## Acceptable values:

| CROWN_CLOSURE_UPPER and CROWN_CLOSURE_LOWER        | Attribute Value |
| :------------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a crown closure class | 0 - 100         |
| Lower Bound - lower bound of a crown closure class | 0 - 100         |
| Blank - no value                                   | NA              |

### AB16

  * uses crownclosure rather than density that AB06 uses


## Error and missing value codes:

|Error_type | Data_type    | CAS04_code | Description                       | CAS05_code |
| :-------- | :----------- | :--------- | :-------------------------------- | :--------- |
| INFTY     | integer      | -1         | positive or negative infinity     | -Inf/+Inf  |
| ERRCODE   | integer      | -9999      | invalid values that are not null  | -9999      |
| UNDEF     | integer      | -8888      | undefined value - true null value | -8888      |
