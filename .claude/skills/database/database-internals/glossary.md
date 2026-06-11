# Glossary — Database Internals

**ACID** — Atomicity, Consistency, Isolation, Durability: the four properties that guarantee database transaction reliability (Ch05)

**ARIES** (Algorithms for Recovery and Isolation Exploiting Semantics) — WAL-based crash recovery protocol using analysis, redo, and undo phases; supports Steal/No-Force buffer policy (Ch05)

**Anti-entropy** — process of detecting and repairing state divergence between replicas (Ch12)

**Atomic broadcast** — protocol ensuring all processes in a distributed system receive the same messages in the same order (Ch14)

**B-Tree** — balanced tree data structure with high fanout, low height, and sorted keys; designed for efficient disk-based storage (Ch02)

**B⁺-Tree** — B-Tree variant (default in practice) where values are stored only in leaf nodes; internal nodes hold separator keys only; leaf level forms a linked list for range scans (Ch02)

**Bitcask** — log-structured storage engine using an append-only log with an in-memory hash index (keydir); fast writes, all keys must fit in RAM (Ch07)

**Bloom filter** — probabilistic data structure that tests set membership with no false negatives but possible false positives; used in LSM Trees to skip SSTables (Ch07)

**BST (Binary Search Tree)** — sorted in-memory tree with fanout=2; unsuitable for disk storage due to low fanout and poor locality (Ch02)

**Buffer manager** — DBMS component that caches disk pages in RAM, manages dirty page tracking, and handles eviction using replacement policies (Ch05)

**Bully algorithm** — leader election algorithm where the node with the highest ID always wins; O(N²) messages (Ch10)

**Bw-Tree** — B-Tree variant using delta chains + mapping table + log-structured backing store; lock-free via compare-and-swap; used in Azure CosmosDB/Hekaton (Ch06)

**Byzantine fault** — failure mode where a node behaves arbitrarily, including sending incorrect or conflicting data to different peers (Ch08, Ch14)

**CAP theorem** — in the presence of a network partition, a distributed system must choose between Consistency (linearizability) and Availability; not a constant trade-off during normal operation (Ch11)

**Calvin** — deterministic distributed transaction protocol using a sequencer to order transactions before execution; avoids 2PC coordination overhead (Ch13)

**Cache-oblivious B-Tree** — B-Tree using van Emde Boas layout that is optimal for any cache hierarchy without knowing cache parameters (Ch06)

**Causal consistency** — consistency model ensuring causally related operations are observed in causal order by all nodes; concurrent operations may diverge (Ch11)

**Checkpointing** — periodically flushing dirty pages and recording a checkpoint LSN to bound recovery time; WAL records before the checkpoint can be discarded (Ch01, Ch05)

**CLR (Compensation Log Record)** — WAL record written during undo to make recovery idempotent; prevents redo/undo looping on partial failures (Ch05)

**CLOCK sweep** — page replacement algorithm; each page has an access bit; scan clock-wise; evict first page with bit=0; approximate LRU with O(1) cost (Ch05)

**Clustered index** — index where data records are stored in key order (always true for IOTs; can be true for separate data files) (Ch01)

**Compaction** — LSM Tree background process that merges SSTables to reclaim space and reduce read amplification; two strategies: leveled and size-tiered (Ch07)

**Consensus** — distributed systems problem: getting multiple processes to agree on a single value, even in the presence of failures (Ch14)

**Copy-on-Write (CoW)** — immutability pattern where modified pages are written to new locations; parent pointers updated; never in-place modification; provides snapshot reads (Ch06)

**CRDT (Conflict-free Replicated Data Type)** — data structure designed for eventual consistency where concurrent updates can be merged deterministically (Ch11, Ch13)

**Divider cell / separator key** — key stored in B-Tree internal node that splits the tree into subtrees with defined key ranges (Ch02)

**Epoch / Term** — monotonically increasing number used to fence stale leaders in distributed systems; operations from lower epoch/term are rejected (Ch10, Ch14)

**Eventual consistency** — consistency model guaranteeing all replicas converge to the same state given no new writes; allows temporary divergence (Ch11)

**FD-Tree (Fractional Cascading Tree)** — B-Tree variant combining a small mutable B-Tree head with multiple sorted immutable runs; uses fractional cascading for efficient search across levels (Ch06)

