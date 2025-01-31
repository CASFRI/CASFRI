#!/bin/bash -x

# This script loads the Canada Landsat Disturbance (CanLaD) 1984-1965 raster
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

inventoryID=DS05

datasetName=CanLaD_19841965
srcPath="$friDir/DS/$inventoryID/data/inventory"

fullTargetTableName=$targetFRISchema.${inventoryID,,}

srcFileName1=PEI_canlad_1965_1984_disturbanceType_3978
srcFullPath1="$srcPath/$srcFileName1.tif"
fullTargetTableName1=$targetFRISchema.${inventoryID,,}_type

srcFileName2=PEI_canlad_1965_1984_disturbanceYear_3978
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

## Create a temporary folder for the temporary combined raster
# tempDstPath=${srcPath}/temp
# tempRasterFullPath=${tempDstPath}/${datasetName}_combined.tif

# if [ ! -d "${tempDstPath}" ]; then
#   mkdir "${tempDstPath}"
# fi

# # Create the temporary raster combining the type and the year raster into a smaller raster 
# # easier to handle for gdal_polygonize.py
# if [ ! -e "${tempRasterFullPath}" ]; then
# 	echo "Creating ${tempRasterFullPath}..."

#   "$pythonPath/scripts/gdal_calc.py" -A "$srcFullPath1" -B "$srcFullPath2" \
#   --type=Byte \
#   --calc="(A-1)*100+(B-numpy.trunc(B/100)*100)" \
#   --co="COMPRESS=LZW" --co="BIGTIFF=YES" --co="TILED=YES" --co="BLOCKXSIZE=1024" --co="BLOCKYSIZE=1024" \
#   --overwrite \
#   --outfile "${tempRasterFullPath}"

# 	echo "${tempRasterFullPath}" created...
# else
# 	echo "${tempRasterFullPath}" already exists. Skipping creation...
# fi

# # DROP the target table if requested
# #if [ $overwriteFRI == True ]; then
#   "$gdalFolder/ogrinfo" "$pg_connection_string" \
#   -sql "
#   DROP TABLE IF EXISTS ${fullTargetTableName}_temp;
#   DROP TABLE IF EXISTS ${fullTargetTableName};
# #  "
# #fi

# # Vectorize directly to PostGIS
# "$gdalFolder/gdal_polygonize.py" "${tempRasterFullPath}" \
# -lco "SPATIAL_INDEX=NONE" \
# -f PostgreSQL "$pg_connection_string" \
# ${fullTargetTableName}_temp

# # Reproject the geometry and parse the combined field into type and year
# "$gdalFolder/ogrinfo" "$pg_connection_string" \
# -sql "
# CREATE TABLE ${fullTargetTableName} AS
# SELECT ogc_fid, 
#        dn orig_value,
#        (dn/100 + 1) dist_type,
#        dn - (dn/100)*100 + CASE WHEN dn - (dn/100)*100 < 30 THEN  2000 ELSE 1900 END dist_year,
# 	     ST_Transform(wkb_geometry, 900914) wkb_geometry,
#        '${datasetName}' AS src_filename, 
#        '${inventoryID}' AS inventory_id
# FROM ${fullTargetTableName}_temp;
# DROP TABLE IF EXISTS ${fullTargetTableName}_temp;


######################## Method 2 - Load as raster #############################

# raster option list: set to default value
# https://postgis.net/docs/using_raster_dataman.html
rasterOptions="-I -C -M -t 2048x2048"
connectionParams="-d $pgdbname -U $pguser -h $pghost -p $pgport"

"$pgFolder/bin/psql" $connectionParams -c "DROP TABLE IF EXISTS rawfri.DS05_year;"
"$pgFolder/bin/psql" $connectionParams -c "DROP TABLE IF EXISTS rawfri.DS05_type;"
"$pgFolder/bin/psql" $connectionParams -c "DROP TABLE IF EXISTS rawfri.DS05_3978;"
"$pgFolder/bin/psql" $connectionParams -c "DROP TABLE IF EXISTS rawfri.DS05_102001;"
"$pgFolder/bin/psql" $connectionParams -c "DROP TABLE IF EXISTS rawfri.DS05_102001_poly;"

### create temp new files, which restate/reproject of file1 to 3978 ###
# "$gdalFolder/gdalwarp -t_srs $prjFile "E:\FRIs\DS\DS05\data\inventory\PEI_canlad_1965_1984_disturbanceYear.tif" "reprojected102001.tif"

# ### restate crs of the source file1 ###
# "$pythonPath/Scripts/gdal_edit.py" -a_srs "EPSG:3978" "E:/FRIs/DS/DS05/data/inventory/PEI_canlad_1965_1984_disturbanceYear.tif"
# "$pythonPath/Scripts/gdal_edit.py" -a_srs "EPSG:3978" "E:/FRIs/DS/DS05/data/inventory/PEI_canlad_1965_1984_disturbanceType.tif"

### upload file1 ###
"$pgFolder/bin/raster2pgsql" -s 3978 $rasterOptions $srcFullPath1 $fullTargetTableName1 | $pgFolder/bin/psql $connectionParams

### upload file2 ### 
"$pgFolder/bin/raster2pgsql" -s 3978 $rasterOptions $srcFullPath2 $fullTargetTableName2 | $pgFolder/bin/psql $connectionParams

### combine both rasters into a single one "DS05"###
"$pgFolder/bin/psql" $connectionParams -c "
CREATE TABLE rawfri.DS05_3978 AS
SELECT 
    ST_MapAlgebra(
        r1.rast, 1,  -- First raster (band 1)
        r2.rast, 1,  -- Second raster (band 1)
        '[rast1] * 10000 + [rast2]',  -- Corrected expression format
        '32BF'  -- Output raster type (32-bit float)
    ) AS rast
FROM rawfri.DS05_type r1
JOIN rawfri.DS05_year r2
ON ST_Intersects(r1.rast, r2.rast);  -- Ensure they overlap
"

### reproject/resample combined rasters to 102001 via PostGIS###
"$pgFolder/bin/psql" $connectionParams -c "
DELETE FROM rawfri.DS05_3978 WHERE ST_NumBands(rast) = 0;
CREATE TABLE rawfri.DS05_102001 AS
SELECT ST_Transform(rast, 102001) AS rast FROM rawfri.DS05_3978;
UPDATE rawfri.DS05_102001 
SET rast = ST_Resample(rast, ST_Transform((SELECT rast FROM rawfri.DS05_3978 LIMIT 1), 102001));
"

### Polyonise in PostGIS"###
"$pgFolder/bin/psql" $connectionParams -c "
CREATE TABLE rawfri.DS05_102001_poly AS
SELECT (ST_DumpAsPolygons(rast)).*
FROM rawfri.DS05_102001;
CREATE INDEX idx_DS05_102001_poly_geom ON rawfri.DS05_102001_poly USING GIST (geom);
"

############## Process - Finish processing for both methods ########################

source ./common_postprocessing.sh