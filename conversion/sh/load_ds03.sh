#!/bin/bash -x

# This script loads the Canada Landsat Disturbance (CanLaD) 2017 raster
# as a dst table only

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
# slower but does not require any special installation.

# The first method is used by default in this script. If you can NOT get
# gdal_polygonize.py to work properly, comment the section using the first
# method and uncomment the section using raster2pgsql.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

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

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

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
# The combined raster is created only once in the FRIs source folder. It is not recreated 
# for each generation of CASFRI.

# Define paths
tempDstPath=${srcPath}/temp
tempRasterFullPath=${tempDstPath}/${datasetName}_combined.tif

# Create a temporary folder for the temporary files
echo --------------------------------
echo Create temp dir for temp raster...
if [ ! -d "${tempDstPath}" ]; then
  mkdir "${tempDstPath}"
  echo Temp dir created...
else
  echo Temp dir already exists. Skipping creation...
fi

# Create the temporary reduced size raster combining the type and the year rasters from 
# two 16 bits int to a smaller 8 bits (byte) raster easier to process with gdal_polygonize.py.
#
# Types values (1 and 2) are converted to 0 and 100
# Years values (from 1985 to 2015) are truncated to values from 85 to 15
# values are then added so that:
#   85 means type=1 and year=1985
#   185 mean type=2 and year=1985
#   15 means type=1 and year=2015
#   115 means type=2 and year=2015
echo --------------------------------
echo Create a temporary reduced size raster
if [ ! -e "${tempRasterFullPath}" ]; then
	echo "Creating ${tempRasterFullPath}..."

  "$pythonPath/python.exe" "$gdalPyFolder/gdal_calc.py" -A "$srcFullPath1" -B "$srcFullPath2" \
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
echo --------------------------------
echo DROP the temp tables if requested
if [ $overwriteFRI == True ]; then
  "$gdalFolder/ogrinfo" "$gdalConnectionString" \
  -sql "
  DROP TABLE IF EXISTS ${fullTargetTableName}_temp CASCADE;
  DROP TABLE IF EXISTS ${fullTargetTableName} CASCADE;
"
  echo Table ${fullTargetTableName} DROPed...
else
   echo Table ${fullTargetTableName} NOT DROPed...
fi

# Vectorize directly to PostGIS
echo --------------------------------
echo Vectorize directly to PostGIS
"$pythonPath/python.exe" "$gdalPyFolder/gdal_polygonize.py" "${tempRasterFullPath}" \
-f PostgreSQL "$gdalConnectionString" \
${fullTargetTableName}_temp dn

# Reproject the geometry and parse the combined field into type and year
echo --------------------------------
echo Reproject and parse
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
CREATE TABLE ${fullTargetTableName} AS
SELECT ogc_fid, 
       dn orig_value,
       (dn/100 + 1) dist_type,
       dn - (dn/100)*100 + CASE WHEN dn - (dn/100)*100 < 30 THEN  2000 ELSE 1900 END dist_year,
	     ST_Transform(wkb_geometry, 102001) wkb_geometry,
       '${datasetName}' AS src_filename, 
       '${inventoryID}' AS inventory_id
FROM ${fullTargetTableName}_temp;
DROP TABLE IF EXISTS ${fullTargetTableName}_temp CASCADE;
"

######################### Method 2 - Load as raster #############################

# ### upload file1 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath1 $fullTargetTableName1 | $pgFolder/bin/psql $psqlConnectionString
# 
# ### upload file2 ###
# "$pgFolder/bin/raster2pgsql" $rasterOptions $srcFullPath2 $fullTargetTableName2 | $pgFolder/bin/psql $psqlConnectionString
# 
# ### combine both rasters into a single one ###
# SELECT
#     ST_MapAlgebra(r1, r2, "([rast1] * 10000 + [rast2.val])") AS rast
# FROM $fullTargetTableName1 r1, 
#      $fullTargetTableName2 r2
# WHERE ST_RasterToWorldCoordX(r1.rast) = ST_RasterToWorldCoordX(r2.rast) AND
#       ST_RasterToWorldCoordY(r1.rast) = ST_RasterToWorldCoordY(r2.rast);

############## Process - Finish processing for both methods ########################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh
