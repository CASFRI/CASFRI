-------------------------------------------------------
-- NT02
-------------------------------------------------------
-- create translation tables from NT01 tables
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nt02_fvi01_cas_test;
CREATE TABLE translation_test.nt02_fvi01_cas_test WITH OIDS AS
SELECT * FROM translation.nt01_fvi01_cas;
-- Update cas_id
UPDATE translation_test.nt02_fvi01_cas_test
SET translation_rules = regexp_replace(translation_rules, 'nt01', 'nt02')
WHERE rule_id = '1';
-- change 'Forest' to 'geonb_forest-foret' in validation rules
UPDATE translation_test.nt02_fvi01_cas_test
SET validation_rules = regexp_replace(validation_rules, 'fc_id_1', 'fc_id')
WHERE rule_id IN ('1');
-- display
SELECT * FROM translation_test.nt02_fvi01_cas_test;
----------------------------

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nt02_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_test_200 AS
SELECT invproj_id, fc_id, ogc_fid, geom, areaha, 
       moisture, crownclos, height, 
       sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, 
       structur, strc_per, origin, typeclas, 
       dis1code, dis1year, dis1ext
FROM rawfri.nt02 TABLESAMPLE SYSTEM (300.0*100/11484) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.nt02_test_200;
--------------------------------------------------------------------------

SELECT TT_Prepare('translation_test', 'nt02_fvi01_cas_test', '_nt02_cas');

SELECT * FROM TT_Translate_nt02_cas('rawfri', 'nt02_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt02_nbi01_cas_test');
