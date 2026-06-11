# Chapter 13: Distributed Transactions

## Core Idea
Making multiple operations across multiple partitions appear atomic requires coordination protocols (2PC, 3PC) or deterministic ordering (Calvin/Spanner); each approach makes a different trade-off among availability, latency, fault tolerance, and partition tolerance.

## Frameworks Introduced
- **Two-Phase Commit (2PC)**: Coordinator-driven atomic commitment in prepare + commit/abort phases
  - When to use: Multi-partition transactions where all participants are expected to be available; acceptable to block on coordinator failure
  - How: Coordinator sends Propose → cohorts vote → if unanimous, coordinator sends Commit; all steps persisted to durable logs

- **Three-Phase Commit (3PC)**: Adds a Prepare phase to 2PC to allow cohorts to proceed independently on coordinator timeout
  - When to use: Synchronous networks where network partitions are not expected; need to avoid cohort blocking
  - How: Propose → Prepare (coordinator broadcasts vote results) → Commit; cohorts timeout-abort if they haven't seen Prepare; timeout-commit if they have

- **Calvin (Deterministic Ordering)**: Pre-agreed global transaction execution order via a sequencer, eliminating coordination during execution
  - When to use: High-throughput multi-partition workloads where pre-declaring read/write sets is feasible
  - How: Sequencer batches transactions into epochs → consensus on batch → scheduler executes all replicas deterministically with same inputs

- **Percolator (Snapshot Isolation on Bigtable)**: Client-driven 2PC with timestamp oracle and row-level locks stored as data columns
  - When to use: Distributed snapshot isolation over a key-value store (e.g., TiDB); incremental processing workloads
  - How: Prewrite phase acquires all locks with primary lock; commit phase starts from primary lock, then cascades to secondary locks

- **Spanner (2PC over Paxos Groups)**: Uses consensus groups per shard + TrueTime for external consistency
  - When to use: Globally distributed databases requiring linearizable multi-shard transactions
  - How: Each shard is a Paxos group; cross-shard transactions run 2PC with Paxos group leaders as cohorts; TrueTime provides bounded uncertainty for timestamp ordering

## Key Concepts
- **Atomic Commitment**: Class of algorithms ensuring all participants commit or all abort; no partial commits; requires unanimity (not valid with Byzantine failures)
- **Cohort**: A partition participant in 2PC/3PC; votes to accept or reject the proposal; must persist its decision locally
- **Coordinator (Transaction Manager)**: Node that initiates the commit protocol, collects votes, and broadcasts the final decision; single point of failure in basic 2PC
- **Blocking Problem (2PC)**: If the coordinator fails after collecting votes but before broadcasting the decision, cohorts are stuck in uncertainty until the coordinator recovers or a new one is elected
- **Split Brain (3PC)**: Under network partition, nodes on different sides of the partition may independently timeout to commit or abort, reaching contradictory states
- **Calvin Sequencer**: Entry point that determines global transaction order; splits timeline into 10ms epochs; each epoch becomes a replication unit
- **Snapshot Isolation (SI)**: Reads see a consistent snapshot as of transaction start timestamp; write-write conflicts abort the later writer (first committer wins); does not prevent write skew
- **Timestamp Oracle**: Cluster-wide source of monotonically increasing timestamps used by Percolator and Spanner for transaction ordering
- **TrueTime**: Google's high-precision wall-clock API exposing uncertainty bounds; Spanner uses it to guarantee external consistency by waiting out the uncertainty window before commit
- **Consistent Hashing**: Partitioning scheme mapping keys to a hash ring; node joins/leaves only affect adjacent ring neighbors, minimizing data movement
- **Invariant Confluence (I-Confluence)**: Property that two diverged but individually valid database states can be merged into a single valid state; enables coordination-free execution for I-Confluent operations

## Mental Models
- Think of **2PC** as a two-step vote with veto power: any cohort can veto (abort) but the coordinator must be alive to announce the result — availability depends entirely on coordinator liveness
- Think of **3PC** as adding a "everyone knows the vote result" step before committing — this lets cohorts self-resolve on timeout, but only works when the network cannot partition
- Use **Calvin** when you can declare read/write sets upfront: by agreeing on order before execution, replicas run in parallel without further coordination — determinism replaces coordination
- Use **Spanner** when you need linearizable multi-shard transactions at global scale and can afford the cost of 2PC over Paxos groups plus TrueTime wait

