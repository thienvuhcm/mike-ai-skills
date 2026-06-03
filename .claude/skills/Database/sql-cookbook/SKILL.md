---
name: sql-cookbook
description: Use when you need to write, review, or refactor SQL queries guided by the recipes of SQL Cookbook (2nd Edition) by Anthony Molinaro & Robert de Graaf — covering retrieving and sorting records, working with multiple tables (joins, set operations, anti-joins), inserting/updating/deleting, metadata queries, string manipulation, numeric and statistical computations (running totals, mode, median, percentages, MAD, Benford's law), date arithmetic and manipulation, working with ranges of consecutive values, advanced searching (pagination, top-n, ranking), reporting and reshaping (pivot/unpivot, histograms, subtotals with GROUP BY ROLLUP/CUBE/GROUPING SETS), hierarchical queries (recursive CTEs, CONNECT BY), window functions, and common table expressions across DB2, Oracle, PostgreSQL, SQL Server, and MySQL. This should trigger for requests such as How do I pivot this result set; Find gaps/islands in consecutive values; Compute a running total / median / mode; Sort NULLs last; Write a recursive query for a parent-child hierarchy; Paginate results; Find rows in one table not in another; De-duplicate rows. Distilled from SQL Cookbook, 2nd Edition.
license: Apache-2.0
metadata:
  author: Anthony Molinaro & Robert de Graaf (source); skill synthesized from SQL Cookbook, 2nd Edition (O'Reilly, 2020)
  version: 1.0.0
---
# SQL Cookbook (2nd Edition)

Write, review, and refactor SQL by applying the recipes of *SQL Cookbook, Second Edition* by Anthony Molinaro & Robert de Graaf — the classic "second book on SQL." Each recipe states a **Problem**, gives a portable **Solution** (with vendor-specific variants where they differ), and explains the **technique** so you can adapt it.

**What is covered in this Skill?**

- **Retrieving records** (Ch. 1): `SELECT *` vs explicit columns, `WHERE` with `AND`/`OR`/parentheses, aliasing and referencing aliases via inline views, concatenation (`||` / `CONCAT` / `+`), `CASE` conditional logic, limiting rows (`FETCH FIRST` / `LIMIT` / `ROWNUM` / `TOP`), random rows, `IS NULL`, `COALESCE`, `LIKE` patterns
- **Sorting query results** (Ch. 2): `ORDER BY` (asc/desc, by position), multi-field sorts, sorting by substrings, mixed alphanumeric sorts (`TRANSLATE`/`REPLACE`), NULL ordering (`NULLS FIRST/LAST`, `is_null` flag), data-dependent `CASE` sort keys
- **Working with multiple tables** (Ch. 3): `UNION ALL` vs `UNION`, joins, `INTERSECT`/`EXCEPT`/`MINUS`, anti-joins (`NOT IN` null-trap, `NOT EXISTS`, outer-join `IS NULL`), full outer joins, aggregates with joins, scalar subqueries, Cartesian products, NULLs in comparisons
- **Inserting, updating, deleting** (Ch. 4): single/default/multi-table inserts, `CREATE TABLE AS`, `UPDATE` from another table, `MERGE`, deleting duplicates, referential-integrity-aware deletes
- **Metadata queries** (Ch. 5): querying the data dictionary / `INFORMATION_SCHEMA` for tables, columns, indexes, constraints, FK-without-index; SQL that generates SQL
- **Working with strings** (Ch. 6): walking a string with a pivot table, counting/removing characters, separating numeric & character data, alphanumeric tests, initials, ordering by parts/numbers in a string, delimited lists (`LISTAGG`/`STRING_AGG`/`GROUP_CONCAT`), IN-list parsing, soundex, regex (`NOT MATCHING`)
- **Working with numbers** (Ch. 7): averages, min/max, sum, counts (and null handling), running totals & products, smoothing (moving average), mode, median, percent of total, trimmed mean, MAD outliers, Benford's law
- **Date arithmetic** (Ch. 8): add/subtract days/months/years, day/month/year/second differences, business-day counts, counting weekdays, difference to next record
- **Date manipulation** (Ch. 9): leap-year test, days in year/month, extracting units, first/last day of month, all weekdays in a year, nth weekday in a month, building a calendar, quarter boundaries, filling missing dates, searching/comparing by date parts, overlapping date ranges
- **Working with ranges** (Ch. 10): consecutive-value ranges (gaps & islands), differences between rows in a group, range start/end, filling missing values, generating consecutive numbers (recursive CTE)
- **Advanced searching** (Ch. 11): pagination, skipping rows, OR in outer joins, reciprocals, top-n, highest/lowest, `LEAD`/`LAG`, ranking (`RANK`/`DENSE_RANK`/`ROW_NUMBER`), suppressing duplicates, "knight values," simple forecasts
- **Reporting and reshaping** (Ch. 12): pivot to one/many rows, reverse pivot (unpivot), suppressing repeats, buckets, histograms (horizontal/vertical), non-GROUP-BY columns, subtotals (`ROLLUP`/`CUBE`/`GROUPING SETS`/`GROUPING`), sparse matrices, grouping by time units, moving-range aggregations
- **Hierarchical queries** (Ch. 13): parent-child / child-parent-grandparent, hierarchical views, all descendants, leaf/branch/root nodes — via recursive CTEs and Oracle `CONNECT BY` (`SYS_CONNECT_BY_PATH`, `CONNECT_BY_ISLEAF`, `CONNECT_BY_ROOT`)
- **Odds 'n' ends** (Ch. 14): SQL Server `PIVOT`/`UNPIVOT`, Oracle `MODEL`, parsing strings from unfixed locations, mixed alphanumeric search, decimal-to-binary, double pivots, scalar-to-composite subqueries, parsing serialized data, percent relative to total, existence within a group
- **Window functions** (Appendix A): the `OVER` clause, `PARTITION BY`, the framing/windowing clause (`ROWS`/`RANGE BETWEEN ... PRECEDING/FOLLOWING`), aggregate vs ranking vs `LEAD`/`LAG`/`FIRST_VALUE`/`LAST_VALUE`
- **Common table expressions** (Appendix B): `WITH` for readable/modular queries and **recursive** CTEs for hierarchies, ranges, and number/date generation

## Scope and platform notes

- Solutions target **DB2 11.5, Oracle 19c, PostgreSQL 12, SQL Server 2017, MySQL 8.0**. Window functions and CTEs (including recursive CTEs) are assumed available in all five.
- The canonical example tables are **EMP** (14 rows: `empno, ename, job, mgr, hiredate, sal, comm, deptno`) and **DEPT** (4 rows: `deptno, dname, loc`), plus pivot tables **T1, T10, T100, T500** (an `id` column numbered 1..n). Use these when illustrating a recipe.
- This is a **query/technique** book: it does not cover schema design theory, transactions, XML/JSON types, or performance tuning except where a recipe demands it.

## Constraints

SQL dialects differ. Before recommending or running a query, confirm the target RDBMS and validate against it; many recipes have vendor-specific syntax (date functions, `ROWNUM` vs `LIMIT` vs `TOP`, `TRANSLATE`, `LISTAGG` vs `STRING_AGG` vs `GROUP_CONCAT`, `CONNECT BY` vs recursive CTE).

- **IDENTIFY THE RDBMS FIRST**: Ask for or infer the database (DB2 / Oracle / PostgreSQL / SQL Server / MySQL) before giving a final query; prefer the standard/portable form, then note vendor variants.
- **PREFER PORTABLE SQL**: Favor ANSI features available across all five engines (window functions, CTEs, `CASE`, `COALESCE`, standard joins) over proprietary syntax unless the user's engine requires it or a proprietary feature is clearly superior.
- **NULL SAFETY**: Treat `NULL` carefully — `NULL` is never `=`/`!=` anything (use `IS [NOT] NULL`); guard against the `NOT IN (subquery-with-NULLs)` trap (prefer `NOT EXISTS`); use `COALESCE` when aggregating or comparing nullable columns.
- **VERIFY DESTRUCTIVE STATEMENTS**: For `INSERT`/`UPDATE`/`DELETE`/`MERGE`, confirm the `WHERE` clause and target rows with the user before executing; show the equivalent `SELECT` first. Never run data-modifying or DDL statements against a database the user has not authorized.
- **CORRECTNESS OVER CLEVERNESS**: Validate results against the EMP/DEPT expected output (or the user's data) — many recipes have subtle edge cases (e.g., `ROWNUM = 5` never returns a row; aggregates dropping NULLs; outer-join filters belonging in the `ON` clause).
- **BEFORE APPLYING**: Read the reference for the full recipe — Problem, Solution variants per vendor, and the Discussion that explains why it works.

## When to use this skill

- "How do I pivot / unpivot / reshape this result set?"
- "Find gaps or islands (ranges of consecutive values) in this data."
- "Compute a running total / running product / moving average / median / mode / percent of total."
- "Sort NULLs first or last," or "sort mixed alphanumeric data."
- "Return rows in table A that are not in table B" (anti-join done safely).
- "Write a recursive query for this parent-child hierarchy" / "find all descendants" / "label leaf/branch/root nodes."
- "Paginate," "return the top-n," "rank with ties," or "look at the next/previous row."
- "Generate a calendar / fill in missing dates / count business days / find overlapping date ranges."
- "Build a delimited list from rows" or "split a delimited string into rows."
- "Calculate subtotals across multiple grouping combinations" (`ROLLUP`/`CUBE`/`GROUPING SETS`).
- "De-duplicate rows" / "merge (upsert) records."

## Workflow

1. **Identify the engine and the goal.** Confirm which of the five databases is in play and restate the problem in EMP/DEPT terms if helpful.

2. **Match the problem to a recipe.** Read `references/sql-cookbook.md` and locate the recipe (by chapter and number) whose Problem matches. Many real tasks combine 2–3 recipes (e.g., gaps-and-islands + window functions + a CTE).

3. **Choose the portable solution, then specialize.** Start from the standard/ANSI solution; switch to the vendor variant only when required by the engine. Cite the recipe number and title.

4. **Adapt to the user's schema and verify.** Replace EMP/DEPT with the real tables/columns, handle NULLs, and check the result against expected output. For destructive statements, show a `SELECT` preview and confirm before running.

5. **Explain the technique briefly.** Note the key idea (window frame, recursive CTE termination, the `NOT IN` null trap, the inline-view-for-alias rule) so the user can adapt it next time.

## Reference

For all recipes with Problem / Solution (per-vendor) / technique and the Window-Function and CTE appendices, see [references/sql-cookbook.md](references/sql-cookbook.md).
