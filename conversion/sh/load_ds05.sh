######################################## Set variables #######################################

source ./common.sh

inventoryID=DS03

datasetName=CanLaD_20151984
srcPath="$friDir/DS/$inventoryID/data/inventory"

fullTargetTableName=$targetFRISchema.${inventoryID,,}

srcFileName1=CanLaD_20151984_latest_type
srcFullPath1="$srcPath/$srcFileName1.tif"
fullTargetTableName1=$targetFRISchema.${inventoryID,,}_type

srcFileName2=CanLaD_20151984_latest_YRT2
srcFullPath2="$srcPath/$srcFileName2.tif"
fullTargetTableName2=$targetFRISchema.${inventoryID,,}_year

unset PROJ_LIB

####################################### Process  ###########################################

################## Method 1 - Combine and vectorize directly to PostGIS ####################

# The initial strategy was to gdal_polygonize.py both rasters directly to PostGIS
# and then to ST_Intersects() the resulting vector layers to isolate all regions having 
# uniques (type, year) pairs of value. However doing this vectorial intersction proved to be 
# too complex to do in PostGIS (too much time).
#
# So the alternative strategy is to compute a raster combining both values into a single 
# value with gdal_cal.py (making the raster to polygonize smaller by the way) and to 
# gdal_polygonize.py the resulting raster directly into PostGIS.
#
# The combined raster is created only for all in the FRIs hierarchy. It is not recreated 
# for each generation of casfri.

# Create a temporary folder for the temporary combined raster
tempDstPath=${srcPath}/temp
tempRasterFullPath=${tempDstPath}/${datasetName}_combined.tif

if [ ! -d "${tempDstPath}" ]; then
  mkdir "${tempDstPath}"
fi

# Create the temporary raster combining the type and the year raster into a smaller raster 
# easier to handle for gdal_polygonize.py
if [ ! -e "${tempRasterFullPath}" ]; then
	echo "Creating ${tempRasterFullPath}..."

  "$pythonPath/scripts/gdal_calc.py" -A "$srcFullPath1" -B "$srcFullPath2" \
  --type=Byte \
  --calc="(A-1)*100+(B-numpy.trunc(B/100)*100)" \
  --co="COMPRESS=LZW" --co="BIGTIFF=YES" --co="TILED=YES" --co="BLOCKXSIZE=1024" --co="BLOCKYSIZE=1024" \
  --overwrite \
  --outfile "${tempRasterFullPath}"

	echo "${tempRasterFullPath}" created...
else
	echo "${tempRasterFullPath}" already exists. Skipping creation...
fi

# DROP the target table if requested
#if [ $overwriteFRI == True ]; then
  "$gdalFolder/ogrinfo" "$pg_connection_string" \
  -sql "
  DROP TABLE IF EXISTS ${fullTargetTableName}_temp;
  DROP TABLE IF EXISTS ${fullTargetTableName};
#  "
#fi

# Vectorize directly to PostGIS
"$pythonPath/scripts/gdal_polygonize.py" "${tempRasterFullPath}" \
-lco "SPATIAL_INDEX=NONE" \
-f PostgreSQL "$pg_connection_string" \
${fullTargetTableName}_temp

# Reproject the geometry and parse the combined field into type and year
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE TABLE ${fullTargetTableName} AS
SELECT ogc_fid, 
       dn orig_value,
       (dn/100 + 1) dist_type,
       dn - (dn/100)*100 + CASE WHEN dn - (dn/100)*100 < 30 THEN  2000 ELSE 1900 END dist_year,
	     ST_Transform(wkb_geometry, 900914) wkb_geometry,
       '${datasetName}' AS src_filename, 
       '${inventoryID}' AS inventory_id
FROM ${fullTargetTableName}_temp;
DROP TABLE IF EXISTS ${fullTargetTableName}_temp;
"

######################### Method 2 - Load as raster #############################

# ### upload file1 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath1 $fullTargetTableName1 | $pgFolder/bin/psql $connectionParams
# 
# ### upload file2 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath2 $fullTargetTableName2 | $pgFolder/bin/psql $connectionParams
# 
# ### combine both rasters into a single one ###
# SELECT
#     ST_MapAlgebra(r1, r2, "([rast1] * 10000 + [rast2.val])") AS rast
# FROM $fullTargetTableName1 r1, 
#      $fullTargetTableName2 r2
# WHERE ST_RasterToWorldCoordX(r1.rast) = ST_RasterToWorldCoordX(r2.rast) AND
#       ST_RasterToWorldCoordY(r1.rast) = ST_RasterToWorldCoordY(r2.rast);

############## Process - Finish processing for both methods ########################

source ./common_postprocessing.sh