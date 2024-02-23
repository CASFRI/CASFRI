#!/bin/bash -x

# This script loads the National Terrestrial Ecosystem Monitoring System (NTEMS)
# raster as a dst table only

# There are two methods to load this raster as a vector table in the CASFRI
# database.

# The first method is to gdal_polygonize.py the raster directly into PostgreSQL.
# This is faster than the second method but getting gdal_polygonize.py to work
# properly is tricky. The second method does not require any special setup.
#
# The python bindings coming with the GDAL version we use from 
# https://www.gisinternals.com/ do not work anymore. To get 
# gdal_polygonize.py to work properly we installed MiniConda (which  install
# its own version of Python) and then numpy and gdal:
#
#   conda install numpy
#   conda install gdal
#
# The second method, using PostGIS raster2pgsql and ST_DumpAsPolygons(), is 
# slower but does not require any special installation.

# The first method is used by default in this script. If you can NOT get
# gdal_polygonize.py to work properly, comment the section using the first
# method and uncomment the section using raster2pgsql.

######################################## Set variables #######################################

source ./common.sh

inventoryID=DS02

baseSrcPath="$friDir/DS/$inventoryID/data/inventory"

fullTargetTableName=$targetFRISchema.${inventoryID,,}

srcFileName=CA_Forest_1985-2020

unset PROJ_LIB
unset PG_USE_COPY

# 20480 40960 81920 122880 128340 163840 193876 193936
offset=0
xsize=193876
ysize=128340
suffix=_${xsize}x${ysize}
rasterCreationOptions="-co COMPRESS=LZW -co TILED=YES -co BLOCKXSIZE=1024 -co BLOCKYSIZE=1024"

###################### Process - Loading vector method ###########################

##### Method 1 - Reduce raster size and vectorize directly to PostGIS ############

connectionParams="-d $pgdbname -U $pguser -h $pghost -p $pgport"
rasterOptions="-I -t 2048x2048"

createCropped=false
createReduced=false
createSQL=false
loadSQL=false
mergeTables=true

for srcDataset in Fire Harvest
do
  datasetName=CA_Forest_${srcDataset}_1985-2020
  srcPath=${baseSrcPath}/${datasetName}
  tempDstPath=${srcPath}/temp

  srcFullPath=${srcPath}/${datasetName}
  croppedRasterFullPath=${tempDstPath}/${datasetName}${suffix}
  reducedRasterFullPath=${croppedRasterFullPath}_reduced

  tempTargetTableName=${fullTargetTableName}_${srcDataset,,}_year

  # Create a temporary folder for the temporary files
  if [ ! -d "${tempDstPath}" ]; then
    mkdir "${tempDstPath}"
  fi

  # Create a cropped version of the raster since the original one was impossible to
  # vectorize with gdal_polygonize.py. The cropped part does not contain anything to 
  # vectorize (only nodata values).
  if [ ! -e "${croppedRasterFullPath}.tif" ] && [ "${createCropped}" == "true" ]; then
  	echo "Creating ${croppedRasterFullPath}.tif..."
  
    "$gdalFolder/gdal_translate" -a_nodata 0 -srcwin ${offset} ${offset} ${xsize} ${ysize} \
    -co COMPRESS=LZW -co TILED=YES -co BLOCKXSIZE=1024 -co BLOCKYSIZE=1024 \
    "${srcFullPath}.tif" "${croppedRasterFullPath}.tif"

  	echo "${croppedRasterFullPath}.tif" created...
  else
  	echo "${croppedRasterFullPath}.tif" already exists. Skipping creation...
  fi

  # Create a temporary raster reducing the size of the raster and setting the 
  # nodata value properly so it is easier to handle by gdal_polygonize.py 
  if [ ! -e "${reducedRasterFullPath}.tif" ] && [ "${createReduced}" == "true" ]; then
  	echo "Creating ${reducedRasterFullPath}.tif..."
  
    "$pythonPath/scripts/gdal_calc.py" -A "${croppedRasterFullPath}.tif" \
    --type=Byte \
    --calc="(numpy.where(A==0, 255, A-numpy.trunc(A/100)*100))" \
    --co="COMPRESS=LZW" --co="TILED=YES" --co="BLOCKXSIZE=1024" --co="BLOCKYSIZE=1024" \
    --overwrite \
    --outfile "${reducedRasterFullPath}.tif"
  
  	echo "${reducedRasterFullPath}.tif" created...
  else
  	echo "${reducedRasterFullPath}.tif" already exists. Skipping creation...
  fi

  # Vectorize the raster into a temporary .sql file (piping it to psql does not work)
  if [ ! -e "${reducedRasterFullPath}.sql" ] && [ "${createSQL}" == "true" ]; then
    "$pythonPath/scripts/gdal_polygonize.py" "${reducedRasterFullPath}.tif" \
    -lco "SPATIAL_INDEX=NONE" -lco "SRID=3978" \
    -f PGDUMP \
    ${reducedRasterFullPath}.sql ${tempTargetTableName} year
  fi

  # DROP the temp tables if requested
  if [ $overwriteFRI == True ] && [ "${loadSQL}" == "true"]; then
    "$gdalFolder/ogrinfo" "$pg_connection_string" \
    -sql "
    DROP TABLE IF EXISTS ${tempTargetTableName} CASCADE;
    "
  fi
  
  # load the .sql file
  if [ -e "${reducedRasterFullPath}.sql" ] && [ "${loadSQL}" == "true" ]; then
    "$pgFolder/bin/psql" $connectionParams -f ${reducedRasterFullPath}.sql
  fi
