
## “HEIGHT\_UPPER, HEIGHT\_LOWER”

### Acceptable values:

| HEIGHT\_UPPER and HEIGHT\_LOWER              | Attribute Value |
| :------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a height class. | 0 - 100         |
| Lower Bound - lower bound of a height class. | 0 - 100         |

### Error and missing value code:

| Error\_type        | Description                            | HEIGHT\_LOWER | HEIGHT\_UPPER |
| :----------------- | :------------------------------------- | ------------: | ------------: |
| Neg infinity       | Negative infinity                      |        \-2222 |        \-2222 |
| Pos infinity       | Positive infinity                      |        \-2221 |        \-2221 |
| Null value         | Undefined value - true null value      |        \-8888 |        \-8888 |
| Empty string       | Missing that is not null               |            NA |            NA |
| Not applicable     | Target attribute not in source table   |        \-8886 |        \-8886 |
| Out of range       | Value is outside the range of values   |        \-9999 |        \-9999 |
| Not in set         | Value is not a member of a set or list |            NA |            NA |
| Invalid value      | Invalid value                          |        \-9997 |        \-9997 |
| Precision too high | Precision is greater than allowed      |        \-9996 |        \-9996 |

### Notes:
