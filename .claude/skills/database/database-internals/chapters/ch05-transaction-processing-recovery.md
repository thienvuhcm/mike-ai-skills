# Chapter 5: Transaction Processing and Recovery

## Core Idea
Durable, concurrent transactions require four cooperating subsystems — page cache, lock manager, log manager (WAL), and transaction manager — each solving a distinct piece of the correctness puzzle; the steal/no-force policy choice determines exactly which undo/redo work is required after a crash.

## Frameworks Introduced
- **ARIES (Algorithm for Recovery and Isolation Exploiting Semantics)**: three-phase crash recovery using steal/no-force, physical redo, logical undo, and fuzzy checkpoints
  - When to use: any system that needs efficient crash recovery without sacrificing concurrency
  - How:
    1. **Analysis phase**: scan WAL from last checkpoint to find dirty pages (redo starting point) and in-progress transactions (undo targets)
    2. **Redo phase**: replay all WAL records from the redo starting point forward — including uncommitted transactions — to restore exact pre-crash state
    3. **Undo phase**: roll back all incomplete transactions in reverse chronological order, writing Compensation Log Records (CLRs) so repeated crashes don't redo the undo work

- **Steal/Force Policy Matrix**: determines when dirty pages are written to disk relative to transaction commit
  - When to use: choose a combination at storage engine design time; determines which log records (undo/redo) must be maintained
  - How: see Reference Tables below

- **Two-Phase Locking (2PL)**: separates lock acquisition (growing phase) from lock release (shrinking phase) to guarantee serializability
  - When to use: pessimistic lock-based concurrency control when correctness must be proven at lock time
  - How: growing phase — acquire all needed locks, release none; shrinking phase — release locks, acquire none; once the first lock is released, no new lock may be acquired

- **Latch Crabbing**: acquire child latch before releasing parent latch during B-Tree traversal (detailed in Ch04, applied here under concurrency control)
  - When to use: physical page access in concurrent B-Tree operations
  - How: hold parent write-latch until child node is confirmed safe from structural changes; release parent latch, hold child latch, descend

- **TinyLFU (frequency-based eviction)**: three-queue admission filter for page cache eviction
  - When to use: page cache under mixed access patterns where recency (LRU) is a poor predictor of future access
  - How: admission queue (new pages, LRU); probation queue (demoted or at-risk pages); protected queue (frequently accessed pages); promote from probation→protected only if candidate's frequency > the item that would be displaced

## Key Concepts
- **ACID**: Atomicity (all-or-nothing), Consistency (application invariants preserved), Isolation (concurrent transactions see no interference), Durability (committed data survives crashes)
- **Page Cache (Buffer Pool)**: in-memory cache of disk pages; dirty pages hold modifications not yet flushed; pinned pages cannot be evicted; coordinates with WAL via checkpoint
- **WAL (Write-Ahead Log)**: append-only, disk-resident log of all operations; a page may only be modified in the page cache after the corresponding log record is written; enables redo and undo after crash
- **LSN (Log Sequence Number)**: monotonically increasing identifier for each WAL record; used to order records and track which log entries a dirty page requires
- **Checkpoint**: process that flushes dirty pages to disk and advances the WAL trim point; sync checkpoint pauses all operations (impractical); fuzzy checkpoint runs asynchronously with `begin_checkpoint` and `end_checkpoint` log records
- **CLR (Compensation Log Record)**: WAL record written during undo of an operation; idempotent — if crash recurs during undo, the CLR prevents the undo from being repeated
- **Steal Policy**: allows flushing a dirty page to disk before its transaction commits; requires undo records in WAL in case the transaction aborts
- **No-Steal Policy**: dirty pages never flushed before commit; eliminates need for undo records; requires larger page cache
- **Force Policy**: all pages modified by a transaction flushed to disk before commit; eliminates need for redo records; increases commit latency due to I/O
- **No-Force Policy**: pages modified by a transaction may remain dirty at commit time; requires redo records in WAL; allows commit batching
- **MVCC (Multiversion Concurrency Control)**: maintains multiple timestamped record versions so readers can access a consistent historical snapshot without blocking writers; the last committed version is "current"
- **Serializability**: the property that a concurrent execution schedule is equivalent to some serial ordering of its transactions; the strongest isolation level
- **Snapshot Isolation**: each transaction reads from a consistent snapshot taken at its start time; prevents dirty reads, non-repeatable reads, and lost updates; but allows write skew anomalies
- **Deadlock**: circular wait between transactions each holding a lock the other needs; detected with a waits-for graph (cycles = deadlock) or avoided with wait-die / wound-wait timestamp protocols
- **Locks vs. Latches**: locks guard logical database objects (keys, ranges) for the transaction duration, managed by the lock manager; latches guard physical page structure during a single operation, managed by the page access code
- **CLOCK-sweep**: circular buffer page replacement where each page has an access bit; bit set to 1 on access; clock hand advances, clearing bits (0) and evicting on second pass; compact and concurrency-friendly

