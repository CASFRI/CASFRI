:: This script loads the Ontario FIM forest inventory (ON02) into PostgreSQL

:: This dataset is split into 41 tables in a single geodatabase, each representing
:: a different forest management unit.

:: The year of photography is included in the attributes table (YRSOURCE)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: All tables have the same core attributes, but many have additional attributes.
:: Load all tables using -addfields

::######################################## Set variables #######################################
SETLOCAL

CALL .\common.bat

SET inventoryID=ON02
SET srcFileName=ON_FRI_forest
SET srcFullPath="%friDir%/ON/%inventoryID%/data/inventory/%srcFileName%.gdb"
SET fullTargetTableName=%targetFRISchema%.on02
SET temp_table=%targetFRISchema%.on02_all_attributes

SET ogr_options=-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -t_srs %prjFile% %overwrite_tab%


:: ########################################## Process ######################################

SETLOCAL ENABLEDELAYEDEXPANSION

for %%F in (AL_615_2D AP_451_2D ARF_110_2D BA_220_2D BSF_030_2D CF_175_2D CL_noFMU_2D CLF_NBI_2D CR_2D DF_535_2D DRM_177_2D ER_230_2D FSF_360_2D GCF_438_2D HF_601_2D KF_644_2D LF_796_2D LS_702_2D LSP_2D MAF_140_2D MB_851_067_370_2D MF_565_2D ML_2D NAG_390_2D NF_754_2D NSF_630_2D OF_796_2D PA_NA_2D PF_421_2D QPP_2D RL_840_2D SF_210_2D SPF_853_2D SUF_889_2D TF_898_2D TL_120_2D W_130_2D WAB_2D WJ_490_2D WRF_060_2D) do (
	
	"%gdalFolder%/ogr2ogr" ^
	-f PostgreSQL %pg_connection_string% %srcFullPath% ^
	-nln %temp_table% ^
	-progress ^
	-sql "SELECT *, '%%F' as src_filename, '%inventoryID%' AS inventory_id FROM %%F" ^
	!ogr_options!
	
	SET ogr_options=-update -append -addfields
)

:: TMF_280_2D is missing PERIMETER value but has Shape_Leng we can use insteead. Make PERIMETER attribute during loading.
for %%F in (TMF_280_2D) do (
	
	"%gdalFolder%/ogr2ogr" ^
	-f PostgreSQL %pg_connection_string% %srcFullPath% ^
	-nln %temp_table% ^
	-progress ^
	-sql "SELECT *, '%%F' as src_filename, '%inventoryID%' AS inventory_id, Shape_Leng as PERIMETER FROM %%F" ^
	!ogr_options!
)

SET query=DROP TABLE IF EXISTS $fullTargetTableName; ^
CREATE TABLE %fullTargetTableName% AS ^
SELECT  AREA, PERIMETER, FMFOBJID, POLYID, POLYTYPE, YRSOURCE, SOURCE, FORMOD, DEVSTAGE, YRDEP, DEPTYPE, ^
OYRORG, OSPCOMP, OLEADSPC, OAGE, OHT, OCCLO, OSI, OSC, UYRORG, USPCOMP, ULEADSPC, UAGE, UHT, UCCLO, USI, USC, ^
INCIDSPC, VERT, HORIZ, PRI_ECO, SEC_ECO, ACCESS1, ACCESS2, MGMTCON1, MGMTCON2, MGMTCON3, VERDATE, SENSITIV, BED ^
FROM %temp_table% ^
; ^
DROP TABLE IF EXISTS %temp_table%;

"%gdalFolder%\ogrinfo" %pg_connection_string% -sql "%query%"

ENDLOCAL