done

# DROP the final target table if requested
if [ $overwriteFRI == True ] && [ "${mergeTables}" == "true" ]; then
  "$gdalFolder/ogrinfo" "$pg_connection_string" \
  -sql "
  DROP TABLE IF EXISTS ${fullTargetTableName} CASCADE;
  "
fi

# Reproject the geometry and merge the two tables
if [ "${mergeTables}" == "true" ]; then
  "$gdalFolder/ogrinfo" "$pg_connection_string" \
  -sql "
  CREATE TABLE ${fullTargetTableName} AS
  SELECT ogc_fid * 2 ogc_fid, 
        year reduced_year,
        'BURN' dist_type,
        year + CASE WHEN year - (year/100)*100 < 30 THEN 2000 ELSE 1900 END dist_year,
        '$inventoryID' inventory_id,
        '$srcFileName' src_filename, 
        'fire' map_sheet_id,
        ST_Transform(wkb_geometry, 900914) wkb_geometry
  FROM ${fullTargetTableName}_fire_year
  UNION ALL
  SELECT ogc_fid * 2 - 1 ogc_fid, 
        year reduced_year,
        'CUT' dist_type,
        year + CASE WHEN year - (year/100)*100 < 30 THEN 2000 ELSE 1900 END dist_year,
        '$inventoryID' inventory_id,
        '$srcFileName' src_filename, 
        'harvest' map_sheet_id,
        ST_Transform(wkb_geometry, 900914) wkb_geometry
  FROM ${fullTargetTableName}_harvest_year
  ;
  --DROP TABLE IF EXISTS ${fullTargetTableName}_fire_year;
  --DROP TABLE IF EXISTS ${fullTargetTableName}_harvest_year;
  "
fi
########################### Process - Loading raster method ################################

# connectionParams="-d $pgdbname -U $pguser -h $pghost -p $pgport"
# rasterOptions="-I -N 0 -t 2000x2000"
# 
# ### upload file1 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath1 $fullTargetTableName1 | $pgFolder/bin/psql $connectionParams
# 
# ### upload file2 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath2 $fullTargetTableName2 | $pgFolder/bin/psql $connectionParams
# 
# ### vectorize raster 1 - type 0 = fire ###
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# CREATE TABLE ${targetFRISchema}.${inventoryID} AS
# WITH rasttable AS (
#   SELECT ST_DumpAsPolygons(rast) gv
#   FROM ${fullTargetTableName1}
# )
# SELECT ST_Transform((gv).geom, 900914) AS wkb_geometry, 
#        (gv).val AS year,
#        0 AS type,
# 	     '${datasetName}' AS src_filename, 
# 	     '${inventoryID}' AS inventory_id 
# FROM rasttable;
# "

# ### vectorize raster 2 - type 1 = logging ###
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# INSECT INTO ${targetFRISchema}.${inventoryID} (
# WITH rasttable AS (
#   SELECT ST_DumpAsPolygons(rast) gv
#   FROM ${fullTargetTableName2}
# )
# SELECT ST_Transform((gv).geom, 900914) AS wkb_geometry, 
#        (gv).val AS year,
#        1 AS type,
# 	   '${datasetName}' AS src_filename, 
# 	   '${inventoryID}' AS inventory_id 
# FROM rasttable
# );
# "

############## Process - Finish processing for both methods ########################

if [ "${loadSQL}" == "true" ]; then
  source ./common_postprocessing.sh
fi