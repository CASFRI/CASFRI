:: Common postprocessing for all batch scripts

:: Create a spatial index on wkb_geometry if requested (generally by conversion scripts generating the last target table with a SQL query)
IF %createSQLSpatialIndex%x == Truex (
  "%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE INDEX ON %fullTargetTableName% USING gist (wkb_geometry)";
)

:: Create an index on OGC_FID
"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE INDEX ON %fullTargetTableName% (ogc_fid)";
