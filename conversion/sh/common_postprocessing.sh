# Common postprocessing for all batch scripts

# Create a spatial index on wkb_geometry if requested (generally by conversion scripts generating the last target table with a SQL query)
if [ ${createSQLSpatialIndex}x == Truex ]; then
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE INDEX ON $fullTargetTableName USING gist (wkb_geometry)";
fi 

# Create an index on OGC_FID
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE INDEX ON $fullTargetTableName (ogc_fid)";

# VACUUM ANALYZE the table
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "VACUUM ANALYZE $fullTargetTableName";

echo
echo CONVERSION OF "$fullTargetTableName" DONE......

if [ ${leaveConvShellOpen}x == Truex ]; then
  /bin/bash
fi
