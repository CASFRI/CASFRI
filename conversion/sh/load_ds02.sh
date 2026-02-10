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
# its own version of Python) and a compatible set of gdal package:
#
#   conda install -c conda-forge gdal=3.10.0 libgdal-core=3.10.0 libgdal-pg=3.10.0 postgresql --force-reinstall
#
# You can then test that the PostgreSQL driver is installed properly:
#
#   ogrinfo --formats | grep -i postgresql
#
# And that gdal_polygonize is running smoothly (must be >= 3.1)
#
#   gdal_polygonize --version
#
# The second method, using PostGIS raster2pgsql and ST_DumpAsPolygons(), is 
# slower and produce a border effect along the tiles but does not require 
# any special installation.

# The first method is used by default in this script. If you can NOT get
# gdal_polygonize.py to work properly, comment the section using the first
# method and uncomment the section using raster2pgsql.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

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

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

##### Method 1 - Reduce raster size and vectorize directly to PostGIS ############

rasterOptions="-I -t 2048x2048"

# Set these variable to false if you don't want to create the associated intermediate step
# For faster debug purpose.
createCropped=true
createReduced=true
createSQLFile=true
loadSQL=true
mergeTables=true

# Do the whole process for the Fire and the Harvest rasters
for srcDataset in Fire Harvest
do
  echo --------------------------------------
  echo Processing the ${srcDataset} raster...
  echo --------------------------------------
  # Define names and paths
  datasetName=CA_Forest_${srcDataset}_1985-2020
  srcPath=${baseSrcPath}/${datasetName}
  tempDstPath=${srcPath}/temp

  srcFullPath=${srcPath}/${datasetName}
  croppedRasterFullPath=${tempDstPath}/${datasetName}${suffix}
  reducedRasterFullPath=${croppedRasterFullPath}_reduced

  tempTargetTableName=${fullTargetTableName}_${srcDataset,,}_year

  # Create a temporary folder for the temporary files
  echo --------------------------------
  echo Create temp dir for temp raster...
  if [ ! -d "${tempDstPath}" ]; then
    mkdir "${tempDstPath}"
    echo Temp dir created...
  else
    echo Temp dir already exists. Skipping creation...
  fi

  # Create a temp version of the raster with the nodata value properly set. The original 
  # nodata area is too complex to vectorize with gdal_polygonize.py. When the nodata
  # value is set properly gdal_polygonize.py ignore it and does not to try to polygonize it.
  echo --------------------------------
  echo Create cropped version of the raster 
  if [ ! -e "${croppedRasterFullPath}.tif" ] && [ "${createCropped}" == "true" ]; then
  	echo "Creating ${croppedRasterFullPath}.tif..."
  
    "$gdalFolder/gdal_translate" -a_nodata 0 -srcwin ${offset} ${offset} ${xsize} ${ysize} \
    -co COMPRESS=LZW -co TILED=YES -co BLOCKXSIZE=1024 -co BLOCKYSIZE=1024 \
    "${srcFullPath}.tif" "${croppedRasterFullPath}.tif"

  	echo "${croppedRasterFullPath}.tif" created...
  else
  	echo "${croppedRasterFullPath}.tif" already exists. Skipping creation...
  fi

  # Create a temporary reduced size raster (from 16 bits unsigned int to byte) 
  # and setting the nodata value properly so it is easier to handle by gdal_polygonize.py
  #
  # 0 is set to nodata value 255
  # other year values are truncated to values under 255 (e.g. 1997 to 97, 2000 to 0 and 2007 to 7)
  echo --------------------------------
  echo Create a temporary reduced raster
  if [ ! -e "${reducedRasterFullPath}.tif" ] && [ "${createReduced}" == "true" ]; then
  	echo "Creating ${reducedRasterFullPath}.tif..."
  
#    "$pythonPath/scripts/gdal_calc.py" -A "${croppedRasterFullPath}.tif" \
    "$pythonPath/python.exe" "$gdalPyFolder/gdal_calc.py" -A "${croppedRasterFullPath}.tif" \
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
  echo --------------------------------
  echo Vectorize the raster into a temporary .sql file if requested
  if [ ! -e "${reducedRasterFullPath}.sql" ] && [ "${createSQLFile}" == "true" ]; then
    "$pythonPath/python.exe" "$gdalPyFolder/gdal_polygonize.py" "${reducedRasterFullPath}.tif" \
    -lco SPATIAL_INDEX=NONE -lco SRID=3978 \
    -f PGDUMP \
    ${reducedRasterFullPath}.sql ${tempTargetTableName} year

    echo ${reducedRasterFullPath}.sql created...
  else
    echo ${reducedRasterFullPath}.sql NOT created...
  fi

  # DROP the temp tables if requested
  echo --------------------------------
  echo DROP the temp tables if requested
  if [ "$overwriteFRI" == "True" ] && [ "${loadSQL}" == "true" ]; then
    "$gdalFolder/ogrinfo" "$gdalConnectionString" \
    -sql "
    DROP TABLE IF EXISTS ${tempTargetTableName} CASCADE;
    "
    echo Table ${tempTargetTableName} DROPPed...
  else
    echo Table ${tempTargetTableName} NOT DROPPed...
  fi
  
  # Load the .sql file
  echo --------------------------------
  echo Load the .sql file
  if [ -e "${reducedRasterFullPath}.sql" ] && [ "${loadSQL}" == "true" ]; then
    "$pgFolder/bin/psql" $psqlConnectionString -f ${reducedRasterFullPath}.sql
    echo ${reducedRasterFullPath}.sql loaded...
  else
    echo ${reducedRasterFullPath}.sql NOT loaded...
  fi
