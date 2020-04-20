:: Join all attribute tables to polygons.
:: The ogc_fid attribute is dropped from all but the poly table. 
:: Original tables are deleted at the end.

SET query2=ALTER TABLE %TableName_meta% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id; ^
ALTER TABLE %TableName_dist% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id; ^
ALTER TABLE %TableName_herbs% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id, DROP COLUMN IF EXISTS crown_closure; ^
ALTER TABLE %TableName_l1% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id, DROP COLUMN IF EXISTS crown_closure; ^
ALTER TABLE %TableName_l2% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id; ^
ALTER TABLE %TableName_l3% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id; ^
ALTER TABLE %TableName_shrubs% DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS poly_id, DROP COLUMN IF EXISTS crown_closure; ^
DROP TABLE IF EXISTS %fullTargetTableName%; ^
CREATE TABLE %fullTargetTableName% AS ^
SELECT * FROM %TableName_poly% A ^
LEFT JOIN %TableName_meta% B ON A.poly_id = B.poly_id_meta ^
LEFT JOIN %TableName_dist% C ON A.poly_id = C.poly_id_dist ^
LEFT JOIN %TableName_herbs% D ON A.poly_id = D.poly_id_herbs ^
LEFT JOIN %TableName_l1% E ON A.poly_id = E.poly_id_l1 ^
LEFT JOIN %TableName_l2% F ON A.poly_id = F.poly_id_l2 ^
LEFT JOIN %TableName_l3% G ON A.poly_id = G.poly_id_l3 ^
LEFT JOIN %TableName_shrubs% H ON A.poly_id = H.poly_id_shrubs; ^
DROP TABLE IF EXISTS %TableName_poly%; ^
DROP TABLE IF EXISTS %TableName_meta%; ^
DROP TABLE IF EXISTS %TableName_dist%; ^
DROP TABLE IF EXISTS %TableName_herbs%; ^
DROP TABLE IF EXISTS %TableName_l1%; ^
DROP TABLE IF EXISTS %TableName_l2%; ^
DROP TABLE IF EXISTS %TableName_l3%; ^
DROP TABLE IF EXISTS %TableName_shrubs%; ^
ALTER TABLE %fullTargetTableName% DROP COLUMN poly_id_meta, DROP COLUMN poly_id_dist, DROP COLUMN poly_id_herbs, DROP COLUMN poly_id_l1, DROP COLUMN poly_id_l2, DROP COLUMN poly_id_l3, DROP COLUMN poly_id_shrubs;
