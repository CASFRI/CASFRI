:: Common postprocessing for all batch scripts

:: Create an index on OGC_FID
"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE INDEX ON %fullTargetTableName% (ogc_fid)";