**Failure detector** — distributed systems component that monitors node liveness and reports suspected failures (Ch09)

**Fanout** — number of child pointers per B-Tree node; determines tree height (h ≈ log_K N where K = fanout) (Ch02)

**FLP impossibility** — theorem proving that in a fully asynchronous system with even one faulty process, no consensus algorithm can always terminate (Ch08, Ch14)

**FTL (Flash Translation Layer)** — firmware layer in SSDs that maps logical page IDs to physical locations and handles wear leveling, GC, and erase block management (Ch02, Ch07)

**Fencing token** — monotonically increasing number issued by a lock service; prevents split-brain by rejecting operations with stale tokens (Ch10)

**Gossip protocol** — epidemic-style distributed communication where each node periodically exchanges state with random peers; O(log N) rounds to reach all nodes (Ch09, Ch12)

**Heap file** — table storage where records are in write order without any key ordering; requires separate index for lookups (Ch01)

**Hinted handoff** — replication technique: when a target node is down, a proxy node stores the update with a "hint" and forwards it when the target recovers (Ch12)

**IOT (Index-Organized Table)** — table storage where data records are stored inside the primary index in key order; no separate data file; clustered by definition (Ch01)

**Isolation level** — degree to which a transaction is isolated from other concurrent transactions; levels: Read Uncommitted, Read Committed, Repeatable Read, Serializable (Ch05)

**LSM Tree** (Log-Structured Merge Tree) — immutable, buffered, ordered storage structure using memtable + SSTable + compaction; optimized for write-heavy workloads (Ch07)

**LSN** (Log Sequence Number) — monotonically increasing identifier for WAL records; used to track which changes have been applied (Ch05)

**Lazy B-Tree** — B-Tree variant that buffers writes at node level before flushing to reduce write amplification; examples: WiredTiger, LA-Tree (Ch06)

**Leader election** — distributed algorithm for selecting a single coordinator among peers (Ch10)

**Linearizability** — strongest consistency model: each operation appears to take effect instantaneously at some point between its invocation and completion; implies total order (Ch11)

**LMDB** (Lightning Memory-Mapped Database) — storage engine using Copy-on-Write B-Trees with MVCC; readers never block writers; entire file is memory-mapped (Ch06)

**Lock manager** — DBMS component that manages locks on database objects to ensure concurrent operations preserve data integrity (Ch01, Ch05)

**Memtable** — in-memory sorted write buffer in an LSM Tree; new writes go here first; flushed to SSTable when full (Ch07)

**Merkle tree** — hash tree where leaf hashes cover data ranges; root hash captures entire state; used for efficient anti-entropy sync between replicas (Ch12)

**MVCC (Multiversion Concurrency Control)** — concurrency control mechanism that maintains multiple versions of data; readers see consistent snapshot without blocking writers (Ch05)

**Multi-Paxos** — Paxos optimization where a stable leader is elected once to avoid Phase 1 overhead in steady-state (Ch14)

**No-Force policy** — dirty pages do not need to be flushed to disk at transaction commit; enables deferred writes but requires ARIES-style recovery (Ch05)

**Nonclustered index** — index where data records are in a separate file not ordered by the index key; secondary indexes are always nonclustered by definition (Ch01)

**NVM (Non-Volatile Memory)** — byte-addressable persistent storage (e.g., Intel Optane) eliminating read/write asymmetry; changes future storage structure design (Ch01)

**OCC (Optimistic Concurrency Control)** — concurrency control that executes without locks and validates at commit; aborts on conflict; best for low-contention workloads (Ch05)

**Occupancy** — ratio of currently stored keys to maximum node capacity in a B-Tree; B-Trees guarantee ≥50% occupancy (Ch02)

**Overflow page** — additional page linked to a B-Tree node to accommodate values that exceed normal page size; also handles cell overflow (Ch04)

**Paxos** — consensus algorithm with proposers, acceptors, and learners; two phases: Prepare/Promise + Accept/Learn; foundation for Multi-Paxos (Ch14)

**PBFT (Practical Byzantine Fault Tolerance)** — consensus protocol tolerating Byzantine faults; requires 3f+1 nodes to tolerate f faults; O(N²) message complexity (Ch14)

