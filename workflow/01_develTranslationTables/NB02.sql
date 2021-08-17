------------------------------------------------------------------------------
-- CASFRI - NB02 translation development script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Check the uniqueness of NB species codes
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the samples (reusing NB01 translation functions prepared by NB01.sql)
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_cas_devel('rawfri', 'nb02_l1_to_nb_l1_map_200'); -- 5 s.

SELECT * FROM TT_Translate_nb01_dst_devel('rawfri', 'nb02_l1_to_nb_l1_map_200'); -- 4 s.

SELECT * FROM TT_Translate_nb01_eco_devel('rawfri', 'nb02_l1_to_nb_l1_map_200'); -- 2 s.

SELECT * FROM TT_Translate_nb01_lyr_devel('rawfri', 'nb02_l1_to_nb_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_lyr_devel('rawfri', 'nb02_l2_to_nb_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'nb02', 3, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_nfl_devel('rawfri', 'nb02_l3_to_nb_l1_map_200'); -- 3 s.

SELECT * FROM TT_Translate_nb01_geo_devel('rawfri', 'nb02_l1_to_nb_l1_map_200'); -- 2 s.

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_nb01_lyr_devel('rawfri', 'nb02_l1_to_nb_l1_map_200') a, rawfri.nb02_l1_to_nb_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
