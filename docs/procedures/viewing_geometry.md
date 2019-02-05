# Viewing spatially-enabled tables

It is often useful to have a look at intermediate results when running queries or conducting an analysis. Here are a few relatively simple approaches.

### pgAdmin4

With recent versions of PostGIS, it is possible to view the geometry of a spatial table if it is in a geographic projection (epgs = 4326).

  * Use the query tool to view some data, including the geometry column
  * Click on the "eye" symbol next to the geometry column name; this will open up the Geometry Viewer tab with the selected polygons.

### QGIS

This assumes you have already created a PostGIS database.

Option 1 - Use Browser

  * Select and expand the PostGIS item in the Browser panel and select the database/schema/table you wish to inspect (you will need your user name and password).

Option 2 - Use DB Manager

  * Go to the Database menu and select "DB Manager"
  * Select and expand the PostGIS item in the left panel and select the database/schema/table you wish to inspect (you will need your user name and password)

### R

The simplest way is to connect to the database/schema/table using the sf package. The example below uses VRI data from BC. The latest VRI table has 4,861,240 records; 5000 records will be selected from across BC and subsequently plotted.

```R
library(sf)
x = st_read(dsn="PG:host=localhost dbname=cas user=postgres password=postgres", layer="bc.vri",
query=paste0("SELECT * FROM bc.vri LIMIT 5000"), stringsAsFactors = FALSE, as_tibble=FALSE)
plot(st_geometry(x)) # plot the geometry
```

### Python

Not tested yet.
