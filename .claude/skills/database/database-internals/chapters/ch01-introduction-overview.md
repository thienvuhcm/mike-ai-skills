# Chapter 1: Introduction and Overview

## Core Idea
Every database design decision traces to three orthogonal variables: **buffering** (collect data in memory before writing), **mutability** (in-place update vs append-only/copy-on-write), and **ordering** (key-sorted or insertion-ordered on disk). Understanding these three dimensions explains why so many storage structures exist.

## Frameworks Introduced

- **DBMS Architecture (Client/Server Pipeline)**
  - When to use: Frame any "how does a database execute a query" discussion
  - How: Transport → Query Processor (parse/validate) → Query Optimizer (statistics-based plan) → Execution Engine (local + remote ops) → **Storage Engine** (transaction mgr, lock mgr, access methods, buffer mgr, recovery mgr)

- **Storage Medium Classification**
  - When to use: Choosing DB for latency-sensitive workloads
  - How: **Disk-based DBMS** — persistent, uses memory as cache (B-Trees, wide/short structures); **In-memory DBMS** — primary store in RAM, disk only for WAL/checkpoint backup; durability via uninterrupted power + battery-backed RAM, or NVM

- **Data Layout Classification: Row vs Column**
  - When to use: Matching DB to access pattern
  - How:
    - **Row-oriented** (MySQL, PostgreSQL) → writes/reads full records; best for OLTP point queries and range scans on all columns
    - **Column-oriented** (Vertica, ClickHouse, Parquet) → stores column values contiguously; best for OLAP aggregates over subsets of columns; enables vectorized SIMD instructions and per-column compression
    - **Wide Column Stores** (BigTable, HBase, Cassandra) → NOT column-oriented; multidimensional sorted map where column families are stored separately but *within a column family* data is row-wise; best for key/prefix-key access

- **Data Files vs Index Files**
  - When to use: Designing table storage
  - How:
    - **Heap files** → records in write order, no key ordering; needs separate index
    - **Hashed files** → hash(key) → bucket; faster lookup than heap but no range scans
    - **Index-organized tables (IOT)** → records stored IN the index in key order; range scans are sequential reads; MySQL InnoDB uses IOT for primary index

- **Primary vs Secondary Indexes**
  - Clustered: data records follow key order (always true for IOT; can be true for separate files)
  - Nonclustered: data in separate file not matching index key order
  - Indirection trade-off: direct offset pointer = fewer seeks but costly pointer updates on relocation; primary key indirection = cheaper updates but extra lookup hop

- **Buffering / Mutability / Ordering (Core Storage Taxonomy)**
  - **Buffering**: collect writes in memory before flushing (B-Tree variants use node-level buffers; LSM Trees buffer an entire memtable)
  - **Mutability**: mutable (in-place update, e.g., classic B-Tree) vs immutable (append-only / copy-on-write, e.g., LSM, Bw-Tree, LMDB CoW)
  - **Ordering**: key-ordered storage enables efficient range scans; out-of-order (insertion order) enables faster sequential writes (Bitcask, WiscKey)

## Key Concepts

- **OLTP**: high-volume short-lived point queries and transactions; row-oriented layout preferred
- **OLAP**: complex aggregations over many rows and few columns; column-oriented layout preferred
- **HTAP**: hybrid combining OLTP + OLAP properties
- **Tombstone**: deletion marker (key + timestamp) written instead of in-place deletion; reclaimed during garbage collection
- **Heap file**: unordered data file; records placed in write order
- **IOT (Index-Organized Table)**: data records stored inside the primary index; clustered by definition
- **Clustered index**: index where data record order matches key order
- **Checkpointing**: periodically applying WAL records to the on-disk backup to bound recovery time
- **NVM (Non-Volatile Memory)**: byte-addressable persistent storage that eliminates read/write asymmetry
- **Spatial locality**: nearby memory locations accessed together; exploited by row-oriented stores

## Mental Models

- Use **row-oriented** when records are consumed whole (all columns); use **column-oriented** when queries scan many rows but few columns (aggregations).
- Think of **wide column stores** as "row stores with grouped columns" — the name is a misnomer; they are optimized for key access, not column scans.
- Think of **IOT** as: the index IS the table — no separate data file, no indirection, but secondary index updates require pointer fixup on record relocation.
- Use **primary key indirection** in secondary indexes when workload is write-heavy with many secondary indexes — extra read hop but avoids updating N index files on record relocation.

## Anti-patterns

- **Confusing column-oriented with wide column stores**: Cassandra/HBase are NOT analytics engines by default; their column families are row-stored within each family.
- **Assuming in-memory DB = disk DB + big page cache**: in-memory DBs use fundamentally different data structures and cannot be replicated by cache tuning.
- **Ignoring the three variables when designing storage**: picking B-Tree vs LSM without analyzing the buffering/mutability/ordering trade-off leads to wrong choices.

## Reference Tables

| Storage Type | Best Workload | Examples | Key Property |
|---|---|---|---|
| Row-oriented | OLTP, point/range queries | MySQL, PostgreSQL | Full record reads are sequential |
| Column-oriented | OLAP, aggregations | ClickHouse, Vertica, Parquet | Column scans, SIMD, per-column compression |
| Wide column store | Key/prefix access | HBase, Cassandra, BigTable | Column families; within family = row-stored |
| IOT | Range scans, key lookups | InnoDB primary | Data IN index, no indirection |

| DBMS Variable | Mutable | Immutable |
|---|---|---|
| Write path | In-place update | Append-only / copy-on-write |
| Read path | Direct lookup | May need merge (LSM) or CoW pointer follow |
| Buffering | Optional (lazy B-Tree) | Always (LSM memtable) |
| Examples | Classic B-Tree, InnoDB | LSM Tree, Bw-Tree, LMDB CoW |

## Worked Example

**Choosing between row-oriented and column-oriented for a time-series analytics DB:**

Scenario: store 1 billion stock price records `(id, symbol, date, price)`. Query pattern: 80% of queries compute `AVG(price) WHERE symbol='DOW' AND date BETWEEN x AND y`.

- **Row-oriented** (PostgreSQL): each page read loads all 4 columns even though only 3 are needed → data read amplification; no SIMD benefit
- **Column-oriented** (ClickHouse): `symbol`, `date`, `price` stored as separate column files → reads only 3 of 4 columns; `price` values are contiguous → SIMD AVG in one pass; run-length encoding on `symbol` can compress 10:1

**Decision**: column-oriented wins when the dominant pattern is column-subset aggregation over many rows.

## Key Takeaways

1. Three storage variables — buffering, mutability, ordering — explain all storage structure variants (B-Trees, LSM, Bw-Trees, Bitcask, WiscKey, etc.).
2. Row-oriented = OLTP (full-record access); column-oriented = OLAP (column aggregations). Wide column stores are a third category optimized for key-based access, not analytics.
3. IOTs store data inside the index — no indirection, ideal for range scans, but secondary index pointer updates are more expensive.
4. In-memory DBs require WAL + checkpoint for durability; they are NOT equivalent to disk DB + bigger RAM cache.
5. Tombstones defer deletion to GC — used in both B-Tree and LSM structures to avoid costly in-place deletes.

## Connects To

- **Ch02**: B-Tree Basics — primary mutable, ordered, disk-based access method
- **Ch05**: Transaction Processing — details on WAL, checkpointing, lock manager, buffer manager
- **Ch07**: Log-Structured Storage — primary immutable, ordered, buffered alternative to B-Trees
- **DDIA Ch3**: Storage engines (Kleppmann's B-Tree vs LSM angle complements this chapter)
