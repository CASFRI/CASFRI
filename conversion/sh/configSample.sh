#!/bin/bash

#config variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
friFolder=C:/Temp
prjF=C:/Temp/canadaAlbersEqualAreaConic.prj
gdalDir="../../../../../../../../program files/gdal"

ogrinfo=$gdalDir/ogrinfo.exe
ogr2ogr=$gdalDir/ogr2ogr.exe