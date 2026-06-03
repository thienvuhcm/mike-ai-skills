# SQL Cookbook (2nd Edition) — Recipe Reference

Distilled from *SQL Cookbook, Second Edition* by Anthony Molinaro & Robert de Graaf (O'Reilly, 2020). Each recipe is given as **Problem → Solution(s) → Technique**. Solutions are shown in portable SQL where possible; vendor-specific variants are labeled **DB2 / Oracle / PostgreSQL / SQL Server / MySQL**. Target versions: DB2 11.5, Oracle 19c, PostgreSQL 12, SQL Server 2017, MySQL 8.0.

## Example data (EMP and DEPT)

Almost every recipe runs against two tables.

**EMP** (14 rows): `EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO`

```
EMPNO ENAME  JOB       MGR  HIREDATE     SAL  COMM  DEPTNO
7369  SMITH  CLERK     7902 17-DEC-2005  800        20
7499  ALLEN  SALESMAN  7698 20-FEB-2006 1600   300  30
7521  WARD   SALESMAN  7698 22-FEB-2006 1250   500  30
7566  JONES  MANAGER   7839 02-APR-2006 2975        20
7654  MARTIN SALESMAN  7698 28-SEP-2006 1250  1400  30
7698  BLAKE  MANAGER   7839 01-MAY-2006 2850        30
7782  CLARK  MANAGER   7839 09-JUN-2006 2450        10
7788  SCOTT  ANALYST   7566 09-DEC-2007 3000        20
7839  KING   PRESIDENT      17-NOV-2006 5000        10
7844  TURNER SALESMAN  7698 08-SEP-2006 1500     0  30
7876  ADAMS  CLERK     7788 12-JAN-2008 1100        20
7900  JAMES  CLERK     7698 03-DEC-2006  950        30
7902  FORD   ANALYST   7566 03-DEC-2006 3000        20
7934  MILLER CLERK     7782 23-JAN-2007 1300        10
```

**DEPT** (4 rows): `DEPTNO, DNAME, LOC`

```
10 ACCOUNTING NEW YORK
20 RESEARCH   DALLAS
30 SALES      CHICAGO
40 OPERATIONS BOSTON
```

**Pivot tables** `T1, T10, T100, T500`: each has a single `ID` column numbered 1..n (1, 10, 100, 500 rows). They exist purely to drive pivots / generate rows. (Modern equivalents: a recursive CTE, `generate_series` in PostgreSQL, or `LEVEL`/`CONNECT BY` in Oracle.)

---

# Chapter 1 — Retrieving Records

Fundamentals of `SELECT`; everything else builds on these.

## 1.1 Retrieving all rows and columns
**Problem:** See all data in a table.
**Solution:** `SELECT * FROM emp`.
**Technique:** `*` returns every column; no `WHERE` returns every row. Use `*` for ad hoc queries, but **list columns explicitly in program code** — performance is identical, but explicit columns are self-documenting and resilient to schema changes (a dropped/added column won't silently change results or break code).

## 1.2 Retrieving a subset of rows
**Problem:** Keep only rows matching a condition.
**Solution:** `SELECT * FROM emp WHERE deptno = 10`.
**Technique:** The `WHERE` clause keeps a row when its predicate is true. Common operators: `=, <, >, <=, >=, !=, <>`.

## 1.3 Finding rows that satisfy multiple conditions
**Problem:** Combine several conditions.
**Solution:**
```sql
SELECT * FROM emp
 WHERE deptno = 10
    OR comm IS NOT NULL
    OR (sal <= 2000 AND deptno = 20)
```
**Technique:** Combine with `AND`, `OR`, and **parentheses**. `AND` binds tighter than `OR`; use parentheses to make intent explicit and control evaluation (`(a OR b OR c) AND d` differs sharply from `a OR b OR (c AND d)`).

## 1.4 Retrieving a subset of columns
**Problem:** Return only specific columns.
**Solution:** `SELECT ename, deptno, sal FROM emp`.
**Technique:** Naming columns avoids transferring unneeded data across the network.

## 1.5 Providing meaningful names for columns (aliasing)
**Problem:** Make column headers readable.
**Solution:** `SELECT sal AS salary, comm AS commission FROM emp`.
**Technique:** `original AS alias`. `AS` is optional in most engines but always accepted. Aliases make results understandable to others.

## 1.6 Referencing an aliased column in WHERE
**Problem:** `WHERE salary < 5000` fails because the alias isn't visible yet.
**Solution:** Wrap the query as an inline view, then filter the outer query:
```sql
SELECT *
  FROM (SELECT sal AS salary, comm AS commission FROM emp) x
 WHERE salary < 5000
```
**Technique:** `WHERE` is evaluated **before** `SELECT`, so `SELECT`-list aliases don't exist during `WHERE` processing. `FROM` is evaluated first, so the inline view's aliases are available to the outer `WHERE`. Same trick is required to reference **aggregate functions, scalar subqueries, and window functions** in a `WHERE`. Some engines require the inline view to be aliased (`)x`); all accept it.

## 1.7 Concatenating column values
**Problem:** Combine columns into one string (e.g., `CLARK WORKS AS A MANAGER`).
**Solution:**
- **DB2 / Oracle / PostgreSQL:** `SELECT ename || ' WORKS AS A ' || job AS msg FROM emp`
- **MySQL:** `SELECT CONCAT(ename, ' WORKS AS A ', job) AS msg FROM emp`
- **SQL Server:** `SELECT ename + ' WORKS AS A ' + job AS msg FROM emp`
**Technique:** `||` is the ANSI concatenation operator (and a shortcut for `CONCAT`); SQL Server uses `+`; MySQL uses the `CONCAT` function.

## 1.8 Conditional logic in a SELECT (CASE)
**Problem:** IF-ELSE inside the SELECT list.
**Solution:**
```sql
SELECT ename, sal,
       CASE WHEN sal <= 2000 THEN 'UNDERPAID'
            WHEN sal >= 4000 THEN 'OVERPAID'
            ELSE 'OK'
       END AS status
  FROM emp
```
**Technique:** `CASE` evaluates conditions top-to-bottom and returns the first match. `ELSE` is optional; omit it and unmatched rows return `NULL`. Alias the expression for a readable header.

## 1.9 Limiting the number of rows returned
**Problem:** Return any *n* rows.
**Solution:**
- **DB2:** `SELECT * FROM emp FETCH FIRST 5 ROWS ONLY`
- **MySQL / PostgreSQL:** `SELECT * FROM emp LIMIT 5`
- **Oracle:** `SELECT * FROM emp WHERE rownum <= 5`
- **SQL Server:** `SELECT TOP 5 * FROM emp`
**Technique:** Oracle's `ROWNUM` is assigned **as each row is fetched**. So `ROWNUM <= 5` works, but **`ROWNUM = 5` never returns a row** (the first kept row must be #1; if you discard rows that aren't #5, the counter never advances). `ROWNUM = 1` is the special case that works. (Oracle 12c+ also supports `FETCH FIRST n ROWS ONLY`.)

## 1.10 Returning n random records
**Problem:** Return *n* different random rows each run.
**Solution:** Put a random function in `ORDER BY`, then limit:
- **DB2:** `... ORDER BY rand() FETCH FIRST 5 ROWS ONLY`
- **MySQL:** `... ORDER BY rand() LIMIT 5`
- **PostgreSQL:** `... ORDER BY random() LIMIT 5`
- **Oracle:** `SELECT * FROM (SELECT ename, job FROM emp ORDER BY dbms_random.value()) WHERE rownum <= 5`
- **SQL Server:** `SELECT TOP 5 ename, job FROM emp ORDER BY newid()`
**Technique:** A **function** in `ORDER BY` sorts on the value computed per row (random) — different from a **numeric constant** in `ORDER BY`, which means "sort by the column in that ordinal position." Limiting happens after the random sort.

## 1.11 Finding NULL values
**Problem:** Find rows where a column is NULL.
**Solution:** `SELECT * FROM emp WHERE comm IS NULL`.
**Technique:** `NULL` is never equal (or unequal) to anything, **not even itself**. You must use `IS NULL` / `IS NOT NULL`; `= NULL` / `!= NULL` never match.

## 1.12 Transforming NULLs into real values
**Problem:** Substitute a value for NULL.
**Solution:** `SELECT COALESCE(comm, 0) FROM emp`.
**Technique:** `COALESCE` returns the first non-NULL argument and works on every engine. `CASE WHEN comm IS NOT NULL THEN comm ELSE 0 END` is equivalent but more verbose.

## 1.13 Searching for patterns (LIKE)
**Problem:** Match a substring/pattern (e.g., names containing "I" or jobs ending in "ER").
**Solution:**
```sql
SELECT ename, job FROM emp
 WHERE deptno IN (10, 20)
   AND (ename LIKE '%I%' OR job LIKE '%ER')
```
**Technique:** `%` matches any sequence of characters; `_` matches a single character. Placement matters: `'%ER'` = ends with ER, `'ER%'` = starts with ER, `'%ER%'` = contains ER.

---

# Chapter 2 — Sorting Query Results

Controlling result-set order with `ORDER BY`.

## 2.1 Returning results in a specified order
**Problem:** Sort by a column.
**Solution:** `SELECT ename, job, sal FROM emp WHERE deptno = 10 ORDER BY sal ASC`.
**Technique:** `ORDER BY` sorts ascending by default (`ASC` optional); use `DESC` for descending. You can sort by **column position**: `ORDER BY 3` sorts by the 3rd item in the SELECT list (handy, but brittle if the SELECT list changes).

## 2.2 Sorting by multiple fields
**Problem:** Sort by DEPTNO ascending, then SAL descending.
**Solution:** `SELECT empno, deptno, sal, ename, job FROM emp ORDER BY deptno, sal DESC`.
**Technique:** Precedence in `ORDER BY` is left-to-right. You may order by a column **not** in the SELECT list (name it explicitly) — **except** when the query uses `GROUP BY` or `DISTINCT`, in which case you can only order by columns present in the SELECT list.

## 2.3 Sorting by substrings
**Problem:** Sort by the last two characters of JOB.
**Solution:**
- **DB2 / MySQL / Oracle / PostgreSQL:** `ORDER BY SUBSTR(job, LENGTH(job) - 1)`
- **SQL Server:** `ORDER BY SUBSTRING(job, LEN(job) - 1, 2)`
**Technique:** Compute the start position as `length - 1`. Note SQL Server's `SUBSTRING` **requires** a length argument (any value ≥ 2 works here); `SUBSTR` takes start-to-end if length is omitted.

## 2.4 Sorting mixed alphanumeric data
**Problem:** A column like `SMITH 20` should be sortable by either the name or the number part.
**Solution (Oracle / SQL Server / PostgreSQL):** strip the unwanted class of characters with `TRANSLATE` + `REPLACE`:
```sql
-- ORDER BY the numeric part
ORDER BY REPLACE(TRANSLATE(data,'0123456789','##########'),'#','')
-- ORDER BY the character part (remove digits)
ORDER BY REPLACE(data,
         REPLACE(TRANSLATE(data,'0123456789','##########'),'#',''),'')
```
**DB2:** same idea, but `TRANSLATE` argument order is reversed: `TRANSLATE(data,'##########','0123456789')`; cast numeric columns to `CHAR` first.
**MySQL:** no `TRANSLATE`, so this technique isn't available.
**Technique:** `TRANSLATE` maps each digit to `#`; `REPLACE` then deletes the `#`s, leaving only the part you want as the sort key.

## 2.5 Dealing with NULLs when sorting
**Problem:** Sort a nullable column (COMM) with NULLs forced first or last, independent of the sort direction of the non-NULL values.
**Solution (portable):** add an `is_null` flag column and sort on it first:
```sql
SELECT ename, sal, comm
  FROM (SELECT ename, sal, comm,
               CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS is_null
          FROM emp) x
 ORDER BY is_null DESC, comm        -- non-NULL asc, NULLs last
-- variants: is_null DESC, comm DESC (NULLs last); is_null, comm (NULLs first); etc.
```
**Oracle:** use the `NULLS FIRST` / `NULLS LAST` extension directly: `ORDER BY comm NULLS LAST`, `ORDER BY comm DESC NULLS FIRST`, etc.
**Technique:** The flag separates the NULL/non-NULL decision from the value sort, so you control NULL placement without disturbing the ordering of real values. (DB2 supports `NULLS FIRST/LAST` only inside a window `OVER(... ORDER BY ...)`, not the final `ORDER BY`.)

## 2.6 Sorting on a data-dependent key
**Problem:** If JOB = 'SALESMAN', sort by COMM; otherwise sort by SAL.
**Solution:** put a `CASE` in the `ORDER BY`:
```sql
SELECT ename, sal, job, comm
  FROM emp
 ORDER BY CASE WHEN job = 'SALESMAN' THEN comm ELSE sal END
```
**Technique:** `ORDER BY` accepts an expression evaluated per row, so conditional/derived sort keys are just a `CASE`.

---

# Chapter 3 — Working with Multiple Tables

Combining rows across tables with set operations and joins. Master the **anti-join NULL trap** and **aggregate-over-join double counting** here.

## 3.1 Stacking one rowset atop another (UNION ALL)
**Problem:** Combine rows from multiple tables into one result, stacked vertically.
**Solution:**
```sql
SELECT ename AS ename_and_dname, deptno FROM emp WHERE deptno = 10
UNION ALL
SELECT '----------', NULL FROM t1
UNION ALL
SELECT dname, deptno FROM dept
```
**Technique:** `UNION ALL` concatenates result sets; every SELECT must have the **same number of columns with compatible data types**. `UNION ALL` keeps duplicates; `UNION` removes them (and usually triggers a sort). Prefer `UNION ALL` unless you actually need duplicate elimination — `UNION` ≈ `DISTINCT` over a `UNION ALL`.

## 3.2 Combining related rows (inner join)
**Problem:** Join tables on a common column.
**Solution (ANSI join, preferred):**
```sql
SELECT e.ename, d.loc
  FROM emp e INNER JOIN dept d ON (e.deptno = d.deptno)
 WHERE e.deptno = 10
```
(Older equi-join style: `FROM emp e, dept d WHERE e.deptno = d.deptno AND e.deptno = 10`.)
**Technique:** Conceptually a join is a Cartesian product filtered by the join condition. The explicit `JOIN ... ON` syntax keeps join logic in `FROM` (clearer, ANSI, works on all five engines); `INNER` is optional.

## 3.3 Finding rows in common between two tables (INTERSECT)
**Problem:** Find rows common to two tables when several columns must match.
**Solution:** Join on **all** the relevant columns, or use `INTERSECT`:
```sql
SELECT empno, ename, job, sal, deptno FROM emp
 WHERE (ename, job, sal) IN (
   SELECT ename, job, sal FROM emp
   INTERSECT
   SELECT ename, job, sal FROM v)
```
(MySQL/SQL Server older versions: join on all columns instead of `INTERSECT`.)
**Technique:** `INTERSECT` returns rows present in both sources (same column count/types) and removes duplicates. Use a join when you also need columns not in the intersected set.

## 3.4 Values in one table not in another (EXCEPT / MINUS / NOT EXISTS)
**Problem:** Find values in a source table absent from a target (e.g., DEPTNOs in DEPT but not in EMP → 40).
**Solution:**
- **DB2 / PostgreSQL / SQL Server:** `SELECT deptno FROM dept EXCEPT SELECT deptno FROM emp`
- **Oracle:** `... MINUS ...`
- **MySQL:** `SELECT deptno FROM dept WHERE deptno NOT IN (SELECT deptno FROM emp)`
**Technique:** `EXCEPT`/`MINUS` subtract the second set from the first, remove duplicates, and are **NULL-safe**. ⚠️ **The `NOT IN` trap:** if the subquery returns any `NULL`, `NOT IN` returns **no rows** — because `x NOT IN (a, b, NULL)` becomes `x<>a AND x<>b AND x<>NULL`, and `... AND NULL` is never TRUE. The NULL-safe alternative is a correlated `NOT EXISTS`:
```sql
SELECT d.deptno FROM dept d
 WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE d.deptno = e.deptno)
```
Remember the SQL truth-table fact: **`TRUE OR NULL` = TRUE, but `FALSE OR NULL` = NULL**.

## 3.5 Rows in one table not corresponding to rows in another (anti-join)
**Problem:** Find rows in one table with no match in another, and return that table's other columns (e.g., departments with no employees → OPERATIONS).
**Solution (outer join + IS NULL):**
```sql
SELECT d.*
  FROM dept d LEFT OUTER JOIN emp e ON (d.deptno = e.deptno)
 WHERE e.deptno IS NULL
```
**Technique:** This is the **anti-join**: outer join keeps unmatched DEPT rows (EMP columns become NULL); the `WHERE e.deptno IS NULL` keeps only the unmatched ones. Unlike 3.4, it can return any columns from the preserved table.

## 3.6 Adding joins without interfering with other joins
**Problem:** Adding a third table drops rows because not every row has a match (e.g., add bonus dates, but not all employees have bonuses).
**Solution:** Outer join the optional table; or use a scalar subquery in the SELECT list:
```sql
-- outer join (DB2/MySQL/PostgreSQL/SQL Server)
SELECT e.ename, d.loc, eb.received
  FROM emp e JOIN dept d ON (e.deptno = d.deptno)
       LEFT JOIN emp_bonus eb ON (e.empno = eb.empno)
 ORDER BY 2;
-- scalar subquery (all engines)
SELECT e.ename, d.loc,
       (SELECT eb.received FROM emp_bonus eb WHERE eb.empno = e.empno) AS received
  FROM emp e, dept d
 WHERE e.deptno = d.deptno;
```
**Technique:** A `LEFT JOIN` adds optional data without removing existing rows. A **scalar subquery** (must return exactly one value/row) tacks on a column without touching already-correct joins. (For multi-value needs, see 14.10.)

## 3.7 Determining whether two tables have the same data
**Problem:** Check if two tables/views hold identical rows *and* cardinality (duplicates matter).
**Solution:** Compare both directions and combine with `UNION ALL`, including a `COUNT(*)` per distinct row so duplicates are detected:
```sql
(SELECT empno,...,deptno, COUNT(*) cnt FROM v   GROUP BY empno,...,deptno
 EXCEPT
 SELECT empno,...,deptno, COUNT(*) cnt FROM emp GROUP BY empno,...,deptno)
UNION ALL
(SELECT empno,...,deptno, COUNT(*) cnt FROM emp GROUP BY empno,...,deptno
 EXCEPT
 SELECT empno,...,deptno, COUNT(*) cnt FROM v   GROUP BY empno,...,deptno)
```
(Oracle: `MINUS`. MySQL/SQL Server without EXCEPT: correlated `NOT EXISTS` on inline views that include `cnt`, using `COALESCE` on nullable columns in the join.)
**Technique:** If the tables are equal, **no rows** are returned. Grouping with `COUNT(*)` makes the comparison sensitive to duplicate counts, not just distinct values. Quick pre-check: `SELECT COUNT(*) FROM a UNION SELECT COUNT(*) FROM b` returns one row only if cardinalities match.

## 3.8 Identifying and avoiding Cartesian products
**Problem:** Missing join condition multiplies rows (3 EMP × 4 DEPT = 12 wrong rows).
**Solution:** Always join the tables: add `AND d.deptno = e.deptno`.
**Technique:** A missing join yields a cross product whose size is the product of cardinalities. Rule of thumb: with *n* tables in `FROM`, you need at least *n − 1* join conditions. (Intentional Cartesian products are useful for pivoting, generating sequences, and mimicking loops — often via a pivot table or recursive CTE.)

## 3.9 Performing joins when using aggregates
**Problem:** A join creates duplicate rows that inflate `SUM`/`AVG` (e.g., MILLER's salary counted twice because he has two bonuses).
**Solution:** Either `SUM(DISTINCT sal)` for the duplicated column, or aggregate **before** joining:
```sql
-- DISTINCT on the duplicated measure
SELECT deptno, SUM(DISTINCT sal) AS total_sal, SUM(bonus) AS total_bonus
  FROM (...) x GROUP BY deptno;
-- or window functions (DB2/Oracle/SQL Server)
SELECT DISTINCT deptno,
       SUM(DISTINCT sal) OVER (PARTITION BY deptno) AS total_sal,
       SUM(bonus)        OVER (PARTITION BY deptno) AS total_bonus
  FROM (...) x;
-- or pre-aggregate in an inline view, then join (all engines)
```
**Technique:** Joins fan out rows; an aggregate over the fanned-out set double-counts. `SUM(DISTINCT sal)` works only when the duplicated values are genuinely identical; the robust general fix is to compute the aggregate in an inline view before joining.

## 3.10 Performing outer joins when using aggregates
**Problem:** Like 3.9, but not every employee has a bonus — an inner join drops employees and breaks `SUM(sal)`.
**Solution:** `LEFT OUTER JOIN` to keep all employees, and make the bonus `CASE` handle the NULL type:
```sql
SELECT deptno, SUM(DISTINCT sal) AS total_sal, SUM(bonus) AS total_bonus
  FROM (SELECT e.empno, e.sal, e.deptno,
               e.sal * CASE WHEN eb.type IS NULL THEN 0
                            WHEN eb.type = 1 THEN .1
                            WHEN eb.type = 2 THEN .2
                            ELSE .3 END AS bonus
          FROM emp e LEFT OUTER JOIN emp_bonus eb ON (e.empno = eb.empno)
         WHERE e.deptno = 10) x
 GROUP BY deptno
```
**Technique:** Outer join preserves all driver rows; add a `WHEN ... IS NULL THEN 0` branch so missing matches contribute 0 to the sum.

## 3.11 Returning missing data from multiple tables (FULL OUTER JOIN)
**Problem:** You need unmatched rows from **both** sides (a department with no employees *and* an employee with no department).
**Solution:**
```sql
SELECT d.deptno, d.dname, e.ename
  FROM dept d FULL OUTER JOIN emp e ON (d.deptno = e.deptno)
```
- **MySQL (no FULL JOIN):** `UNION` of a `RIGHT OUTER JOIN` and a `LEFT OUTER JOIN`.
- **Oracle (legacy):** two `(+)` outer joins combined with `UNION`.
**Technique:** A full outer join = left outer join ∪ right outer join; it returns matched rows plus unmatched rows from each side.

## 3.12 Using NULLs in operations and comparisons
**Problem:** Compare a nullable column as if NULLs were real values (e.g., employees whose COMM < WARD's, including NULL commissions).
**Solution:**
```sql
SELECT ename, comm FROM emp
 WHERE COALESCE(comm, 0) < (SELECT comm FROM emp WHERE ename = 'WARD')
```
**Technique:** `COALESCE(comm, 0)` turns NULL into a comparable value so it participates in the predicate instead of evaluating to NULL (and being excluded).

---

# Chapter 4 — Inserting, Updating, and Deleting

DML recipes. ⚠️ Always preview the affected rows with a `SELECT` before running `UPDATE`/`DELETE`/`MERGE`; know what `TRUNCATE` cannot undo.

## 4.1 Inserting a new record
**Problem:** Insert one row.
**Solution:** `INSERT INTO dept (deptno, dname, loc) VALUES (50, 'PROGRAMMING', 'BALTIMORE')`.
Multi-row (DB2/SQL Server/PostgreSQL/MySQL): `INSERT INTO dept (deptno,dname,loc) VALUES (1,'A','B'), (2,'B','C')`.
**Technique:** Single-row `INSERT` syntax is identical across engines. You may omit the column list, but then you must supply **all** columns in `SELECT *` order — fragile and prone to NOT NULL constraint errors. Always list columns in code.

## 4.2 Inserting default values
**Problem:** Insert a row using a column's defined default.
**Solution:** `INSERT INTO d VALUES (DEFAULT)` or `INSERT INTO d (id) VALUES (DEFAULT)`. All-defaults shortcuts: MySQL `INSERT INTO d VALUES ()`; PostgreSQL/SQL Server `INSERT INTO d DEFAULT VALUES`.
**Technique:** The `DEFAULT` keyword (all engines) inserts the column's table-defined default. For a mix of columns, simply **omit** a column from the insert list to get its default — no `DEFAULT` keyword needed.

## 4.3 Overriding a default value with NULL
**Problem:** Force NULL into a column that has a non-NULL default.
**Solution:** `INSERT INTO d (id, foo) VALUES (NULL, 'Brighten')`.
**Technique:** Explicitly listing `NULL` overrides the default. Omitting the column instead would apply the default (e.g., 0), which is *not* the same as NULL. (Fails if a NOT NULL constraint exists.)

## 4.4 Copying rows from one table into another
**Problem:** Bulk-copy query results into another table.
**Solution:** `INSERT INTO dept_east (deptno,dname,loc) SELECT deptno,dname,loc FROM dept WHERE loc IN ('NEW YORK','BOSTON')`.
**Technique:** `INSERT ... SELECT`. Omit the `WHERE` to copy all rows. Same column-order caveat as 4.1.

## 4.5 Copying a table definition (structure only, no rows)
**Problem:** Create an empty table with the same columns as another.
**Solution:**
- **DB2:** `CREATE TABLE dept_2 LIKE dept`
- **Oracle / MySQL / PostgreSQL:** `CREATE TABLE dept_2 AS SELECT * FROM dept WHERE 1 = 0`
- **SQL Server:** `SELECT * INTO dept_2 FROM dept WHERE 1 = 0`
**Technique:** A `WHERE 1 = 0` predicate in CTAS / `SELECT INTO` copies the column structure but returns no rows. (CTAS does not copy indexes/constraints — only columns.)

## 4.6 Inserting into multiple tables at once
**Problem:** Route rows from one query into several target tables.
**Solution:**
- **Oracle:** `INSERT ALL WHEN loc IN (...) THEN INTO dept_east ... WHEN loc='CHICAGO' THEN INTO dept_mid ... ELSE INTO dept_west ... SELECT ... FROM dept`. `INSERT FIRST` stops at the first matching `WHEN`; `INSERT ALL` evaluates every `WHEN` (so a row can land in multiple tables).
- **DB2:** insert into a `UNION ALL` view whose member tables carry `CHECK` constraints that uniquely route each row.
- **MySQL / PostgreSQL / SQL Server:** no multi-table insert.
**Technique:** Multi-table insert is largely an Oracle feature; DB2 emulates it via constrained `UNION ALL` views.

## 4.7 Blocking inserts to certain columns
**Problem:** Allow inserts into only some columns.
**Solution:** Create a view exposing only the permitted columns (`CREATE VIEW new_emps AS SELECT empno, ename, job FROM emp`) and grant insert on the **view**, not the table.
**Technique:** Inserts into a simple view are rewritten against the base table; columns not in the view get their defaults/NULL. View-update rules get complex fast — consult vendor docs.

## 4.8 Modifying records in a table (UPDATE)
**Problem:** Change values in some/all rows (e.g., +10% salary for dept 20).
**Solution:** `UPDATE emp SET sal = sal * 1.10 WHERE deptno = 20`.
**Technique:** `UPDATE ... SET ... WHERE`. **No `WHERE` updates every row.** Preview with a matching `SELECT` of the new expressions before running.

## 4.9 Updating when corresponding rows exist
**Problem:** Update rows in EMP only if the employee exists in EMP_BONUS.
**Solution:** `UPDATE emp SET sal = sal*1.20 WHERE empno IN (SELECT empno FROM emp_bonus)` — or the `EXISTS` form:
```sql
UPDATE emp SET sal = sal*1.20
 WHERE EXISTS (SELECT NULL FROM emp_bonus WHERE emp.empno = emp_bonus.empno)
```
**Technique:** A subquery in the `WHERE` restricts which rows update. With `EXISTS`, the subquery's SELECT list is irrelevant (`SELECT NULL` emphasizes that the correlation in the `WHERE`, not the projected columns, drives the update).

## 4.10 Updating with values from another table
**Problem:** Set EMP.SAL/COMM from NEW_SAL where DEPTNO matches.
**Solution:**
- **DB2 (portable):** correlated subquery in `SET`, **plus** an `EXISTS` in the outer `WHERE`:
```sql
UPDATE emp e
   SET (e.sal, e.comm) = (SELECT ns.sal, ns.sal/2 FROM new_sal ns WHERE ns.deptno = e.deptno)
 WHERE EXISTS (SELECT * FROM new_sal ns WHERE ns.deptno = e.deptno)
```
- **MySQL:** `UPDATE emp e, new_sal ns SET e.sal = ns.sal, e.comm = ns.sal/2 WHERE e.deptno = ns.deptno`
- **PostgreSQL:** `UPDATE emp SET sal = ns.sal, comm = ns.sal/2 FROM new_sal ns WHERE ns.deptno = emp.deptno`
- **SQL Server:** `UPDATE e SET e.sal = ns.sal, e.comm = ns.sal/2 FROM emp e, new_sal ns WHERE ns.deptno = e.deptno`
- **Oracle:** update a key-preserved inline-view join.
**Technique:** ⚠️ The `WHERE` *inside the SET subquery* is **not** the same as the `WHERE` on the table being updated. Without the outer `WHERE`/`EXISTS`, non-matching rows get **NULL** (the subquery returns nothing). For Oracle's updatable-join-view, the joined-to table must be **key-preserved** (unique on the join column).

## 4.11 Merging records (UPSERT)
**Problem:** Insert if absent, update if present, optionally delete after update.
**Solution:**
```sql
MERGE INTO emp_commission ec
USING (SELECT * FROM emp) emp
   ON (ec.empno = emp.empno)
WHEN MATCHED THEN
   UPDATE SET ec.comm = 1000
   DELETE WHERE (sal < 2000)
WHEN NOT MATCHED THEN
   INSERT (ec.empno, ec.ename, ec.deptno, ec.comm)
   VALUES (emp.empno, emp.ename, emp.deptno, emp.comm)
```
**Technique:** `MERGE` synchronizes a target with a source in one statement (great for flat-file feeds). The `ON` join decides matched vs not-matched. Available in DB2/Oracle/PostgreSQL 15+/SQL Server; **MySQL has no `MERGE`** (use `INSERT ... ON DUPLICATE KEY UPDATE`).

## 4.12 Deleting all records
**Problem:** Empty a table.
**Solution:** `DELETE FROM emp` (or `TRUNCATE TABLE emp`).
**Technique:** `DELETE` with no `WHERE` removes all rows (and is transactional/rollback-able). `TRUNCATE` is faster but, in Oracle and others, **cannot be rolled back** and resets storage — check vendor docs.

## 4.13 Deleting specific records
**Problem:** Delete rows matching a criterion.
**Solution:** `DELETE FROM emp WHERE deptno = 10`.
**Technique:** A `WHERE` scopes the delete. Preview with `SELECT` first — a typo (`deptno = 20`) deletes the wrong rows irreversibly.

## 4.14 Deleting a single record
**Problem:** Delete exactly one row.
**Solution:** `DELETE FROM emp WHERE empno = 7782`.
**Technique:** Identify by primary/unique key so you can be certain only one row matches; otherwise verify the count first.

## 4.15 Deleting referential-integrity violations
**Problem:** Delete EMP rows pointing to non-existent departments.
**Solution:**
```sql
DELETE FROM emp WHERE NOT EXISTS (SELECT * FROM dept WHERE dept.deptno = emp.deptno)
-- or: DELETE FROM emp WHERE deptno NOT IN (SELECT deptno FROM dept)
```
**Technique:** Same anti-join logic as querying — prefer `NOT EXISTS` if the dept list could contain NULLs (the `NOT IN` trap from 3.4 applies to `DELETE` too).

## 4.16 Deleting duplicate records
**Problem:** Keep one row per duplicate group, delete the rest.
**Solution:**
```sql
DELETE FROM dupes
 WHERE id NOT IN (SELECT MIN(id) FROM dupes GROUP BY name)
```
MySQL (can't reference the target table twice) — wrap it: `... WHERE id NOT IN (SELECT min_id FROM (SELECT MIN(id) AS min_id FROM dupes GROUP BY name) tmp)`.
**Technique:** Define "duplicate" (same `name`), pick a discriminator key (`id`), keep `MIN(id)` per group and delete the rest. A window function (`ROW_NUMBER() OVER (PARTITION BY name ORDER BY id)`) is the modern alternative.

## 4.17 Deleting records referenced from another table
**Problem:** Delete EMP rows for departments with ≥ 3 accidents in DEPT_ACCIDENTS.
**Solution:**
```sql
DELETE FROM emp
 WHERE deptno IN (SELECT deptno FROM dept_accidents GROUP BY deptno HAVING COUNT(*) >= 3)
```
**Technique:** `GROUP BY ... HAVING COUNT(*) >= n` finds the qualifying keys; the `DELETE` removes matching rows.

---

# Chapter 5 — Metadata Queries

Discover schema objects by querying the data dictionary. This is the **least standardized** area: Oracle and DB2 use vendor catalogs; PostgreSQL/MySQL/SQL Server expose the ISO `INFORMATION_SCHEMA` (plus engine-specific catalogs). Examples assume schema `SMEAGOL`.

## 5.1 Listing tables in a schema
| Engine | Query |
|---|---|
| DB2 | `SELECT tabname FROM syscat.tables WHERE tabschema = 'SMEAGOL'` |
| Oracle | `SELECT table_name FROM all_tables WHERE owner = 'SMEAGOL'` |
| PostgreSQL / MySQL / SQL Server | `SELECT table_name FROM information_schema.tables WHERE table_schema = 'SMEAGOL'` |
**Technique:** Databases describe themselves through tables/views. `INFORMATION_SCHEMA` is the ISO-standard set shared by PostgreSQL, MySQL, and SQL Server.

## 5.2 Listing a table's columns
| Engine | Query (table EMP) |
|---|---|
| DB2 | `SELECT colname, typename, colno FROM syscat.columns WHERE tabname='EMP' AND tabschema='SMEAGOL'` |
| Oracle | `SELECT column_name, data_type, column_id FROM all_tab_columns WHERE owner='SMEAGOL' AND table_name='EMP'` |
| PostgreSQL / MySQL / SQL Server | `SELECT column_name, data_type, ordinal_position FROM information_schema.columns WHERE table_schema='SMEAGOL' AND table_name='EMP'` |
**Technique:** Same catalogs also expose length, nullability, and default values.

## 5.3 Listing indexed columns for a table
- **DB2:** join `syscat.indexes` + `syscat.indexcoluse` (cols: `indname, colname, colseq`).
- **Oracle:** `SELECT table_name, index_name, column_name, column_position FROM sys.all_ind_columns WHERE table_name='EMP' AND table_owner='SMEAGOL'`.
- **PostgreSQL:** join `pg_catalog.pg_indexes` + `information_schema.columns`.
- **MySQL:** `SHOW INDEX FROM emp`.
- **SQL Server:** join `sys.tables`, `sys.indexes`, `sys.index_columns`, `sys.columns`.
**Technique:** Knowing which columns are indexed helps predict filter/join performance.

## 5.4 Listing constraints on a table
- **DB2:** `syscat.tabconst` + `syscat.columns` (`constname, colname, type`).
- **Oracle:** `all_constraints` + `all_cons_columns` (`constraint_name, column_name, constraint_type`).
- **PostgreSQL / MySQL / SQL Server:** `information_schema.table_constraints` + `information_schema.key_column_usage`.
**Technique:** Useful to find tables missing a primary key, un-enforced FK candidates, or check constraints. (`constraint_type`: `P`/`PRIMARY KEY`, `R`/`FOREIGN KEY`, `U`/`UNIQUE`, `C`/`CHECK`.)

## 5.5 Listing foreign keys without corresponding indexes
**Problem:** Find FK columns lacking an index (a common performance/locking issue).
**Solution:** LEFT JOIN the set of FK columns to the set of indexed columns and keep rows where the index name `IS NULL`. Each vendor uses its own catalogs:
- **DB2:** `syscat.tabconst`/`keycoluse` (type `'F'`) left join `syscat.indexes`/`indexcoluse`.
- **Oracle:** `all_cons_columns` + `all_constraints` (type `'R'`) outer-joined to `all_ind_columns`.
- **PostgreSQL:** `key_column_usage` + `referential_constraints` left join `pg_indexes` + columns.
- **SQL Server:** `sys.foreign_keys`/`foreign_key_columns`/`columns` left join `sys.indexes`/`index_columns`.
- **MySQL:** compare `SHOW INDEX FROM emp` against `information_schema.key_column_usage` (FK indexes can be dropped).
**Technique:** Anti-join (5.5) = "FK columns" minus "indexed columns."

## 5.6 Using SQL to generate SQL
**Problem:** Automate maintenance by generating statements from the catalog.
**Solution (Oracle examples):**
```sql
-- row counts for every table
SELECT 'select count(*) from '||table_name||';' AS cnts FROM user_tables;
-- disable all foreign keys
SELECT 'alter table '||table_name||' disable constraint '||constraint_name||';'
  FROM user_constraints WHERE constraint_type = 'R';
-- generate INSERT scripts from data
SELECT 'insert into emp(empno,ename,hiredate) '||chr(10)||
       'values('||empno||','''||ename||'',to_date('''||hiredate||'''));'
  FROM emp WHERE deptno = 10;
```
**Technique:** Build statement strings by concatenating literal SQL with catalog/data values. The query only *produces* text; you still run it. Same idea on any engine — only catalog names and date formatting differ.

## 5.7 Describing the data-dictionary views (Oracle)
**Problem:** Recall which dictionary views exist and their columns without docs.
**Solution:** `SELECT table_name, comments FROM dictionary ORDER BY table_name` lists the views; `SELECT column_name, comments FROM dict_columns WHERE table_name = 'ALL_TAB_COLUMNS'` describes one. Wildcard search: `... FROM dictionary WHERE table_name LIKE '%TABLE%'`.
**Technique:** Oracle even documents its dictionary in `DICTIONARY`/`DICT_COLUMNS` — bootstrap discovery from those two views.

---

# Chapter 6 — Working with Strings

SQL is awkward at string work; the recurring tricks are **"walking a string"** with a pivot table (6.1) and using **`TRANSLATE` + `REPLACE`** to collapse a whole class of characters into one so you can manipulate them as a group. MySQL lacks `TRANSLATE` — emulate it with nested `REPLACE`. SQL Server uses `LEN`/`SUBSTRING`/`DATALENGTH`/`REPLICATE`; others use `LENGTH`/`SUBSTR`/`RPAD`.

## 6.1 Walking a string ⭐ (foundational)
**Problem:** Turn a string into one row per character (no loops in SQL).
**Solution:** Cartesian-join the string to a pivot table with enough rows, then `SUBSTR` one character per row:
```sql
SELECT SUBSTR(e.ename, iter.pos, 1) AS c
  FROM (SELECT ename FROM emp WHERE ename = 'KING') e,
       (SELECT id AS pos FROM t10) iter
 WHERE iter.pos <= LENGTH(e.ename)
```
**Technique:** A pivot table (T10 = 10 rows) supplies the iteration counter; `iter.pos <= LENGTH(...)` stops the "loop" at the string length. `iter.pos` then drives `SUBSTR`. This pattern underlies most recipes in the chapter — read it first.

## 6.2 Embedding quotes within string literals
**Problem:** Put a single quote inside a literal.
**Solution:** Double the quote: `'g''day mate'`, `'beavers'' teeth'`, and `''''` (a literal containing one quote).
**Technique:** Think of quotes like parentheses — always an even number. Two quotes with nothing between them (`''`) is **NULL/empty**, not a quote.

## 6.3 Counting occurrences of a character in a string
**Problem:** Count commas in `'10,CLARK,MANAGER'`.
**Solution:**
```sql
SELECT (LENGTH('10,CLARK,MANAGER') - LENGTH(REPLACE('10,CLARK,MANAGER', ',', ''))) / LENGTH(',') AS cnt
  FROM t1
```
**Technique:** Original length minus length-with-the-substring-removed = total characters removed; divide by the search string's length so multi-character searches (e.g., `'LL'`) count correctly. (SQL Server: `LEN`.)

## 6.4 Removing unwanted characters from a string
**Problem:** Strip vowels and zeros from values.
**Solution:**
```sql
-- DB2/Oracle/PostgreSQL/SQL Server
SELECT ename,
       REPLACE(TRANSLATE(ename, 'aaaaa', 'AEIOU'), 'a', '') AS stripped1,
       sal,
       REPLACE(CAST(sal AS CHAR(4)), '0', '') AS stripped2
  FROM emp
```
MySQL: nested `REPLACE(REPLACE(... ,'A',''),'E','')...` for each vowel.
**Technique:** `TRANSLATE` maps every vowel to one sentinel char (`a`); `REPLACE` deletes it. `REPLACE` alone handles the single character (`0`).

## 6.5 Separating numeric and character data
**Problem:** Split `'SMITH800'` into `SMITH` and `800`.
**Solution:** Use `TRANSLATE` to collapse one class to a sentinel, then `REPLACE` it out:
```sql
-- Oracle form (others differ only in cast/pad syntax)
SELECT REPLACE(TRANSLATE(data,'0123456789','0000000000'),'0') AS ename,
       TO_NUMBER(REPLACE(TRANSLATE(LOWER(data),
                 'abcdefghijklmnopqrstuvwxyz', RPAD('z',26,'z')),'z')) AS sal
  FROM (SELECT ename||sal AS data FROM emp) x
```
**Technique:** To get the digits, turn every letter into `z` then strip `z`; to get the letters, turn every digit into `0` then strip `0`. Cast the digit string to a number.

## 6.6 Determining whether a string is alphanumeric
**Problem:** Keep only rows whose value contains nothing but letters/digits.
**Solution:** Translate every alphanumeric to one sentinel (`a`) and keep rows where the result is all sentinels of the same length:
```sql
-- Oracle/PostgreSQL
SELECT data FROM v
 WHERE TRANSLATE(LOWER(data),'0123456789abcdefghijklmnopqrstuvwxyz', RPAD('a',36,'a'))
       = RPAD('a', LENGTH(data), 'a')
-- MySQL (regex)
SELECT data FROM v WHERE data REGEXP '[^0-9a-zA-Z]' = 0
```
**Technique:** Translating *the wanted* class to a single char and comparing against a same-length string of that char isolates "purely alphanumeric." (Easier to define the allowed set than enumerate all disallowed characters.)

## 6.7 Extracting initials from a name
**Problem:** `'Stewie Griffin'` → `'S.G.'`.
**Solution (Oracle/PostgreSQL):** strip periods, translate lowercase letters to `#`, remove `#`, replace spaces with `.`, append `.`:
```sql
SELECT REPLACE(REPLACE(TRANSLATE(REPLACE('Stewie Griffin','.',''),
       'abcdefghijklmnopqrstuvwxyz', RPAD('#',26,'#')),'#',''),' ','.')||'.'
  FROM t1
```
MySQL: `SUBSTRING_INDEX` + `CONCAT_WS` to pull first/middle/last initials.
**Technique:** Removing lowercase letters leaves the capitals (the initials); spaces become dots.

## 6.8 Ordering by parts of a string
**Problem:** Sort employees by the last two characters of ENAME.
**Solution:** `ORDER BY SUBSTR(ename, LENGTH(ename) - 1)` (SQL Server: `SUBSTRING(ename, LEN(ename) - 1, 2)`).
**Technique:** Any expression — including `SUBSTR` — is legal in `ORDER BY`.

## 6.9 Ordering by a number embedded in a string
**Problem:** Sort `'CLARK 7782 ACCOUNTING'` rows by the embedded employee number.
**Solution:** Strip non-digits with the nested `TRANSLATE`/`REPLACE` pattern, cast to a number, and sort:
```sql
-- Oracle
SELECT data FROM v
 ORDER BY TO_NUMBER(REPLACE(TRANSLATE(data,
            REPLACE(TRANSLATE(data,'0123456789','##########'),'#'),
            RPAD('#',LENGTH(data),'#')),'#'))
```
**Technique:** First translate digits→`#` and strip them to learn the *non-digit* characters; translate those away, leaving only digits; cast and sort. (MySQL: no `TRANSLATE`.) Build such expressions in the SELECT list first, then move them to `ORDER BY`.

## 6.10 Creating a delimited list from table rows (aggregate → CSV)
**Problem:** Collapse the employees of each department into one comma-separated value.
**Solution:**
- **DB2 / Oracle 11gR2+ / standard:** `LISTAGG(ename, ',') WITHIN GROUP (ORDER BY empno)`
- **PostgreSQL / SQL Server 2017+:** `STRING_AGG(ename, ',' ORDER BY empno)`
- **MySQL:** `GROUP_CONCAT(ename ORDER BY empno SEPARATOR ',')`
- **Oracle (legacy):** `SYS_CONNECT_BY_PATH` over a `CONNECT BY` walk with `ROW_NUMBER`.
```sql
SELECT deptno, STRING_AGG(ename, ',' ORDER BY empno) AS emps
  FROM emp GROUP BY deptno
```
**Technique:** These are aggregate functions, so pair with `GROUP BY`. The standard is `LISTAGG`; `STRING_AGG`/`GROUP_CONCAT` are the common equivalents.

## 6.11 Converting delimited data into a multivalued IN-list (CSV → rows)
**Problem:** Use a comma-separated string (`'7654,7698,7782,7788'`) as the values of an `IN` list.
**Solution:** Walk the string and parse out each value, then feed them to the `IN` subquery. Engine-specific parsing:
- **MySQL:** nested `SUBSTRING_INDEX(SUBSTRING_INDEX(vals, ',', pos), ',', -1)`.
- **PostgreSQL:** `SPLIT_PART(vals, ',', pos)`.
- **Oracle:** `SUBSTR` + `INSTR(emps, ',', 1, pos)` to find the nth/n+1th delimiter (wrap the list in commas).
- **DB2 / SQL Server:** walk so each row drops one leading char, keep rows beginning with `,`, then `SUBSTR`/`SUBSTRING` to the next comma.
**Technique:** Wrap the list in delimiters (`',' || list || ','`) so first/last values need no special-casing; the row count = number of delimiters (± 1). (Modern engines: `STRING_SPLIT` / `regexp_split_to_table` / JSON table functions are simpler — see 6.14.)

## 6.12 Alphabetizing a string
**Problem:** Reorder the characters within each value alphabetically (`MARTIN` → `AIMNRT`).
**Solution:** Walk each string into one row per character, then re-aggregate the characters in sorted order:
```sql
-- MySQL
SELECT ename, GROUP_CONCAT(c ORDER BY c SEPARATOR '')
  FROM (SELECT ename, SUBSTR(a.ename, iter.pos, 1) c
          FROM emp a, (SELECT id pos FROM t10) iter
         WHERE iter.pos <= LENGTH(a.ename)) x
 GROUP BY ename
```
DB2/PostgreSQL: `LISTAGG`/`STRING_AGG(c, '' ORDER BY c)`. Oracle: `SYS_CONNECT_BY_PATH`. SQL Server (<2017): `MAX(CASE WHEN pos = n ...)` concatenation.
**Technique:** Split (walk) → sort → re-join. The aggregate's `ORDER BY c` does the alphabetizing.

## 6.13 Identifying strings that can be treated as numbers
**Problem:** From mixed values, keep only those containing digits and return just the numeric part (`CL10AR` → `10`, `7369` → `7369`, `ALLEN` → dropped).
**Solution (Oracle/DB2/PostgreSQL):** `TRANSLATE` digits → `9`; if removing the `9`s leaves something, the row has letters — translate the letters to `#` and strip them, leaving digits; cast to number. Filter rows with `INSTR/STRPOS/POSSTR(TRANSLATE(mixed,'0123456789','9999999999'),'9') > 0`.
MySQL: walk the string, keep chars with `ASCII(...) BETWEEN 48 AND 57`, `GROUP_CONCAT` and cast. SQL Server: `ISNUMERIC` + wildcard (no `TRANSLATE`).
**Technique:** Collapse digits to one sentinel to detect/strip them as a unit. ⚠️ All digits in a value concatenate into one number (`99Gennick87` → `9987`).

## 6.14 Extracting the nth delimited substring
**Problem:** Return the 2nd element of each CSV value.
**Solution:**
- **PostgreSQL:** `SPLIT_PART(name, ',', pos)`, keep `pos = 2`.
- **MySQL:** `SUBSTRING_INDEX(SUBSTRING_INDEX(name, ',', pos), ',', -1)`, keep `pos = 2`.
- **Oracle:** `SUBSTR`/`INSTR` with `pos` to bound the nth value.
- **SQL Server:** `STRING_SPLIT` (table-valued; combine rows with a `STRING_AGG` CTE first if needed).
- **DB2:** walk, keep comma-led rows, `ROW_NUMBER()` to pick the nth.
**Technique:** Same walk-and-parse as 6.11; filter to the desired ordinal position.

## 6.15 Parsing an IP address
**Problem:** Split `92.111.0.2` into four columns.
**Solution:**
- **MySQL:** four `SUBSTRING_INDEX(SUBSTRING_INDEX(ip,'.',n),'.',-1)`.
- **PostgreSQL:** `SPLIT_PART(ip,'.',1..4)`.
- **Oracle:** `SUBSTR` + `INSTR(ip,'.',1,n)` to bound each octet.
- **DB2 / SQL Server:** recursive CTE walk (prepend a `.` so each octet has a leading delimiter).
**Technique:** Locate the periods, take the text between them. `SPLIT_PART`/`SUBSTRING_INDEX` make this a one-liner; regex (6.17) is another option.

## 6.16 Comparing strings by sound (SOUNDEX)
**Problem:** Match names that *sound* alike despite different spellings (Johnson/Jonson/Jonsen).
**Solution:** Self-join on `SOUNDEX`:
```sql
SELECT an1.a_name AS name1, an2.a_name AS name2, SOUNDEX(an1.a_name) AS soundex_name
  FROM author_names an1
  JOIN author_names an2
    ON (SOUNDEX(an1.a_name) = SOUNDEX(an2.a_name) AND an1.a_name NOT LIKE an2.a_name)
```
**Technique:** `SOUNDEX` keeps the first letter and encodes the rest as phonetic digit codes (e.g., m and n both → 5). SQL Server's `DIFFERENCE` returns a 0–4 similarity of two soundex codes. Available in all five engines; for finer matching, use other algorithms via UDFs.

## 6.17 Finding text not matching a pattern (regex)
**Problem:** In a free-text column, find badly formatted phone numbers (mixed separators like `989 313-5351`).
**Solution (three steps with regex):**
```sql
SELECT emp_id, text FROM employee_comment
 WHERE REGEXP_LIKE(text, '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}')        -- A: looks like a phone number
   AND REGEXP_LIKE(
         REGEXP_REPLACE(text, '[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}', '***'),  -- B: blank out well-formed ones
         '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}')                        -- anything still matching A is bad
```
**Technique:** Pattern A defines "apparent phone numbers"; Pattern B (using a back-reference `\1` so both separators must match) defines *valid* ones. Replace the valid ones with `***`, then anything still matching A is malformed. Regex function names vary: Oracle/PostgreSQL `REGEXP_LIKE`/`REGEXP_REPLACE`; MySQL `REGEXP`/`REGEXP_REPLACE`; SQL Server uses `LIKE`/`PATINDEX` (no full regex pre-2025).

---

# Chapter 7 — Working with Numbers

This chapter covers common numeric and statistical computations. SQL is not a full statistics package, but it has a rich enough calculation toolkit — especially window functions — to extract real insight from data already living in the database. **NULL handling is the recurring theme:** aggregates silently ignore NULLs, which is sometimes what you want and sometimes a bug.

## 7.1 Computing an Average
**Problem:** Compute the average of a set of values — either all rows, or per group (e.g., average salary of all employees, and per department).
**Solution:**
```sql
SELECT AVG(sal) AS avg_sal FROM emp;                 -- all rows

SELECT deptno, AVG(sal) AS avg_sal                   -- per department
  FROM emp
 GROUP BY deptno;
```
**Technique:** `AVG` ignores NULLs. To count NULLs as zero (so they pull the average down), wrap the column: `AVG(COALESCE(comm, 0))`. Any non-aggregated column (`deptno`) placed beside an aggregate must appear in `GROUP BY`.

## 7.2 Finding the Min/Max Value in a Column
**Problem:** Find the smallest and largest values in a column, optionally per group.
**Solution:**
```sql
SELECT MIN(sal) AS min_sal, MAX(sal) AS max_sal FROM emp;

SELECT deptno, MIN(sal) AS min_sal, MAX(sal) AS max_sal
  FROM emp
 GROUP BY deptno;
```
**Technique:** `MIN`/`MAX` ignore NULLs. `MIN(comm)` in DEPTNO 30 returns 0 (the smallest non-null commission), not NULL, even though most rows there have NULL.

## 7.3 Summing the Values in a Column
**Problem:** Sum a column, optionally per group.
**Solution:**
```sql
SELECT SUM(sal) AS total_sal FROM emp;

SELECT deptno, SUM(sal) AS total_sal
  FROM emp
 GROUP BY deptno;
```
**Technique:** `SUM` ignores NULLs — `SUM(comm)` adds only the non-null commissions. Use `SUM(COALESCE(comm,0))` if you intend to divide that sum by a full row count later.

## 7.4 Counting Rows in a Table
**Problem:** Count rows, optionally per group.
**Solution:**
```sql
SELECT COUNT(*) AS n FROM emp;

SELECT deptno, COUNT(*) AS n
  FROM emp
 GROUP BY deptno;
```
**Technique:** `COUNT(*)` counts every row including NULLs; `COUNT(1)` is equivalent. Use it when you want "how many rows."

## 7.5 Counting Values in a Column
**Problem:** Count rows with a non-NULL value in a column (e.g., how many employees can earn a commission).
**Solution:**
```sql
SELECT COUNT(comm) AS commissioned FROM emp;   -- -> 4
```
**Technique:** `COUNT(column)` counts only non-NULL values: `COUNT(comm)` = 4 while `COUNT(*)` = 14. The distinction is fundamental — `COUNT(*)` = rows, `COUNT(col)` = non-null values; `COUNT(DISTINCT col)` = distinct non-null values.

## 7.6 Generating a Running Total
**Problem:** Compute a cumulative total of a column.
**Solution:**
```sql
SELECT ename, sal,
       SUM(sal) OVER (ORDER BY sal, empno) AS running_total
  FROM emp
 ORDER BY sal, empno;
```
**Technique:** `SUM(sal) OVER (ORDER BY ...)` sums the current row plus all preceding rows in the given order. **Add a unique tiebreaker (`empno`)** to the `ORDER BY`: without it, equal-`sal` rows share the same cumulative value (the default `RANGE` frame groups ties), which is wrong for a running total. See Appendix A for framing details.

## 7.7 Generating a Running Product
**Problem:** Compute a cumulative product of a column.
**Solution:**
```sql
-- DB2, Oracle, PostgreSQL, MySQL (LN = natural log)
SELECT empno, ename, sal,
       EXP(SUM(LN(sal)) OVER (ORDER BY sal, empno)) AS running_prod
  FROM emp WHERE deptno = 10;

-- SQL Server uses LOG for the natural log
SELECT empno, ename, sal,
       EXP(SUM(LOG(sal)) OVER (ORDER BY sal, empno)) AS running_prod
  FROM emp WHERE deptno = 10;
```
**Technique:** Multiply via logs — `a*b*c = EXP(LN a + LN b + LN c)`. Apply the running-`SUM` window to `LN(sal)`, then `EXP`. **Caveat:** logs are undefined for values ≤ 0, so this only works for strictly positive numbers; handle zeros/negatives separately.

## 7.8 Smoothing a Series of Values
**Problem:** A noisy time series (e.g., daily sales) obscures the trend; compute a moving average.
**Solution:**
```sql
SELECT date1, sales,
       LAG(sales,1) OVER (ORDER BY date1) AS lag1,
       LAG(sales,2) OVER (ORDER BY date1) AS lag2,
       (sales
        + LAG(sales,1) OVER (ORDER BY date1)
        + LAG(sales,2) OVER (ORDER BY date1)) / 3 AS moving_avg
  FROM sales;
```
**Technique:** `LAG(sales,n)` returns the value `n` rows earlier in the ordering; averaging current + two prior values yields a 3-point moving average (first two rows are NULL). For a **weighted** average emphasizing recent data, change coefficients/divisor, e.g. `(3*sales + 2*lag1 + lag2)/6`. Equivalent framed form: `AVG(sales) OVER (ORDER BY date1 ROWS 2 PRECEDING)`.

## 7.9 Calculating a Mode
**Problem:** Find the most frequent value (mode), e.g., the mode salary in DEPTNO 20.
**Solution:**
```sql
-- DB2, MySQL, PostgreSQL, SQL Server
SELECT sal
  FROM (
    SELECT sal, DENSE_RANK() OVER (ORDER BY cnt DESC) AS rnk
      FROM (SELECT sal, COUNT(*) AS cnt
              FROM emp WHERE deptno = 20 GROUP BY sal) x
  ) y
 WHERE rnk = 1;

-- Oracle: KEEP ... DENSE_RANK FIRST (returns the single highest mode on ties)
SELECT MAX(sal) KEEP (DENSE_RANK FIRST ORDER BY cnt DESC) AS sal
  FROM (SELECT sal, COUNT(*) cnt FROM emp WHERE deptno = 20 GROUP BY sal);
```
**Technique:** Count occurrences of each value, rank the counts with `DENSE_RANK() OVER (ORDER BY cnt DESC)`, keep rank 1. `DENSE_RANK` preserves **ties** — if several values tie for most frequent, all come back (unlike `ROW_NUMBER`). Oracle's `KEEP` form is compact but returns just one mode.

## 7.10 Calculating a Median
**Problem:** Find the median (middle value), e.g., median salary in DEPTNO 20.
**Solution:**
```sql
-- DB2, PostgreSQL, Oracle: ordered-set aggregate
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sal) AS median
  FROM emp WHERE deptno = 20;

-- SQL Server: PERCENTILE_CONT is a window function -> needs OVER()
SELECT DISTINCT
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sal) OVER () AS median
  FROM emp WHERE deptno = 20;

-- Oracle also has MEDIAN()
SELECT MEDIAN(sal) FROM emp WHERE deptno = 20;
```
MySQL (no `PERCENTILE_CONT`) — emulate with `CUME_DIST` in a CTE:
```sql
WITH rank_tab AS (
  SELECT sal, CUME_DIST() OVER (ORDER BY sal) AS rank_sal
    FROM emp WHERE deptno = 20),
inter AS (
  SELECT sal FROM rank_tab WHERE rank_sal >= 0.5
  UNION
  SELECT sal FROM rank_tab WHERE rank_sal <= 0.5)
SELECT AVG(sal) AS median_sal FROM inter;
```
**Technique:** The median is the 50th percentile, so `PERCENTILE_CONT(0.5)` gives it directly (other percentiles, e.g. 0.05/0.95, come free for outlier work). The MySQL workaround averages the highest value at-or-below the midpoint with the lowest at-or-above — correct for both odd and even counts.

## 7.11 Determining the Percentage of a Total
**Problem:** What percentage of a total does a subset contribute (e.g., DEPTNO 10's share of all salaries)?
**Solution:**
```sql
-- MySQL, PostgreSQL: CASE inside SUM / grand total
SELECT (SUM(CASE WHEN deptno = 10 THEN sal END) / SUM(sal)) * 100 AS pct
  FROM emp;

-- DB2, Oracle, SQL Server: SUM OVER, filter OUTSIDE the inline view
SELECT DISTINCT (d10 / total) * 100 AS pct
  FROM (SELECT deptno,
               SUM(sal) OVER ()                    AS total,
               SUM(sal) OVER (PARTITION BY deptno) AS d10
          FROM emp) x
 WHERE deptno = 10;
```
**Technique:** Divide subset sum by grand total, × 100. With window functions the `WHERE deptno = 10` filter **must be outside** the inline view — windows run after `WHERE`, so filtering first would make "total" only DEPTNO 10's sum. For integer salaries, `CAST(... AS DECIMAL)` before dividing to avoid integer truncation.

## 7.12 Aggregating Nullable Columns
**Problem:** Aggregate a nullable column with NULLs counted, not dropped (e.g., average commission of *all* DEPTNO 30 employees).
**Solution:**
```sql
SELECT AVG(COALESCE(comm, 0)) AS avg_comm
  FROM emp WHERE deptno = 30;
```
**Technique:** `AVG(comm)` = "average among those who earn one" (sum/4). `AVG(COALESCE(comm,0))` = "average across everyone" (sum/6). Decide which question you are asking and `COALESCE` accordingly — the most common NULL-aggregation bug.

## 7.13 Computing Averages Without High and Low Values (Trimmed Mean)
**Problem:** Average while excluding the highest and lowest values to reduce skew.
**Solution:**
```sql
-- MySQL, PostgreSQL
SELECT AVG(sal)
  FROM emp
 WHERE sal NOT IN ((SELECT MIN(sal) FROM emp),
                   (SELECT MAX(sal) FROM emp));

-- DB2, Oracle, SQL Server
SELECT AVG(sal)
  FROM (SELECT sal,
               MIN(sal) OVER () AS min_sal,
               MAX(sal) OVER () AS max_sal
          FROM emp) x
 WHERE sal NOT IN (min_sal, max_sal);
```
**Technique:** A *trimmed mean* is a robust statistic (less sensitive to outliers). `NOT IN` excludes **all** rows tied at the extreme; to drop only a single instance of each, use `(SUM(sal) - MIN(sal) - MAX(sal)) / (COUNT(*) - 2)`.

## 7.14 Converting Alphanumeric Strings into Numbers
**Problem:** Extract only the digits — return `123321` from `'paul123f321'`.
**Solution:**
```sql
-- Oracle, SQL Server, PostgreSQL: letters -> '#', then strip '#'
SELECT CAST(REPLACE(
         TRANSLATE('paul123f321',
                   'abcdefghijklmnopqrstuvwxyz', RPAD('#',26,'#')),
         '#','') AS INTEGER) AS num
  FROM t1;

-- DB2: REPEAT instead of RPAD; TRANSLATE arg order differs
SELECT CAST(REPLACE(
         TRANSLATE('paul123f321', REPEAT('#',26),
                   'abcdefghijklmnopqrstuvwxyz'),
         '#','') AS INTEGER) AS num
  FROM t1;
```
**Technique:** `TRANSLATE` maps letters to `#`, `REPLACE` strips them, leaving digits to `CAST`. For arbitrary junk (not just letters), nest the idea: translate digits to `#` and strip to discover the non-digit set, then translate that set to `#` in the original and strip — keeping only digits regardless of what else appears. MySQL lacks `TRANSLATE`; use `REGEXP_REPLACE(str,'[^0-9]','')`.

## 7.15 Changing Values in a Running Total
**Problem:** A running total whose direction depends on another column — a balance where purchases add and payments subtract.
**Solution:**
```sql
SELECT CASE WHEN trx = 'PY' THEN 'PAYMENT' ELSE 'PURCHASE' END AS trx_type,
       amt,
       SUM(CASE WHEN trx = 'PY' THEN -amt ELSE amt END)
           OVER (ORDER BY id, amt) AS balance
  FROM V;
```
**Technique:** Put a `CASE` *inside* the windowed `SUM`: negate payments, keep purchases positive, then accumulate with `SUM(...) OVER (ORDER BY ...)`. Same deterministic-ordering rule as Recipe 7.6.

## 7.16 Finding Outliers Using the Median Absolute Deviation (MAD)
**Problem:** Detect outliers robustly, without assuming a normal distribution (the basis of the "3 standard deviations" rule).
**Solution:**
```sql
-- PostgreSQL / DB2
WITH median (median) AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sal) FROM emp),
devtab (deviation) AS (
  SELECT ABS(sal - median) FROM emp JOIN median ON 1=1),
mad (mad) AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY deviation) FROM devtab)
SELECT ABS(sal - mad)/mad AS mad_distance, sal, ename, job
  FROM mad JOIN emp ON 1=1;

-- Oracle (MEDIAN simplifies it)
WITH deviation (deviation) AS (SELECT ABS(sal - MEDIAN(sal)) FROM emp),
mad (mad) AS (SELECT MEDIAN(deviation) FROM deviation)
SELECT ABS(sal - mad)/mad, sal, ename, job FROM mad JOIN emp;
```
SQL Server uses `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ...) OVER ()` with `DISTINCT`; MySQL emulates each median with the `CUME_DIST` CTE from 7.10.
**Technique:** MAD = the median of the absolute deviations from the median. Compute the median, then the median of `ABS(value - median)`, then express each point as `ABS(value - median)/MAD`. A distance ≥ 3 flags an outlier — analogous to "3 sigma" but robust to skewed, non-normal data. In EMP only the CEO's salary exceeds 3 MAD.

## 7.17 Finding Anomalies Using Benford's Law
**Problem:** Detect suspect data (fraud, duplicates, errors) that does not appear as outliers, by checking the distribution of leading digits against Benford's law.
**Solution:**
```sql
WITH first_digits (first_digit) AS (
  SELECT LEFT(CAST(sal AS CHAR), 1) FROM emp),
total_count (total) AS (
  SELECT COUNT(*) FROM emp),
expected_benford (digit, expected) AS (
  SELECT value, (LOG10(value + 1) - LOG10(value))
    FROM t10 WHERE value < 10)
SELECT COUNT(first_digit), digit,
       COALESCE(COUNT(*)/total, 0) AS actual_proportion, expected
  FROM first_digits
  JOIN total_count
  RIGHT JOIN expected_benford
    ON first_digits.first_digit = expected_benford.digit
 GROUP BY digit, total
 ORDER BY digit;
```
**Technique:** Benford's law: the expected frequency of leading digit *d* is `log10((d+1)/d) = log10(d+1) - log10(d)`. Build the expected curve from `T10`, count actual leading digits (`LEFT(CAST(sal AS CHAR),1)`), and compare. A `RIGHT JOIN` to the expected table keeps digits with zero actual count. Benford works best with many values spanning several orders of magnitude; large deviations suggest fabricated or duplicated numbers.

---

# Chapter 8 — Date Arithmetic

Simple date arithmetic: adding/subtracting intervals, and measuring the distance between two dates in days, months, years, or smaller units. Date functions are the **least standardized** area across vendors — every engine has equivalents, but the syntax differs. The book standardizes on the `DD-MON-YYYY` display format and simple `DATE` types; adjust for `TIMESTAMP`/time-zone types as needed. These recipes assume CLARK was hired `09-JUN-2006` in the worked examples.

## 8.1 Adding and Subtracting Days, Months, and Years
**Problem:** Add or subtract some number of days, months, or years from a date.
**Solution:**
```sql
-- DB2: typed interval literals after the value
SELECT hiredate - 5 DAY,  hiredate + 5 DAY,
       hiredate - 5 MONTH, hiredate + 5 MONTH,
       hiredate - 5 YEAR,  hiredate + 5 YEAR
  FROM emp WHERE deptno = 10;

-- Oracle: integer arithmetic = days; ADD_MONTHS for months/years
SELECT hiredate - 5, hiredate + 5,
       ADD_MONTHS(hiredate, -5),    ADD_MONTHS(hiredate, 5),
       ADD_MONTHS(hiredate, -5*12), ADD_MONTHS(hiredate, 5*12)
  FROM emp WHERE deptno = 10;

-- PostgreSQL: INTERVAL with quotes (ISO standard)
SELECT hiredate - INTERVAL '5 day',   hiredate + INTERVAL '5 day',
       hiredate - INTERVAL '5 month',  hiredate + INTERVAL '5 month',
       hiredate - INTERVAL '5 year',   hiredate + INTERVAL '5 year'
  FROM emp WHERE deptno = 10;

-- MySQL: INTERVAL without quotes, or DATE_ADD
SELECT hiredate - INTERVAL 5 DAY,  hiredate + INTERVAL 5 MONTH,
       DATE_ADD(hiredate, INTERVAL -5 YEAR)
  FROM emp WHERE deptno = 10;

-- SQL Server: DATEADD(unit, n, date)
SELECT DATEADD(day,-5,hiredate),   DATEADD(day,5,hiredate),
       DATEADD(month,-5,hiredate), DATEADD(month,5,hiredate),
       DATEADD(year,-5,hiredate),  DATEADD(year,5,hiredate)
  FROM emp WHERE deptno = 10;
```
**Technique:** Plain integer ±N means days only on Oracle/DB2 `DATE` types — and only for `DATE`, not `TIMESTAMP` (passing a TIMESTAMP to `ADD_MONTHS` can drop fractional seconds). The `INTERVAL '5 day'` form is ISO-standard (PostgreSQL/Oracle require the quotes; MySQL omits them). Months/years need a dedicated function (`ADD_MONTHS`, `DATEADD`, `INTERVAL`) because their length varies.

## 8.2 Determining the Number of Days Between Two Dates
**Problem:** Find the difference in days between two dates (e.g., ALLEN's and WARD's hire dates).
**Solution:** Pull each date with an inline view, then subtract.
```sql
-- Oracle, PostgreSQL: date subtraction yields days
SELECT ward_hd - allen_hd
  FROM (SELECT hiredate AS ward_hd  FROM emp WHERE ename='WARD')  x,
       (SELECT hiredate AS allen_hd FROM emp WHERE ename='ALLEN') y;

-- DB2: DAYS() converts to a day-number first
SELECT DAYS(ward_hd) - DAYS(allen_hd) FROM ... ;

-- MySQL, SQL Server: DATEDIFF
-- SQL Server: DATEDIFF(day, allen_hd, ward_hd)
-- MySQL:      DATEDIFF(ward_hd, allen_hd)  (larger date first)
```
**Technique:** The two single-row inline views form a harmless Cartesian product (1 × 1 = 1 row), giving both dates on one row to subtract. Oracle/PostgreSQL subtract dates directly; DB2 needs `DAYS()`; MySQL/SQL Server use `DATEDIFF` (mind the argument order — SQL Server takes a unit first, MySQL returns `date1 - date2`).

## 8.3 Determining the Number of Business Days Between Two Dates
**Problem:** Count working days (excluding Saturday/Sunday) between two dates, inclusive.
**Solution:** Use a pivot table (T500) to generate one row per day in the range, then count days that aren't weekends.
```sql
-- Oracle form
SELECT SUM(CASE WHEN TO_CHAR(jones_hd + t500.id - 1, 'DY') IN ('SAT','SUN')
                THEN 0 ELSE 1 END) AS days
  FROM (SELECT MAX(CASE WHEN ename='BLAKE' THEN hiredate END) AS blake_hd,
               MAX(CASE WHEN ename='JONES' THEN hiredate END) AS jones_hd
          FROM emp WHERE ename IN ('BLAKE','JONES')) x,
       t500
 WHERE t500.id <= blake_hd - jones_hd + 1;
```
Weekday-name function varies: DB2 `DAYNAME`, MySQL `DATE_FORMAT(d,'%a')`, Oracle `TO_CHAR(d,'DY')`, PostgreSQL `TRIM(TO_CHAR(d,'DAY'))`, SQL Server `DATENAME(dw,d)`.
**Technique:** Two steps: (1) generate every date in `[start, end]` by adding `t500.id - 1` to the earlier date, bounding the count with `t500.id <= end - start + 1`; (2) `SUM` a `CASE` that scores weekdays 1 and weekends 0. `MAX(CASE ...)` collapses BLAKE's and JONES's rows into one. To also skip public holidays, add `AND date NOT IN (SELECT day FROM holidays)`.

## 8.4 Determining the Number of Months or Years Between Two Dates
**Problem:** Find the difference between two dates in months and years (e.g., between first and last hire dates).
**Solution:**
```sql
-- Oracle: MONTHS_BETWEEN, then /12 for years
SELECT MONTHS_BETWEEN(max_hd, min_hd),
       MONTHS_BETWEEN(max_hd, min_hd)/12
  FROM (SELECT MIN(hiredate) min_hd, MAX(hiredate) max_hd FROM emp) x;

-- SQL Server: DATEDIFF with month / year units
SELECT DATEDIFF(month, min_hd, max_hd), DATEDIFF(year, min_hd, max_hd)
  FROM (SELECT MIN(hiredate) min_hd, MAX(hiredate) max_hd FROM emp) x;

-- DB2 / MySQL (YEAR, MONTH) and PostgreSQL (EXTRACT): compute months by hand
SELECT mnth, mnth/12
  FROM (SELECT (YEAR(max_hd)-YEAR(min_hd))*12 + (MONTH(max_hd)-MONTH(min_hd)) AS mnth
          FROM (SELECT MIN(hiredate) min_hd, MAX(hiredate) max_hd FROM emp) x) y;
```
**Technique:** There are always 12 months per year, so compute months first and divide by 12 for years. The portable formula is `(year2-year1)*12 + (month2-month1)`. Beware that "years between" computed from calendar years (1983-1980 = 3) disagrees with months/12 (~25/12 ≈ 2) — round to taste. Oracle's `MONTHS_BETWEEN` and SQL Server's `DATEDIFF(month,...)` do it directly.

## 8.5 Determining the Number of Seconds, Minutes, or Hours Between Two Dates
**Problem:** Express the gap between two dates in seconds, minutes, and hours.
**Solution:** Find the day difference, then multiply.
```sql
-- Oracle, PostgreSQL
SELECT dy*24 AS hr, dy*24*60 AS min, dy*24*60*60 AS sec
  FROM (SELECT (MAX(CASE WHEN ename='WARD'  THEN hiredate END)
              - MAX(CASE WHEN ename='ALLEN' THEN hiredate END)) AS dy
          FROM emp) x;
```
DB2 uses `DAYS(...)` to get the day count; MySQL/SQL Server use `DATEDIFF` then multiply.
**Technique:** Once you have whole days, the sub-day units are just constants: ×24 (hours), ×1440 (minutes), ×86400 (seconds). (With `TIMESTAMP` values you'd instead use `EXTRACT`/`DATEDIFF(second,...)` to keep the time-of-day component.)

## 8.6 Counting the Occurrences of Weekdays in a Year
**Problem:** Count how many times each weekday occurs in a given year.
**Solution:** (1) generate every date in the year, (2) format each to its weekday name, (3) `GROUP BY` and count.
```sql
-- PostgreSQL: GENERATE_SERIES as the row source
SELECT TO_CHAR(CAST(date_trunc('year',current_date) AS date) + gs.id - 1, 'DAY'),
       COUNT(*)
  FROM generate_series(1,366) gs(id)
 WHERE gs.id <= (CAST(date_trunc('year',current_date) + INTERVAL '12 month' AS date)
                 - CAST(date_trunc('year',current_date) AS date))
 GROUP BY TO_CHAR(CAST(date_trunc('year',current_date) AS date) + gs.id - 1, 'DAY');

-- Oracle: recursive CONNECT BY generates LEVEL = 1..days-in-year
WITH x AS (
  SELECT LEVEL lvl FROM dual
   CONNECT BY LEVEL <= (ADD_MONTHS(TRUNC(SYSDATE,'y'),12) - TRUNC(SYSDATE,'y')))
SELECT TO_CHAR(TRUNC(SYSDATE,'y')+lvl-1, 'DAY'), COUNT(*)
  FROM x GROUP BY TO_CHAR(TRUNC(SYSDATE,'y')+lvl-1, 'DAY');
```
DB2 and SQL Server use a recursive `WITH` (SQL Server: `OPTION (MAXRECURSION 366)`); MySQL selects against T500.
**Technique:** The hard part is generating ~365/366 consecutive dates — by recursive CTE, `CONNECT BY LEVEL`, `GENERATE_SERIES`, or a pivot table. Bound the count by `(first day of next year) - (first day of this year)` so leap years self-adjust. Then weekday name + `GROUP BY` gives the tallies (one weekday gets 53, the rest 52).

## 8.7 Determining the Date Difference Between the Current Record and the Next Record
**Problem:** For each row, find the gap in days to the next row's date (e.g., days between each DEPTNO 10 hire and the next hire anywhere).
**Solution:** Use `LEAD` to bring the next date onto the current row, then subtract.
```sql
-- Oracle
SELECT ename, hiredate, next_hd, next_hd - hiredate AS diff
  FROM (SELECT deptno, ename, hiredate,
               LEAD(hiredate) OVER (ORDER BY hiredate) AS next_hd
          FROM emp)
 WHERE deptno = 10;
```
DB2/PostgreSQL subtract the dates (DB2 via `DAYS`); MySQL/SQL Server use `DATEDIFF`.
**Technique:** `LEAD(hiredate) OVER (ORDER BY hiredate)` reads the following row without a self-join. Because windows run **after** `WHERE`, keep the `deptno` filter in the *outer* query if "next" should consider all departments. **Duplicate-date trap (Oracle):** `LEAD` does not skip ties, so rows sharing a date get a diff of 0. Fix by computing the distance to the next *distinct* date and passing it to `LEAD`:
```sql
LEAD(hiredate, cnt-rn+1) OVER (ORDER BY hiredate)   -- jump over the duplicates
-- where, in an inner view partitioned by hiredate:
--   cnt = COUNT(*)        OVER (PARTITION BY hiredate)
--   rn  = ROW_NUMBER()    OVER (PARTITION BY hiredate ORDER BY empno)
```
`cnt-rn+1` is each tied row's distance to the first row past the duplicates.

---

# Chapter 9 — Date Manipulation

Searching and modifying dates: leap-year tests, day/month/year boundaries, extracting parts, enumerating weekdays, calendars, quarters, filling gaps, and comparing/overlapping ranges. The recurring building blocks are: (a) **TRUNC/DATE_TRUNC** (or arithmetic) to snap a date to the start of a year/month; (b) **generating a run of consecutive dates** (recursive CTE, `CONNECT BY LEVEL`, `GENERATE_SERIES`, or a pivot table); and (c) **a weekday-name/number function** that differs per vendor. Treat each recipe as a template you adapt to any month/year/weekday.

## 9.1 Determining Whether a Year Is a Leap Year
**Problem:** Is the current year a leap year?
**Solution:** Find the last day of February; if it is the 29th, it's a leap year.
```sql
-- Oracle: LAST_DAY of February
SELECT TO_CHAR(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'y'),1)), 'DD') FROM t1;

-- MySQL: LAST_DAY then DAY
SELECT DAY(LAST_DAY(DATE_ADD(DATE_ADD(DATE_ADD(current_date,
            INTERVAL -DAYOFYEAR(current_date) DAY), INTERVAL 1 DAY),
            INTERVAL 1 MONTH))) AS dy FROM t1;

-- SQL Server: try to build Feb 29; NULL if it doesn't exist
SELECT COALESCE(DAY(CAST(CONCAT(YEAR(GETDATE()),'-02-29') AS date)), 28);
```
DB2/PostgreSQL: generate February's days with a recursive CTE / `GENERATE_SERIES` and take `MAX(day)`.
**Technique:** Snap to Jan 1 (`TRUNC(...,'y')`), add a month to reach Feb 1, then ask for the last day. Oracle/MySQL have `LAST_DAY`; SQL Server's trick — cast a literal `'YYYY-02-29'` and let an invalid date yield NULL, then `COALESCE(...,28)` — is neat but vendor-specific.

## 9.2 Determining the Number of Days in a Year
**Problem:** How many days are in the current year (365 or 366)?
**Solution:** `(first day of next year) − (first day of this year)`.
```sql
-- Oracle
SELECT ADD_MONTHS(TRUNC(SYSDATE,'y'),12) - TRUNC(SYSDATE,'y') FROM dual;

-- SQL Server
SELECT DATEDIFF(d, curr_year, DATEADD(yy,1,curr_year))
  FROM (SELECT DATEADD(d, -DATEPART(dy,GETDATE())+1, GETDATE()) AS curr_year) x;

-- PostgreSQL
SELECT CAST((curr_year + INTERVAL '1 year') AS date) - curr_year
  FROM (SELECT CAST(date_trunc('year',current_date) AS date) AS curr_year) x;
```
DB2 uses `DAYS()`; MySQL uses `DATEDIFF` with interval arithmetic.
**Technique:** Find Jan 1 of this year, add a year, subtract. This sidesteps leap-year logic entirely — the calendar does the counting.

## 9.3 Extracting Units of Time from a Date
**Problem:** Break a date/timestamp into numeric day, month, year, hour, minute, second.
**Solution:** The ANSI `EXTRACT` works on most engines; each vendor also has legacy functions.
```sql
-- ANSI (DB2, Oracle, PostgreSQL, MySQL)
SELECT EXTRACT(HOUR FROM current_timestamp), EXTRACT(MINUTE FROM current_timestamp),
       EXTRACT(SECOND FROM current_timestamp), EXTRACT(DAY FROM current_timestamp),
       EXTRACT(MONTH FROM current_timestamp), EXTRACT(YEAR FROM current_timestamp);

-- SQL Server (no EXTRACT pre-2022): DATEPART
SELECT DATEPART(hour,GETDATE()), DATEPART(minute,GETDATE()), DATEPART(second,GETDATE()),
       DATEPART(day,GETDATE()),  DATEPART(month,GETDATE()),  DATEPART(year,GETDATE());
```
Legacy forms: DB2 `HOUR()/MINUTE()/.../YEAR()`; Oracle/PostgreSQL `TO_NUMBER(TO_CHAR(d,'hh24'/'mi'/...))`; MySQL `DATE_FORMAT(d,'%k'/'%i'/...)`.
**Technique:** Prefer ANSI `EXTRACT` for portability; fall back to `DATEPART` on SQL Server. The format-code approaches return strings — wrap in `TO_NUMBER` if you need numerics.

## 9.4 Determining the First and Last Days of a Month
**Problem:** First and last day of the current month.
**Solution:**
```sql
-- Oracle: TRUNC to month start; LAST_DAY for month end
SELECT TRUNC(SYSDATE,'mm') AS firstday, LAST_DAY(SYSDATE) AS lastday FROM dual;

-- PostgreSQL: date_trunc('month') + 1 month - 1 day
SELECT firstday, CAST(firstday + INTERVAL '1 month' - INTERVAL '1 day' AS date) AS lastday
  FROM (SELECT CAST(date_trunc('month',current_date) AS date) AS firstday) x;

-- MySQL: subtract DAY()-1 for first; LAST_DAY for last
SELECT DATE_ADD(current_date, INTERVAL -DAY(current_date)+1 DAY) AS firstday,
       LAST_DAY(current_date) AS lastday FROM t1;
```
DB2/SQL Server: subtract `DAY(date)` to reach the prior month's end, add 1 day for first; for last, add a month then subtract `DAY()` of that.
**Technique:** First day: `current − (DAY(current) − 1)`. Last day: either `LAST_DAY` (Oracle/MySQL), or `first-of-next-month − 1 day`. Note Oracle's `TRUNC` drops the time-of-day; `LAST_DAY` keeps it.

## 9.5 Determining All Dates for a Particular Weekday Throughout a Year
**Problem:** List every Friday (say) in the current year.
**Solution:** Generate every day of the year, keep the ones whose weekday matches.
```sql
-- Oracle: CONNECT BY LEVEL to generate the year, TO_CHAR to filter
WITH x AS (
  SELECT TRUNC(SYSDATE,'y') + LEVEL - 1 AS dy
    FROM t1
   CONNECT BY LEVEL <= ADD_MONTHS(TRUNC(SYSDATE,'y'),12) - TRUNC(SYSDATE,'y'))
SELECT * FROM x WHERE TO_CHAR(dy,'dy') = 'fri';

-- PostgreSQL: recursive CTE, EXTRACT(DOW) = 6 (Sunday=0)
WITH RECURSIVE cal (dy) AS (
  SELECT current_date - (CAST(EXTRACT(doy FROM current_date) AS int) - 1)
  UNION ALL
  SELECT dy + 1 FROM cal WHERE EXTRACT(year FROM dy) = EXTRACT(year FROM dy+1))
SELECT dy FROM cal WHERE CAST(EXTRACT(dow FROM dy) AS int) = 6;
```
DB2/SQL Server use a recursive `WITH` filtered by `DAYNAME`/`DATENAME(dw,...)` (SQL Server needs `OPTION (MAXRECURSION 400)`); MySQL uses a recursive CTE + `DAYOFWEEK(dy)=6`.
**Technique:** Two steps again: enumerate the year, then filter by weekday. Mind that weekday *numbering* differs (`DOW` Sunday=0 in PostgreSQL, `DAYOFWEEK` Sunday=1 in MySQL) — using the *name* (`'Friday'`/`'fri'`) avoids off-by-one errors.

## 9.6 Determining the Date of the First and Last Occurrences of a Specific Weekday in a Month
**Problem:** Find, e.g., the first and last Mondays of the current month.
**Solution:**
```sql
-- Oracle: NEXT_DAY does the heavy lifting
SELECT NEXT_DAY(TRUNC(SYSDATE,'mm') - 1, 'MONDAY')              AS first_monday,
       NEXT_DAY(LAST_DAY(TRUNC(SYSDATE,'mm')) - 7, 'MONDAY')    AS last_monday
  FROM dual;
```
DB2/SQL Server: recursive `WITH` over the month, flag Mondays with a `CASE`, take `MIN`/`MAX`. PostgreSQL/MySQL: arithmetic on the weekday number to step from the 1st of the month to its first Monday, then add 21 or 28 days for the last.
**Technique:** Oracle's `NEXT_DAY(d,'MONDAY')` returns the first Monday strictly after `d`; start from the last day of the prior month for the first Monday, and from `last_day − 7` for the last. The portable arithmetic form: with weekday numbers (Sun=1..Sat=7, Monday=2), the offset to the next Monday is computed by `CASE SIGN(dow − 2)`. Once you have the first occurrence, add 7/14/21 for the 2nd/3rd/4th, and choose +21 vs +28 for the last by testing whether +28 stays in the month.

## 9.7 Creating a Calendar
**Problem:** Produce a desk-calendar layout for the current month — seven weekday columns, one row per week.
**Solution:** Generate every day of the month tagged with its ISO week (`wk`), day-of-month (`dm`), and day-of-week (`dw`); then pivot with `MAX(CASE dw WHEN ...)` grouped by week.
```sql
-- Oracle (CONNECT BY generates the month; TO_CHAR 'iw'/'dd'/'d' supply wk/dm/dw)
WITH x AS (
  SELECT * FROM (
    SELECT TO_CHAR(TRUNC(SYSDATE,'mm')+LEVEL-1,'iw') wk,
           TO_CHAR(TRUNC(SYSDATE,'mm')+LEVEL-1,'dd') dm,
           TO_NUMBER(TO_CHAR(TRUNC(SYSDATE,'mm')+LEVEL-1,'d')) dw,
           TO_CHAR(TRUNC(SYSDATE,'mm')+LEVEL-1,'mm') curr_mth,
           TO_CHAR(SYSDATE,'mm') mth
      FROM dual CONNECT BY LEVEL <= 31)
   WHERE curr_mth = mth)
SELECT MAX(CASE dw WHEN 2 THEN dm END) Mo,
       MAX(CASE dw WHEN 3 THEN dm END) Tu,
       MAX(CASE dw WHEN 4 THEN dm END) We,
       MAX(CASE dw WHEN 5 THEN dm END) Th,
       MAX(CASE dw WHEN 6 THEN dm END) Fr,
       MAX(CASE dw WHEN 7 THEN dm END) Sa,
       MAX(CASE dw WHEN 1 THEN dm END) Su
  FROM x
 GROUP BY wk
 ORDER BY wk;
```
DB2/SQL Server/MySQL use a recursive `WITH` over the month (functions `WEEK_ISO`/`DAYOFWEEK`, or `DATEPART(ww,...)`/`DATEPART(dw,...)`); PostgreSQL uses `GENERATE_SERIES`.
**Technique:** This is a classic **pivot**: one row per day → seven columns per week. The ISO week number is the `GROUP BY` key (so each calendar row is a week); `MAX(CASE dw WHEN n THEN dm END)` drops each day-of-month into its weekday column (NULLs collapse under `MAX`). Re-order the `CASE` branches to switch between Mon–Sun and Sun–Sat layouts.

## 9.8 Listing Quarter Start and End Dates for the Year
**Problem:** Return the start and end date of each of the four quarters of a year.
**Solution:** Generate four rows, then offset the first day of the year by 3/6/9/12 months.
```sql
-- Oracle: ROWNUM gives quarter number; ADD_MONTHS builds the bounds
SELECT ROWNUM AS qtr,
       ADD_MONTHS(TRUNC(SYSDATE,'y'), (ROWNUM-1)*3)     AS q_start,
       ADD_MONTHS(TRUNC(SYSDATE,'y'),  ROWNUM*3) - 1    AS q_end
  FROM emp
 WHERE ROWNUM <= 4;

-- SQL Server: recursive CTE of 4 rows, DATEADD for the bounds
WITH x (dy, cnt) AS (
  SELECT DATEADD(d, -(DATEPART(dy,GETDATE())-1), GETDATE()), 1
  UNION ALL
  SELECT DATEADD(m,3,dy), cnt+1 FROM x WHERE cnt+1 <= 4)
SELECT DATEPART(q, DATEADD(d,-1,dy)) AS qtr,
       DATEADD(m,-3,dy) AS q_start,
       DATEADD(d,-1,dy) AS q_end
  FROM x ORDER BY 1;
```
DB2 uses `ROW_NUMBER() OVER () ... FETCH FIRST 4 ROWS`; PostgreSQL/MySQL use a recursive CTE.
**Technique:** Add `n*3` months to Jan 1 to get the day *after* each quarter's end; subtract 1 day for `q_end` and 3 months for `q_start`. `QUARTER()`/`DATEPART(q,...)` (applied to `q_end`) labels each row. The only portability wrinkle: PostgreSQL needs `CAST(... AS date)` after interval math so the recursive `UNION ALL` column types line up.

## 9.9 Determining Quarter Start and End Dates for a Given Quarter
**Problem:** Given `YYYYQ` (e.g., `20051`), return that quarter's start and end dates.
**Solution:** `MOD(yrq,10)` extracts the quarter; `*3` gives its ending month; build a date and adjust.
```sql
-- Oracle
SELECT ADD_MONTHS(q_end,-2) AS q_start,
       LAST_DAY(q_end)      AS q_end
  FROM (SELECT TO_DATE(SUBSTR(yrq,1,4) || MOD(yrq,10)*3, 'yyyymm') AS q_end
          FROM (SELECT 20051 yrq FROM dual UNION ALL
                SELECT 20052 FROM dual UNION ALL
                SELECT 20053 FROM dual UNION ALL
                SELECT 20054 FROM dual) x) y;
```
DB2/PostgreSQL/MySQL/SQL Server follow the same shape with their own substring/`MOD`(`%`)/date-build functions (`STR_TO_DATE`, `CAST`, `LAST_DAY`, or `+1 month -1 day`).
**Technique:** The year is the first four characters; the quarter is `yrq mod 10`. Multiply the quarter by 3 to get the **last month** of the quarter, build the first day of that month (`SUBSTR(year)||month` → date), then the last day of the quarter is `LAST_DAY` (or `+1 month -1 day`) and the start is `q_end_month - 2 months`.

## 9.10 Filling in Missing Dates
**Problem:** Produce a row for *every* month (or week/year) in a range even when no data exists — e.g., count hires per month from 2000–2003, showing 0 for empty months.
**Solution:** Generate all months in the range, then `LEFT JOIN` to the data and `COUNT`.
```sql
-- Oracle: CONNECT BY generates the months; outer join + COUNT
WITH x AS (
  SELECT ADD_MONTHS(start_date, LEVEL-1) AS start_date
    FROM (SELECT MIN(TRUNC(hiredate,'y'))           AS start_date,
                 ADD_MONTHS(MAX(TRUNC(hiredate,'y')),12) AS end_date
            FROM emp)
   CONNECT BY LEVEL <= MONTHS_BETWEEN(end_date, start_date))
SELECT x.start_date AS mth, COUNT(e.hiredate) AS num_hired
  FROM x LEFT JOIN emp e ON x.start_date = TRUNC(e.hiredate,'mm')
 GROUP BY x.start_date
 ORDER BY 1;
```
DB2/SQL Server/MySQL use a recursive `WITH` to build the months; PostgreSQL likewise (join on matching `EXTRACT(year)`/`EXTRACT(month)`).
**Technique:** The whole point is the **outer join**: real data alone has gaps, so you manufacture the complete axis (first-of-each-month from min to max) and `LEFT JOIN` to it. Critically, use `COUNT(e.hiredate)` (a column) not `COUNT(*)` — the column count returns 0 for unmatched (NULL) months, whereas `COUNT(*)` would return 1. Truncate `hiredate` to its first-of-month so it matches the generated axis.

## 9.11 Searching on Specific Units of Time
**Problem:** Find rows matching a month or weekday regardless of year — e.g., employees hired in February or December, or on a Tuesday.
**Solution:** Filter on the month-name / weekday-name function.
```sql
-- DB2, MySQL
SELECT ename FROM emp
 WHERE MONTHNAME(hiredate) IN ('February','December')
    OR DAYNAME(hiredate) = 'Tuesday';

-- Oracle, PostgreSQL (RTRIM removes the blank-padding TO_CHAR adds)
SELECT ename FROM emp
 WHERE RTRIM(TO_CHAR(hiredate,'month')) IN ('february','december')
    OR RTRIM(TO_CHAR(hiredate,'day')) = 'tuesday';

-- SQL Server
SELECT ename FROM emp
 WHERE DATENAME(m,hiredate) IN ('February','December')
    OR DATENAME(dw,hiredate) = 'Tuesday';
```
**Technique:** Extract just the part you care about (month name, weekday name) and compare. The only gotcha: Oracle/PostgreSQL `TO_CHAR(...,'month'/'day')` right-pads to a fixed width — `RTRIM` it before comparing. Put the function in the `SELECT` first to confirm exact return values/casing.

## 9.12 Comparing Records Using Specific Parts of a Date
**Problem:** Find employees hired on the same month *and* weekday as another employee.
**Solution:** Self-join EMP, compare the formatted date parts, and use `a.empno < b.empno` to avoid reciprocal duplicates.
```sql
-- Oracle, PostgreSQL
SELECT a.ename || ' was hired on the same month and weekday as ' || b.ename AS msg
  FROM emp a, emp b
 WHERE TO_CHAR(a.hiredate,'DMON') = TO_CHAR(b.hiredate,'DMON')
   AND a.empno < b.empno
 ORDER BY a.ename;
```
DB2 compares the tuple `(DAYOFWEEK(hiredate), MONTHNAME(hiredate))`; MySQL uses `DATE_FORMAT(hiredate,'%w%M')`; SQL Server compares `DATENAME(dw,...)` and `DATENAME(m,...)`.
**Technique:** Self-join gives every pair of employees. Format both hire dates to "weekday + month" and keep the matches. **Use `a.empno < b.empno`, not `!=`** — `!=` returns each pair twice (A–B and B–A); `<` keeps one of each and also excludes self-matches.

## 9.13 Identifying Overlapping Date Ranges
**Problem:** Find rows where one project starts before another (by the same employee) ends.
**Solution:** Self-join on employee; keep rows where one project's start falls within another's `[start, end]`.
```sql
-- DB2, PostgreSQL, Oracle
SELECT a.empno, a.ename,
       'project ' || b.proj_id || ' overlaps project ' || a.proj_id AS msg
  FROM emp_project a, emp_project b
 WHERE a.empno = b.empno
   AND b.proj_start >= a.proj_start
   AND b.proj_start <= a.proj_end
   AND a.proj_id != b.proj_id;
```
MySQL/SQL Server differ only in string concatenation (`CONCAT`, `+`).
**Technique:** Two ranges overlap when one's start lies inside the other (`b.proj_start BETWEEN a.proj_start AND a.proj_end`). The self-join on `empno` confines the comparison to one employee's projects. Oracle alternative: if the max projects per employee is bounded, replace the self-join with a chain of `LEAD(proj_start, n) OVER (PARTITION BY ename ORDER BY proj_start)` checks (avoids the self-join when it is more expensive than the sort).

---

# Chapter 10 — Working with Ranges

Everyday queries that search, generate, or manipulate ranges of consecutive values — the classic **gaps-and-islands** family. The toolkit is small and reusable: `LEAD`/`LAG` to peek at the neighbouring row, a `CASE`+running-`SUM` to assign group ids to "islands," outer joins to a generated axis to fill gaps, and recursive CTEs / `GENERATE_SERIES` to manufacture rows.

## 10.1 Locating a Range of Consecutive Values
**Problem:** Return rows that are part of a consecutive run — each row whose `proj_end` equals the next row's `proj_start`.
**Solution:** Use `LEAD` to bring the next row's start onto the current row, then keep matches.
```sql
SELECT proj_id, proj_start, proj_end
  FROM (SELECT proj_id, proj_start, proj_end,
               LEAD(proj_start) OVER (ORDER BY proj_id) AS next_proj_start
          FROM V) alias
 WHERE next_proj_start = proj_end;
```
**Technique:** `LEAD(proj_start) OVER (ORDER BY proj_id)` reads the following row's start without a self-join. Because window functions run *after* `WHERE`, the `LEAD` must live in an inline view — filtering first would compute `LEAD` over the already-filtered rows. If you also want the *last* row of each run included (its start matches the prior row's end), add `LAG(proj_end) OVER (...)` and keep rows where `proj_end = next_start OR proj_start = last_end`.

## 10.2 Finding Differences Between Rows in the Same Group or Partition
**Problem:** Show each employee's salary and the difference to the salary of the next employee hired *in the same department*; show `N/A` for the last per department.
**Solution:** `LEAD` partitioned by department.
```sql
WITH next_sal_tab (deptno, ename, sal, hiredate, next_sal) AS (
  SELECT deptno, ename, sal, hiredate,
         LEAD(sal) OVER (PARTITION BY deptno ORDER BY hiredate)
    FROM emp)
SELECT deptno, ename, sal, hiredate,
       COALESCE(CAST(sal - next_sal AS CHAR), 'N/A') AS diff
  FROM next_sal_tab;
```
**Technique:** `LEAD(sal) OVER (PARTITION BY deptno ORDER BY hiredate)` keeps the comparison inside each department; the last employee per department has a NULL `next_sal` → `COALESCE` to `'N/A'` (cast the numeric difference to a string so the literal fits the column). **Duplicate-`hiredate` trap (Oracle):** as in 8.7, `LEAD` does not skip ties — pass a computed distance `LEAD(sal, cnt-rn+1) OVER (...)` where `cnt = COUNT(*) OVER (PARTITION BY deptno, hiredate)` and `rn = ROW_NUMBER() OVER (PARTITION BY deptno, hiredate ORDER BY ...)` to jump past same-day rows.

## 10.3 Locating the Beginning and End of a Range of Consecutive Values
**Problem:** Collapse each island into one row showing its start and end (single, non-consecutive rows are their own island).
**Solution:** Flag where a new island begins (`LAG`), running-`SUM` the flags into a group id, then `MIN`/`MAX` per group.
```sql
SELECT proj_grp, MIN(proj_start), MAX(proj_end)
  FROM (
    SELECT proj_id, proj_start, proj_end,
           SUM(flag) OVER (ORDER BY proj_id) AS proj_grp
      FROM (
        SELECT proj_id, proj_start, proj_end,
               CASE WHEN LAG(proj_end) OVER (ORDER BY proj_id) = proj_start
                    THEN 0 ELSE 1 END AS flag
          FROM V) a1) a2
 GROUP BY proj_grp;
```
**Technique:** This is the canonical **islands** pattern. `LAG(proj_end)` compares each row to the prior row's end; a `CASE` emits `0` when the row continues the run and `1` when a new island starts. A running `SUM(flag) OVER (ORDER BY ...)` turns those flags into a stable group id (it increments only at island boundaries). Finally `MIN(start)`/`MAX(end)` per group give each island's extent.

## 10.4 Filling in Missing Values in a Range of Values
**Problem:** Count hires per year across a whole decade, returning 0 for years with no hires.
**Solution:** Generate every year in the range, then `LEFT JOIN` to the grouped counts.
```sql
-- Oracle
SELECT x.yr, COALESCE(cnt, 0) AS cnt
  FROM (SELECT EXTRACT(YEAR FROM MIN(hiredate) OVER ())
               - MOD(EXTRACT(YEAR FROM MIN(hiredate) OVER ()), 10)
               + ROWNUM - 1 AS yr
          FROM emp WHERE ROWNUM <= 10) x
  LEFT JOIN (SELECT TO_NUMBER(TO_CHAR(hiredate,'YYYY')) yr, COUNT(*) cnt
               FROM emp GROUP BY TO_NUMBER(TO_CHAR(hiredate,'YYYY'))) y
    ON x.yr = y.yr;
```
DB2/SQL Server use EMP itself (14 rows) as the pivot source with `ROW_NUMBER`/`TOP (10)`; PostgreSQL/MySQL use the 10-row `T10` table.
**Technique:** Same "generate-the-axis-then-outer-join" idea as 9.10, here for *years*. Build the decade start with `year_of_min_hire − MOD(year_of_min_hire,10)`, add `0..9` via a row-number/pivot, then `LEFT JOIN` the per-year counts and `COALESCE(cnt,0)`.

## 10.5 Generating Consecutive Numeric Values
**Problem:** Produce a "row source" of integers `1..n` on demand (a dynamic pivot table).
**Solution:**
```sql
-- DB2, SQL Server, PostgreSQL, MySQL: recursive CTE
WITH x (id) AS (
  SELECT 1
  UNION ALL
  SELECT id + 1 FROM x WHERE id + 1 <= 10)
SELECT * FROM x;

-- PostgreSQL: built-in generator (start, stop, optional step)
SELECT id FROM generate_series(1, 10) x(id);

-- Oracle: CONNECT BY LEVEL (or the MODEL clause)
SELECT LEVEL AS id FROM dual CONNECT BY LEVEL <= 10;
```
**Technique:** A dynamic row generator removes the need for a fixed pivot table that might be too small. The recursive CTE seeds `1` and increments until the bound; `GENERATE_SERIES(start, stop, step)` does it natively in PostgreSQL (arguments can be subqueries, e.g. `generate_series((SELECT MIN(deptno) FROM emp), (SELECT MAX(deptno) FROM emp), 5)`); Oracle's `CONNECT BY LEVEL <= n` against `dual` is the idiomatic equivalent. These generated numbers feed date sequences, string walking (Ch. 6), and pivots (Ch. 12).

---

# Chapter 11 — Advanced Searching

Searching operations that require a *different way of thinking*: pagination, skipping rows, top-n, ranking, peeking at neighbouring rows, and simple forecasts. Most of these lean on **window functions** — `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`/`LAG`, and `MIN`/`MAX OVER`. A constant reminder: SQL has no inherent "first/next/last," so you must impose order with `ORDER BY` (usually inside an `OVER` clause) before ranges mean anything.

## 11.1 Paginating Through a Result Set
**Problem:** Return rows 1–5, then 6–10, etc. (scroll through results a page at a time).
**Solution:** Number the rows with `ROW_NUMBER`, then filter the window in an inline view.
```sql
SELECT sal
  FROM (SELECT ROW_NUMBER() OVER (ORDER BY sal) AS rn, sal FROM emp) x
 WHERE rn BETWEEN 1 AND 5;     -- next page: BETWEEN 6 AND 10
```
**Technique:** `ROW_NUMBER() OVER (ORDER BY sal)` assigns 1..n; pick any contiguous window by changing the `BETWEEN`. The numbering must happen in a subquery because window functions run after `WHERE`. (Oracle pre-12c alternative: nest `ROWNUM` over an ordered subquery — two levels deep. Modern engines also offer `OFFSET ... FETCH`.)

## 11.2 Skipping n Rows from a Table
**Problem:** Return every other row (1st, 3rd, 5th, …).
**Solution:** Number the rows, then keep where `MOD(rn, 2) = 1`.
```sql
SELECT ename
  FROM (SELECT ROW_NUMBER() OVER (ORDER BY ename) rn, ename FROM emp) x
 WHERE MOD(rn, 2) = 1;         -- SQL Server: rn % 2 = 1
```
**Technique:** `ROW_NUMBER` gives a gap-free sequence (no ties); modulo arithmetic then selects every nth row. Change the divisor/remainder to skip differently (e.g. `MOD(rn,3)=0` for every third).

## 11.3 Incorporating OR Logic When Using Outer Joins
**Problem:** Return employees only for DEPTNOs 10 and 20 but *all* departments (incl. 30, 40) from DEPT.
**Solution:** Put the `OR`/filter in the `JOIN ... ON` clause, not the `WHERE`.
```sql
SELECT e.ename, d.deptno, d.dname, d.loc
  FROM dept d
  LEFT JOIN emp e
    ON d.deptno = e.deptno
   AND (e.deptno = 10 OR e.deptno = 20)
 ORDER BY 2;
-- equivalently, pre-filter EMP in an inline view, then outer join
```
**Technique:** A condition on the **null-producing (right) side** of an outer join belongs in `ON`, not `WHERE`. In `WHERE`, `e.deptno = 10` discards the unmatched DEPT rows (where `e.deptno` is NULL), silently turning the outer join back into an inner join. Moving the predicate to `ON` filters which EMP rows join while preserving every DEPT row.

## 11.4 Determining Which Rows Are Reciprocals
**Problem:** In a table of `(test1, test2)` scores, find pairs where one row's `(test1,test2)` is another's `(test2,test1)` — return each reciprocal once.
**Solution:** Self-join on the swapped columns, keep one of each pair.
```sql
SELECT DISTINCT v1.*
  FROM V v1, V v2
 WHERE v1.test1 = v2.test2
   AND v1.test2 = v2.test1
   AND v1.test1 <= v1.test2;
```
**Technique:** The self-join matches a row to its mirror. `DISTINCT` removes duplicates from repeated values; the final `v1.test1 <= v1.test2` keeps only one member of each reciprocal pair (and includes equal pairs like 20/20).

## 11.5 Selecting the Top n Records
**Problem:** Return the employees with the top five salaries.
**Solution:** Rank by descending salary and keep the top ranks.
```sql
SELECT ename, sal
  FROM (SELECT ename, sal, DENSE_RANK() OVER (ORDER BY sal DESC) dr FROM emp) x
 WHERE dr <= 5;
```
**Technique:** Choose the ranking function by tie policy: `DENSE_RANK` → five *distinct* salaries (ties count once; may return >5 rows); `ROW_NUMBER` → exactly five rows (ties broken arbitrarily); `RANK` → five with rank-number gaps after ties. This is the same idea as `FETCH FIRST 5 ROWS WITH TIES` where supported.

## 11.6 Finding Records with the Highest and Lowest Values
**Problem:** Return the employees with both the lowest and highest salary.
**Solution:** Expose `MIN`/`MAX OVER` on every row, then keep matches.
```sql
SELECT ename
  FROM (SELECT ename, sal,
               MIN(sal) OVER () min_sal,
               MAX(sal) OVER () max_sal
          FROM emp) x
 WHERE sal IN (min_sal, max_sal);
```
**Technique:** `MIN(sal) OVER ()` / `MAX(sal) OVER ()` with an empty `OVER ()` make the table-wide extremes available on each row without a subquery aggregate or join; filter `sal IN (min_sal, max_sal)`.

## 11.7 Investigating Future Rows
**Problem:** Find employees who earn less than the employee hired immediately after them.
**Solution:** `LEAD` to the next hire's salary, then compare.
```sql
SELECT ename, sal, hiredate
  FROM (SELECT ename, sal, hiredate,
               LEAD(sal) OVER (ORDER BY hiredate) AS next_sal
          FROM emp) alias
 WHERE sal < next_sal;
```
**Technique:** `LEAD(sal) OVER (ORDER BY hiredate)` reads the salary of the next-hired employee; keep rows where the current salary is smaller. **Duplicate-`hiredate` trap (Oracle):** pass a distance `LEAD(sal, cnt-rn+1)` (same `cnt`/`rn` construction as 8.7 / 10.2) to skip same-day hires.

## 11.8 Shifting Row Values
**Problem:** Show each salary with the next-higher and next-lower salary, wrapping at the ends.
**Solution:** `LEAD`/`LAG` ordered by salary, `COALESCE` the ends to the table extremes.
```sql
SELECT ename, sal,
       COALESCE(LEAD(sal) OVER (ORDER BY sal), MIN(sal) OVER ()) AS forward,
       COALESCE(LAG(sal)  OVER (ORDER BY sal), MAX(sal) OVER ()) AS rewind
  FROM emp;
```
**Technique:** `LEAD`/`LAG` (default offset 1) return the adjacent rows; the top row's `LEAD` and the bottom row's `LAG` are NULL, so `COALESCE` to `MIN OVER ()` / `MAX OVER ()` wraps around. `LEAD(sal, n)` / `LAG(sal, n)` jump n rows when you need a wider shift.

## 11.9 Ranking Results
**Problem:** Rank salaries, allowing ties.
**Solution:**
```sql
SELECT DENSE_RANK() OVER (ORDER BY sal) AS rnk, sal FROM emp;
```
**Technique:** Three ranking functions, three tie behaviours: `DENSE_RANK` (ties share a rank, *no gaps* — 1,2,2,3), `RANK` (ties share a rank, *gaps* follow — 1,2,2,4), `ROW_NUMBER` (no ties — 1,2,3,4). Pick by whether you want gaps and whether ties may share a number.

## 11.10 Suppressing Duplicates
**Problem:** List the distinct job types.
**Solution:** `DISTINCT` is simplest; `GROUP BY` and a windowed `ROW_NUMBER` also work.
```sql
SELECT DISTINCT job FROM emp;
-- or
SELECT job FROM emp GROUP BY job;
-- or (window-function variant)
SELECT job FROM (
  SELECT job, ROW_NUMBER() OVER (PARTITION BY job ORDER BY job) rn FROM emp) x
 WHERE rn = 1;
```
**Technique:** `DISTINCT` applies to the *entire* select list — adding a column changes what "distinct" means (distinct *pairs*). `GROUP BY` and `DISTINCT` are not interchangeable in general (GROUP BY enables aggregation). The `ROW_NUMBER` partitioned by `job`, keeping `rn = 1`, returns one row per group — handy when you also want a specific representative row.

## 11.11 Finding Knight Values
**Problem:** For each employee, also return the salary of the *last-hired* employee in their department (a value reached by "jumping" to another row, then across to its column — like a chess knight).
**Solution:**
```sql
-- DB2 / SQL Server: flag the latest-hire salary, then MAX OVER the flag
SELECT deptno, ename, sal, hiredate,
       MAX(latest_sal) OVER (PARTITION BY deptno) AS latest_sal
  FROM (SELECT deptno, ename, sal, hiredate,
               CASE WHEN hiredate = MAX(hiredate) OVER (PARTITION BY deptno)
                    THEN sal ELSE 0 END AS latest_sal
          FROM emp) x
 ORDER BY 1, 4 DESC;

-- Oracle: rank in one dimension (hiredate), aggregate over another (sal)
SELECT deptno, ename, sal, hiredate,
       MAX(sal) KEEP (DENSE_RANK LAST ORDER BY hiredate)
         OVER (PARTITION BY deptno) AS latest_sal
  FROM emp
 ORDER BY 1, 4 DESC;
```
**Technique:** You need to rank by one column (`hiredate`) but return a value from another (`sal`). Portable approach: a `CASE` tags the latest-hire's salary (0 otherwise), then `MAX(...) OVER (PARTITION BY deptno)` broadcasts the single non-zero value to every row in the department. Oracle's `MAX(sal) KEEP (DENSE_RANK LAST ORDER BY hiredate)` does the rank-here-aggregate-there in one expression, avoiding the extra subquery.

## 11.12 Generating Simple Forecasts
**Problem:** For each order, return three rows (the order plus two follow-up steps) with extra `verified`/`shipped` date columns.
**Solution:** Cartesian-product each row with a 3-row generator, then fill columns with `CASE`.
```sql
-- SQL Server / DB2 (recursive CTE generator); Oracle uses CONNECT BY, PostgreSQL GENERATE_SERIES
WITH nrows (n) AS (
  SELECT 1 FROM t1 UNION ALL SELECT n+1 FROM nrows WHERE n+1 <= 3)
SELECT id, order_date, process_date,
       CASE WHEN nrows.n >= 2 THEN process_date + 1 END AS verified,
       CASE WHEN nrows.n  = 3 THEN process_date + 2 END AS shipped
  FROM (SELECT nrows.n AS id,
               GETDATE() + nrows.n      AS order_date,
               GETDATE() + nrows.n + 2  AS process_date
          FROM nrows) orders, nrows
 ORDER BY 1;
```
**Technique:** A row generator (`nrows`, `CONNECT BY LEVEL <= 3`, or `GENERATE_SERIES(1,3)`) Cartesian-joined to the base set produces n copies of each row; `CASE` keyed on the generator value `n` populates the staged date columns (NULL until that stage applies). This "multiply rows then conditionally fill" pattern is the basis of many report-shaping queries (Ch. 12).

---

# Chapter 12 — Reporting and Reshaping

The "report writer's" chapter: turning rows into columns and back (pivot / unpivot), suppressing repeats, bucketing, histograms, subtotals (`ROLLUP` / `CUBE` / `GROUPING SETS`), sparse matrices, grouping by time, and moving-window aggregations. Two patterns recur constantly: **`CASE` inside an aggregate** (`MAX`/`SUM(CASE WHEN col=val THEN ... END)`) to transpose rows to columns, and **`ROW_NUMBER`** to manufacture the unique row keys that pivots need.

## 12.1 Pivoting a Result Set into One Row
**Problem:** Turn a per-group count into a single wide row — e.g. one row with a column per DEPTNO showing the employee count.
**Solution:** Sum a `CASE` per target column.
```sql
SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS deptno_10,
       SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS deptno_20,
       SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS deptno_30
  FROM emp;
-- DEPTNO_10 DEPTNO_20 DEPTNO_30
--         3         5         6
```
**Technique:** Each `CASE` emits 1 for its department and 0 otherwise; `SUM` collapses the column to its group total. With no `GROUP BY`, the whole table folds into one row. Swap `SUM(... 1 ...)` for `MAX(CASE WHEN ... THEN value END)` when transposing a *value* rather than a count.

## 12.2 Pivoting a Result Set into Multiple Rows
**Problem:** Put each employee's name under a column for their JOB, one employee per row-slot.
**Solution:** Manufacture a per-job row number, then `MAX(CASE …)` grouped by it.
```sql
SELECT MAX(CASE WHEN job='CLERK'     THEN ename END) AS clerks,
       MAX(CASE WHEN job='ANALYST'   THEN ename END) AS analysts,
       MAX(CASE WHEN job='MANAGER'   THEN ename END) AS mgrs,
       MAX(CASE WHEN job='PRESIDENT' THEN ename END) AS prez,
       MAX(CASE WHEN job='SALESMAN'  THEN ename END) AS sales
  FROM (SELECT job, ename,
               ROW_NUMBER() OVER (PARTITION BY job ORDER BY ename) rn
          FROM emp) x
 GROUP BY rn;
```
**Technique:** Without a row key, `MAX(CASE …)` would collapse every job to a single name. `ROW_NUMBER() OVER (PARTITION BY job ...)` numbers names 1..n *within* each job; grouping by that `rn` produces one output row per "slot," so all names survive. What you put in `GROUP BY` (and the non-aggregated select items) controls the report's shape.

## 12.3 Reverse Pivoting a Result Set
**Problem:** Turn columns back into rows — convert the wide `(deptno_10, deptno_20, deptno_30)` count row into `(deptno, counts_by_dept)` rows.
**Solution:** Cartesian-product the wide row with an N-row table, then pick the right column per row with `CASE`.
```sql
SELECT d.deptno,
       CASE d.deptno
            WHEN 10 THEN ec.deptno_10
            WHEN 20 THEN ec.deptno_20
            WHEN 30 THEN ec.deptno_30
       END AS counts_by_dept
  FROM emp_cnts ec
 CROSS JOIN (SELECT deptno FROM dept WHERE deptno <= 30) d;
```
**Technique:** Unpivoting needs *more* rows than you started with, so cross-join the single wide row to any table expression with cardinality ≥ the number of columns to unfold (here DEPT supplies the three DEPTNO values). The `CASE` keyed on `d.deptno` selects the matching column for each manufactured row. (SQL Server/Oracle also have native `UNPIVOT`; see Ch. 14.)

## 12.4 Reverse Pivoting into One Column
**Problem:** Stack each employee's ENAME, JOB, and SAL into a single column, with a blank line between employees.
**Solution:** Cross-join each row to a 4-row generator, then `CASE` on the generated number.
```sql
WITH four_rows (id) AS (
  SELECT 1 UNION ALL SELECT id+1 FROM four_rows WHERE id < 4),
x_tab (ename, job, sal, rn) AS (
  SELECT e.ename, e.job, e.sal,
         ROW_NUMBER() OVER (PARTITION BY e.empno ORDER BY e.empno)
    FROM emp e
    JOIN four_rows ON 1 = 1)            -- Cartesian product
SELECT CASE rn
            WHEN 1 THEN ename
            WHEN 2 THEN job
            WHEN 3 THEN CAST(sal AS CHAR(4))
            -- rn = 4 → NULL, the spacer line
       END AS emps
  FROM x_tab;
```
**Technique:** The Cartesian join makes four copies of each employee; `ROW_NUMBER` resets to 1..4 per employee (window functions run after FROM/WHERE), and the `CASE` routes column 1→name, 2→job, 3→salary, 4→blank. `CAST(sal ...)` keeps every `CASE` branch the same type. (`RECURSIVE` keyword required after `WITH` in Oracle, PostgreSQL, MySQL.)

## 12.5 Suppressing Repeating Values from a Result Set
**Problem:** Show DEPTNO only on the first row of each group (blank it on repeats), for a cleaner printed report.
**Solution:** `LAG` to the prior DEPTNO; blank the value when it matches.
```sql
SELECT CASE WHEN LAG(deptno) OVER (ORDER BY deptno) = deptno
            THEN NULL ELSE deptno END AS deptno,
       ename
  FROM emp;
-- Oracle alternative: TO_NUMBER(DECODE(LAG(deptno) OVER (ORDER BY deptno), deptno, NULL, deptno))
```
**Technique:** `LAG(deptno) OVER (ORDER BY deptno)` reads the previous row's department; when it equals the current value you're on a repeat, so emit NULL. The first row of each group has a different (or NULL) predecessor and keeps its value. This is purely cosmetic — order matters.

## 12.6 Pivoting a Result Set to Facilitate Inter-Row Calculations
**Problem:** Compute differences *between* groups (e.g. DEPTNO 20's total salary minus 10's, and minus 30's) — values that live in different rows.
**Solution:** Pivot the group totals into one row, then subtract columns.
```sql
SELECT d20_sal - d10_sal AS d20_10_diff,
       d20_sal - d30_sal AS d20_30_diff
  FROM (SELECT SUM(CASE WHEN deptno=10 THEN sal END) AS d10_sal,
               SUM(CASE WHEN deptno=20 THEN sal END) AS d20_sal,
               SUM(CASE WHEN deptno=30 THEN sal END) AS d30_sal
          FROM emp) totals_by_dept;
```
**Technique:** Inter-row arithmetic is awkward while the values are in separate rows. Pivot first (`SUM(CASE …)` puts each department's total in its own column of a single row), then the subtractions are ordinary column expressions. A CTE form reads the same and is often clearer.

## 12.7 Creating Buckets of Data, of a Fixed Size
**Problem:** Split rows into groups of exactly five (number of groups unknown).
**Solution:** Number the rows, divide by the bucket size, take the ceiling.
```sql
SELECT CEIL(ROW_NUMBER() OVER (ORDER BY empno) / 5.0) AS grp,  -- SQL Server: CEILING
       empno, ename
  FROM emp;
```
**Technique:** `ROW_NUMBER` gives 1..n; `/ 5.0` (float division) then `CEIL` maps rows 1–5→1, 6–10→2, etc. The last bucket simply holds the remainder. Change the divisor to change the fixed bucket size.

## 12.8 Creating a Predefined Number of Buckets
**Problem:** Distribute rows into a fixed number of buckets (e.g. 4), letting sizes differ by at most one.
**Solution:** `NTILE`.
```sql
SELECT NTILE(4) OVER (ORDER BY empno) AS grp, empno, ename
  FROM emp;
```
**Technique:** `NTILE(n)` splits the ordered set into `n` as-equal-as-possible buckets, putting any leftover rows into the lowest-numbered buckets first. This is the inverse of 12.7 (fixed *count* of buckets vs fixed *size*), and the natural first step before per-quartile aggregates.

## 12.9 Creating Horizontal Histograms
**Problem:** Draw a bar of `*` per group — e.g. one `*` per employee in each department.
**Solution:** `COUNT(*)` per group, fed to a string-repeat function.
```sql
-- DB2:             REPEAT('*', COUNT(*))
-- Oracle/PG/MySQL: LPAD('*', COUNT(*), '*')   (PostgreSQL: cast COUNT(*)::integer)
-- SQL Server:      REPLICATE('*', COUNT(*))
SELECT deptno, LPAD('*', COUNT(*), '*') AS cnt
  FROM emp
 GROUP BY deptno;
```
**Technique:** Identical logic everywhere; only the repeat function's name differs by vendor. `COUNT(*)` per `GROUP BY deptno` gives the bar length; the string function turns the number into that many asterisks.

## 12.10 Creating Vertical Histograms
**Problem:** Draw bars that grow from the bottom up — a `*` column per department.
**Solution:** One `*` per employee tagged into its department column, keyed by `ROW_NUMBER`, then `MAX(CASE …)` grouped by that key, ordered descending.
```sql
SELECT MAX(deptno_10) d10, MAX(deptno_20) d20, MAX(deptno_30) d30
  FROM (SELECT ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY empno) rn,
               CASE WHEN deptno=10 THEN '*' END deptno_10,
               CASE WHEN deptno=20 THEN '*' END deptno_20,
               CASE WHEN deptno=30 THEN '*' END deptno_30
          FROM emp) x
 GROUP BY rn
 ORDER BY 1 DESC, 2 DESC, 3 DESC;   -- SQL Server: omit DESC (NULL sort differs)
```
**Technique:** Same transpose engine as 12.2 — `ROW_NUMBER` per department gives each `*` a slot, `MAX(CASE …)` groups them into columns. The `ORDER BY ... DESC` pushes the asterisks to the bottom so the bars appear to rise; adjust direction to match how your engine sorts NULLs.

## 12.11 Returning Non-GROUP BY Columns
**Problem:** Find the highest- and lowest-paid employees per department *and* per job, returning each employee's name/dept/job/salary — columns a plain `GROUP BY` would forbid.
**Solution:** Compute the extremes with `MIN`/`MAX OVER` partitions (which keep every row), then filter.
```sql
SELECT deptno, ename, job, sal,
       CASE WHEN sal = max_by_dept THEN 'TOP SAL IN DEPT'
            WHEN sal = min_by_dept THEN 'LOW SAL IN DEPT' END AS dept_status,
       CASE WHEN sal = max_by_job  THEN 'TOP SAL IN JOB'
            WHEN sal = min_by_job  THEN 'LOW SAL IN JOB'  END AS job_status
  FROM (SELECT deptno, ename, job, sal,
               MAX(sal) OVER (PARTITION BY deptno) max_by_dept,
               MAX(sal) OVER (PARTITION BY job)    max_by_job,
               MIN(sal) OVER (PARTITION BY deptno) min_by_dept,
               MIN(sal) OVER (PARTITION BY job)    min_by_job
          FROM emp) x
 WHERE sal IN (max_by_dept, max_by_job, min_by_dept, min_by_job);
```
**Technique:** Aggregate window functions (`MAX/MIN OVER (PARTITION BY …)`) compute per-group extremes *without* collapsing rows, so non-grouped columns like ENAME remain available. Filter to rows whose salary equals one of the four extremes, then label them with `CASE`. This sidesteps the classic "column not in GROUP BY" error.

## 12.12 Calculating Simple Subtotals
**Problem:** Sum salaries by JOB and add a grand-total row.
**Solution:** `GROUP BY ROLLUP`, with `GROUPING` (or `COALESCE`) to label the total row.
```sql
-- DB2 / Oracle / PostgreSQL
SELECT CASE GROUPING(job) WHEN 0 THEN job ELSE 'TOTAL' END AS job,
       SUM(sal) AS sal
  FROM emp
 GROUP BY ROLLUP(job);

-- SQL Server / MySQL
SELECT COALESCE(job, 'TOTAL') AS job, SUM(sal) AS sal
  FROM emp
 GROUP BY job WITH ROLLUP;
```
**Technique:** `ROLLUP(job)` adds a super-aggregate (grand-total) row on top of the per-JOB sums. On that extra row JOB is NULL; `GROUPING(job)` returns 1 there (0 on normal rows), letting `CASE`/`COALESCE` print "TOTAL" instead of NULL. Syntax differs (`ROLLUP(col)` vs `... WITH ROLLUP`) but the mechanism is the same.

## 12.13 Calculating Subtotals for All Possible Expression Combinations
**Problem:** Produce salary totals by DEPTNO *and* JOB, by JOB alone, by DEPTNO alone, and a grand total — every combination.
**Solution:** `GROUP BY CUBE` (or `GROUPING SETS`), labelled with `GROUPING`.
```sql
-- Oracle / DB2 / SQL Server / PostgreSQL (cast GROUPING to CHAR(1) in DB2/SQL Server; + concat in SQL Server)
SELECT deptno, job,
       CASE GROUPING(deptno) || GROUPING(job)
            WHEN '00' THEN 'TOTAL BY DEPT AND JOB'
            WHEN '10' THEN 'TOTAL BY JOB'
            WHEN '01' THEN 'TOTAL BY DEPT'
            WHEN '11' THEN 'GRAND TOTAL FOR TABLE'
       END AS category,
       SUM(sal) AS sal
  FROM emp
 GROUP BY CUBE(deptno, job)
 ORDER BY GROUPING(job), GROUPING(deptno);

-- Oracle / DB2: GROUPING SETS lets you pick exactly which aggregations to emit
GROUP BY GROUPING SETS ((deptno), (job), (deptno, job), ())   -- () = grand total

-- MySQL (no CUBE): UNION ALL one query per aggregation level
```
**Technique:** `CUBE(a, b)` generates *all* `2^n` grouping combinations: `(a,b)`, `(a)`, `(b)`, and `()`. On super-aggregate rows the rolled-up column is NULL; `GROUPING(col)` returns 1 there, so concatenating `GROUPING(deptno)||GROUPING(job)` yields a two-bit code (`00`/`01`/`10`/`11`) that a `CASE` maps to a label. `GROUPING SETS` is the surgical alternative — you list precisely the combinations you want (drop `()` to omit the grand total, drop `(deptno)` to omit per-department subtotals). MySQL lacks `CUBE`, so emulate each level with `UNION ALL` and NULL placeholders.

## 12.14 Identifying Rows That Are Not Subtotals
**Problem:** In a `CUBE`/`ROLLUP` report, flag which rows are real detail rows vs generated subtotals.
**Solution:** Expose `GROUPING` per column.
```sql
SELECT deptno, job, SUM(sal) AS sal,
       GROUPING(deptno) AS deptno_subtotals,
       GROUPING(job)    AS job_subtotals
  FROM emp
 GROUP BY CUBE(deptno, job);   -- SQL Server: GROUP BY deptno, job WITH CUBE
```
**Technique:** `GROUPING(col)` = 1 means "this column was rolled up for this row" (the value is NULL because it's a super-aggregate), 0 means it's a genuine grouping value. So `(0,0)` = detail row (a real DEPTNO/JOB combination), `(0,1)` = subtotal by DEPTNO, `(1,0)` = subtotal by JOB, `(1,1)` = grand total. This is the building block 12.13 used for labelling. (MySQL supports neither `CUBE` nor `GROUPING` here.)

## 12.15 Using Case Expressions to Flag Rows
**Problem:** Map each JOB value to a set of Boolean (0/1) indicator columns.
**Solution:** One `CASE` per target flag.
```sql
SELECT ename,
       CASE WHEN job='CLERK'     THEN 1 ELSE 0 END AS is_clerk,
       CASE WHEN job='SALESMAN'  THEN 1 ELSE 0 END AS is_sales,
       CASE WHEN job='MANAGER'   THEN 1 ELSE 0 END AS is_mgr,
       CASE WHEN job='ANALYST'   THEN 1 ELSE 0 END AS is_analyst,
       CASE WHEN job='PRESIDENT' THEN 1 ELSE 0 END AS is_prez
  FROM emp
 ORDER BY 2,3,4,5,6;
```
**Technique:** Each `CASE` tests one category and emits 1/0 — a one-hot encoding of the JOB column. Useful for debugging, building feature matrices, or feeding downstream tools that expect indicator variables. (Contrast with 12.1, where `SUM(CASE …)` would *aggregate* these flags into counts.)

## 12.16 Creating a Sparse Matrix
**Problem:** Transpose DEPTNO and JOB into columns, leaving NULLs where a row doesn't apply (a literal sparse cross-tab).
**Solution:** A bare `CASE` per target column (no aggregate) keeps every row sparse.
```sql
SELECT CASE deptno WHEN 10 THEN ename END AS d10,
       CASE deptno WHEN 20 THEN ename END AS d20,
       CASE deptno WHEN 30 THEN ename END AS d30,
       CASE job WHEN 'CLERK'     THEN ename END AS clerks,
       CASE job WHEN 'MANAGER'   THEN ename END AS mgrs,
       CASE job WHEN 'PRESIDENT' THEN ename END AS prez,
       CASE job WHEN 'ANALYST'   THEN ename END AS anals,
       CASE job WHEN 'SALESMAN'  THEN ename END AS sales
  FROM emp;
```
**Technique:** Without an aggregate or `GROUP BY`, each input row stays its own output row — the `CASE`s scatter each name into exactly the columns that match, leaving NULLs elsewhere (a sparse matrix). To "densify" (squeeze out NULL rows), wrap in `MAX(CASE …)` grouped by a per-DEPTNO `ROW_NUMBER`, exactly as in 12.2 / 12.10.

## 12.17 Grouping Rows by Units of Time
**Problem:** Summarize a transaction log into fixed buckets — e.g. totals per five-row (five-second) interval.
**Solution:** Derive a bucket id by dividing an id/seconds value, then aggregate per bucket.
```sql
SELECT CEIL(trx_id / 5.0) AS grp,        -- SQL Server: CEILING
       MIN(trx_date) AS trx_start,
       MAX(trx_date) AS trx_end,
       SUM(trx_cnt)  AS total
  FROM trx_log
 GROUP BY CEIL(trx_id / 5.0);
```
When there is no clean sequential id, bucket on the time itself, e.g. Oracle `CEIL(TO_NUMBER(TO_CHAR(trx_date,'miss'))/5.0)` and group by hour + bucket.
**Technique:** The same `CEIL(n/size)` bucketing as 12.7, applied to a time-ordered key, turns rows into time windows; `MIN`/`MAX`/`SUM` then summarize each window. A windowed variant `SUM(trx_cnt) OVER (PARTITION BY CEIL(trx_id/5.0) ORDER BY trx_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` gives a running total within each bucket while keeping detail rows.

## 12.18 Performing Aggregations over Different Groups/Partitions Simultaneously
**Problem:** On every employee row, show the count for their department, the count for their job, and the table-wide count — three different aggregations at once.
**Solution:** Multiple `COUNT(*) OVER` with different partitions.
```sql
SELECT ename,
       deptno, COUNT(*) OVER (PARTITION BY deptno) AS deptno_cnt,
       job,    COUNT(*) OVER (PARTITION BY job)    AS job_cnt,
               COUNT(*) OVER ()                    AS total
  FROM emp;
```
**Technique:** Each `OVER` clause defines its *own* partitioning, so one pass produces department-level, job-level, and whole-table (`OVER ()` = entire result) counts side by side — no self-joins or correlated subqueries. Remember window functions run *after* `WHERE`: filter first if you want the counts computed over the filtered set, or wrap in an inline view to filter *after* the counts are fixed.

## 12.19 Performing Aggregations over a Moving Range of Values
**Problem:** Compute a 90-day moving salary sum ordered by hire date (each row sums everyone hired in the preceding 90 days, inclusive).
**Solution:** A range-framed `SUM OVER`; fall back to a correlated scalar subquery where range-by-interval isn't supported.
```sql
-- Oracle (date ranges allowed directly)
SELECT hiredate, sal,
       SUM(sal) OVER (ORDER BY hiredate
                      RANGE BETWEEN 90 PRECEDING AND CURRENT ROW) AS spending_pattern
  FROM emp;

-- DB2: ORDER BY DAYS(hiredate) (DB2 won't range-by-number over a DATE directly)
-- MySQL: RANGE INTERVAL 90 DAY PRECEDING
-- PostgreSQL / SQL Server: correlated scalar subquery
SELECT e.hiredate, e.sal,
       (SELECT SUM(sal) FROM emp d
         WHERE d.hiredate BETWEEN e.hiredate - 90 AND e.hiredate) AS spending_pattern
  FROM emp e
 ORDER BY 1;
```
**Technique:** A **value-based frame** `RANGE BETWEEN 90 PRECEDING AND CURRENT ROW` sums all rows whose ordering value lies within 90 (days) of the current row — distinct from a **row-based frame** (`ROWS BETWEEN n PRECEDING …`), which counts physical rows. Vendor support for ranging over dates/intervals varies (Oracle direct; DB2 via `DAYS()`; MySQL via `INTERVAL`); where it's unavailable, a correlated subquery filtering `BETWEEN hiredate-90 AND hiredate` reproduces the same window.

## 12.20 Pivoting a Result Set with Subtotals
**Problem:** Build a manager-by-department salary matrix that also carries `ROLLUP` subtotals (per-department totals and a grand total) into the pivoted, readable report.
**Solution:** `ROLLUP` first to make the subtotals, tag them with `GROUPING`, then pivot with `SUM(CASE …)`.
```sql
SELECT mgr,
       SUM(CASE deptno WHEN 10 THEN sal ELSE 0 END) AS dept10,
       SUM(CASE deptno WHEN 20 THEN sal ELSE 0 END) AS dept20,
       SUM(CASE deptno WHEN 30 THEN sal ELSE 0 END) AS dept30,
       SUM(CASE flag WHEN '11' THEN sal END) AS total       -- '11' = grand-total row
  FROM (SELECT deptno, mgr, SUM(sal) AS sal,
               CAST(GROUPING(deptno) AS CHAR(1)) || CAST(GROUPING(mgr) AS CHAR(1)) AS flag
          FROM emp
         WHERE mgr IS NOT NULL
         GROUP BY ROLLUP(deptno, mgr)) x       -- SQL Server/MySQL: GROUP BY deptno,mgr WITH ROLLUP
 GROUP BY mgr
 ORDER BY COALESCE(mgr, 9999);
```
Concatenation/`GROUPING` syntax follows the vendor rules from 12.13 (`||` vs `+` vs `CONCAT`).
**Technique:** This composes two earlier recipes. The inner query uses `ROLLUP(deptno, mgr)` to produce detail rows *plus* per-department and grand-total super-aggregates; `GROUPING(deptno)||GROUPING(mgr)` stamps each row's level as a two-bit `flag`. The outer query then does a standard `SUM(CASE deptno …)` pivot into one column per department, and `SUM(CASE flag WHEN '11' …)` lifts only the grand-total value into the `TOTAL` column. Reshaping subtotalled data is just "make the subtotals, label them, then pivot."

---

# Chapter 13 — Hierarchical Queries

Parent-child data (an employee's `MGR` points at another employee's `EMPNO`) is easy to store but harder to *retrieve* as a tree. The portable engine is the **recursive CTE** (`WITH RECURSIVE`), now in all five databases; Oracle additionally offers `CONNECT BY` with `SYS_CONNECT_BY_PATH`, `LEVEL`, `CONNECT_BY_ISLEAF`, and `CONNECT_BY_ROOT`. The mental model: an **anchor** member picks the starting node(s), and a **recursive** member repeatedly joins the working set back to the table to walk up or down one level at a time.

## 13.1 Expressing a Parent-Child Relationship
**Problem:** Show each employee with their manager's name ("FORD works for JONES").
**Solution:** Self-join EMP on `mgr = empno`.
```sql
-- DB2 / Oracle / PostgreSQL ( || ); MySQL CONCAT(...); SQL Server ( + )
SELECT a.ename || ' works for ' || b.ename AS emps_and_mgrs
  FROM emp a, emp b
 WHERE a.mgr = b.empno;
```
**Technique:** A single self-join resolves one level of hierarchy: alias `a` is the child, `b` the parent, joined on `a.mgr = b.empno`. **Note KING (no manager) drops out** of the equi-join because `a.mgr` is NULL and NULL never equals anything — use a `LEFT JOIN` (or a scalar subquery `(SELECT b.ename FROM emp b WHERE b.empno = a.mgr)`) to keep the root row. One self-join only reaches *immediate* parents; deeper trees need recursion (13.2+).

## 13.2 Expressing a Child-Parent-Grandparent Relationship
**Problem:** Walk the full chain from a leaf up to the root — "MILLER-->CLARK-->KING".
**Solution:** Recursive CTE climbing `mgr → empno` (Oracle: `CONNECT BY` + `SYS_CONNECT_BY_PATH`).
```sql
-- DB2 / SQL Server / PostgreSQL / MySQL (MySQL & PostgreSQL: WITH RECURSIVE)
WITH x (tree, mgr, depth) AS (
  SELECT CAST(ename AS VARCHAR(100)), mgr, 0          -- anchor: the leaf
    FROM emp WHERE ename = 'MILLER'
  UNION ALL
  SELECT CAST(x.tree || '-->' || e.ename AS VARCHAR(100)), e.mgr, x.depth + 1
    FROM emp e, x
   WHERE x.mgr = e.empno)                             -- recurse: find this row's manager
SELECT tree AS leaf___branch___root
  FROM x
 WHERE depth = 2;

-- Oracle
SELECT LTRIM(SYS_CONNECT_BY_PATH(ename, '-->'), '-->') AS leaf___branch___root
  FROM emp
 WHERE LEVEL = 3
 START WITH ename = 'MILLER'
 CONNECT BY PRIOR mgr = empno;
```
**Technique:** The anchor selects MILLER with `depth = 0`; each recursive step joins the working row's `mgr` to the next employee's `empno`, concatenating the name and incrementing `depth`. Filtering `depth = 2` (or Oracle `LEVEL = 3`) keeps only the fully-walked row. In `CONNECT BY`, `PRIOR mgr = empno` expresses the parent join and `SYS_CONNECT_BY_PATH` builds the breadcrumb string (`LTRIM` strips the leading separator). The depth filter is hard-coded here; 13.4 shows a filter-free generic walk.

## 13.3 Creating a Hierarchical View of a Table
**Problem:** Render the *whole* org chart from the root down — every path "KING", "KING - BLAKE", "KING - BLAKE - ALLEN", …
**Solution:** Recursive CTE anchored at the root (`mgr IS NULL`), descending `empno → mgr`.
```sql
-- DB2 / PostgreSQL / SQL Server / MySQL (MySQL/PostgreSQL: WITH RECURSIVE; concat per vendor)
WITH x (ename, empno) AS (
  SELECT CAST(ename AS VARCHAR(100)), empno
    FROM emp WHERE mgr IS NULL                         -- anchor: the root (KING)
  UNION ALL
  SELECT CAST(x.ename || ' - ' || e.ename AS VARCHAR(100)), e.empno
    FROM emp e, x
   WHERE e.mgr = x.empno)                              -- recurse: find this node's children
SELECT ename AS emp_tree
  FROM x
 ORDER BY 1;

-- Oracle
SELECT LTRIM(SYS_CONNECT_BY_PATH(ename, ' - '), ' - ') AS emp_tree
  FROM emp
 START WITH mgr IS NULL
 CONNECT BY PRIOR empno = mgr
 ORDER BY 1;
```
**Technique:** This reverses 13.2's direction — anchor at the root (`mgr IS NULL`) and recurse *downward* via `e.mgr = x.empno`, accumulating the path string as you go. With no `LEVEL`/`depth` filter, *every* node is emitted with its full path from the root, so the query adapts automatically as the tree grows or reshapes. (Oracle aside: `LPAD('.', 2*LEVEL, '.') || ename` indents the tree visually; `SYS_CONNECT_BY_PATH` instead rolls the ancestors into each row.)

## 13.4 Finding All Child Rows for a Given Parent Row
**Problem:** Return everyone who works under JONES — directly or indirectly — including JONES.
**Solution:** Recursive CTE anchored at JONES, descending the tree (Oracle: `START WITH` + `CONNECT BY`).
```sql
-- DB2 / PostgreSQL / SQL Server / MySQL (MySQL/PostgreSQL: WITH RECURSIVE)
WITH x (ename, empno) AS (
  SELECT ename, empno FROM emp WHERE ename = 'JONES'   -- anchor
  UNION ALL
  SELECT e.ename, e.empno
    FROM emp e, x
   WHERE x.empno = e.mgr)                               -- recurse downward
SELECT ename FROM x;

-- Oracle
SELECT ename
  FROM emp
 START WITH ename = 'JONES'
 CONNECT BY PRIOR empno = mgr;
```
**Technique:** Anchoring at a *non-root* node and recursing `x.empno = e.mgr` returns the entire subtree beneath it — the recursion stops naturally when no more children are found. This "jump to any node, then collect its whole subtree" pattern (and its mirror, collecting all ancestors with `x.mgr = e.empno`) is the workhorse for org-chart, bill-of-materials, and folder-tree queries.

## 13.5 Determining Which Rows Are Leaf, Branch, or Root Nodes
**Problem:** Label each employee as leaf (manages no one), branch (manages someone *and* has a manager), or root (has no manager) with 0/1 flags.
**Solution:** Three existence tests; Oracle 10g+ has built-in `CONNECT_BY_ISLEAF` / `CONNECT_BY_ROOT`.
```sql
-- DB2 / PostgreSQL / MySQL / SQL Server
SELECT e.ename,
       (SELECT SIGN(COUNT(*)) FROM emp d
         WHERE 0 = (SELECT COUNT(*) FROM emp f WHERE f.mgr = e.empno)) AS is_leaf,
       (SELECT SIGN(COUNT(*)) FROM emp d
         WHERE d.mgr = e.empno AND e.mgr IS NOT NULL)                  AS is_branch,
       (SELECT SIGN(COUNT(*)) FROM emp d
         WHERE d.empno = e.empno AND d.mgr IS NULL)                    AS is_root
  FROM emp e
 ORDER BY 4 DESC, 3 DESC;

-- Oracle (10g+)
SELECT ename,
       CONNECT_BY_ISLEAF AS is_leaf,
       (SELECT COUNT(*) FROM emp e
         WHERE e.mgr = emp.empno AND emp.mgr IS NOT NULL AND ROWNUM = 1) AS is_branch,
       DECODE(ename, CONNECT_BY_ROOT(ename), 1, 0) AS is_root
  FROM emp
 START WITH mgr IS NULL
 CONNECT BY PRIOR empno = mgr;
```
**Technique:** Each node type is an existence question: *leaf* = nobody has this row as their `mgr`; *branch* = someone does **and** this row itself has a `mgr`; *root* = `mgr IS NULL`. `SIGN(COUNT(*))` squashes the count to 0/1 (or count against a one-row table like `T1`). Oracle's `CONNECT_BY_ISLEAF` (1 on leaves) and `CONNECT_BY_ROOT(col)` (returns the root's value for the current branch, so comparing it to `ename` flags the root) do leaf/root detection natively, but require a `CONNECT BY` query. **Modelling note:** EMP uses NULL `mgr` for the root (a *tree* hierarchy); a *recursive* hierarchy (root points at itself) risks infinite loops in `CONNECT BY`/recursive CTEs and needs explicit cycle handling.

---

# Chapter 14 — Odds 'n' Ends

A grab-bag of queries that didn't fit elsewhere — some genuinely useful (SQL Server `PIVOT`/`UNPIVOT`, parsing serialized strings, set-membership tests), some more playful (Oracle `MODEL`, decimal→binary). Several recipes are intentionally vendor-specific to showcase a proprietary feature; where a portable equivalent exists it's the `CASE`/`SUM` pivot or the recursive CTE you've already seen.

## 14.1 Creating Cross-Tab Reports Using SQL Server's PIVOT Operator
**Problem:** Transpose rows to columns (employee counts per department) without `CASE` expressions or joins.
**Solution:** SQL Server's `PIVOT` operator.
```sql
SELECT [10] AS dept_10, [20] AS dept_20, [30] AS dept_30, [40] AS dept_40
  FROM (SELECT deptno, empno FROM emp) driver
 PIVOT (COUNT(driver.empno)
        FOR driver.deptno IN ([10],[20],[30],[40])) AS empPivot;
```
**Technique:** `PIVOT` is syntactic sugar for the classic `SUM(CASE deptno WHEN n THEN 1 ELSE 0 END)` transpose. The inline view ("driver") supplies the rows; the `FOR ... IN (...)` list names both the values to aggregate over *and* the output column names (bracketed values become columns). Because the driver is an ordinary table expression, you can join EMP→DEPT inside it to pivot on department *names* instead of numbers.

## 14.2 Unpivoting a Cross-Tab Report Using SQL Server's UNPIVOT Operator
**Problem:** Reverse a pivot — turn the one-row, four-column cross-tab back into four `(dname, cnt)` rows.
**Solution:** SQL Server's `UNPIVOT` operator, fed by the pivoted result.
```sql
SELECT dname, cnt
  FROM (/* the PIVOT query from 14.1, aliased new_driver */) new_driver
 UNPIVOT (cnt FOR dname IN (ACCOUNTING, SALES, RESEARCH, OPERATIONS)) AS un_pivot;
```
**Technique:** `UNPIVOT` rotates columns back into rows: each column name in the `FOR ... IN (...)` list becomes a value in the `dname` column, and that column's value becomes `cnt`. It's the inverse of 14.1 — note unpivoting is not perfectly lossless (NULLs and the original row grouping aren't necessarily recoverable). The portable equivalent is the cross-join-and-`CASE` unpivot from 12.3.

## 14.3 Transposing a Result Set Using Oracle's MODEL Clause
**Problem:** Pivot department counts into columns using Oracle's `MODEL` clause (as an exercise — not its intended use).
**Solution:**
```sql
SELECT MAX(d10) d10, MAX(d20) d20, MAX(d30) d30
  FROM (
    SELECT d10, d20, d30
      FROM (SELECT deptno, COUNT(*) cnt FROM emp GROUP BY deptno)
     MODEL
       DIMENSION BY (deptno d)
       MEASURES (deptno, cnt d10, cnt d20, cnt d30)
       RULES (
         d10[ANY] = CASE WHEN deptno[CV()]=10 THEN d10[CV()] ELSE 0 END,
         d20[ANY] = CASE WHEN deptno[CV()]=20 THEN d20[CV()] ELSE 0 END,
         d30[ANY] = CASE WHEN deptno[CV()]=30 THEN d30[CV()] ELSE 0 END));
```
**Technique:** `MODEL` treats columns as **arrays** indexed by the `DIMENSION BY` key: `MEASURES` declares arrays (`d10`/`d20`/`d30`, all aliases of `cnt`), and `RULES` rewrite cells — `CV()` ("current value") is the dimension value of the cell being computed, so each rule keeps `cnt` only in its own department's array and zeroes the rest. `MAX` then collapses the now-diagonal arrays into one row. This is a deliberate misuse to learn the syntax; for real pivoting prefer `CASE`/`SUM` or `PIVOT`. `MODEL`'s real strengths are spreadsheet-like inter-row formulas, iteration, and upserting cells.

## 14.4 Extracting Elements of a String from Unfixed Locations
**Problem:** Pull the three values enclosed in `[...]` out of a serialized log string, where their positions vary.
**Solution:** Oracle `INSTR` (with occurrence/negative args) to locate the brackets, `SUBSTR` to slice between them.
```sql
SELECT SUBSTR(msg, INSTR(msg,'[',1,1)+1, INSTR(msg,']',1,1)-INSTR(msg,'[',1,1)-1) AS first_val,
       SUBSTR(msg, INSTR(msg,'[',1,2)+1, INSTR(msg,']',1,2)-INSTR(msg,'[',1,2)-1) AS second_val,
       SUBSTR(msg, INSTR(msg,'[',-1,1)+1, INSTR(msg,']',-1,1)-INSTR(msg,'[',-1,1)-1) AS last_val
  FROM V;
```
**Technique:** `INSTR(str, sub, pos, occurrence)` finds the *nth* occurrence of a delimiter; a **negative** `pos` (`INSTR(msg,'[',-1,1)`) searches from the end, neatly grabbing the *last* bracket pair. The slice length is `close − open − 1`, and `+1` on the start index skips the opening `[` — the `±1` arithmetic is what excludes both brackets. The same idea works elsewhere with each engine's `INSTR`/`CHARINDEX`/`POSITION` + `SUBSTR`/`SUBSTRING`, or with regex (`REGEXP_SUBSTR`) where available.

## 14.5 Finding the Number of Days in a Year (Alternate Oracle Solution)
**Problem:** Count the days in a given year (Oracle-specific alternative to the Ch. 9 recipe).
**Solution:** Format the last day of the year as its day-of-year ordinal (`DDD`).
```sql
SELECT TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE,'y'), 12) - 1, 'DDD') AS days_in_year
  FROM dual;     -- 365, or 366 in a leap year
```
**Technique:** `TRUNC(date,'y')` snaps to Jan 1; `ADD_MONTHS(..., 12) - 1` lands on Dec 31; `TO_CHAR(..., 'DDD')` returns that date's day-of-year number — which *is* the day count for the year. A compact alternative to subtracting the two year-boundary dates (see Ch. 9's portable version).

## 14.6 Searching for Mixed Alphanumeric Strings
**Problem:** Keep only strings that contain **both** letters and digits (reject all-letter or all-digit values).
**Solution:** `TRANSLATE` letters→`#` and digits→`*`, then require at least one of each.
```sql
SELECT strings
  FROM (SELECT strings,
               TRANSLATE(strings,
                 'abcdefghijklmnopqrstuvwxyz0123456789',
                 RPAD('#',26,'#') || RPAD('*',10,'*')) AS translated
          FROM v) x
 WHERE INSTR(translated,'#') > 0      -- has at least one letter
   AND INSTR(translated,'*') > 0;     -- has at least one digit
```
**Technique:** `TRANSLATE` maps each character class to a single marker (`#` for any letter, `*` for any digit), reducing "does it contain a letter and a digit?" to two cheap `INSTR(...) > 0` checks. `TRANSLATE` (available in Oracle, DB2, PostgreSQL) is the portable workhorse for character-class tests when you'd rather not reach for regular expressions; in MySQL/SQL Server use regex or nested `REPLACE`.

## 14.7 Converting Whole Numbers to Binary Using Oracle
**Problem:** Render an integer (e.g. each salary) as its binary string.
**Solution:** Oracle `MODEL` with an iterating rule that repeatedly takes `mod 2` and halves.
```sql
SELECT ename, sal,
       (SELECT bin FROM dual
         MODEL
           DIMENSION BY (0 attr)
           MEASURES (sal num, CAST(NULL AS VARCHAR2(30)) bin, '0123456789ABCDEF' hex)
           RULES ITERATE (10000) UNTIL (num[0] <= 0) (
             bin[0] = SUBSTR(hex[CV()], MOD(num[CV()],2)+1, 1) || bin[CV()],
             num[0] = TRUNC(num[CV()]/2))) AS sal_binary
  FROM emp;
```
**Technique:** This is a procedural algorithm expressed declaratively. `RULES ITERATE (n) UNTIL (cond)` loops: each pass prepends the low bit (`MOD(num,2)` indexed into the `hex` lookup string) to `bin` and integer-halves `num`, stopping when `num <= 0`. Running it as a scalar subquery against `dual` turns `MODEL` into a per-row "function." Honestly better done in a stored function — the value here is seeing `MODEL`'s iteration and array access. (Change the divisor/lookup to convert to other bases.)

## 14.8 Pivoting a Ranked Result Set
**Problem:** Rank employees by salary, then lay them out in three columns: top 3, next 3, and the rest.
**Solution:** `DENSE_RANK` to rank, a `CASE` to bucket into groups, `ROW_NUMBER` to position within each group, then pivot.
```sql
SELECT MAX(CASE grp WHEN 1 THEN RPAD(ename,6)||' ('||sal||')' END) top_3,
       MAX(CASE grp WHEN 2 THEN RPAD(ename,6)||' ('||sal||')' END) next_3,
       MAX(CASE grp WHEN 3 THEN RPAD(ename,6)||' ('||sal||')' END) rest
  FROM (SELECT ename, sal,
               CASE WHEN rnk <= 3 THEN 1 WHEN rnk <= 6 THEN 2 ELSE 3 END AS grp,
               ROW_NUMBER() OVER (
                 PARTITION BY CASE WHEN rnk <= 3 THEN 1 WHEN rnk <= 6 THEN 2 ELSE 3 END
                 ORDER BY sal DESC, ename) AS grp_rnk
          FROM (SELECT ename, sal, DENSE_RANK() OVER (ORDER BY sal DESC) rnk FROM emp) x) y
 GROUP BY grp_rnk;
```
**Technique:** Three layers, one table scan. Innermost: `DENSE_RANK` ranks salaries with ties (no gaps). Middle: a `CASE` on that rank assigns each row to group 1/2/3, and a `ROW_NUMBER` partitioned by the *same* `CASE` gives each row its row-slot within its group. Outer: a standard `MAX(CASE grp …)` pivot, grouped by `grp_rnk`, lines the three groups up side by side. A showcase of how much window functions accomplish in a single pass.

## 14.9 Adding a Column Header into a Double Pivoted Result Set
**Problem:** Stack two tables into two side-by-side columns, with each group's DEPTNO printed as a header above its employees.
**Solution:** Cartesian-join each table to a 2-row generator to manufacture a spare slot per department, slide the DEPTNO into that slot, then stack ('union') and pivot.
```sql
-- Oracle (abridged shape)
SELECT MAX(DECODE(flag2, 0, it_dept)) research,
       MAX(DECODE(flag2, 1, it_dept)) apps
  FROM (SELECT SUM(flag1) OVER (PARTITION BY flag2 ORDER BY flag1, ROWNUM) flag,
               it_dept, flag2
          FROM ( /* per table: cross join to (CONNECT BY LEVEL <= 2),
                    ROW_NUMBER per deptno, keep rn <= cnt+1,
                    DECODE(rn,1, deptno, ' '||ename) AS it_dept, flag1=1, flag2=0|1 */ ) tmp1) tmp2
 GROUP BY flag;
```
**Technique:** The trick is making **room** for the header. Cross-joining each department's rows with a 2-row table (`CONNECT BY LEVEL <= 2`) doubles them; keeping `rn <= cnt+1` leaves exactly one extra slot per department, and `DECODE(rn, 1, deptno, ename)` drops the DEPTNO into that first slot. `flag1`/`flag2` then drive a running-total ranking (`SUM(flag1) OVER (PARTITION BY flag2 ORDER BY ...)`) that aligns the two stacks row-for-row before the final `MAX(DECODE(flag2 …))` pivot. An elaborate "stack 'n' pivot" — included to stretch the technique.

## 14.10 Converting a Scalar Subquery to a Composite Subquery in Oracle
**Problem:** Return *several* columns from a `SELECT`-list subquery, which normally must yield exactly one value.
**Solution:** Wrap the multiple values in an Oracle **object type** (one scalar object), then unpack its attributes in an enclosing inline view.
```sql
-- CREATE TYPE generic_obj AS OBJECT (val1 VARCHAR2(10), val2 VARCHAR2(10), val3 DATE);
SELECT x.deptno, x.ename,
       x.multival.val1 AS dname,
       x.multival.val2 AS loc,
       x.multival.val3 AS today
  FROM (SELECT e.deptno, e.ename, e.sal,
               (SELECT generic_obj(d.dname, d.loc, SYSDATE+1)
                  FROM dept d WHERE e.deptno = d.deptno) AS multival
          FROM emp e) x;     -- inline view MUST be named to dot into the object's attributes
```
**Technique:** You don't really break the one-value rule — you return a single *object* that bundles several attributes. The object constructor (`generic_obj(...)`) makes one scalar value; wrapping the query in a (named) inline view lets you reach the attributes with dot notation (`x.multival.val1`). Contrived — a plain join solves the real problem — but it demonstrates object types and attribute access. The inline view must be aliased or the dotted references won't resolve.

## 14.11 Parsing Serialized Data into Rows
**Problem:** Split colon-delimited strings (up to three values each, some missing) into `(val1, val2, val3)` columns, keeping empties in the right slot.
**Solution:** Walk each string with a number generator, `INSTR` to find the *nth* and *(n+1)th* delimiter, `SUBSTR` the slice between them, then pivot by position.
```sql
WITH cartesian AS (SELECT LEVEL id FROM dual CONNECT BY LEVEL <= 100)
SELECT MAX(DECODE(id, 1, SUBSTR(strings, p1+1, p2-1))) val1,
       MAX(DECODE(id, 2, SUBSTR(strings, p1+1, p2-1))) val2,
       MAX(DECODE(id, 3, SUBSTR(strings, p1+1, p2-1))) val3
  FROM (SELECT v.strings, c.id,
               INSTR(v.strings, ':', 1, c.id) p1,
               INSTR(v.strings, ':', 1, c.id+1) - INSTR(v.strings, ':', 1, c.id) p2
          FROM v, cartesian c
         WHERE c.id <= (LENGTH(v.strings) - LENGTH(REPLACE(v.strings, ':'))) - 1)
 GROUP BY strings;
```
**Technique:** This is the string-walk of Ch. 6 plus a positional pivot. For each occurrence `id`, `INSTR(str, ':', 1, id)` gives the position of the *id-th* delimiter (`p1`) and the gap to the next (`p2`); `SUBSTR(strings, p1+1, p2-1)` extracts the field — automatically empty when two delimiters are adjacent (a missing value). The walk is bounded by the delimiter count (`LENGTH − LENGTH(REPLACE(...))`). Finally `MAX(DECODE(id, n, ...))` grouped by string lands each field in its column. Portable with each engine's substring/position functions.

## 14.12 Calculating Percent Relative to Total
**Problem:** Show each JOB's share of total salary (with headcount, so the percentages aren't misleading).
**Solution:** Oracle `RATIO_TO_REPORT` (portable fallback: divide by a windowed total — see 7.11).
```sql
SELECT job, num_emps, SUM(ROUND(pct)) AS pct_of_all_salaries
  FROM (SELECT job,
               COUNT(*) OVER (PARTITION BY job)   AS num_emps,
               RATIO_TO_REPORT(sal) OVER () * 100 AS pct
          FROM emp)
 GROUP BY job, num_emps;
```
**Technique:** `RATIO_TO_REPORT(sal) OVER ()` returns each salary as a fraction of the window's total (×100 for a percentage); `COUNT(*) OVER (PARTITION BY job)` adds headcount on the same pass; the outer `SUM(ROUND(pct))` rolls the per-row percentages up to each JOB. The portable equivalent is `100 * SUM(sal) / SUM(SUM(sal)) OVER ()` (or a `sal / (SELECT SUM(sal) FROM emp)` scalar subquery) as in 7.11.

## 14.13 Testing for Existence of a Value Within a Group
**Problem:** Flag whether *any* row in a group meets a condition — e.g. did a student pass at least one exam in a period? — and mark the latest still-open row.
**Solution:** `MAX(...) OVER (PARTITION BY group)` to broadcast the group's verdict to every member, then `CASE`/`DECODE` to format.
```sql
SELECT student_id, test_id, grade_id, period_id, test_date,
       DECODE(grp_p_f, 1, LPAD('+',6), LPAD('-',6)) AS metreq,
       DECODE(grp_p_f, 1, 0, DECODE(test_date, last_test, 1, 0)) AS in_progress
  FROM (SELECT v.*,
               MAX(pass_fail) OVER (PARTITION BY student_id, grade_id, period_id) grp_p_f,
               MAX(test_date) OVER (PARTITION BY student_id, grade_id, period_id) last_test
          FROM V v) x;
```
**Technique:** The trick is to evaluate rows *as a group*, not individually. Because `pass_fail` is 0/1, `MAX(pass_fail) OVER (PARTITION BY ...)` returns 1 for the whole partition if *any* member passed — an existence test that still returns every detail row. `MAX(test_date) OVER (...)` likewise tags each partition's latest row, so the `in_progress` flag can mark the most recent attempt only when the requirement is unmet. This "aggregate-over-partition then compare back" pattern answers any "does any row in this group …?" question without collapsing the rows.

---

# Appendix A — Window Function Refresher

Window functions underpin most of the harder recipes in this book. They look like aggregates but keep the detail rows: where `GROUP BY` returns *one* row per group, a window function returns a value *for every row*, computed over a related set of rows (the "window"). The keyword `OVER` is what turns an aggregate into a window function. (DB2 calls these OLAP functions, Oracle calls them analytic functions; the ISO term is *window functions*.)

## A.1 Grouping fundamentals (the basis for windowing)
**Concept:** `GROUP BY` collapses like rows into one row per distinct grouping value, over which aggregates (`COUNT`, `SUM`, `MIN`, `MAX`, …) are computed.
```sql
SELECT deptno, COUNT(*) AS cnt, MAX(sal) AS hi_sal, MIN(sal) AS lo_sal
  FROM emp
 GROUP BY deptno;
```
**Key rules / gotchas:**
- **Every non-aggregated SELECT item must appear in `GROUP BY`** (constants, scalar subqueries, and window functions are exceptions, since `SELECT` is evaluated after `GROUP BY`). Adding a column like `job` to both `SELECT` and `GROUP BY` changes the grouping ("how many *types* of employee per dept").
- **`COUNT(*)` vs `COUNT(col)`:** `COUNT(*)` counts rows (NULLs included); `COUNT(col)` counts only non-NULL values — so a NULL group reports `COUNT(col) = 0` but `COUNT(*) = 5`. Use `COUNT(*)` to count members; `COUNT(col)` to count present values.
- **NULLs form one group** under `GROUP BY` (and `PARTITION BY`), since aggregates ignore NULL values themselves.
- `GROUP BY` already makes its groups distinct — adding `DISTINCT` on top is redundant. (MySQL's lax "select non-grouped columns" behaviour is a footgun; don't rely on it.)

## A.2 The OVER clause — a window function in miniature
**Concept:** `agg(...) OVER (...)` computes the aggregate over a window of rows but returns it on every row. Empty `OVER ()` = the whole result set.
```sql
SELECT ename, deptno, COUNT(*) OVER () AS cnt   -- 14 on every row
  FROM emp;
```
**Order of evaluation:** Window functions run **after** `WHERE`/`GROUP BY`/`HAVING` and **before** `ORDER BY`. So `WHERE deptno = 10` first cuts the set to 3 rows, *then* `COUNT(*) OVER ()` returns 3 — to filter on a window result, wrap the query in an inline view and filter outside.

## A.3 PARTITION BY — a "moving GROUP BY"
**Concept:** `PARTITION BY` splits rows into groups for the aggregation but, unlike `GROUP BY`, keeps every row and doesn't force the rest of the SELECT list into the grouping. Each partition is independent, so different window functions can partition differently in the same query.
```sql
SELECT ename, deptno,
       COUNT(*) OVER (PARTITION BY deptno) AS dept_cnt,
       job,
       COUNT(*) OVER (PARTITION BY job)    AS job_cnt
  FROM emp;
```
**Technique:** This is the more efficient, more flexible cousin of a correlated subquery (`(SELECT COUNT(*) FROM emp d WHERE d.deptno = e.deptno)`). NULLs go into a single partition, exactly as with `GROUP BY`.

## A.4 ORDER BY inside OVER — and the framing clause
**Concept:** Adding `ORDER BY` *inside* `OVER` orders the rows within the partition **and** implies a default frame of `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` — which is exactly why an ordered `SUM` becomes a running total.
```sql
SELECT deptno, ename, hiredate, sal,
       SUM(sal) OVER (ORDER BY hiredate) AS running_total,         -- default frame → running total
       SUM(sal) OVER (PARTITION BY deptno) AS dept_total,          -- no ORDER BY → whole-partition total
       SUM(sal) OVER ()                    AS grand_total
  FROM emp
 WHERE deptno = 10;
```
**The framing clause** defines the sub-window of rows fed to the function. Two flavours:
- **`ROWS BETWEEN ... PRECEDING/FOLLOWING`** — counts *physical rows* (e.g. `ROWS BETWEEN 1 PRECEDING AND CURRENT ROW` = this row + the prior one; `ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING` = a 7-row band).
- **`RANGE BETWEEN ...`** — counts by *value* of the `ORDER BY` key (e.g. `RANGE BETWEEN 90 PRECEDING AND CURRENT ROW` over a date — see 12.19).
Bounds: `UNBOUNDED PRECEDING`, `n PRECEDING`, `CURRENT ROW`, `n FOLLOWING`, `UNBOUNDED FOLLOWING`. `UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` = the whole partition (same as omitting `ORDER BY`); `CURRENT ROW AND CURRENT ROW` = just this row.
**Caveat:** Some engines/versions restrict framing — historically SQL Server disallowed `ORDER BY` in `OVER` for *aggregate* window functions (allowed for ranking functions); check your version.

## A.5 The function families
- **Aggregate window functions:** `SUM`, `AVG`, `COUNT`, `MIN`, `MAX OVER (...)` — running totals, moving averages, per-partition extremes that keep detail rows (Ch. 7, 11, 12).
- **Ranking functions:** `ROW_NUMBER` (unique 1..n), `RANK` (ties share a rank, gaps follow), `DENSE_RANK` (ties share a rank, no gaps), `NTILE(n)` (n equal buckets) — pagination, top-n, bucketing (Ch. 11, 12).
- **Positional / navigation:** `LAG`/`LEAD` (prior/next row), `FIRST_VALUE`/`LAST_VALUE` — inter-row differences, gaps-and-islands, filling values (Ch. 8–11).
**Why it matters:** One pass over the data answers questions that otherwise need multiple self-joins or scalar subqueries — e.g. each employee's salary alongside their dept max/min, job max/min, table max/min, dept running total, dept sum, and grand total, all in a single `SELECT`. Cleaner *and* faster at scale.

---

# Appendix B — Common Table Expressions

When a query needs to run aggregates/window functions over a *derived* table, you need either a **subquery** or a **common table expression (CTE)**. CTEs (the `WITH` clause) make multi-step queries readable and — crucially — enable **recursion**.

## B.1 Subqueries vs CTEs (non-recursive)
**Concept:** Both build a virtual table. A subquery inlines it; a CTE names it up front with `WITH`.
```sql
-- Subquery (some engines require the alias: PostgreSQL, SQL Server, MySQL do; Oracle doesn't)
SELECT MAX(HeadCount) AS HighestJobHeadCount
  FROM (SELECT job, COUNT(empno) AS HeadCount FROM emp GROUP BY job) head_count_tab;

-- Equivalent CTE
WITH head_count_tab (job, HeadCount) AS (
  SELECT job, COUNT(empno) FROM emp GROUP BY job)
SELECT MAX(HeadCount) AS HighestJobHeadCount
  FROM head_count_tab;
```
**Technique:** Both solve the "can't nest aggregates directly" problem (`MAX` of per-job `COUNT`). The CTE wins on readability once queries grow: each derived table is declared *before* the main query and named, so you read top-to-bottom instead of inside-out. Add more CTEs by separating them with commas (name, then its parenthesised query). For a single shallow nesting, a subquery is just as good.

## B.2 Recursive CTEs
**Concept:** A recursive CTE has an **anchor** member (the seed rows) `UNION ALL` a **recursive** member that references the CTE itself, iterating until it adds no more rows. This is the portable engine for hierarchies (Ch. 13), ranges, and number/date generation (Ch. 10).
```sql
-- First 20 Fibonacci numbers (carries current + previous in two columns)
WITH RECURSIVE workingTable (fibNum, nextNumber, index1) AS (
  SELECT 0, 1, 1                                              -- anchor: seed the first row
  UNION ALL
  SELECT fibNum + nextNumber, fibNum, index1 + 1             -- recursive: derive the next row
    FROM workingTable
   WHERE index1 < 20)                                         -- termination guard
SELECT fibNum FROM workingTable;
```
**Key points:**
- **`RECURSIVE` keyword** is required in MySQL, PostgreSQL, and Oracle; **not** used in SQL Server or DB2 (`WITH x (...) AS (...)`).
- **The termination condition is mandatory** — without the `WHERE` bound the recursion never stops (or the engine hits a row/recursion cap or a numeric overflow). Add a counter column when the natural data doesn't bound the walk.
- The anchor sets the starting row(s) and column types; the recursive member must produce union-compatible columns.

These two constructs — subqueries and CTEs (especially recursive CTEs, now available across all five engines) — are what let the rest of this book reach beyond plain table queries: generating rows, walking strings and trees, and layering aggregates over window functions.