done

# DROP the final target table if requested
echo --------------------------------
echo DROP the final target table if requested
if [ "$overwriteFRI" == "True" ] && [ "${mergeTables}" == "true" ]; then
  "$gdalFolder/ogrinfo" "$gdalConnectionString" \
  -sql "
  DROP TABLE IF EXISTS ${fullTargetTableName} CASCADE;
  "
  echo Table ${fullTargetTableName} DROPed...
else
   echo Table ${fullTargetTableName} NOT DROPed...
fi

# Reproject the geometries and merge the two tables
echo --------------------------------
echo Reproject the geometries and merge the two tables
if [ "${mergeTables}" == "true" ]; then
  "$gdalFolder/ogrinfo" "$gdalConnectionString" \
  -sql "
  CREATE TABLE ${fullTargetTableName} AS
  SELECT ogc_fid * 2 ogc_fid, 
        year reduced_year,
        'BURN' dist_type,
        year + CASE WHEN year - (year/100)*100 < 30 THEN 2000 ELSE 1900 END dist_year,
        '$inventoryID' inventory_id,
        '$srcFileName' src_filename, 
        'fire' map_sheet_id,
        ST_Transform(wkb_geometry, 102001) wkb_geometry
  FROM ${fullTargetTableName}_fire_year
  UNION ALL
  SELECT ogc_fid * 2 - 1 ogc_fid, 
        year reduced_year,
        'CUT' dist_type,
        year + CASE WHEN year - (year/100)*100 < 30 THEN 2000 ELSE 1900 END dist_year,
        '$inventoryID' inventory_id,
        '$srcFileName' src_filename, 
        'harvest' map_sheet_id,
        ST_Transform(wkb_geometry, 102001) wkb_geometry
  FROM ${fullTargetTableName}_harvest_year
  ;
  DROP TABLE IF EXISTS ${fullTargetTableName}_fire_year CASCADE;
  DROP TABLE IF EXISTS ${fullTargetTableName}_harvest_year CASCADE;
  "
fi
########################### Process - Loading raster method ################################

# rasterOptions="-I -N 0 -t 2000x2000"
# 
# ### upload file1 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath1 $fullTargetTableName1 | $pgFolder/bin/psql $psqlConnectionString
# 
# ### upload file2 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath2 $fullTargetTableName2 | $pgFolder/bin/psql $psqlConnectionString
# 
# ### vectorize raster 1 - type 0 = fire ###
# "$gdalFolder/ogrinfo" "$gdalConnectionString" \
# -sql "
# CREATE TABLE ${targetFRISchema}.${inventoryID} AS
# WITH rasttable AS (
#   SELECT ST_DumpAsPolygons(rast) gv
#   FROM ${fullTargetTableName1}
# )
# SELECT ST_Transform((gv).geom, 102001) AS wkb_geometry, 
#        (gv).val AS year,
#        0 AS type,
# 	     '${datasetName}' AS src_filename, 
# 	     '${inventoryID}' AS inventory_id 
# FROM rasttable;
# "

# ### vectorize raster 2 - type 1 = logging ###
# "$gdalFolder/ogrinfo" "$gdalConnectionString" \
# -sql "
# INSECT INTO ${targetFRISchema}.${inventoryID} (
# WITH rasttable AS (
#   SELECT ST_DumpAsPolygons(rast) gv
#   FROM ${fullTargetTableName2}
# )
# SELECT ST_Transform((gv).geom, 102001) AS wkb_geometry, 
#        (gv).val AS year,
#        1 AS type,
# 	   '${datasetName}' AS src_filename, 
# 	   '${inventoryID}' AS inventory_id 
# FROM rasttable
# );
# "

############## Process - Finish processing for both methods ########################

if [ "${mergeTables}" == "true" ]; then
  thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source $thisScriptDir/../post_conversion.sh

fi