**Percolator** — distributed transaction protocol using snapshot isolation + timestamp oracle + MVCC in Bigtable-like storage (Ch13)

**Phi (φ) Accrual Failure Detector** — failure detector that outputs a suspicion value (φ) based on heartbeat arrival distribution; threshold is application-configurable (Ch09)

**Quorum** — minimum number of nodes required to acknowledge an operation for it to be considered committed; typically majority (N/2 + 1) (Ch11, Ch14)

**Raft** — consensus algorithm designed for understandability; strong leader model; log replication with majority acknowledgment; explicit leader election via randomized timeouts (Ch10, Ch14)

**Read repair** — lazy anti-entropy: when a read detects stale data at one replica, it proactively updates it (Ch12)

**Ring algorithm** — leader election algorithm that passes tokens around a logical ring; O(N) messages, O(N) rounds (Ch10)

**Row-oriented DBMS** — database storing records row-by-row; best for OLTP workloads with full-record access (Ch01)

**RUM Conjecture** — trade-off theorem: you can optimize at most 2 of 3: Read amplification, Update (write) amplification, Memory/space amplification (Ch07)

**Sequential consistency** — consistency model weaker than linearizability: operations appear in the same order to all nodes, but not necessarily in real-time order (Ch11)

**Serializability** — isolation level where concurrent transaction execution is equivalent to some serial execution; prevents all anomalies (Ch05)

**Skiplist** — probabilistic data structure used as memtable implementation in many LSM Trees; O(log N) average case for all operations with no rebalancing (Ch07)

**Slotted page** — page format with a pointer array at the beginning; cells grow from the end; allows key reordering without moving cell data (Ch03)

**Spanner** — Google's globally-distributed database; uses TrueTime (GPS/atomic clocks) for external consistency; 2PC across Paxos groups (Ch13)

**Split-brain** — situation where two nodes both believe they are the leader; prevented by epoch/term numbers and quorum requirements (Ch10)

**SSTable (Sorted String Table)** — immutable, sorted file in LSM Trees; contains data blocks + bloom filter + index block (Ch07)

**Steal policy** — dirty pages can be evicted to disk before the owning transaction commits; requires UNDO logging for crash recovery (Ch05)

**SWIM** (Scalable Weakly-consistent Infection-style Membership) — failure detection using indirect probing + gossip for membership propagation; O(N) message complexity (Ch09)

**Three storage variables** — buffering (amortize writes), mutability (in-place vs append-only), ordering (sorted vs insertion-order); three dimensions explaining all storage structure design choices (Ch01)

**Tombstone** — deletion marker (key + timestamp or key + deletion flag) written instead of in-place deletion; reclaimed during GC or compaction (Ch01, Ch07)

**Transaction manager** — DBMS component that schedules transactions and ensures logical consistency (Ch01, Ch05)

**Two Generals' Problem** — classic impossibility result: two parties cannot reliably coordinate over an unreliable channel in finite time; relates to exactly-once delivery challenges (Ch08)

**Two-Phase Commit (2PC)** — distributed commit protocol: Phase 1 (Prepare) + Phase 2 (Commit/Abort); blocking if coordinator fails after prepare (Ch13)

**Three-Phase Commit (3PC)** — non-blocking variant of 2PC adding PreCommit phase; not partition-tolerant; rarely used in practice (Ch13)

**Vector clock** — logical clock that tracks causality between events in a distributed system; each process maintains a vector of counters (Ch11)

**WiscKey** — LSM Tree variant separating keys from values; keys stored in LSM, values in an append-only value log; reduces write amplification for large values (Ch07)

**WiredTiger** — MongoDB storage engine; implements Lazy B-Tree with in-memory buffering + MVCC (Ch06)

**Write amplification** — ratio of bytes written to storage to bytes written by application; high write amplification = more disk wear and lower throughput (Ch06, Ch07)

**WAL (Write-Ahead Log)** — durability mechanism: log changes before applying them to pages; enables crash recovery and replication (Ch05)

**Zab** (ZooKeeper Atomic Broadcast) — total order broadcast protocol used by ZooKeeper; three phases: Discovery, Synchronization, Broadcast (Ch14)
