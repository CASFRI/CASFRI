------------------------------------------------------------------------------
-- CASFRI - Test tables comparison script for CASFRI v5
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
---------------------------------------------------------
-- Compare new with old tables
---------------------------------------------------------
SELECT '1.0' number, 
       'Compare "cas_all_new_ordered" and "cas_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''cas_all_test'', ''casfri50_test'' , ''cas_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.cas_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.cas_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.0' number, 
       'Compare "dst_all_new_ordered" and "dst_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''dst_all_test'', ''casfri50_test'' , ''dst_all_new_ordered'', ''cas_id, layer'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.dst_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.dst_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.0' number, 
       'Compare "eco_all_new_ordered" and "eco_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''eco_all_test'', ''casfri50_test'' , ''eco_all_new_ordered'', ''cas_id, layer'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.eco_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.eco_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.0' number, 
       'Compare "lyr_all_new_ordered" and "lyr_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''lyr_all_test'', ''casfri50_test'' , ''lyr_all_new_ordered'', ''cas_id, layer'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.lyr_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.lyr_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.0' number, 
       'Compare "nfl_all_new_ordered" and "nfl_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''nfl_all_test'', ''casfri50_test'' , ''nfl_all_new_ordered'', ''cas_id, layer'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.nfl_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.nfl_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------