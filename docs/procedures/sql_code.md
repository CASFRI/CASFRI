## Useful sql code for PostgreSQL queries

#### Find Spatial Reference System Identifier (SRID)
> SELECT DISTINCT ST_SRID(wkb_geometry) from bc.bc_0008;

#### Count records in table
> SELECT COUNT(inventory_standard_cd) AS "total_count" FROM bc.bc_0008;

#### Count records in table grouped by field
> SELECT COUNT(inventory_standard_cd) AS "count", inventory_standard_cd FROM bc.bc_0008 GROUP BY(inventory_standard_cd);

#### Summarise fields by group
> SELECT COUNT(inventory_standard_cd) AS "count", MIN(geometry_area) AS "min_area", MAX(geometry_area) AS "max_area", inventory_standard_cd AS "inv" FROM bc.bc_0008 GROUP BY(inventory_standard_cd);
