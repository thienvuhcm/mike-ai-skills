# Cheatsheet — Database Internals

## Storage Structure Selector

| Need | Use | Why |
|---|---|---|
| Point queries + range scans, mixed R/W | B-Tree / B⁺-Tree | Sorted, mutable, low read amplification |
| Write-heavy, accept higher read cost | LSM Tree | Sequential writes, compaction amortizes |
| Snapshot reads, read-heavy, no in-place mutation | CoW B-Tree (LMDB) | Readers never blocked; crash-safe root swap |
| Large values, key-only LSM too costly | WiscKey (key-value separation) | Only keys sorted in LSM; values in append log |
| All keys fit in RAM, write-heavy | Bitcask | In-memory hash index + append-only log |

**Rule**: When write amplification is the bottleneck → LSM. When read latency is critical → B-Tree. When both matter equally → measure; tune LSM compaction.

## B-Tree vs LSM Trade-off Matrix

| Dimension | B-Tree | LSM Tree |
|---|---|---|
| Write amplification | Low–Medium (in-place + WAL) | High (compaction rewrites) |
| Read amplification | Low (O(log N) pages) | Medium–High (multiple levels) |
| Space amplification | Low (no duplicates) | High (old versions before compaction) |
| Range scan | Excellent (leaf linked list) | Good (merge on read, or within level) |
| Write throughput | Random I/O (HDD bottleneck) | Sequential I/O (near-disk-bandwidth) |
| Read latency | Predictable | Varies with compaction state |

**RUM Conjecture rule**: You can only optimize 2 of {Read, Update, Memory}. Choose which 2 based on workload.

## B-Tree Variant Selector

| Scenario | Use |
|---|---|
| Readers must never block, small DB fits in mmap | CoW B-Tree (LMDB) |
| Write-heavy + B-Tree structure required | Lazy B-Tree (WiredTiger) |
| Mixed read/write on flash, B-Tree required | FD-Tree (fractional cascading) |
| Concurrent writes on NVM, lock-free required | Bw-Tree |
| Optimal for any cache hierarchy without tuning | Cache-oblivious B-Tree |

## Concurrency Control Selector

| Scenario | Use |
|---|---|
| High contention, OLTP | 2PL (Two-Phase Locking) — pessimistic |
| Low contention, short transactions | OCC — optimistic, validate at commit |
| Readers must not block writers | MVCC — snapshot reads |
| Distributed, need external consistency | Spanner / TrueTime + 2PL |

**Isolation level quick guide**:
- Read Committed: prevents dirty reads; allows phantom reads
- Repeatable Read: prevents dirty + non-repeatable; allows phantoms (MySQL default)
- Serializable: prevents all anomalies; lowest throughput
- Snapshot Isolation: practical MVCC; beware write skew

## Recovery Policy Combinations

| Steal | Force | Recovery Needed | Performance |
|---|---|---|---|
| No-Steal + Force | Simple (no UNDO, no REDO) | Worst (must flush all dirty pages at commit) |
| Steal + No-Force | ARIES (UNDO + REDO) | Best (most flexible for buffer manager) |
| No-Steal + No-Force | REDO only | Buffer manager constrained |
| Steal + Force | UNDO only | Commit = slow flush |

**ARIES default**: Steal + No-Force → always use ARIES-style recovery.

## Distributed Commit Protocol Selector

| Scenario | Protocol |
|---|---|
| Low latency, network reliable, simplest correct option | 2PC |
| Coordinator failure must not block | 3PC (but: not partition-tolerant) |
| Deterministic ordering, minimize coordination | Calvin |
| Global consistency with real-time clocks | Spanner (TrueTime) |
| Snapshot isolation on row-level locks in KV store | Percolator |

**Rule**: 2PC is the default. Add a Paxos-backed coordinator to solve blocking on coordinator failure.

## Consistency Model Selector

| Need | Use |
|---|---|
| Strongest: ops appear instantaneous | Linearizability |
| Same order at all nodes, not real-time | Sequential consistency |
| Causally related ops in order, concurrent ok | Causal consistency |
| Replicas converge eventually, max availability | Eventual consistency |

**CAP decision**:
- During partition: choose CP (sacrifice availability) or AP (sacrifice consistency)
- During normal operation: no trade-off necessary

## Consensus Protocol Selector

| Scenario | Protocol |
|---|---|
| Understandability, leader-based, crash-stop | Raft |
| Industry standard, flexible roles | Multi-Paxos |
| ZooKeeper-style coordination | Zab |
| Byzantine (malicious) faults, ≤f/3N faults | PBFT |
| Leaderless, flexible quorum sizes | EPaxos / Flexible Paxos |

## Failure Detection Decision Rules

- **If**: network is stable, cluster ≤ ~50 nodes → simple heartbeat + timeout
- **If**: network jitter varies → Phi Accrual (φ threshold = 8 is production default)
- **If**: cluster is large (100s+ nodes) → SWIM (indirect probing + gossip; O(N) messages)
- **If**: detecting failure must be fast + false positives tolerated → lower timeout
- **If**: false positives cause split-brain risk → use fencing tokens regardless of detection method

## Leader Election Decision Rules

- **If**: simplicity, node IDs are known, small cluster → Bully (O(N²) msgs, not for large clusters)
- **If**: ring topology, N messages preferred → Ring algorithm
- **If**: you're already using Raft/Paxos → use their built-in leader election
- **Always**: use epoch/term fencing tokens. A node believing it is leader without a current token must be ignored.

## Anti-Entropy Decision Rules

- **Read repair**: use always (lazy, free, converges read-heavy keys fastest)
- **Hinted handoff**: use for short outages (< hours); bound hint storage
- **Merkle trees**: use when you need to detect divergence across millions of keys efficiently (Cassandra's `nodetool repair`)
- **Gossip**: use for membership state; don't use for large data payloads

## LSM Compaction Strategy Decision

- **Leveled** (RocksDB default): use when read latency matters; ~10× write amplification per level but predictable
- **Size-tiered** (Cassandra default): use when write throughput is critical; accept higher space amplification
- **Rule**: if bloom filters miss rate is high → too many levels/tiers, trigger compaction earlier

## Bloom Filter Sizing Rule

Target false positive rate ε ≈ (0.6185)^(m/n) where m = bits, n = keys.
- **1% false positives** → ~10 bits per key
- **0.1% false positives** → ~15 bits per key
- **Rule**: always add bloom filters to LSM SSTables for point queries.

## Tells & Smells

| Symptom | Likely Cause |
|---|---|
| Write throughput degrades over time | LSM compaction falling behind; size-tiered → switch to leveled |
| Read latency spikes under write load | B-Tree page splits/rebalancing; or LSM read amplification |
| Recovery time is minutes | Checkpoint interval too long; reduce checkpoint gap |
| Split-brain after leader failure | Missing fencing tokens; two nodes both believe they are leader |
| 2PC transaction stuck indefinitely | Coordinator failed post-Prepare; need Paxos coordinator or presumed-abort |
| Replica divergence grows over time | Read repair not running on cold keys; schedule full Merkle-tree repair |
| Memory balloons during writes | LSM memtable too large or flush stalled by compaction; back-pressure needed |
