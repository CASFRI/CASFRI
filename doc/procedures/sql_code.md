## Useful sql code for PostgreSQL quesries

#### Find Spatial Reference System Identifier (SRID)
> SELECT DISTINCT ST_SRID(wkb_geometry) from bc.bc_0008;

#### Count records in table
> SELECT COUNT(inventory_standard_cd) AS "total_count" FROM bc.bc_0008;

#### Count records in table grouped by field
> SELECT COUNT(inventory_standard_cd) AS "count", inventory_standard_cd FROM bc.bc_0008 GROUP BY(inventory_standard_cd);
