# SPECIES_X

## Acceptable values:

| SPECIES_1 - SPECIES_10                                                                                                | Attribute Value |
| :-------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species (SPECIES_#) - Example: Populus tremuloides, Trembling Aspen. Ten species can be listed per layer per polygon. | POPU TREM       |


## Error and missing value codes:

|Error_type       | Data_type    | CAS04_code  | Description                       | CAS05_code  |
| :-------------- | :----------- | :---------- | :-------------------------------- | :---------- |
| ERRCODE         | string       | -9999       | invalid values that are not null  | "Invalid"   |
| UNDEF           | string       | -8888       | undefined value - true null value | "Null"      |
| SPECIES_ERRCODE | string       | "XXXX ERRC" | species error code                | "XXXX ERRC" |
| MISSCODE        | string       | -1111       | empty string ("")                 | "Missing"   |

