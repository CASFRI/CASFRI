------------------------------------------------------------------------------
-- CASFRI Helper functions uninstall file for CASFRI v5 beta
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
DROP FUNCTION IF EXISTS TT_nb_nbi01_wetland_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_validation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_yvi01_nat_non_veg_validation(text,text,text);
DROP FUNCTION IF EXISTS TT_yvi01_nfl_soil_moisture_validation(text,text,text,text);
DROP FUNCTION IF EXISTS TT_sk_utm01_species_percent_validation(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_avi01_stand_structure_validation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_stand_structure_validation(text,text,text,text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_vri01_hasCountOfNotNull(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_hasCountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_hasCountOfNotNull(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_on_fim02_hasCountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_hasCountOfNotNull(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS tt_sfv01_hasCountOfNotNull(text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm_hasCountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_structure_per_validation(text, text);
DROP FUNCTION IF EXISTS TT_qc_prg3_wetland_validation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg4_wetland_validation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg5_wetland_validation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg4_not_double_species_validation(text);
DROP FUNCTION IF EXISTS TT_mb_fri_hascountOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_isCommercial(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_isNonCommercial(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_isForest(text, text);
DROP FUNCTION IF EXISTS TT_qc_prg4_lengthMatchList(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_origin_lower_validation(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_origin_newfoundland_validation(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_crown_closure_validation(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_height_validation(text, text, text);
DROP FUNCTION IF EXISTS TT_qc_hasCountOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_ab_avi01_wetland_validation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_wetland_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_bc_vri01_wetland_validation(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_wetland_validation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_wetland_validation(text, text, text);
DROP FUNCTION IF EXISTS TT_nt_fvi01_wetland_validation(text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm01_wetland_validation(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ab_photo_year_validation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_sfv01_wetland_validation(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fli01_wetland_validation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fri01_wetland_validation(text, text, text);
DROP FUNCTION IF EXISTS TT_pc02_wetland_validation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_pc02_hasCountOfNotNull(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_wetland_validation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nb_hasCountOfNotNull(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fim_species(text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_disturbance_mapText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_disturbance_notNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_disturbance_hasCountOfLayers(text, text, text, text);
DROP FUNCTION IF EXISTS TT_fim_species_count_validate(text, text);
-------------------------------------------------------------------------------
-- ROW_TRANSLATION_RULE functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_HasNFLInfo(text, text, text);
DROP FUNCTION IF EXISTS TT_row_translation_rule_nt_lyr(text, text, text, text, text);
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
DROP FUNCTION IF EXISTS TT_nb_nbi01_wetland_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_nbi01_nb01_productive_for_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nbi01_nb02_productive_for_translation(text);
DROP FUNCTION IF EXISTS TT_fim_species_code(text, int);
DROP FUNCTION IF EXISTS TT_fim_species_percent_translation(text, text);
DROP FUNCTION IF EXISTS TT_fim02_stand_structure_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_yvi01_nat_non_veg_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_yvi01_non_for_veg_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_countOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_countOfNotNull(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sfv01_countOfNotNull(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sfv01_stand_structure_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm01_species_percent_translation(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_sk_utm01_species(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_generic_stand_structure_translation(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_stand_structure_translation(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fli01_stand_structure_translation(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_countOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_countOfNotNull(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_on_fim02_countOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm_countOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_bc_height(text, text, text, text);
DROP FUNCTION IF EXISTS TT_fvi01_structure_per(text, text);
DROP FUNCTION IF EXISTS TT_wetland_code_translation(text, text);
DROP FUNCTION IF EXISTS TT_qc_prg3_wetland_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg4_wetland_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg5_wetland_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg4_species_per_translation(text, text);
DROP FUNCTION IF EXISTS TT_qc_prg5_species_per_translation(text, text);
DROP FUNCTION IF EXISTS TT_mb_fri_countOfNotNull(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_crown_closure_upper_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_crown_closure_lower_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_height_upper_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_height_lower_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_productivity_translation(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_productivity_type_translation(text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_origin_upper_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_origin_lower_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_qc_origin_translation(text, text);
DROP FUNCTION IF EXISTS TT_qc_countOfNotNull(text, text, text);
DROP FUNCTION IF EXISTS TT_lyr_layer_translation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_lyr_layer_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_lyr_layer_translation(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_lyr_layer_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_lyr_layer_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_bc_lyr_layer_translation(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ab_avi01_wetland_translation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_wetland_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_bc_vri01_wetland_translation(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_wetland_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_wetland_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_nt_fvi01_wetland_translation(text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_pc01_species_per_translation(text, text);
DROP FUNCTION IF EXISTS TT_sk_utm01_wetland_translation(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ab_photo_year_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_sfv01_wetland_translation(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fli01_wetland_translation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fri01_wetland_translation(text, text, text);
DROP FUNCTION IF EXISTS TT_pc02_wetland_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_pc02_countOfNotNull(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_wetland_translation(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nb_lyr_layer_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nb_countofnotnull(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_lyr_layer_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_on_lyr_layer_translation(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_sfvi_lyr_layer_translation(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg3_src_inv_area_translation(text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_stand_structure_translation(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_disturbance_copyText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_disturbance_copyInt(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_yt_yvi02_disturbance_matchList(text, text, text, text, text, text);
-------------------------------------------------------------------------------
-- Generic functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_nb_nbi01_wetland_code(text, text, text);
DROP FUNCTION IF EXISTS TT_qc_wetland_code(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ab_avi01_wetland_code(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_nl_nli01_wetland_code(text, text, text);
DROP FUNCTION IF EXISTS TT_bc_vri01_wetland_code(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_ns_nsi01_wetland_code(text, text, text, text);
DROP FUNCTION IF EXISTS TT_pe_pei01_wetland_code(text, text);
DROP FUNCTION IF EXISTS TT_nt_fvi01_wetland_code(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_utm01_wetland_code(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_sk_sfv01_wetland_code(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fli01_wetland_code(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_mb_fri01_wetland_code(text, text);
DROP FUNCTION IF EXISTS TT_pc02_wetland_code(text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg5_species_code_to_reordered_array(text);
DROP FUNCTION IF EXISTS TT_yt_wetland_code(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_qc_prg5_species(text, text);
DROP FUNCTION IF EXISTS TT_qc_prg4_species(text, text);
-------------------------------------------------------------------------------
-- Tools functions
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_TableColumnType(name, name, name);
DROP FUNCTION IF EXISTS TT_TableColumnNames(name, name);
DROP FUNCTION IF EXISTS TT_ColumnExists(name, name, name);
DROP FUNCTION IF EXISTS TT_CompareRows(jsonb, jsonb, boolean);
DROP FUNCTION IF EXISTS TT_CompareTables(name, name, name, name, name, boolean, boolean);
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
DROP FUNCTION IF EXISTS TT_IsJsonGeometry(text);
DROP FUNCTION IF EXISTS TT_Count(name, name);
-------------------------------------------------------------------------------
-- Tools views
-------------------------------------------------------------------------------
DROP VIEW IF EXISTS TT_Queries;
-------------------------------------------------------------------------------
-- Test VIEWs
-------------------------------------------------------------------------------
DROP VIEW IF EXISTS rawfri.ab06_lyr1 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_nfl3 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_dst1 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_nfl3_dst1 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_lyr CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_nfl4 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_and_nfl4 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_dst_or_nfl3_and_nfl4 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_and_nfl2_or_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_and_nfl4_or_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_or_nfl2_not_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_or_nfl4_not_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_and_nfl2_not_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_and_nfl4_not_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl3_or_eco CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl3_and_eco_not_dst2 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_extra_lyr1_for_nfl3_and_nfl4_not_dst CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_null CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_cas_id CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_lyr1_cas_id_nfl CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_not_lyr1 CASCADE;
DROP VIEW IF EXISTS rawfri.ab06_site_class CASCADE;