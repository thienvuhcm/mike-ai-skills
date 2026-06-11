---
name: database-internals
description: "Knowledge base from \"Database Internals: A Deep Dive into How Distributed Data Systems Work\" by Alex Petrov (O'Reilly, 2019). Use when applying Petrov's frameworks for storage engine design (B-Trees, LSM Trees, B-Tree variants, file formats, buffer management, WAL/ARIES recovery), distributed systems algorithms (failure detection, leader election, replication, anti-entropy, distributed transactions, consensus), and making trade-off decisions between B-Tree vs LSM, read/write/space amplification, consistency models (linearizability vs causal vs eventual), and distributed commit protocols (2PC vs Paxos vs Raft)."
allowed-tools:
  - Read
  - Grep
argument-hint: [topic, algorithm name, chapter number, or system name]
---

# Database Internals: A Deep Dive into How Distributed Data Systems Work
**Author**: Alex Petrov | **Pages**: ~356 | **Chapters**: 14 | **Parts**: 2 | **Generated**: 2026-06-11

## How to Use This Skill

- **Without arguments** — load core frameworks for reference
- **With a topic** — ask about `B-Tree`, `LSM`, `Paxos`, `ARIES`, or any indexed topic → I read the relevant chapter
- **With chapter** — ask for `ch05` → I load that specific chapter
- **Browse** — ask "what chapters do you have?" to see the full index

When you ask about a topic not in Core Frameworks below, I will read the relevant chapter file before answering.

---

## Core Frameworks & Mental Models

### The Three Storage Variables (Ch01)

Every storage structure reflects choices on three orthogonal dimensions. These dimensions explain all storage structure variants:

| Variable | Option A | Option B | Effect |
|---|---|---|---|
| **Buffering** | Write to disk immediately | Collect in memory first | Buffering reduces write amplification |
| **Mutability** | In-place update (mutable) | Append-only / CoW (immutable) | Immutability improves concurrency; defers write amplification |
| **Ordering** | Key-sorted on disk | Insertion-ordered | Sorted enables range scans; insertion-ordered enables faster sequential writes |

- **B-Tree**: mutable + optional buffering + key-sorted → best for balanced read/write OLTP workloads
- **LSM Tree**: immutable + always-buffered + key-sorted (per level) → best for write-heavy workloads
- **Bitcask / WiscKey**: immutable + unordered → fastest raw writes but range scans require key index

### B-Tree (Ch02, Ch04, Ch06)

**Use when**: balanced OLTP read/write workloads; range scans common; random point queries dominant.

- Structure: root → internal nodes (separator keys + child pointers) → leaf nodes (key-value pairs)
- **B⁺-Tree** (default): values only in leaf nodes; leaf level = doubly-linked list → range scan = sequential read
- Fanout K (hundreds) → height = O(log_K N) → 3–4 disk seeks for billion-item tree
- **Split** (overflow): allocate sibling, copy half, promote midpoint key to parent → propagates up to root
- **Merge** (underflow): copy right→left, demote separator from parent → propagates up to root
- **B-Tree Variants** (Ch06):
  - **Copy-on-Write** (LMDB): never modify pages in-place; write new page, update parent pointer; reads always see consistent snapshot
  - **Lazy B-Tree** (WiredTiger, LA-Tree): buffer writes at node level before flush; reduces write amplification
  - **FD-Tree**: immutable sorted runs + fractional cascading for O(log² N) amortized writes
  - **Bw-Tree** (Azure CosmosDB, Hekaton): delta chains + mapping table + log-structured backing store; lock-free via compare-and-swap
  - **Cache-Oblivious B-Tree**: van Emde Boas layout; optimal for unknown cache hierarchy

### LSM Tree (Ch07)

**Use when**: write-heavy workloads; high write throughput; can tolerate slightly higher read amplification.

- **Write path**: append to WAL → insert into in-memory memtable → flush memtable to immutable SSTable on disk
- **Read path**: check memtable → check each level's SSTables (newest to oldest) → merge-read
- **SSTable**: immutable sorted file; includes data blocks + bloom filter (skip levels with no match) + index block
- **Compaction**: periodically merge SSTables to reclaim space and reduce read amplification
  - **Size-tiered**: merge similar-size SSTables → higher write throughput, more space amplification
  - **Leveled** (LevelDB/RocksDB): each level has bounded size; merge into next level → better read/space, more write amplification
- **RUM Conjecture**: you can optimize at most 2 of 3: Read amplification, Update (write) amplification, Memory/Space amplification
  - B-Tree: low R, medium W, low M
  - LSM: high R, low W, higher M (with compaction)

### Storage Engine Components (Ch05)

**Buffer Manager**: page cache (RAM ↔ disk); dirty page tracking; replacement policies:
  - **CLOCK/LRU-K**: evict least-recently-used pages; pin hot pages
  - Steal/No-Force: **Steal** = dirty pages can be evicted before commit; **No-Force** = pages don't have to flush on commit → needs ARIES recovery

**Recovery — ARIES** (Algorithms for Recovery and Isolation Exploiting Semantics):
  - Write-ahead log (WAL): write log record BEFORE modifying page
  - LSN (Log Sequence Number): each log record has monotonically increasing LSN
  - Three phases: **Analysis** (find dirty pages + active transactions at crash) → **Redo** (replay ALL changes from checkpoint) → **Undo** (rollback uncommitted transactions)
  - Steal + No-Force enables: buffer manager evicts dirty pages freely; commit doesn't require flush

**Concurrency Control**:
  - **2PL** (Two-Phase Locking): growing phase (acquire locks) → shrinking phase (release locks); prevents dirty/non-repeatable reads and phantoms at serializable level
  - **MVCC** (Multiversion Concurrency Control): readers see consistent snapshot without blocking writers; writers create new versions; used in PostgreSQL, MySQL InnoDB
  - **OCC** (Optimistic Concurrency Control): execute without locks; validate at commit; abort on conflict; best for low-contention workloads

### Distributed Systems Fundamentals (Ch08)

**Fallacies of Distributed Computing**: the network is NOT reliable; latency is NOT zero; bandwidth is NOT infinite; network is NOT secure; topology DOES change; there is NOT one administrator; transport cost is NOT zero; the network is NOT homogeneous.

**FLP Impossibility**: in an asynchronous system with even one faulty process, it is impossible to have a consensus algorithm that always terminates. Practical systems use timeouts, randomization, or partial synchrony assumptions to work around this.

**Failure Models** (weakest to strongest tolerance required):
  - **Crash-stop**: node crashes and stays down — most common assumption
  - **Crash-recovery**: node can crash and rejoin — requires log-based recovery
  - **Omission**: node selectively drops messages — harder to detect than crash
  - **Byzantine**: node behaves arbitrarily (including sending wrong data) — requires BFT protocols

### Failure Detection (Ch09)

**Heartbeat-based**: node sends periodic heartbeats; detector marks node failed if heartbeat missed for timeout period. Problem: false positives if timeout too short; slow detection if timeout too long.

**Phi Accrual Failure Detector**: instead of binary alive/dead, outputs a suspicion value φ; threshold chosen by application based on acceptable false positive rate. Adapts to network conditions by modeling heartbeat arrival times as normal distribution. Used in Akka, Cassandra.

**SWIM** (Scalable Weakly-consistent Infection-style Membership): avoids direct ping storms; uses indirect probing (ask random nodes to probe target); membership updates propagated via gossip; O(N) messages total vs O(N²) for all-pairs heartbeat.

### Leader Election (Ch10)

**When needed**: single-writer coordination, distributed lock, metadata operations.

- **Bully Algorithm**: highest ID wins; node that notices failure broadcasts election; O(N²) messages; simple but not used in large systems
- **Ring Algorithm**: token passed around ring; O(N) messages but O(N) rounds; requires known ring topology
- **Raft Leader Election**: randomized timeout → first node to time out sends RequestVote; majority vote wins; epoch (term) number fences stale leaders → prevents split-brain

**Fencing Token**: monotonically increasing number issued by lock service; storage systems reject operations with stale tokens — prevents split-brain from "zombie leaders."

### Replication & Consistency Models (Ch11)

**Replication**: synchronous (strong consistency, higher latency) vs asynchronous (lower latency, risk of data loss on primary failure); chain replication (strong consistency + high throughput for reads via tail).

**Consistency Models** (strongest to weakest):

| Model | What it guarantees | Real-world implication |
|---|---|---|
| **Linearizability** | Operations appear instantaneous; reads see latest write globally | Requires coordination across all nodes (Paxos, Raft); highest latency |
| **Sequential consistency** | Operations appear in same order to all nodes; individual process order preserved | Slightly weaker than linearizable; some reads can miss concurrent writes |
| **Causal consistency** | Causally related operations preserve order; concurrent ops can diverge | Practical middle ground; achievable without global coordination |
| **Eventual consistency** | All replicas converge given no new writes | Fastest; most available; applications must handle conflicts |

**Session guarantees** (applicable within a single client session):
- Read-your-writes: see your own writes immediately
- Monotonic reads: reads never go backward
- Monotonic writes: writes committed in order
- Writes-follow-reads: write after read sees same or later state

**CAP Theorem**: when a partition occurs, choose Consistency (linearizability) OR Availability. Most systems operate without partitions most of the time — latency trade-offs are more relevant day-to-day.

### Anti-Entropy & Gossip (Ch12)

**Read repair**: when a read sees stale data at one replica, proactively update it. Lazy convergence — only repairs on read path.

**Hinted handoff**: when a node is down, temporarily store updates at a different node with a "hint" to forward when the target recovers. Reduces window of inconsistency.

**Merkle Tree**: hash tree where each leaf is a hash of a data range; compare root hashes to detect divergence; traverse down to find exact differing ranges. Used for efficient anti-entropy sync (Cassandra, DynamoDB).

**Gossip** (epidemic broadcast): each node periodically exchanges state with random peers. Scalable dissemination: O(log N) rounds to reach all nodes. Push (sender initiates) vs pull (receiver initiates) vs push-pull (both).

### Distributed Transactions (Ch13)

**2PC (Two-Phase Commit)**:
  - Phase 1 (Prepare): coordinator sends PREPARE to all cohorts; cohorts respond YES/NO
  - Phase 2 (Commit/Abort): if all YES → COMMIT; if any NO → ABORT
  - Problem: coordinator failure after prepare → cohorts blocked waiting (blocking protocol)
  - Used in: XA transactions, most RDBMS distributed transaction support

**3PC (Three-Phase Commit)**:
  - Adds PreCommit phase between prepare and commit — non-blocking but not partition-tolerant; rarely used in practice

**Calvin** (deterministic ordering): transactions ordered by sequencer before execution; all nodes execute same deterministic schedule → no 2PC needed for coordination; high throughput but ordering bottleneck.

**Percolator** (Google, used in TiDB): snapshot isolation via timestamp oracle; uses Bigtable-like storage for locks; write transactions use MVCC with distributed locks; works without a centralized coordinator.

### Consensus (Ch14)

**Why consensus is hard**: FLP impossibility — cannot have safe + live consensus in async system with failures. Solutions use partial synchrony (timeout assumptions) or randomization.

**Paxos**:
  - Roles: Proposers (initiate proposals), Acceptors (vote), Learners (observe outcomes)
  - Phase 1 (Prepare): proposer sends `Prepare(n)`; acceptors promise not to accept older proposals
  - Phase 2 (Accept): proposer sends `Accept(n, v)`; acceptors accept if still valid
  - Multi-Paxos: one stable leader handles steady-state with single round-trip; leader election done once
  - Variants: Fast Paxos, Egalitarian Paxos (EPaxos), Flexible Paxos

**Raft**: designed for understandability; strong leader model; log entries from leader → followers; majority acknowledgment → commit; leader election via randomized timeouts + term numbers. Used in: etcd, CockroachDB, TiKV.

**Zab** (ZooKeeper Atomic Broadcast): 3 phases — Discovery (elect leader), Synchronization (catch up followers), Broadcast (steady-state). Total order broadcast for all updates.

**Byzantine Fault Tolerance (PBFT)**: handles malicious/arbitrary failures; requires 3f+1 nodes to tolerate f faults; O(N²) messages per request; used in blockchains and safety-critical systems.

| Protocol | Failures tolerated | Message complexity | Blocking? | Practical use |
|---|---|---|---|---|
| 2PC | None (coordinator failure = block) | O(N) | Yes | XA transactions |
| 3PC | Coordinator crash | O(N) | No | Rarely used |
| Paxos/Multi-Paxos | Minority crash | O(N) per round | No | Chubby, etcd |
| Raft | Majority-1 crash | O(N) | No | etcd, CockroachDB |
| Zab | Majority-1 crash | O(N) | No | ZooKeeper |
| PBFT | Minority Byzantine | O(N²) | No | Blockchains |

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-introduction-overview.md) | Introduction and Overview | Three storage variables, DBMS architecture, row/column/wide-column, IOT vs heap |
| [ch02](chapters/ch02-btree-basics.md) | B-Tree Basics | BST vs B-Tree, splits/merges, B⁺-Tree, separator keys, fanout/height trade-off |
| [ch03](chapters/ch03-file-formats.md) | File Formats | Binary encoding, slotted pages, cell layout, fixed-size vs variable-size records |
| [ch04](chapters/ch04-implementing-btrees.md) | Implementing B-Trees | Sibling pointers, high keys, overflow pages, binary search with indirection, breadcrumbs |
| [ch05](chapters/ch05-transaction-processing-recovery.md) | Transaction Processing and Recovery | Buffer manager, ARIES (WAL/LSN/Steal/No-Force), MVCC, OCC, 2PL, isolation levels |
| [ch06](chapters/ch06-btree-variants.md) | B-Tree Variants | CoW B-Tree (LMDB), Lazy B-Tree (WiredTiger), FD-Tree, Bw-Tree, Cache-Oblivious B-Tree |
| [ch07](chapters/ch07-log-structured-storage.md) | Log-Structured Storage | LSM Tree, SSTable, memtable, compaction (leveled/size-tiered), RUM conjecture, Bitcask, WiscKey |
| [ch08](chapters/ch08-distributed-intro-overview.md) | Introduction and Overview (Part II) | Fallacies of distributed computing, FLP impossibility, failure models, partial synchrony |
| [ch09](chapters/ch09-failure-detection.md) | Failure Detection | Heartbeat, Phi Accrual Failure Detector, SWIM, gossip-based membership |
| [ch10](chapters/ch10-leader-election.md) | Leader Election | Bully, Ring, Raft election, epoch/term, fencing token, lease |
| [ch11](chapters/ch11-replication-consistency.md) | Replication and Consistency | CAP, linearizability, causal consistency, eventual consistency, session guarantees, CRDTs |
| [ch12](chapters/ch12-anti-entropy-dissemination.md) | Anti-Entropy and Dissemination | Read repair, hinted handoff, Merkle trees, gossip, bitmap version vectors |
| [ch13](chapters/ch13-distributed-transactions.md) | Distributed Transactions | 2PC, 3PC, Calvin, Percolator, Spanner, consistent hashing |
| [ch14](chapters/ch14-consensus.md) | Consensus | Paxos, Multi-Paxos, Raft, Zab, PBFT, Byzantine consensus, atomic broadcast |

## Topic Index

- **ARIES** → ch05
- **Anti-entropy** → ch12
- **Atomic broadcast** → ch14
- **B-Tree** → ch02, ch04, ch06
- **B⁺-Tree** → ch02
- **Bitcask** → ch07
- **Bloom filter** → ch07
- **Buffer management** → ch05
- **Bully algorithm** → ch10
- **Bw-Tree** → ch06
- **Byzantine fault** → ch08, ch14
- **CAP theorem** → ch11
- **Cache-oblivious B-Tree** → ch06
- **Calvin** → ch13
- **Causal consistency** → ch11
- **Checkpointing** → ch01, ch05
- **Clustered index** → ch01
- **Column-oriented DBMS** → ch01
- **Compaction** → ch07
- **Consensus** → ch14
- **Copy-on-Write** → ch06
- **CRDTs** → ch11, ch13
- **Distributed transactions** → ch13
- **Eventual consistency** → ch11
- **FD-Tree** → ch06
- **FLP impossibility** → ch08, ch14
- **Failure detection** → ch09
- **Failure models** → ch08
- **Fanout** → ch02
- **Fencing token** → ch10
- **File formats** → ch03
- **Gossip** → ch09, ch12
- **Heap file** → ch01
- **Hinted handoff** → ch12
- **IOT (Index-Organized Table)** → ch01
- **LSM Tree** → ch07
- **LSN** → ch05
- **Lazy B-Tree** → ch06
- **Leader election** → ch10
- **Linearizability** → ch11
- **LMDB** → ch06
- **Lock manager** → ch05
- **MVCC** → ch05
- **Memtable** → ch07
- **Merkle tree** → ch12
- **NVM** → ch01
- **OCC** → ch05
- **Paxos** → ch14
- **Percolator** → ch13
- **Phi Accrual Failure Detector** → ch09
- **Quorum** → ch11, ch14
- **RUM conjecture** → ch07
- **Raft** → ch10, ch14
- **Read repair** → ch12
- **Replication** → ch11
- **Row-oriented DBMS** → ch01
- **SSTable** → ch07
- **SWIM** → ch09
- **Sequential consistency** → ch11
- **Serializability** → ch05
- **Slotted pages** → ch03
- **Spanner** → ch13
- **Split / Merge (B-Tree)** → ch02, ch04
- **Three storage variables** → ch01
- **Tombstone** → ch01, ch07
- **Transaction isolation** → ch05
- **Two-Phase Commit (2PC)** → ch13
- **WAL (Write-Ahead Log)** → ch05
- **WiscKey** → ch07
- **WiredTiger** → ch06
- **Zab** → ch14

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions
- [patterns.md](patterns.md) — all techniques and design patterns
- [cheatsheet.md](cheatsheet.md) — quick reference tables and decision guides

---

## Scope & Limits

This skill covers the book content only (storage engines + distributed algorithms). For:
- Query optimization, relational algebra, SQL internals → not covered here
- Production tuning, specific database configuration → combine with project-specific tools
- NVM/PMEM-specific structures → brief coverage in ch01, ch06; refer to research papers
