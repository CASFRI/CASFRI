
## Height

Revised: March 19, 2019

Stand height is based on an average height of leading species of
dominant and co-dominant heights of the vegetation layer and can
represent trees, shrubs, or herbaceous cover. Height can be represented
by actual values or by height class and its representation is variable
across Canada; therefore, CAS will use upper and lower bounds to
represent height. The detailed height table is presented in Appendix 6.

**Acceptable values:**

| HEIGHT\_UPPER and HEIGHT\_LOWER              | Attribute Value |
| :------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a height class. | 0 - 100         |
| Lower Bound - lower bound of a height class. | 0 - 100         |

**Error and missing value
codes:**

| Error\_type        | Description                          | HEIGHT\_LOWER | HEIGHT\_UPPER |
| :----------------- | :----------------------------------- | ------------: | ------------: |
| Neg infinity       | Negative infinity                    |        \-2222 |        \-2222 |
| Pos infinity       | Positive infinity                    |        \-2221 |        \-2221 |
| Null value         | Undefined value - true null value    |        \-8888 |        \-8888 |
| Not applicable     | Target attribute not in source table |        \-8886 |        \-8886 |
| Out of range       | Value is outside the range of values |        \-9999 |        \-9999 |
| Invalid value      | Invalid value                        |        \-9997 |        \-9997 |
| Precision too high | Precision is greater than allowed    |        \-9996 |        \-9996 |

**Notes:**