## Mental Models
- Think of the page cache + WAL as a two-stage durability system: WAL provides immediate durability (sequential append), page cache provides performance (random-access batching); checkpoint reconciles them periodically
- Use steal/no-force (ARIES policy) as the default: it maximizes cache flexibility and commit throughput at the cost of needing both redo and undo records in the WAL
- Think of locks as "transaction-duration keys to data rooms" and latches as "momentary door handles on physical pages" — they serve different layers and must both be held correctly
- Think of MVCC as a time machine for readers: instead of blocking on a write lock, a reader looks up the version that was current at its start timestamp

## Anti-patterns
- **Using FIFO page replacement**: root and upper-level B-Tree nodes are paged in first and evicted first even though they are the most reused pages — use LRU, CLOCK, or LFU instead
- **Force policy in high-throughput systems**: every commit triggers synchronous I/O for all modified pages, serializing commits — use no-force with WAL redo instead
- **Ignoring CLRs during undo**: if a crash occurs mid-undo and CLRs are not written, the undo operations will be repeated on the next recovery, potentially causing incorrect state
- **Using two-phase locking without deadlock detection**: circular waits will hang indefinitely — always pair 2PL with a waits-for graph detector or timestamp-based avoidance (wait-die / wound-wait)
- **Conflating locks and latches**: latches are not managed by the lock manager and do not participate in deadlock detection; confusing the two leads to either unsafe page access or incorrect transaction semantics
- **Flushing only at crash recovery**: without regular checkpoints, recovery must replay the entire WAL from the beginning — checkpoint frequently to bound recovery time

## Reference Tables

### Steal / Force Policy Matrix
| Policy Combination  | Undo needed? | Redo needed? | Typical use                      |
|---------------------|-------------|-------------|----------------------------------|
| Steal + No-Force    | Yes         | Yes         | ARIES (PostgreSQL, MySQL, most DBs) |
| Steal + Force       | Yes         | No          | Rarely used; high commit latency |
| No-Steal + No-Force | No          | Yes         | Simpler recovery; large cache needed |
| No-Steal + Force    | No          | No          | Simplest recovery; impractical at scale |

### ACID Properties and Responsible Components
| Property    | Responsible Component(s)                  | Key mechanism                     |
|-------------|-------------------------------------------|-----------------------------------|
| Atomicity   | Log manager + transaction manager         | WAL undo records; rollback        |
| Consistency | Application + constraint enforcement      | User-defined invariants           |
| Isolation   | Lock manager + concurrency control        | 2PL, MVCC, timestamp ordering     |
| Durability  | Log manager + page cache + checkpoint     | WAL force before commit; fsync    |

### Isolation Levels and Anomalies Allowed
| Isolation Level  | Dirty Read | Non-Repeatable Read | Phantom Read | Write Skew |
|------------------|------------|---------------------|--------------|------------|
| Read Uncommitted | Allowed    | Allowed             | Allowed      | Allowed    |
| Read Committed   | Prevented  | Allowed             | Allowed      | Allowed    |
| Repeatable Read  | Prevented  | Prevented           | Allowed      | Allowed    |
| Snapshot Isolation | Prevented | Prevented          | Prevented    | Allowed    |
| Serializable     | Prevented  | Prevented           | Prevented    | Prevented  |

### Page Replacement Algorithms
| Algorithm   | Eviction criterion                    | Concurrency cost | Real-world use              |
|-------------|---------------------------------------|------------------|-----------------------------|
| FIFO        | Oldest paged-in page                  | Low              | Large sequential scans (PostgreSQL circular buffer) |
| LRU         | Least recently accessed               | High (relinking) | Common baseline             |
| 2Q          | Distinguishes recent vs. frequent     | Medium           | Improvement over plain LRU  |
| LRU-K       | K most recent accesses per page       | Medium-High      | IBM DB2, academic use       |
| CLOCK-sweep | Access bit cleared on second pass     | Low (CAS ops)    | Linux kernel, many databases |
| TinyLFU     | Frequency histogram; 3-queue admission| Medium           | Caffeine (Java), modern systems |

