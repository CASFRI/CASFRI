-- The goal of these statistics is to verify how LYR, NFL, DST and ECO info are structured in raw inventories.
-- They should help us determine how rows must be selected for translation now that we filter some of them out 
-- with TT_CreateMappingview() allegedly because they have no info.
--
-- Unexpected results are flagged with the 'ALERT' keyword...

-- A) One thing we want to make sure is that rows having LYR, NFL, DST or ECO info, in the source inventory, 
--    represent a complete coverage of the inventory. In other word, if some extra info, not captured by those 
--    attributes, might be found when these attributes are all NULL or empty.

-- B) We also want to verify if NFL info is always independent of LYR info or not. When they are independant, 
--    'layer' can always be = 1 in both target tables. When they are not independent then 'layer', for NFL 
--    rows, is dependent on the presence or absence of LYR info.

-- C) We also want to verify the relation between LYR1 and LYR2, between NFL1 and NFL2 and between DST1, DST2 
--    and DST3 info. i.e. Does it happen, sometimes, that LYR2 info is found without LYR1 info? Those rows 
--    should be assigned layer=1.

-- D) Beside this, we want also to check if soil_moist_reg, site_class and site_index values can be present in 
--    the absence of LYR, NFL or DST info. i.e. if they are sometimes found alone without other info so that 
--    we need to translate those extra row to get all.

-- For each inventory, compute:

--  A1) The total count of rows.
--  A2) The count of rows having no LYR1, LYR2, NFL1, NFL2, DST1, DST2 and ECO info. If not 0 then we have to 
--      translate those rows in some way.

--  B1) The count of rows having NFL info also having LYR1 or LYR2 info. If 0 then 'layer' can be hardcoded. 
--      Otherwise it must take LYR1 (and LYR2?) into account.
--  B2) The count of rows having NFL info also having LYR1 but not or LYR2 info.
--  B3) The count of rows having NFL info also having LYR2 but not or LYR1 info.

--  C1) The count of rows having LYR1 and LYR2 info. If not 0 then layer can be 1 or 2.
--  C2) The count of rows having LYR1 and LYR2 info. If not 0 then layer can be 1 or 2.
--  C3) The count of rows having LYR2 info without LYR1 info. Then those rows should get 'layer' = 1.
--  C4) The count of rows having LYR2 info with NFL1 info.
--  C5) The count of rows having LYR2 info with NFL2 info.

--  D1) The count of rows having soil_moist_reg set without LYR1, LYR2, NFL1 or NLF2 info.
--  D2) The count of rows having soil_moist_reg set for layer 2 without LYR1, LYR2, NFL1 or NLF2 info.
--  D3) The count of rows having soil_moist_reg for layer 1 set to a different value than layer 2.

--  D4) The count of rows having site_class set without LYR1 or LYR2 info.
--  D5) The count of rows having site_class for layer 1 set to a different value than layer 2.

--  D6) The count of rows having site_index set without LYR1 or LYR2 info.
--  D7) The count of rows having site_class for layer 1 set to a different value than layer 2.

-----------------------------
-- AB06
-----------------------------
-- A1) 11484
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, NULL, NULL, 'a1');
SELECT * FROM rawfri.ab06_a1;

-- A2) 0
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, NULL, 'LYR1, LYR2, NFL1, NFL2, DST1, DST2, ECO', 'a2');
SELECT count(*) FROM rawfri.ab06_a2;

-- B1) 0
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, '[NFL1, LYR1, LYR2]', NULL, 'b1');
SELECT count(*) FROM rawfri.ab06_b1;

-- B2) 0
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, '[NFL1, LYR1]', 'LYR2', 'b2');
SELECT count(*) FROM rawfri.ab06_b2;

-- B3) 8 NFL1 and LYR2 info without LYR1 info. Same as C2
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, '[NFL1, LYR2]', 'LYR1', 'b3');
SELECT * FROM rawfri.ab06_b3;

-- C1) 4784
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, 'LYR2', NULL, 'c1');
SELECT count(*) FROM rawfri.ab06_c1;

-- C2) 4776
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, '[LYR1, LYR2]', NULL, 'c2');
SELECT count(*) FROM rawfri.ab06_c2;

-- C3) 8 Same as B3. ALERT! LYR2 info without LYR1 info
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, 'LYR2', 'LYR1', 'c3');
SELECT * FROM rawfri.ab06_c3;

-- C4) 8
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, '[LYR2, NFL1]', NULL, 'c4');
SELECT count(*) FROM rawfri.ab06_c4;

-- C5) 0
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, '[LYR2, NFL2]', NULL, 'c5');
SELECT count(*) FROM rawfri.ab06_c5;

-- D1) 0
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, 'soil_moist_reg', 'LYR1, LYR2, NFL1, NFL2', 'd1');
SELECT count(*) FROM rawfri.ab06_d1;

-- D2) 0
SELECT TT_CreateFilterView('rawfri', 'ab06', NULL, 'umoist_reg', 'LYR1, LYR2, NFL1, NFL2', 'd2');
SELECT count(*) FROM rawfri.ab06_d2;

-- D3) ALERT! 5216 rows have umoist_reg different than moist_reg!
SELECT TT_CreateFilterView('rawfri', 'ab06', 'moist_reg, umoist_reg, LYR1, LYR2, NFL1, NFL2, DST1, DST2, ECO', NULL, NULL, 'd3'); 
SELECT * FROM rawfri.ab06_d3
WHERE moist_reg != umoist_reg;

-- D4) ALERT! 1573 rows have site_class info without LYR1 and LYR2 info
SELECT TT_CreateFilterView('rawfri', 'ab06', 'site_class, LYR1, NFL1, LYR2, NFL2, DST1, DST2, ECO', 'site_class', 'LYR1, LYR2', 'd4');
SELECT * FROM rawfri.ab06_d4;

-- D5)
SELECT TT_CreateFilterView('rawfri', 'ab06', 'tpr, utpr, LYR1, NFL1, LYR2, NFL2, DST1, DST2, ECO', NULL, NULL, 'd5'); 
SELECT * FROM rawfri.ab06_d5
WHERE tpr != utpr;

-- D6) No site index info in AB06
SELECT TT_CreateFilterView('rawfri', 'ab06', 'site_index, LYR1, NFL1, LYR2, NFL2, DST1, DST2, ECO', 'site_index', 'LYR1, LYR2', 'd6');
SELECT * FROM rawfri.ab06_d6;

-- D7) Useless

