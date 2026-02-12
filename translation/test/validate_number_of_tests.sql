-------------------------------------------------------------------------------
-- Check if the number of test is sufficient
--
-- TT_CheckNumberOfTests() helps validate if the number of random row tested is 
-- sufficient considering the number of final translated rows for each inventory 
-- and each cas table (cas, dst, eco, lyr and nfl. geo tables are not tested 
-- because they do not involve extensive translation).
--
-- IMPORTANTT: A complete translation have to be performed before running this 
-- test in order to know the number of final translated rows.
--
-- The last TT_CheckNumberOfTests() parameter determines whether the test 
-- numbers are grouped by layer or not. For some CASFRI tables (NFL for most 
-- inventories, ECO for PC), source attributes may sometimes translate into more 
-- than one layer. In such cases, it becomes difficult and sometimes impossible — 
-- to set the correct number of source rows to test in order to obtain the proper 
-- number of tests for each layer. When this happens, it is preferable to define 
-- this number globally across all layers.
--
-- This query takes about 7 minutes and should return 0 rows if the number of 
-- tests is sufficient in every cases. You can also remove the WHERE clause to 
-- get a complete list of all the cases and their respective number of tests, 
-- source rows, target rows, and percentage difference.
-------------------------------------------------------------------------------
SELECT * FROM (
  SELECT (TT_CheckNumberOfTests('cas', 'all', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('dst', 'all', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('eco', 'all', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('lyr', 'all', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'ab', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'bc', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'ds', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'mb', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'nb', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'nl', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'ns', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'nt', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'on', TRUE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'pc', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'pe', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'pe', FALSE)).*
  UNION ALL
  SELECT (TT_CheckNumberOfTests('nfl', 'sk', FALSE)).*
) nb_test
WHERE NOT sufficient OR diff_pct >= 20;