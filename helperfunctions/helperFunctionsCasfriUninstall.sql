------------------------------------------------------------------------------
-- CASFRI Helper functions uninstall file for CASFR v5 beta
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
-- Validation functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_nbi01_wetland_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_validation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_tie01_2layer_age_codes_validation(text,text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_tie01_not_etage_notnull_validation(text,text);
DROP FUNCTION IF EXISTS TT_tie01_not_etage_layer1_validation(text,text);
DROP FUNCTION IF EXISTS TT_tie01_not_etage_dens_layers_validation(text,text,text,text);
DROP FUNCTION IF EXISTS TT_yvi01_nat_non_veg_validation(text,text,text);
DROP FUNCTION IF EXISTS TT_yvi01_nfl_soil_moisture_validation(text,text,text,text);
DROP FUNCTION IF EXISTS TT_sk_utm01_species_percent_validation(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_avi01_stand_structure_validation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_stand_structure_validation(text,text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_vri01_hasCountOfNotNull(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_hasCountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_hasCountOfNotNull(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_on_fim02_hasCountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_hasCountOfNotNull(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS tt_sfv01_hasCountOfNotNull(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm_hasCountOfNotNull(text, text, text, text, text);
-------------------------------------------------------------------------------
-- ROW_TRANSLATION_RULE functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_HasNFLInfo(text, text, text);
-------------------------------------------------------------------------------
-- Translation functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_vri01_origin_translation(text, text);
DROP FUNCTION IF EXISTS TT_vri01_site_index_translation(text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_dist_yr_translation(text, text);
DROP FUNCTION IF EXISTS TT_avi01_non_for_veg_translation(text, text);
DROP FUNCTION IF EXISTS TT_avi01_stand_structure_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nbi01_stand_structure_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nbi01_wetland_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_nbi01_nb01_productive_for_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nbi01_nb02_productive_for_translation(text);
DROP FUNCTION IF EXISTS TT_tie01_crownclosure_translation(text, text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_tie01_height_translation(text, text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fim_species_code(text, int);
DROP FUNCTION IF EXISTS TT_fim_species_translation(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fim_species_percent_translation(text, text);
DROP FUNCTION IF EXISTS TT_fim02_stand_structure_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_yvi01_nat_non_veg_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_yvi01_non_for_veg_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_countOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_countOfNotNull(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sfv01_countOfNotNull(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sfv01_stand_structure_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm01_species_percent_translation(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_sk_utm01_species_translation(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_generic_stand_structure_translation(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_countOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_countOfNotNull(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_on_fim02_countOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm_countOfNotNull(text, text, text, text);
-------------------------------------------------------------------------------
-- Generic functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_nbi01_wetland_code(text, text, text);
-------------------------------------------------------------------------------
-- Tools functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_TableColumnType(name, name, name);
DROP FUNCTION IF EXISTS TT_TableColumnNames(name, name);
DROP FUNCTION IF EXISTS TT_ColumnExists(name, name, name);
DROP FUNCTION IF EXISTS TT_CompareRows(jsonb, jsonb);
DROP FUNCTION IF EXISTS TT_CompareTables(name, name, name, name, name, boolean);
DROP FUNCTION IF EXISTS TT_RandomInt(int, int, int, double precision) CASCADE;
DROP FUNCTION IF EXISTS TT_RandomInt(int, int, int);
DROP FUNCTION IF EXISTS TT_TableColumnIsUnique(name, name, name);
DROP FUNCTION IF EXISTS TT_TableColumnIsUnique(name, name);
DROP FUNCTION IF EXISTS TT_Histogram(text, text, text, int, text);
DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, text);
DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, text, text); 
DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, int, text, text);
DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, int, text, text);
DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, int, int, text, text);
DROP FUNCTION IF EXISTS TT_CreateFilterView(text, text, text, text, text, text); 
DROP FUNCTION IF EXISTS TT_CreateMapping(text, int, text, int);
DROP FUNCTION IF EXISTS TT_DeleteAllViews(text);
DROP FUNCTION IF EXISTS TT_ArrayDistinct(anyarray, boolean, boolean);
DROP FUNCTION IF EXISTS TT_CountEstimate(text);
DROP FUNCTION IF EXISTS TT_StackTranslationRules(text, text);
DROP FUNCTION IF EXISTS TT_AddConstraint(name, name, text, text[], text[]);
DROP FUNCTION IF EXISTS TT_IsMissingOrInvalidText() CASCADE;
DROP FUNCTION IF EXISTS TT_IsMissingOrNotInSetCode() CASCADE;
DROP FUNCTION IF EXISTS TT_IsMissingOrInvalidNumber() CASCADE;
DROP FUNCTION IF EXISTS TT_IsMissingOrInvalidRange() CASCADE;