## Anti-patterns
- **2PC without backup coordinators**: Coordinator failure leaves cohorts blocked indefinitely; always design coordinator recovery or use Paxos groups (as Spanner does) to make the coordinator highly available
- **Using 3PC across partitioned networks**: 3PC's non-blocking guarantee assumes synchrony; a real network partition causes split brain where nodes on both sides independently decide, leading to contradictory states
- **Snapshot isolation where serializability is required**: SI prevents read skew and some anomalies but allows write skew (two transactions modifying disjoint sets that together violate an invariant); use serializable isolation if invariants span disjoint rows
- **Modulo-based hash partitioning**: `hash(v) mod N` requires relocating nearly all keys when N changes; use consistent hashing so only O(K/N) keys move when a node joins or leaves
- **Ignoring lock contention in Spanner-style systems**: Every read-write transaction requires locks from the Paxos group leader; high write contention on the same shard serializes through a single leader, becoming a throughput bottleneck

## Reference Tables

### Atomic Commitment Protocol Comparison

| Property | 2PC | 3PC | Calvin | Spanner |
|---|---|---|---|---|
| Coordinator failure | Blocks cohorts | Cohorts self-resolve (timeout) | No coordinator after sequencer | Paxos group survives individual failures |
| Network partition | Blocks | Split brain possible | Safe (consensus on sequencer) | Safe (Paxos per shard) |
| Message rounds | 2 | 3 | 1 (sequencer) + execution | 2PC + Paxos rounds |
| Availability | Low (coordinator dependency) | Medium | High | High |
| Latency | Low | Medium | Low (batched epochs) | Higher (TrueTime wait + 2PC) |
| Used in | MySQL, PostgreSQL | Rarely in practice | FaunaDB | CockroachDB, YugaByte DB, Google Spanner |

### Transaction Model Comparison

| Model | Isolation | Prevents | Allows | Coordination |
|---|---|---|---|---|
| 2PC (basic) | Serializable | Dirty reads, lost updates | — | Per-transaction coordinator |
| Snapshot Isolation | SI | Read skew, dirty reads | Write skew | Timestamp oracle |
| Calvin | Serializable | All anomalies | — | Pre-execution sequencer only |
| RAMP | Read Atomic | Fractured reads, dirty reads | Write skew | Lightweight metadata |

## Worked Example

**2PC money transfer: debit Account A (Partition 1), credit Account B (Partition 2)**

1. **Prepare phase**: Coordinator sends `Propose(txn_id)` to Partition 1 and Partition 2.
   - Partition 1 checks it can debit Account A (sufficient funds, no conflicting lock). Votes YES, persists vote locally.
   - Partition 2 checks it can credit Account B. Votes YES, persists vote locally.
2. **Coordinator decision**: Both votes are YES → coordinator persists "commit" decision to its durable log.
3. **Commit phase**: Coordinator sends `Commit(txn_id)` to both partitions.
   - Both partitions apply the operation, release locks, and ACK.
4. **Failure scenario**: If coordinator crashes after step 2 but before step 3, cohorts wait. They can contact the backup coordinator, which reads the coordinator's durable log, sees the commit decision, and broadcasts it. Since commit decisions are unanimous, replaying from any participant's log is safe.

**Result**: Both partitions atomically transition from state A to state B, or neither does.

## Key Takeaways
1. Atomic commitment requires unanimity — even one cohort veto aborts the entire transaction; this is a fundamental availability trade-off not present in consensus algorithms
2. 2PC is simple and widely used but has a blocking flaw: coordinator failure leaves cohorts in limbo; mitigate with durable coordinator logs and backup coordinators (or use Paxos groups as cohorts)
3. 3PC eliminates blocking only in synchronous networks — network partitions introduce split brain, which is why 3PC is rarely used in real distributed systems
4. Calvin's key insight: if all replicas agree on execution order before acquiring locks, no cross-replica coordination is needed during execution — determinism is cheaper than coordination
5. Spanner's key insight: using Paxos groups as 2PC cohorts decouples individual node failures from transaction availability; TrueTime provides external consistency without global lock management
6. Snapshot isolation is not serializable — write skew can still occur; choose the isolation level deliberately based on application invariants
7. Consistent hashing minimizes partition rebalancing cost from O(K) to O(K/N) when cluster membership changes

## Connects To
- **Ch05 (Local Transaction Processing)**: This chapter is the distributed counterpart; 2PC execution phases map to local prepare/commit mechanisms described there
- **Ch11 (Replication and Consistency)**: Single-partition consistency models established here underpin the multi-partition guarantees 2PC must maintain
- **Ch12 (Anti-Entropy)**: Anti-entropy handles eventual consistency; distributed transactions provide stronger atomic guarantees when eventual consistency is insufficient
- **Ch14 (Consensus)**: Calvin and Spanner both use Paxos internally; consensus algorithms provide the fault-tolerant foundation on which distributed transactions are built
