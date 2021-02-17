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

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc01_species_codes_idx
ON translation.species_code_mapping (pc01_species_codes)
WHERE TT_NotEmpty(pc01_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc02_species_codes_idx
ON translation.species_code_mapping (pc02_species_codes)
WHERE TT_NotEmpty(pc02_species_codes);

--------------------------------------------------------------------------
-- Create index for qc stand structure
--------------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS qc_stand_structure_lookup_idx
ON translation.qc_standstructure_lookup (source_val)

-------------------------------------------------------
-- Translate all LYR tables into a common table. 32h
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr');
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr', 'ab_avi01_lyr');
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
SELECT TT_Prepare('translation', 'pc_panp01_lyr', '_pc01_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'pc_wbnp01_lyr', '_pc02_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'qc_ini03_lyr', '_qc02_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'qc_ini04_lyr', '_qc06_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'qc_ipf05_lyr', '_qc07_lyr', 'ab_avi01_lyr'); 
-------------------------
DROP TABLE IF EXISTS casfri50.lyr_all CASCADE;
------------------------
-- Translate AB03 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab03_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB03 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab03_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB06 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS -- 4m41s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB06 layer 2 reusing AB06 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB07 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab07', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab07_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB07 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab07', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab07_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB08 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab08', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab08_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB08 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab08', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab08_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB10 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab10_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB10 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab10', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab10_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB11 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab11_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB11 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab11', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab11_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB16 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab16_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB16 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab16_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB25 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab25_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB25 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab25', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab25_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB29 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1, NULL, 'lyr');

CREATE TABLE casfri50.lyr_all AS 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab29_l1_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate AB29 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab29', 2, 'ab', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all 
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab29_l2_to_ab_l1_map_lyr');
COMMIT;

------------------------
-- Translate NB01 using NB generic translation table and only rows with LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l1_to_nb_l1_map_lyr');
COMMIT;

------------------------
-- Translate NB01 layer 2 using NB layer 1 generic translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l2_to_nb_l1_map_lyr');
COMMIT;

------------------------
-- Translate NB02 using NB generic translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l1_to_nb_l1_map_lyr');
COMMIT;

------------------------
-- Translate NB02 layer 2 reusing NB01 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l2_to_nb_l1_map_lyr');
COMMIT;

------------------------
-- Translate BC08 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc08_l1_to_bc_l1_map_lyr');
COMMIT;

------------------------
-- Translate BC08 layer 2 reusing BC08 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc08_l2_to_bc_l1_map_lyr');
COMMIT;

------------------------
-- Translate BC10 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc10_l1_to_bc_l1_map_lyr');
COMMIT;

------------------------
-- Translate BC10 layer 2 reusing BC10 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc10_l2_to_bc_l1_map_lyr');
COMMIT;

------------------------
-- Translate NT01 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h49m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l1_to_nt_l1_map_lyr');
COMMIT;

------------------------
-- Translate NT01 layer 2 using NT layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h24m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l2_to_nt_l1_map_lyr');
COMMIT;

------------------------
-- Translate NT03 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt03_l1_to_nt_l1_map_lyr');
COMMIT;

------------------------
-- Translate NT03 layer 2 using NT layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt03', 2, 'nt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt03_l2_to_nt_l1_map_lyr');
COMMIT;

------------------------
-- Translate ON02 using ON translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l1_to_on_l1_map_lyr');
COMMIT;

------------------------
-- Translate ON02 layer 2 using ON translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l2_to_on_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK01 using UTM translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_utm_lyr('rawfri', 'sk01_l1_to_sk_utm_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK01 layer 2 using UTM translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_utm_lyr('rawfri', 'sk01_l2_to_sk_utm_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK02 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk02_l1_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK02 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk02_l2_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK02 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk02_l3_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK03 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk03_l1_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK03 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk03_l2_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK03 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk03_l3_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK04 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk04_l1_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK04 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk04_l2_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK04 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk04_l3_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK05 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk05_l1_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK05 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk05_l2_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK05 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk05_l3_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK06 layer 1 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk06_l1_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK06 layer 2 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 2, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk06_l2_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate SK06 layer 3 using SFV translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 3, 'sk_sfv', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_sfv_lyr('rawfri', 'sk06_l3_to_sk_sfv_l1_map_lyr');
COMMIT;

------------------------
-- Translate YT02 using YVI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_yt_lyr('rawfri', 'yt02_l1_to_yt_l1_map_lyr');
COMMIT;

------------------------
-- Translate NS03 layer 1 using NS generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, NULL, 'lyr');
INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ns_lyr('rawfri', 'ns03_l1_to_ns_nsi_l1_map_lyr');
COMMIT;

------------------------
-- Translate NS03 layer 2 using NS generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_ns_lyr('rawfri', 'ns03_l2_to_ns_nsi_l1_map_lyr');
COMMIT;

------------------------
-- Translate PE01 layer 1 using PE generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pe_lyr('rawfri', 'pe01_l1_to_pe_pei_l1_map_lyr');
COMMIT;

------------------------
-- Translate MB05 layer 1 using MB_FRI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fri_lyr('rawfri', 'mb05_l1_to_mb_fri_l1_map_lyr');
COMMIT;

------------------------
-- Translate MB06 layer 1 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l1_to_mb_fli_l1_map_lyr');
COMMIT;

------------------------
-- Translate MB06 layer 2 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l2_to_mb_fli_l1_map_lyr');
COMMIT;

------------------------
-- Translate MB06 layer 3 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 3, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l3_to_mb_fli_l1_map_lyr');
COMMIT;

------------------------
-- Translate MB06 layer 4 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 4, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l4_to_mb_fli_l1_map_lyr');
COMMIT;

------------------------
-- Translate MB06 layer 5 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 5, 'mb_fli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb_fli_lyr('rawfri', 'mb06_l5_to_mb_fli_l1_map_lyr');
COMMIT;

------------------------
-- Translate NL01 layer 1 using NL_NLI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nl_lyr('rawfri', 'nl01_l1_to_nl_nli_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC03 layer 1 using QC_INI03 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc03_lyr('rawfri', 'qc03_l1_to_qc_ini03_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC03 layer 2 using QC_INI03 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc03', 2, 'qc_ini03', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc03_lyr('rawfri', 'qc03_l2_to_qc_ini03_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC04 layer 1 using QC_INI04 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc04_lyr('rawfri', 'qc04_l1_to_qc_ini04_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC04 layer 2 using QC_INI04 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc04', 2, 'qc_ini04', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc04_lyr('rawfri', 'qc04_l2_to_qc_ini04_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC05 layer 1 using QC_IPF05 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc05_lyr('rawfri', 'qc05_l1_to_qc_ipf_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC05 layer 2 using QC_IPF05 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc05', 2, 'qc_ipf', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc05_lyr('rawfri', 'qc05_l2_to_qc_ipf_l1_map_lyr');
COMMIT;

------------------------
-- Translate PC01 layer 1 using PC_PANP translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, NULL, 'lyr');

--Translate Layer 1
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc01_lyr('rawfri', 'pc01_l1_to_pc_panp_l1_map_lyr');
COMMIT;


-- Translate PC01 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc01_lyr('rawfri', 'pc01_l2_to_pc_panp_l1_map_lyr');
COMMIT;


-- Translate PC01 layer
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc01_lyr('rawfri', 'pc01_l3_to_pc_panp_l1_map_lyr');
COMMIT;


------------------------
-- Translate PC02 using PC_WBNP translation table
--Layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_lyr');
COMMIT;


--Layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_lyr');
COMMIT;


--Layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_lyr');
COMMIT;


--Layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_lyr');
COMMIT;


--Layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_lyr');
COMMIT;


--Layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_lyr');
COMMIT;


--Layer 7
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC02 layer 1 using QC_INI03 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc02', 1, 'qc_ini03', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc02_lyr('rawfri', 'qc02_l1_to_qc_ini03_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC02 layer 2 using QC_INI03 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc02', 2, 'qc_ini03', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc02_lyr('rawfri', 'qc02_l2_to_qc_ini03_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC06 layer 1 using QC_INI04 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc06_lyr('rawfri', 'qc06_l1_to_qc_ini04_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC06 layer 2 using QC_INI04 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc06', 2, 'qc_ini04', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc06_lyr('rawfri', 'qc06_l2_to_qc_ini04_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC07 layer 1 using QC_IPF05 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc07_lyr('rawfri', 'qc07_l1_to_qc_ipf_l1_map_lyr');
COMMIT;

------------------------
-- Translate QC07 layer 2 using QC_IPF05 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc07', 2, 'qc_ipf', 1, NULL, 'lyr');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc07_lyr('rawfri', 'qc07_l2_to_qc_ipf_l1_map_lyr');
COMMIT;

--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4)
ORDER BY inv;
--inv  nb
--AB03   72787
--AB06   14179
--AB07   33811
--AB08   44227
--AB10  225160
--AB11  112854
--AB16  149674
--AB25  529256
--AB29  651779
--AB30       0
--BC08 4272025
--BC10 4744673
--MB01   ?????
--MB02   ?????
--MB04   ?????
--MB05  854163
--MB06  213982
--MB07   ?????
--NB01  932271
--NB02 1053554
--NL01  867045
--NS01   ?????
--NS02   ?????
--NS03  972710
--NT01  245832
--NT03  ??????
--ON02 2240815
--PC01    7319
--PC02    1760
--PE01   81073
--QC03  160597
--QC04 1720580
--QC05 5133315
--SK01  860394
--SK02   28983
--SK03   10767
--SK04  708553
--SK05  483663
--SK06  296399
--YT01   ?????
--YT02  105102

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer
ORDER BY left(cas_id, 4), layer;
-- inv lyr nb
-- AB06	1	9403
-- AB06	2	4776
-- AB16	1	104945
-- AB16	2	44729
-- BC08 1	4118380
-- BC08 2	153645
-- BC10	1	4570063
-- BC10	2	174610
-- MB05 1	854163
-- MB06 1	147458
-- MB06 2	58331
-- MB06 3	8085
-- MB06 4	108
-- NB01	1	767392
-- NB01	2	164879
-- NB02	1	870925
-- NB02	2	182629
-- NL01 1	867045
-- NS03	1	742317
-- NS03	2	230393
-- NT01 1	236612
-- NT01 2	9220
-- NT03 1	?????
-- NT03 2	?????
-- ON02	1	2066889
-- ON02	2	173927
-- PC01 1 11186
-- PC01 2 1589
-- PC01 3 137
-- PC02 1   885
-- PC02 2   644
-- PC02 3   215
-- PC02 4   16
-- PE01	1	81073
-- QC03 1	160356
-- QC03 2	241
-- QC04 1	1694157
-- QC04 2	26423
-- QC05 -3333 289
-- QC05 1 5062162
-- QC05 2	71153
-- SK01	1	846500
-- SK01	2	13894
-- SK02	1	23975
-- SK02	2	4843
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
-- YT02	1	5593
SELECT count(*) FROM casfri50.lyr_all; -- 26500563
--------------------------------------------------------------------------
