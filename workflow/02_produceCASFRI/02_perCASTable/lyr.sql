------------------------------------------------------------------------------
-- CASFRI Sample workflow file for CASFRI v5 beta
-- For use with PostgreSQL Table Tranlation Engine v0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
-- https://github.com/edwardsmarc/casfri
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

CREATE SCHEMA IF NOT EXISTS casfri50;

-------------------------------------------------------
-- Check the uniqueness of all species codes
-------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_bc_species_codes_idx
ON translation.species_code_mapping (bc_species_codes)
WHERE TT_NotEmpty(bc_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nb_species_codes_idx
ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nt_species_codes_idx
ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_on_species_codes_idx
ON translation.species_code_mapping (on_species_codes)
WHERE TT_NotEmpty(on_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_sk_species_codes_idx
ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_yt_species_codes_idx
ON translation.species_code_mapping (yt_species_codes)
WHERE TT_NotEmpty(yt_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ns_species_codes_idx
ON translation.species_code_mapping (ns_species_codes)
WHERE TT_NotEmpty(ns_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pe_species_codes_idx
ON translation.species_code_mapping (pe_species_codes)
WHERE TT_NotEmpty(pe_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_mb_species_codes_idx
ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nl_species_codes_idx
ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

-------------------------------------------------------
-- Translate all LYR tables into a common table. 32h
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr'); -- used for both AB16 and NB02AB06 layer 1 and 2
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr', 'ab_avi01_lyr'); -- used for both NB01 and NB02, layer 1 and 2
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr', 'ab_avi01_lyr'); -- used for both BC08 and BC10, layer 1 and 2
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr', 'ab_avi01_lyr'); -- used for both NT01 and NT02, layer 1 and 2
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_utm_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk_sfv_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'ns_nsi01_lyr', '_ns_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'pe_pei01_lyr', '_pe_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'mb_fri01_lyr', '_mb_fri_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'mb_fli01_lyr', '_mb_fli_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'nl_nli01_lyr', '_nl_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'qc_ini03_lyr', '_qc03_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'qc_ini04_lyr', '_qc04_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'qc_ipf05_lyr', '_qc05_lyr', 'ab_avi01_lyr'); 
-------------------------
DROP TABLE IF EXISTS casfri50.lyr_all CASCADE;
------------------------
-- Translate AB06 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS -- 4m41s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l1_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab06_l1_to_ab_l1_map_lyr');
------------------------
-- Translate AB06 layer 2 reusing AB06 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l2_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab06_l2_to_ab_l1_map_lyr');
------------------------
-- Translate AB16 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 46m20s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab16_l1_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab16_l1_to_ab_l1_map_lyr');
------------------------
-- Translate AB16 layer 2 reusing AB16 layer 1 translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab16_l2_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab16_l2_to_ab_l1_map_lyr');
------------------------
-- Translate NB01 using NB generic translation table and only rows with LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l1_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr', 'nb01_l1_to_nb_l1_map_lyr');
------------------------
-- Translate NB01 layer 2 using NB layer 1 generic translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l2_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr', 'nb01_l2_to_nb_l1_map_lyr');
------------------------
-- Translate NB02 using NB generic translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l1_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr', 'nb02_l1_to_nb_l1_map_lyr');
------------------------
-- Translate NB02 layer 2 reusing NB01 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l2_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr', 'nb02_l2_to_nb_l1_map_lyr');
------------------------
-- Translate BC08 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc08_l1_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr', 'bc08_l1_to_bc_l1_map_lyr');
------------------------
-- Translate BC08 layer 2 reusing BC08 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc08_l2_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr', 'bc08_l2_to_bc_l1_map_lyr');
------------------------
-- Translate BC10 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc10_l1_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr', 'bc10_l1_to_bc_l1_map_lyr');
------------------------
-- Translate BC10 layer 2 reusing BC10 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc10_l2_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr', 'bc10_l2_to_bc_l1_map_lyr');
------------------------
-- Translate NT01 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h49m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l1_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr', 'nt01_l1_to_nt_l1_map_lyr');
------------------------
-- Translate NT01 layer 2 using NT layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h24m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l2_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr', 'nt01_l2_to_nt_l1_map_lyr');
------------------------
-- Translate NT02 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l1_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr', 'nt02_l1_to_nt_l1_map_lyr');
------------------------
-- Translate NT02 layer 2 using NT layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l2_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr', 'nt02_l2_to_nt_l1_map_lyr');
------------------------
-- Translate ON02 using ON translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l1_to_on_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_lyr', 'on02_l1_to_on_l1_map_lyr');
------------------------
-- Translate ON02 layer 2 using ON translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l2_to_on_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_lyr', 'on02_l2_to_on_l1_map_lyr');
------------------------
-- Translate SK01 using UTM translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_utm_lyr('rawfri', 'sk01_l1_to_sk_utm_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_lyr', 'sk01_l1_to_sk_utm_l1_map_lyr');
------------------------
-- Translate SK01 layer 2 using UTM translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_utm_lyr('rawfri', 'sk01_l2_to_sk_utm_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_lyr', 'sk01_l2_to_sk_utm_l1_map_lyr');
------------------------
-- Translate SK02 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk02_l1_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk02_l1_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK02 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk02_l2_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk02_l2_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK02 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk02_l3_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk02_l3_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK03 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk03_l1_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk03_l1_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK03 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk03_l2_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk03_l2_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK03 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk03_l3_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk03_l3_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK04 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk04_l1_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk04_l1_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK04 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk04_l2_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk04_l2_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK04 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk04_l3_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk04_l3_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK05 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk05_l1_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk05_l1_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK05 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk05_l2_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk05_l2_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK05 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk05_l3_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk05_l3_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK06 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk06_l1_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk06_l1_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK06 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk06_l2_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk06_l2_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate SK06 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk06_l3_to_sk_sfv_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk06_l2_to_sk_sfv_l1_map_lyr');
------------------------
-- Translate YT02 using YVI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_yt_lyr('rawfri', 'yt02_l1_to_yt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_lyr', 'yt02_l1_to_yt_l1_map_lyr');
------------------------
-- Translate NS03 layer 1 using NS generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, NULL, 'lyr');
INSERT INTO casfri50.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr('rawfri', 'ns03_l1_to_ns_nsi_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_lyr', 'ns03_l1_to_ns_nsi_l1_map_lyr');
------------------------
-- Translate NS03 layer 2 using NS generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_ns_lyr('rawfri', 'ns03_l2_to_ns_nsi_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_lyr', 'ns03_l2_to_ns_nsi_l1_map_lyr');
------------------------
-- Translate PE01 layer 1 using PE generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pe_lyr('rawfri', 'pe01_l1_to_pe_pei_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pe_pei01_lyr', 'pe01_l1_to_pe_pei_l1_map_lyr');
------------------------
-- Translate MB05 layer 1 using MB_FRI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fri_lyr('rawfri', 'mb05_l1_to_mb_fri_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fri01_lyr', 'mb05_l1_to_mb_fri_l1_map_lyr');
------------------------
-- Translate MB06 layer 1 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l1_to_mb_fli_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_lyr', 'mb06_l1_to_mb_fli_l1_map_lyr');
------------------------
-- Translate MB06 layer 2 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l2_to_mb_fli_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_lyr', 'mb06_l2_to_mb_fli_l1_map_lyr');
------------------------
-- Translate MB06 layer 3 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 3, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l3_to_mb_fli_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_lyr', 'mb06_l3_to_mb_fli_l1_map_lyr');
------------------------
-- Translate MB06 layer 4 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 4, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l4_to_mb_fli_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_lyr', 'mb06_l4_to_mb_fli_l1_map_lyr');
------------------------
-- Translate MB06 layer 5 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 5, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l5_to_mb_fli_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_lyr', 'mb06_l5_to_mb_fli_l1_map_lyr');
------------------------
-- Translate NL01 layer 1 using NL_NLI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nl_lyr('rawfri', 'nl01_l1_to_nl_nli_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nl_nli01_lyr', 'nl01_l1_to_nl_nli_l1_map_lyr');
------------------------
-- Translate QC03 layer 1 using QC_INI03 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc03_lyr('rawfri', 'qc03_l1_to_qc_ini03_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini03_lyr', 'qc03_l1_to_qc_ini03_l1_map_lyr');
------------------------
-- Translate QC03 layer 2 using QC_INI03 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc03', 2, 'qc_ini03', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc03_lyr('rawfri', 'qc03_l2_to_qc_ini03_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini03_lyr', 'qc03_l2_to_qc_ini03_l1_map_lyr');
------------------------
-- Translate QC04 layer 1 using QC_INI04 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc04_lyr('rawfri', 'qc04_l1_to_qc_ini04_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini04_lyr', 'qc04_l1_to_qc_ini04_l1_map_lyr');
------------------------
-- Translate QC04 layer 2 using QC_INI04 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc04', 2, 'qc_ini04', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc04_lyr('rawfri', 'qc04_l2_to_qc_ini04_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini04_lyr', 'qc04_l2_to_qc_ini04_l1_map_lyr');
------------------------
-- Translate QC05 layer 1 using QC_IPF05 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf05', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc05_lyr('rawfri', 'qc05_l1_to_qc_ipf05_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ipf05_lyr', 'qc05_l1_to_qc_ipf05_l1_map_lyr');
------------------------
-- Translate QC05 layer 2 using QC_IPF05 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc05', 2, 'qc_ipf05', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc05_lyr('rawfri', 'qc05_l2_to_qc_ipf05_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ipf05_lyr', 'qc05_l2_to_qc_ipf05_l1_map_lyr');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4)
ORDER BY inv;
-- inv  nb
-- AB06	14179
-- AB16	149674
-- BC08	4113383
-- BC10	4744673
-- NB01	932271
-- NB02	1053554
-- NS03	972710
-- NT01	246179
-- NT02	350967
-- ON02	2240815
-- PE01	81073
-- SK01	860394
-- SK02	28983
-- SK03	10767
-- SK04	708553
-- SK05	483663
-- SK06	296399
-- YT02	105102

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer
ORDER BY left(cas_id, 4), layer;
-- inv lyr nb
-- AB06	1	9403
-- AB06	2	4776
-- AB16	1	104945
-- AB16	2	44729
-- BC08	1	4113383
-- BC10	1	4570063
-- BC10	2	174610
-- NB01	1	767392
-- NB01	2	164879
-- NB02	1	870925
-- NB02	2	182629
-- NS03	1	742317
-- NS03	2	230393
-- NT01	1	236939
-- NT01	2	9240
-- NT02	1	266159
-- NT02	2	84808
-- ON02	1	2066888
-- ON02	2	173927
-- PE01	1	81073
-- SK01	1	846500
-- SK01	2	13894
-- SK02	1	23976
-- SK02	2	4844
-- SK02	3	165
-- SK03	1	7435
-- SK03	2	3318
-- SK03	3	14
-- SK04	1	549987
-- SK04	2	154902
-- SK04	3	3664
-- SK05	1	378763
-- SK05	2	103292
-- SK05	3	1608
-- SK06	1	184309
-- SK06	2	101696
-- SK06	3	10394
-- YT02	1	105102

SELECT count(*) FROM casfri50.lyr_all; -- 17393341
--------------------------------------------------------------------------
