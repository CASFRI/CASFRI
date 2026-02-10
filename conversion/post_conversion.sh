# Common postprocessing for all batch scripts

echo "######################## Begin post_processing.sh #######################"

# Create a spatial index on wkb_geometry if requested (generally by conversion scripts generating the last target table with a SQL query)
if [ ${createSQLSpatialIndex}x == Truex ]; then
"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "CREATE INDEX ON $fullTargetTableName USING gist (wkb_geometry)";
fi 

# Create an index on OGC_FID
"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "CREATE INDEX ON $fullTargetTableName (ogc_fid)";

# VACUUM ANALYZE the table
"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "VACUUM ANALYZE $fullTargetTableName";

echo
echo CONVERSION OF "$fullTargetTableName" DONE......
duration=$SECONDS
pretty_time "$duration"

if [ ${leaveConvShellOpen}x == Truex ]; then
  /bin/bash
fi

echo "######################## Begin post_processing.sh #######################"