### Concurrency Control Approach Comparison
| Approach               | Conflict detection | Blocking?  | Anomaly prevention  | Deadlock risk |
|------------------------|-------------------|------------|---------------------|---------------|
| OCC (Optimistic)       | At commit (validation) | No    | Serializable if validation passes | No           |
| MVCC                   | Version timestamps | Reads never block writes | Snapshot isolation level | Depends on implementation |
| 2PL (Pessimistic)      | At lock acquisition | Yes    | Serializable         | Yes — needs detection |
| Timestamp Ordering     | At read/write time | Abort/restart | Serializable (with Thomas Write Rule) | No |

## Worked Example

**ARIES Recovery after crash**

Scenario: WAL contains records for T1 (committed) and T2 (in-progress at crash). Last fuzzy checkpoint started at LSN 100.

WAL snapshot:
```
LSN 100  begin_checkpoint
LSN 110  T1: write page P3, before=X, after=Y
LSN 120  T2: write page P7, before=A, after=B
LSN 130  T1: commit
LSN 140  end_checkpoint (dirty pages: {P3, P7}; active txns: {T1, T2})
LSN 150  T2: write page P9, before=C, after=D
LSN 160  T2: write page P3, before=Y, after=Z
<<< CRASH >>>
```

**Phase 1 — Analysis** (start from LSN 100, the last `begin_checkpoint`):
- Dirty page table from `end_checkpoint`: P3 (recLSN=110), P7 (recLSN=120)
- Active transactions: T1 committed at LSN 130; T2 still active
- Continue scanning to crash: add P9 (recLSN=150) to dirty page table; update P3 recLSN stays 110
- Undo list = {T2}; Redo start = min(recLSN) = 110

**Phase 2 — Redo** (from LSN 110 forward):
- LSN 110: install Y into P3 (unless P3 on disk already has LSN ≥ 110)
- LSN 120: install B into P7
- LSN 130: T1 commit (no page change)
- LSN 150: install D into P9
- LSN 160: install Z into P3
- Database now in exact pre-crash state

**Phase 3 — Undo** (T2 only, reverse chronological):
- Undo LSN 160: write CLR(LSN=161), restore P3 to Y
- Undo LSN 150: write CLR(LSN=162), restore P9 to C
- Undo LSN 120: write CLR(LSN=163), restore P7 to A
- T2 fully rolled back; CLRs ensure crash during undo is safe

**Result**: P3=Y (T1's value), P7=A (pre-T2), P9=C (pre-T2). T1's commit is durable; T2 is as if it never happened.

## Key Takeaways
1. The steal/no-force combination (ARIES) is the practical default: it gives maximum page cache flexibility and commit throughput, requiring both undo and redo log records
2. WAL must be flushed to disk before the corresponding page cache modifications are made visible — violating write-ahead ordering breaks all recovery guarantees
3. ARIES three-phase recovery (analysis → redo → undo) fully reconstructs pre-crash state before rolling back incomplete transactions; CLRs make undo idempotent across repeated crashes
4. Locks (transaction-duration, managed by lock manager, protect logical data) and latches (operation-duration, protect physical pages) are separate mechanisms that must both be used correctly
5. Fuzzy checkpoints bound recovery time without pausing all operations — store `begin_checkpoint` and `end_checkpoint` records in WAL; recovery starts from `begin_checkpoint` LSN
6. MVCC eliminates read-write conflicts at the storage level by keeping multiple record versions — readers take a timestamped snapshot and never block writers
7. Blink-Trees (sibling links + high keys) reduce concurrent B-Tree latch contention by allowing splits to be visible via sibling pointers before parent pointers are updated

## Connects To
- **Ch03**: Page cache manages the slotted pages defined in Ch03; WAL log records reference page IDs and cell offsets from those formats
- **Ch04**: Latch crabbing and Blink-Tree concurrency from Ch04 are the physical-level concurrency mechanisms that complement the logical-level locks from Ch05
- **Ch13**: Distributed transactions extend the node-local concurrency control described here with two-phase commit, Percolator snapshot isolation, and deterministic concurrency control (Calvin)
