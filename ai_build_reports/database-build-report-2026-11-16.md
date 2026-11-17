# Fresh CASFRI test database build - 2026-11-16

## Scope and safeguards

- **Purpose: test build only.** This run exercised the full workflow on four inventories; it was not a production deployment or release. References below to production functions or outputs describe the normal workflow used within this test database.
- Requested inventories: **AB03, AB06, AB07, AB08 only**.
- Existing local configuration: `config.sh`; target `casfri_ai`, localhost port 5435.
- The target database did not exist at preflight. Existing databases were not dropped or changed.
- The source directory configured by `friDir` is read-only input for this work: no extraction, renaming, editing, or output is directed there.
- Read all 11 pre-existing Markdown files in the two workspaces. Follow the main README's **Build the whole database from scratch**, including common setup, checks, both flat tables, history, and coverages. Archived inventory-update and release instructions are context, not authorization to publish or commit.
- Preserve the three pre-existing edits in geohistory functions, geohistory tests, and historical preparation SQL.
- Keep credentials out of logs. Run existing shell scripts wherever practical, capturing their output and independently checking database results rather than trusting exit codes alone.

## Status

**Test build completed**, with the test-compatibility and numerical-geometry caveats documented below.

- Database: **casfri_ai**, localhost:5435, using the existing local configuration.
- PostgreSQL 13.12; PostGIS 3.4.0; GEOS 3.12.0. GDAL 3.13.3 was used for loading.
- Only the requested four raw inventories and their shared Alberta photograph-year dependency were imported. Reference metadata and translation definitions cover other inventories too; that does not import their source inventories.
- Both flat materialized views, production geohistory, and all eight coverage tables were produced.
- All 24 translated count comparisons, 174 attribute-constraint checks, and six geometry-constraint checks passed.
- **Test caveat:** the unchanged synthetic geohistory suite still reports three stale assertions, and the unchanged additional-check script reports two subset-sensitive assertions. The causes and independent replacement checks are documented below; these scripts are not being described as completely green.
- Started approximately **15:14:18**, local time (UTC-05:00).
- Derived-product generation completed at **15:39:08**. Final database statistics were collected at **15:46:53**; the final precedence investigation completed at **15:48:15**. Elapsed time from the approximate start through that verification was **33 minutes 57 seconds**, excluding subsequent report finalization.
- Final database size: **5,758 MB**, as reported by PostgreSQL's `pg_size_pretty()`, including raw data, normalized/flat/history/coverage outputs, definitions, test data and retained workflow intermediates. `ANALYZE` completed.

## Database contents

| Inventory | Raw | CAS | GEO | DST | ECO | LYR | NFL | History rows |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| AB03 | 61,633 | 61,633 | 61,633 | 6,426 | 3,776 | 72,787 | 19,001 | 62,324 |
| AB06 | 11,484 | 11,484 | 11,484 | 1,875 | 1,174 | 14,179 | 3,515 | 11,484 |
| AB07 | 23,268 | 23,268 | 23,268 | 1,418 | 1,516 | 33,811 | 4,770 | 23,268 |
| AB08 | 34,474 | 34,474 | 34,474 | 6,202 | 1,022 | 44,227 | 7,729 | 34,714 |
| Total | 130,859 | 130,859 | 130,859 | 15,921 | 7,488 | 165,004 | 35,015 | 131,790 |

- Normalized six-table total: **485,146 rows**, excluding the four HDR rows.
- `casfri50_flat.cas_flat_all_layers_same_row`: **130,859 rows**.
- `casfri50_flat.cas_flat_one_layer_per_row`: **200,019 rows**, exactly the sum of `NUM_OF_LAYERS`.
- Production preparation split the source stands into **275,115** one-kilometre grid pieces.
- Geohistory spans **1900-2030**, according to the installed implementation's bounds.
- History contains **130,757 distinct stand identifiers**. The 102 suppressed AB03 identifiers are investigated below; normalized/source stands were not deleted.

## Problems and remedies

Main step numbers refer to [Build the whole database from scratch](../README.md#build-the-whole-database-from-scratch), not the execution numbers in the timing table. Step 1 includes Common setup; cross-cutting problems are marked "Across steps".

TODO lists recommended code or test changes to prevent recurrence; these changes have not been implemented. "AI assistant can handle the situation" means no code change is currently established as necessary, not that checks or unexplained discrepancies may be ignored.

Priority ranks only actionable code/test follow-up work: `high` for security or data-integrity risks, silent execution failures, and small, well-defined fixes; `medium` for nonurgent automation, policy clarification or more involved test maintenance with a verified workaround; `low` for optional diagnostics or regression-coverage expansion without a known correctness risk. A workaround does not lower a security or data-loss risk. Priority is `N/A` when TODO says "AI assistant can handle the situation".

The medium-ranked items are dependency-loading automation (2), partial-build HDR scoping (11), the temporal-policy decision (14), geometry-assertion refactoring (16), and subset-aware validation (17). Problem 20 remains high because protecting accepted archives takes precedence over its optional AB-fixture expansion.

| No. | Main step | Problem | Action / resolution | Status | Priority | TODO |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | Inventory selection (2) | Existing `fullList` contains only AB03. Sourcing configuration can overwrite command-line inventory selections. | Set the existing local configuration's list to AB03, AB06, AB07, AB08, and also pass explicit identifiers where appropriate. | Resolved | high | Change [define_invlist.sh](../define_invlist.sh) and its calling batch scripts so configuration loading cannot overwrite explicit inventory arguments. [Details](#problem-1). |
| 2 | Convert and load inventories (5) | AB conversions require a separate photo-year shapefile. Explicit inventory arguments skip automatic photo-year loading. | Ran `load_ab_photoyear.sh` for the shared Alberta photograph-year dataset, then converted all four inventories. No unrelated photograph-year datasets were loaded. | Resolved | medium | Change [convert_all.sh](../conversion/convert_all.sh) to check and load missing shared photo-year dependencies for explicitly selected inventories. [Details](#problem-2). |
| 3 | Common setup: logging (1) | Several supplied scripts enable Bash tracing, including commands containing database credentials. | Route Bash's trace stream to a null file descriptor before starting scripts. Do not copy credentials into scripts or the report. | Resolved | high | Remove unconditional tracing from the shell loaders/wrappers and protect configuration and credential handling in [common.sh](../common.sh). [Details and affected files](#problem-3). |
| 4 | Common setup: Git Bash (1) | Git Bash is installed but is not on PowerShell's command search path. The default launcher opens detached GUI windows. | Invoke the installed console Bash by its explicit path and use console Bash for child commands so completion and logs can be observed. | Resolved | N/A | AI assistant can handle the situation |
| 5 | Common setup: database preflight (1) | An initial inline PowerShell-to-Bash database probe lost SQL quoting and returned ambiguous output. | Replace inline quoting with a session-local shell runner and SQL files; the repeated preflight confirmed the target database is absent. | Resolved | N/A | AI assistant can handle the situation |
| 6 | Common setup: framework installation (1) | Framework `install.sh` cannot write to PostgreSQL's protected `share\extension` directory (permission denied). | Used the framework README's documented alternative: loaded `engine.sql`, `helperFunctions.sql`, and `helperFunctionsGIS.sql` directly into the new database. All three suites subsequently returned zero failing rows. The framework functions are installed directly, not registered as a PostgreSQL extension. No elevation or server-wide installation change. | Resolved | N/A | AI assistant can handle the situation |
| 7 | Common setup: command output (1) | Windows PowerShell treats native stderr as an error record even for normal PostgreSQL notices. | Capture native output with a non-terminating preference and explicitly check the executable's exit code; restore strict PowerShell error handling afterward. | Resolved | N/A | AI assistant can handle the situation |
| 8 | Common setup: helper tests (1) | The CASFRI helper suite initially reports 23 failed `TT_CreateFilterView()` assertions. Reloading metadata does not change them. The checkout uses CRLF in multiline expected SQL, while the function returns LF. | Rerun the complete, unchanged suite through an LF-normalizing input stream (`tr -d '\r'`). All failures disappear: zero failing rows. No helper implementation or expected result was weakened or edited. | Resolved | high | In [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql), normalize CRLF/LF in the expected multiline SQL for the 23 filter-view checks without ignoring other SQL differences. [Details](#problem-8). |
| 9 | Convert and load inventories (5) | GDAL prints its connection string in ordinary informational output, not just shell tracing. | Add credential redaction to the log-capture stream and scrub the earlier captured logs. Shell-trace suppression alone was insufficient. | Resolved | high | In [common.sh](../common.sh), remove the password from `gdalConnectionString` and use libpq password-file or environment-based authentication instead. [Details](#problem-9). |
| 10 | Batch execution and validation (Across steps) | Shell batches can return exit code zero despite failed child commands or false test results. | Enabled `ON_ERROR_STOP` through the inherited psql startup file, checked captured logs for errors, inspected boolean results, and queried actual database counts and geometry independently. Translation, history, and coverage logs contained no PostgreSQL errors or warnings. | Mitigated | high | Change the conversion, test, translation, history and coverage batch scripts to collect every worker's exit status, stop on SQL errors and turn failed checks into a failing batch result. [Files and details](#problem-10). |
| 11 | Initialize and translate CASFRI tables (8) | Initialization copies the complete inventory metadata into HDR, even with only four raw inventories selected. | Removed all HDR records except AB03, AB06, AB07 and AB08 from the newly created target database before translation. Verified exactly four HDR identifiers afterward. | Resolved | medium | Pass the resolved selection from [01_createCASFRITables.sh](../workflow/02_produceCASFRI/01_createCASFRITables.sh) to [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql) and filter HDR creation to those identifiers. [Details](#problem-11). |
| 12 | Sample translations (7) | Province-wide sample generation would replace accepted Alberta CSVs with results for only the inventories currently loaded. | Backed up all five accepted files, generated and compared the requested inventories, retained generated evidence separately, and restored the exact originals. Final SHA256 comparisons confirm all five accepted files are unchanged. | Resolved | high | In [test_translation.sh](../translation/test/test_translation.sh), replace unconditional deletion/export of accepted CSVs with staged output and an explicit acceptance step, guarding partial-jurisdiction runs. [Details](#problem-12). |
| 13 | Sample comparisons (7) | CAS sample area/perimeter values differ from accepted CSVs at floating-point precision. | Compared all 800 CAS samples: maximum area difference **2.84600787381351e-10 ha**, maximum perimeter difference **5.9699232224375e-08 m**. Row keys/counts and every other attribute match; DST/ECO/LYR/NFL are exact matches. Accepted values were not replaced. | Explained | N/A | AI assistant can handle the situation |
| 14 | Geohistory tests (12) | Synthetic geohistory assertion 2.1 expects a 1930 lower bound, but `TT_PolygonGeoHistory()` sets 1900. | Verified the two exact expected polygon footprints, reference year 2000, and actual bounds 1900-2030. Production output also consistently uses 1900-2030. Did not alter the user's pre-existing function/test edits or change the model's temporal policy. | Explained; original assertion remains stale | medium | Confirm the intended lower year, then align `refYearBegin` in [geohistory.sql](../helperfunctions/geohistory/geohistory.sql) and test 2.1 in [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql). [Decision and details](#problem-14). |
| 15 | Geohistory tests (12) | Test 6.2 deliberately gives `TT_ValidYearUnion()` an invalid year range: start year **2010**, end year **2000**. The function correctly rejects this range, but the test still reports failure because it compares the entire error message with an older expected message. | **Expected:** `TT_ValidYearUnion() ERROR: Lower value is higher than higher value...`<br>**Actual:** `TT_ValidYearUnion() ERROR: Lower value (2010) is higher than higher value (2000)...`<br>The added year values make the messages unequal. Independently verified that the invalid range raises the intended error (SQLSTATE `P0001`). Recommended fix: update the expected test message to include the years, or check the error condition without requiring identical wording. No function or test code was changed during this build. | Year-range rejection verified; expected test message still needs updating | high | In [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), update test 6.2's expected message to include `(2010)` and `(2000)`; keep rejection of reversed years mandatory. [Details](#problem-15). |
| 16 | Geohistory tests (12) | Synthetic assertion 6.3 compares a Polygon composite byte-for-byte, but the final aggregate normalizes to MultiPolygon. | Verified exactly one output interval, bounds 2000-2000, and topological equality with the expected polygon using `ST_Equals()`. | Explained; original assertion remains stale | medium | In [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), rewrite test 6.3 to check result count, topology and year bounds separately instead of comparing entire geometry composites. [Details](#problem-16). |
| 17 | Constraints, indexes and additional checks (10) | Additional checks 1.5 and 1.6 require the aggregate of observed patterns to equal every possible national pattern, including absent layers/species counts. They also depend on aggregate ordering without `ORDER BY`. | Ran row-level invalid-order/gap queries instead: **zero height-order violations and zero species gaps**. Only one/two forest layers are present here; absence of three/four/five-layer examples is not a data defect. Existing descriptions refer to [#475](https://github.com/CASFRI/CASFRI/issues/475) and [#676](https://github.com/CASFRI/CASFRI/issues/676). | Explained; original assertions remain subset-sensitive | medium | In [03_additionalChecks.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/03_additionalChecks.sql), make checks 1.5/1.6 reject invalid observed rows rather than require all national patterns. Keep their diagnostic queries consistent. [Details](#problem-17). |
| 18 | Flat-table validation (11) | The one-layer flat SQL test includes an unrestricted dump of every row and an obsolete national count comment. | Executed equivalent count, duplicate-layer, layer-maximum and layer-count checks without dumping 200,019 wide rows. The expected count was calculated from this build's CAS data, not a national release constant. | Resolved for this build | high | In [04_one_layer_per_row_test.sql](../workflow/03_flatCASFRI/04_one_layer_per_row_test.sql), compare counts with the current CAS layer total and remove the unrestricted row dump from normal validation. [Details](#problem-18). |
| 19 | Geohistory tests and preparation (12) | Synthetic geohistory tests replace production validity/precedence functions. | Ran the synthetic suite before production preparation; `01_PrepareGeoHistory.sh` then installed the production functions. Did not rerun table-resetting preparation after history generation. | Resolved | high | Isolate the function replacements in [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql) and review the real-data test scripts for the same side effect. Restore definitions without resetting history tables. [Details](#problem-19). |
| 20 | Archived geohistory regressions (12) | Archived real-inventory geohistory regressions sample NB/NT/BC/SK, none of which were requested or loaded. Their dump script also deletes archived sampling CSVs before exporting replacements. | Did not import additional inventories or execute empty-data archive replacement. Substituted full AB production geometry, interval, overlap, identifier and footprint checks. Archived cross-province geohistory regressions were **not validated** by this build. | Scope limitation | high | Extend [geohistory_test_with_inv_data.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data.sql), its gridded counterpart and fixture loader with AB cases; replace the blanket CSV deletion in [dump_test_tables_with_inv_data.sh](../helperfunctions/geohistory/dump_test_tables_with_inv_data.sh) with guarded exports. [Details](#problem-20). |
| 21 | Inventory coverage production (13) | Parallel coverage procedures create the same shared tables/indexes on their first run. | Pre-created the eight tables and four gridded indexes serially, with exactly the definitions used by the existing procedure, before running the unchanged parallel shell batch. No race occurred. | Prevented | high | In [03_ProduceInventoryCoverages.sh](../workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh), initialize shared tables/indexes serially before launching workers, using the definitions in [geohistory.sql](../helperfunctions/geohistory/geohistory.sql). [Details](#problem-21). |
| 22 | Geohistory validation (12) | AB03 history has 102 fewer distinct stand identifiers than CAS, despite having more history rows overall. | Confirmed all 102 are covered by **AB08 polygons from the same photograph year**, whose precedence rank is 8 versus AB03's 3. There are 101 stands from 1993 and one from 1994. All are covered to within one square centimetre; maximum per-stand remainder is **1.7644969102741505e-06 m2**. An initial same-inventory-only hypothesis did not explain them; tracing cross-inventory precedence did. Source/normalized stands remain intact. | Explained: intended cross-inventory suppression | N/A | AI assistant can handle the situation |
| 23 | History and coverage validation (12 and 13) | Strict spatial topology finds microscopic simultaneous overlaps and grid-reconstruction differences. | Measured all history overlap pairs: 1,369 positive-area numerical slivers, maximum **2.4963630307329142e-08 m2**; **none exceed one square centimetre** (the implementation's minimum retained polygon area). Coverage grid reconstruction differs by at most **1.0399311577202752e-05 m2**. Reported these rather than claiming exact zero. | Explained | N/A | AI assistant can handle the situation |
| 24 | Source/history footprint validation (12) | Exact unions of source and history polygons are not perfectly identical. | Independently unioned both full datasets without the coverage algorithm's buffering or hole removal. Their symmetric difference is **0.35346375948007586 m2**, relative difference **2.568973566700673e-11** across a source footprint of **13,758,948,868.206089 m2**. Largest difference component is **0.35307568760208596 m2**. Retained the existing geometry workflow and reported the discrepancy explicitly; no input or expected geometry was edited to hide it. | Quantified numerical/spatial caveat; not exact equality | N/A | AI assistant can handle the situation |
| 25 | Final source-integrity verification (14) | The first final source-file enumeration returned 202 files instead of 206. | Diagnosed omission of four pre-existing hidden Word lock files. Repeated enumeration with `-Force`: all **206** paths, sizes, UTC modification times and SHA256 hashes match the pre-build snapshot; no files were added or removed. Did not modify/delete the hidden files. | Resolved | N/A | AI assistant can handle the situation |
| 26 | Final reference-file verification (14) | A final accepted-CSV verification initially used `testtables` instead of the actual `tables` directory. | Corrected the verification path and repeated the checks; all five original accepted files match their backups. This was an audit-command path error, not a data change. | Resolved | N/A | AI assistant can handle the situation |

### Detailed code-change TODOs

These are proposed follow-up changes, not changes made during this build. Problem numbers match the table. Preserve existing user edits and accepted reference data when implementing them; confirm the temporal-policy decision in problem 14 before changing behavior.

#### Problem 1

**Preserve explicit inventory selections.**

Files: [define_invlist.sh](../define_invlist.sh), [common.sh](../common.sh), and the argument-handling blocks in [convert_all.sh](../conversion/convert_all.sh), [test_translation.sh](../translation/test/test_translation.sh), [02_translateAll.sh](../workflow/02_produceCASFRI/02_translateAll.sh), [02_ProduceGeoHistory.sh](../workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh) and [03_ProduceInventoryCoverages.sh](../workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh).

- The callers currently assign command-line inventories to `fullList` before sourcing `define_invlist.sh`, which sources `common.sh` and reloads configuration. Preserve the explicit arguments separately and apply them after configuration has loaded, before falling back to the configured list or metadata selection.
- Preserve the special `02_translateAll.sh INVENTORY TABLE` form and its selected CASFRI table; fixing inventory selection must not discard that argument.
- Verify three cases: explicit arguments conflicting with configured `fullList`, configured `fullList` without arguments, and metadata-column selection with neither override. Only the intended inventories may run.

#### Problem 2

**Load required shared photograph-year data for explicit selections.**

File to change: [convert_all.sh](../conversion/convert_all.sh). Reuse [load_ab_photoYear.sh](../conversion/sh/load_ab_photoYear.sh) for the Alberta dependency rather than duplicating its loading commands.

- Replace the blanket rule that skips shared datasets whenever inventory arguments are supplied with a dependency check for the resolved inventory selection.
- For the four inventories in this build, check that `rawfri.ab_photoyear` exists and load it first if missing. Identify other inventories' dependencies before extending the rule; do not load unrelated shared datasets just because they appear in `photoYearList`.
- Reuse an existing dependency table unless a refresh is explicitly requested. Test both a fresh database and one where the shared table already exists, then require matching raw counts.

#### Problem 3

**Stop automatic tracing of credential-bearing commands.**

Files include [common.sh](../common.sh), [test_translation.sh](../translation/test/test_translation.sh), [01_createCASFRITables.sh](../workflow/02_produceCASFRI/01_createCASFRITables.sh), [02_ProduceGeoHistory.sh](../workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh), [load_test_tables.sh](../helperfunctions/geohistory/load_test_tables.sh), [load_test_tables_with_inv_data.sh](../helperfunctions/geohistory/load_test_tables_with_inv_data.sh), and the conversion loaders such as [load_ab03.sh](../conversion/sh/load_ab03.sh), [load_ab06.sh](../conversion/sh/load_ab06.sh), [load_ab07.sh](../conversion/sh/load_ab07.sh) and [load_ab08.sh](../conversion/sh/load_ab08.sh).

- Remove unconditional `-x` shebang options and `set -x` commands from normal execution paths. Apply the same rule to the other loaders using that pattern, not only the four listed here.
- If diagnostic tracing remains available, suspend it while reading configuration or assigning/exporting credentials in `common.sh`. Child scripts must not unexpectedly re-enable it around sensitive commands.
- Verify ordinary output and explicitly requested diagnostic output using a dummy password. Neither stdout nor stderr may contain it. Implement this together with problem 9: disabling shell tracing alone does not stop GDAL from logging its connection string.

#### Problem 8

**Make multiline helper-test expectations independent of checkout line endings.**

File to change: [helperFunctionsCASFRITest.sql](../helperfunctions/helperFunctionsCASFRITest.sql), in the `TT_CreateFilterView()` tests numbered 16.1 onward.

- Normalize CRLF to LF in the expected multiline SQL strings before equality comparison, for example by removing carriage returns with `replace(expected_text, chr(13), '')`.
- Keep comparisons of SQL statements, identifiers, clauses and line structure intact. Do not remove all whitespace or change the production helper merely to match a checkout's line endings.
- Run the complete helper suite using both CRLF and LF versions of its input; all 23 filter-view checks must give the same result without an external `tr` workaround.

#### Problem 9

**Remove passwords from GDAL connection arguments.**

File to change: [common.sh](../common.sh), where `gdalConnectionString` is constructed.

- Remove the `password=...` component. Prefer an existing libpq password file, including one selected through `PGPASSFILE`, or provide the configured password through `PGPASSWORD` with tracing disabled.
- Ensure GDAL and psql child processes inherit the selected authentication mechanism and still work non-interactively. Never print the password-file contents or the password environment value.
- Test successful authentication and an invalid-password failure with dummy credentials, checking normal GDAL informational output as well as shell traces. Retain log redaction as additional protection, not as the only fix.

#### Problem 10

**Make batch completion and failure reporting reliable.**

Files to change: [convert_all.sh](../conversion/convert_all.sh), [test_translation.sh](../translation/test/test_translation.sh), [02_translateAll.sh](../workflow/02_produceCASFRI/02_translateAll.sh), [02_ProduceGeoHistory.sh](../workflow/04_produceHistoricalTable/02_ProduceGeoHistory.sh) and [03_ProduceInventoryCoverages.sh](../workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh).

- Track each worker process and collect its exit status. A bare final `wait`, or a later successful count query, must not hide an earlier worker failure. Wait for all workers even when post-processing is disabled.
- Ensure the tracked process represents the actual worker, not just a detached window launcher. Preserve the worker's failure status if a shell-close prompt runs afterward.
- Pass `ON_ERROR_STOP=1` to psql invocations. Separately turn false validation results into a nonzero batch result: `ON_ERROR_STOP` alone does not treat a successful `SELECT` returning `false` as an error.
- Prevent dependent exports or success summaries after failure. Verify a failing SQL statement, a failed child process and a false count check among otherwise successful parallel jobs; each batch must report failure and identify the affected inventory/table.

#### Problem 11

**Limit HDR initialization to the resolved build selection.**

Files to change: [01_createCASFRITables.sh](../workflow/02_produceCASFRI/01_createCASFRITables.sh) and [01_createCASFRITables.sql](../workflow/02_produceCASFRI/01_createCASFRITables.sql).

- Resolve the inventory selection in the shell wrapper using the same rules as the other batches, then pass the identifiers safely to psql as data rather than constructing unchecked SQL fragments.
- Filter the `CREATE TABLE casfri50.hdr_all AS SELECT ... FROM public.inventory_metadata` statement to those identifiers. Reject an empty or invalid selection instead of silently creating an unintended HDR scope.
- Verify the exact set of HDR identifiers for a partial build and a full metadata-based build, and confirm the HDR primary key and CAS-to-HDR foreign key still pass. This remains a fresh-build initializer; do not repurpose its destructive table creation as an incremental update.

#### Problem 12

**Separate generated sample CSVs from accepted references.**

File to change: [test_translation.sh](../translation/test/test_translation.sh), in the final per-province CSV export loop.

- Remove the unconditional `rm ./tables/${table_name}_test.csv` before export. Write generated files to a separate staging location and retain the accepted files until comparison and explicit acceptance.
- Record which inventories actually contributed to a province's generated results. A partial set of loaded inventories must not replace a complete provincial reference, even if the script was invoked with only one inventory.
- Check every export's status before offering replacement. Verify a partial Alberta build and an interrupted/failed export leave all five original accepted CSVs byte-for-byte unchanged.

#### Problem 14

**Resolve the intended historical lower bound before aligning the test.**

Files: [geohistory.sql](../helperfunctions/geohistory/geohistory.sql), in `TT_PolygonGeoHistory()` where `refYearBegin` is 1900, and [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), test 2.1.

- Confirm whether the intended model starts in 1900 or 1930. This is a behavior decision, not just a formatting discrepancy.
- If 1900 is intended, update test 2.1's expected lower bounds. If 1930 is intended, change the production lower-bound logic and review its treatment of older, negative and missing photograph years.
- Do not replace every occurrence of 1930 or 1900: some values represent photograph years rather than validity limits. Run the full artificial-data history suite and inspect resulting intervals before rebuilding production history.

#### Problem 15

**Update the reversed-year test's expected error message.**

File to change: [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), test 6.2. The corresponding exception is raised by `TT_ValidYearUnionStateFct()` in [geohistory.sql](../helperfunctions/geohistory/geohistory.sql).

- Change the expected text to `TT_ValidYearUnion() ERROR: Lower value (2010) is higher than higher value (2000)...`.
- Keep the deliberately reversed 2010-2000 input. Do not weaken the test to accept no error, an unrelated error, or merely any SQLSTATE `P0001` exception.
- No production-function change is needed for this mismatch: its added year values make the error more informative. Verify the corrected test passes and still fails if reversed intervals are accepted.

#### Problem 16

**Check the aggregate's geometry and interval explicitly.**

File to change: [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), test 6.3. Review the output contract of `TT_ValidYearUnionFinalFct()` in [geohistory.sql](../helperfunctions/geohistory/geohistory.sql), which currently applies `ST_Multi()`.

- Replace equality of the entire expected `geomlowuppval[]` composite with separate checks: exactly one result, geometry topologically equal to the expected square using `ST_Equals()`, and lower/upper years both 2000.
- If MultiPolygon output is part of the intended contract, assert that type explicitly rather than accidentally requiring Polygon through the expected composite.
- Do not remove the production `ST_Multi()` normalization just to satisfy the old expected value. Verify wrong geometry, extra intervals and incorrect year bounds are still detected.

#### Problem 17

**Make additional checks work for any valid inventory subset.**

File to change: [03_additionalChecks.sql](../workflow/02_produceCASFRI/03_ConstraintsChecksAndIndexes/03_additionalChecks.sql), checks 1.5 and 1.6 and their `list_query` diagnostic text.

- For check 1.5, derive `passed` from the absence of invalid per-stand layer orderings. Reuse the rule already expressed by its diagnostic query instead of comparing the observed pattern array with all five national patterns.
- For check 1.6, reject actual gaps between meaningful species slots while preserving the existing treatment of missing-value and `NOT_IN_SET` codes. If string patterns are retained, use the `_10` separator consistently for the tenth slot; the current construction uses `10` while the allowed pattern contains `_10`.
- Keep the pass/fail predicate and the rows listed for diagnosis consistent. Test a valid one/two-layer subset, all valid layer counts, a height inversion, a species gap and a valid ten-species row. Invalid data must still fail; missing examples of valid national patterns must not.

#### Problem 18

**Make flat-table validation concise and build-specific.**

File to change: [04_one_layer_per_row_test.sql](../workflow/03_flatCASFRI/04_one_layer_per_row_test.sql).

- Replace the old national-count guidance with an actual comparison between the view's row count and `sum(num_of_layers)` from the current `casfri50.cas_all`.
- Remove the unrestricted `SELECT *, max(layer) OVER (...)` from normal execution, or clearly separate it as an optional diagnostic. Keep focused counts and listings of failures.
- Retain duplicate `(cas_id, layer)` checks and verify each stand's row count and maximum layer against its CAS layer count. Confirm an intentionally duplicated or missing layer is detected without printing every valid row.

#### Problem 19

**Prevent tests from leaving production functions replaced.**

Files: [geohistory_test.sql](../helperfunctions/geohistory/geohistory_test.sql), which replaces `TT_RowIsValid()` and `TT_HasPrecedence()`, plus [geohistory_test_with_inv_data.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data.sql) and [geohistory_test_with_inv_data_gridded.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data_gridded.sql), which also redefine precedence.

- Isolate the test definitions. Where the suite is transaction-safe, run its temporary definition changes in a transaction and roll them back after collecting results; otherwise capture and restore only the original function definitions.
- Preserve failure reporting and any explicitly required diagnostic outputs. Do not rely on the operator remembering a restoration step after a failed test.
- Do not restore functions by rerunning [01_PrepareGeoHistory.sql](../workflow/04_produceHistoricalTable/01_PrepareGeoHistory.sql): that file also resets production history/grid tables. Verify function definitions before and after the tests are identical and existing history rows are unchanged.

#### Problem 20

**Add applicable AB regression cases and protect archived outputs.**

Files: [geohistory_test_with_inv_data.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data.sql), [geohistory_test_with_inv_data_gridded.sql](../helperfunctions/geohistory/geohistory_test_with_inv_data_gridded.sql), [load_test_tables_with_inv_data.sh](../helperfunctions/geohistory/load_test_tables_with_inv_data.sh), [dump_test_tables_with_inv_data.sh](../helperfunctions/geohistory/dump_test_tables_with_inv_data.sh), and the associated accepted CSVs in [testtables](../helperfunctions/geohistory/testtables).

- Add small AB sampling cases covering photograph-year changes and cross-inventory precedence, with both gridded and ungridded comparisons. Create reviewed expected results, then teach the loader about those fixtures.
- Check case prerequisites before execution. Mark cases requiring unloaded inventories as not exercised rather than accepting empty comparisons or importing extra inventories.
- Replace `rm ./testtables/sampling*.csv` with guarded, case-specific export handling. Validate the selected output tables and stage every export before replacing any accepted file; unloaded cases and failed exports must leave their archives untouched.
- Verify an AB-only run exercises the new cases without changing NB/NT/BC/SK references. Accept new fixtures only after their geometries, intervals and precedence behavior have been reviewed.

#### Problem 21

**Initialize shared coverage objects before parallel workers.**

File to change: [03_ProduceInventoryCoverages.sh](../workflow/04_produceHistoricalTable/03_ProduceInventoryCoverages.sh). Use the existing definitions in `TT_ProduceDerivedCoverages()` in [geohistory.sql](../helperfunctions/geohistory/geohistory.sql).

- Add a serial, fail-fast initialization before the loop that launches inventory jobs. Create the four ungridded tables, their four gridded counterparts and the four gridded GiST indexes once.
- Match the procedure's columns (`inv`, `nb_polys`, `nb_points`, `geom`) and the ungridded primary keys. Use idempotent creation; never drop existing coverage rows merely to avoid a creation race.
- Keep any standalone-procedure initialization compatible, but do not depend on concurrent `CREATE TABLE IF NOT EXISTS` calls to serialize first-time creation. Do not rerun history preparation to initialize coverage objects.
- Test four parallel inventories against a fresh coverage schema, then rerun against populated tables. All eight tables must contain the selected inventories without catalog-creation errors or duplicate gridded rows.

## Validation results

1. **Framework and CASFRI helpers:** all three framework suites passed; the complete CASFRI helper suite passed when unchanged CRLF input was normalized to LF during execution.
2. **Raw and translated counts:** all four raw counts and all 24 inventory/table translated counts exactly match metadata. Expected counts were not edited.
3. **Translation samples:** all 20 inventory/table comparisons have identical row keys and counts. All non-CAS outputs and all non-metric CAS attributes match accepted results exactly. The 28 layer/inventory sample-size groups are sufficient, have no unsampled required groups, and are below the script's 20% excess threshold (maximum 14%).
4. **Translation errors:** full scans of CAS, DST, ECO, LYR and NFL found zero rows containing `TRANSLATION_ERROR` or `-3333`.
5. **Constraints and structure:** all 174 attribute checks and six GEO checks passed. Additional checks 1.1-1.4 passed. Row-level replacements for 1.5-1.6 found no data violations.
6. **Geometry:** all 130,859 normalized geometries are non-null, non-empty, valid and in SRID 102001. All 131,790 history geometries also meet those conditions; intervals are non-null and correctly ordered. No history orphans or duplicate stand/interval keys were found.
7. **Flat tables:** same-row count equals CAS; one-layer row count equals the sum of layer counts; zero duplicate layers and zero per-stand layer-count/maximum mismatches.
8. **Geohistory:** complete spatial/temporal self-join found no simultaneous intersection larger than one square centimetre. Tiny numerical intersections are quantified above. All 102 suppressed stand identifiers are explained by same-year AB08 precedence. Independent full source/history unions are valid SRID-102001 geometries, differing by 0.353464 m2 overall; exact equality is not claimed. The three synthetic assertion mismatches are explained, not silently counted as passes.
9. **Coverages:** all four inventories occur in all eight tables, with valid, non-empty SRID-102001 geometry, correct source stand counts, and stored point counts matching actual geometry. The four gridded tables contain respectively **235, 235, 234 and 229** rows. All 16 inventory/type grid reconstructions were compared with their ungridded output.
10. **Source protection:** final integrity verification at **15:40:51** compared all **206 files**, including hidden files: zero path/size/timestamp differences and zero SHA256 differences. All five accepted translation reference CSVs also match the pre-build backups.
11. **Final scope/statistics:** after `ANALYZE`, the raw schema contains exactly `ab03` (61,633 rows), `ab06` (11,484), `ab07` (23,268), `ab08` (34,474), and the shared `ab_photoyear` table (560). No normalized constraints remain unvalidated.

### Coverage vertex counts

| Inventory | Detailed | No holes/islands | Simplified | Smoothed |
| --- | ---: | ---: | ---: | ---: |
| AB03 | 10,715 | 10,675 | 404 | 1,059 |
| AB06 | 1,517 | 1,517 | 36 | 203 |
| AB07 | 4,567 | 4,567 | 182 | 415 |
| AB08 | 5,397 | 5,397 | 264 | 1,008 |

The existing "detailed" coverage algorithm itself buffers/unbuffers intermediate unions and removes small holes/islands. It is not being treated as an exact raw-polygon union for the separate source/history footprint audit.

## Step timings

Times below are local (UTC-05:00); durations are wall-clock seconds for each invocation, including retries. Some steps ran concurrently, so durations must not be added to infer total elapsed time. Reading, diagnosis, comparison preparation and report writing also take time between invocations. The failed extension-install duration was reconstructed from its recorded start and log modification time.

| Step | Start | Seconds | Result |
| --- | --- | ---: | --- |
| Read all Markdown, inspect configuration/scripts, preflight and source snapshot | Approximately 15:14:18 | Not separately timed | Target absent; four sources available |
| Initial SHA256 snapshot of 206 source files | Before conversion | 11.61 | Baseline recorded |
| 01 Create fresh database | 15:18:58 | 1.29 | Created from template0, UTF8 |
| 02 Framework filesystem installation attempt | 15:19:15 | 0.55 | Permission denied; used documented alternative |
| 03 Enable PostGIS | 15:20:20 | 1.20 | Passed |
| 04 Load framework SQL directly | 15:20:21 | 0.77 | Passed |
| 05 Run three framework suites | 15:20:22 | 1.64 | Zero failures |
| 06 Load CASFRI helper functions | 15:20:23 | 0.79 | Passed |
| 07 Initial helper tests | 15:20:24 | 3.98 | 23 CRLF-sensitive failures |
| 08 Load translation/lookup definitions and metadata | 15:21:20 | 23.83 | Passed |
| 09 Repeat helpers after metadata load | 15:21:44 | 4.12 | Same 23 formatting failures |
| 10 Diagnose multiline filter-view comparison | 15:23:02 | 0.72 | Identified line-ending mismatch |
| 11 Complete helper suite with LF input | 15:23:02 | 4.02 | Zero failures |
| 12 Load shared Alberta photograph years | 15:24:03 | 3.84 | Passed |
| 13 Convert AB03/AB06/AB07/AB08 | 15:24:07 | 18.30 | All four raw counts match |
| 14 Generate province-wide available-inventory samples | 15:24:57 | 8.66 | Generated selected-inventory results |
| Compare samples and preserve/restore accepted CSVs | Between 15:25:05 and 15:25:59 | Not separately timed | Keys/counts match; only tiny CAS metric differences |
| 15 Validate samples and translation-error codes | 15:25:59 | 0.81 | Passed |
| 16 Initialize normalized CASFRI tables | 15:26:27 | 1.27 | Passed |
| 17 Restrict HDR to four requested inventories | 15:26:28 | 0.78 | Exactly four HDR rows |
| 18 Full parallel translation | 15:26:29 | 270.10 | All 24 count checks pass |
| 19 Load geohistory functions | 15:29:33 | 0.83 | Passed |
| 20 Load synthetic history fixtures | 15:29:34 | 8.47 | Passed |
| 21 Run LF-normalized synthetic history suite | 15:29:43 | 44.26 | Three stale assertions investigated |
| 22 Investigate geometry/error/interval assertions | 15:31:06 | 0.76 | Two semantic checks pass; isolated 1900/1930 mismatch |
| 23 Apply attribute constraints | 15:31:28 | 8.09 | All 174 checks pass |
| 24 Apply geometry constraints | 15:31:36 | 6.06 | All six checks pass |
| 25 Add standard indexes | 15:31:42 | 5.21 | Passed |
| 26 Additional consistency checks | 15:31:47 | 4.60 | Four pass; two subset-sensitive assertions investigated |
| 27 Build same-row flat view and test count | 15:32:03 | 23.88 | 130,859 rows; zero difference |
| 28 Build one-layer flat view | 15:32:27 | 40.69 | 200,019 rows |
| 29 Prepare production history and grid | 15:33:48 | 64.90 | Production functions restored; 275,115 grid pieces |
| 30 Generate history, union intervals and build indexes | 15:35:08 | 240.35 | 131,790 history rows |
| 31 Serial coverage table/index bootstrap | 15:37:47 | 0.80 | Prevented first-run DDL race |
| 32 Produce all coverage variants | 15:37:47 | 40.56 | Four inventories, eight tables |
| 33 Recheck synthetic semantics against current bounds | 15:37:51 | 0.77 | All three supplementary checks pass |
| 34 Validate full translation, flat tables and sample sufficiency | 15:37:52 | 12.14 | No data violations; all 28 sample groups sufficient |
| 35a Initial final-source audit | 15:39:01 | 5.94 | Retry needed: hidden files omitted from enumeration |
| 35b Corrected final-source audit including hidden files | 15:40:44 | 7.19 | All 206 files unchanged |
| 36 Full history/coverage geometry and overlap validation | 15:40:42 | 42.32 | Valid output; only quantified microscopic differences |
| 37 Investigate 102 suppressed AB03 history identifiers | 15:41:59 | 1.65 | Footprints covered to sub-square-centimetre tolerance |
| 38 Exact source/history footprint and final statistics audit | 15:43:31 | 202.49 | Footprint discrepancy quantified; ANALYZE complete; zero unvalidated constraints |
| 39 Trace cross-inventory suppression | 15:48:10 | 4.72 | All 102 AB03 cases explained by same-year AB08 precedence |
| Report compilation and final repository/evidence checks | Overlapped final verification, then finalized afterward | Not separately timed | This report and preserved evidence |

Measured invocations total **1,113.35 seconds** (18 minutes 33.35 seconds), plus the separately recorded **11.61-second** initial hashing run. This sum includes failed attempts but excludes uninstrumented reading, investigation, sample-comparison preparation and writing. It is not the overall elapsed duration because several invocations overlap.

## Execution and preservation notes

- Used the supplied shell loaders and batches for photograph years, conversion, sample translation, normalized-table initialization, full translation, both flat views, history preparation/production, synthetic fixture loading, and coverage production.
- Ran supplied SQL directly where no shell wrapper exists. Used small session-local SQL checks for inventory scoping and independent validation, not alternative translation implementations.
- Existing configuration credentials, database name, paths, projection, translation rules and parallelism were reused. The only configuration edit was `fullList=(AB03 AB06 AB07 AB08)`.
- Other databases were not touched. PostgreSQL installation permissions and global server settings were not changed.
- The three pre-existing source edits remain untouched. No new implementation changes were made to compensate for the stale assertions. Updating those tests to compare allowed row patterns, current explicit bounds, error semantics and topological geometry is recommended separately.
- No accepted regression CSVs, source inventories, README, metadata expected counts or translation rules were changed. No commits, pushes or releases were performed.
- No new GitHub issues were created. Every applied data constraint passed; pre-existing test-assertion incompatibilities and the archived cross-province regression limitation are preserved explicitly in this report rather than being presented as successful tests.
- Detailed redacted logs, timing CSV, original/generated test comparisons, SQL verification scripts and source manifests/hashes are retained in a local evidence directory outside the repository.
