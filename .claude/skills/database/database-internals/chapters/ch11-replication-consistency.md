# Chapter 11: Replication and Consistency

## Core Idea
Replication improves durability and availability but forces you to choose a consistency model — a contract that defines exactly which operations are visible to which readers and in what order — because atomically updating all copies is equivalent to solving consensus and is therefore expensive.

## Frameworks Introduced
- **Tunable Consistency (N/W/R quorums)**:
  - When to use: Eventually consistent stores (Cassandra, Dynamo) where you need to dial the consistency/availability trade-off per operation.
  - How: Set N = replication factor, W = write acknowledgment count, R = read response count. When R + W > N, read and write sets always overlap, guaranteeing the most recent write is visible. Decrease W or R to favor availability/latency; increase to favor consistency.

- **CRDTs (Conflict-Free Replicated Data Types)**:
  - When to use: Systems that must accept writes on any replica without coordination and reconcile later (shopping carts, counters, collaborative editing).
  - How: Define data structures whose merge operation is commutative, associative, and idempotent. Replicas apply operations locally; propagation can happen out of order; the merge function always produces the same final state regardless of delivery order.

- **CAP / PACELEC Framework**:
  - When to use: Architectural decision-making when choosing between CP and AP system designs.
  - How: CAP — under a network partition, choose either consistency (reject requests to preserve linearizability) or availability (serve potentially stale data). PACELC adds: even without partitions, choose between lower latency (weaker consistency) and higher consistency (more coordination cost).

## Key Concepts
- **Replication**: Maintaining multiple copies of data across nodes to improve durability, availability, and read throughput; introduces the problem of keeping copies in sync.
- **Quorum**: A majority of N/2 + 1 nodes; any two quorums share at least one node, guaranteeing overlap between the last write and any subsequent read.
- **Linearizability**: The strongest practical single-object consistency model; every write appears to take effect at a single indivisible point between its invocation and completion, and all subsequent reads observe it. No stale reads allowed after the linearization point.
- **Sequential consistency**: Weaker than linearizability; all processes see write operations in the same total order consistent with each individual process's program order, but there is no real-time bound — the order can lag wall clock time.
- **Causal consistency**: Only causally related operations must be seen in the same order by all processes; concurrent, causally unrelated writes may be observed in different orders by different nodes.
- **Eventual consistency**: If no new updates arrive, all replicas will eventually converge to the same value; no bound on when; conflict resolution (LWW or vector clocks) required for diverged states.
- **Vector clock**: A per-process logical clock vector used to establish partial causal order between events, detect conflicts, and reconstruct causal history without a global clock.
- **CRDT (Conflict-Free Replicated Data Type)**: A data structure whose merge function is commutative, associative, and idempotent, enabling convergent state without coordination.
- **Last-Write-Wins (LWW)**: Conflict resolution strategy that retains the write with the largest timestamp; simple but risks discarding concurrent writes.
- **Session guarantees**: Per-client consistency promises: read-your-writes, monotonic reads, monotonic writes, writes-follow-reads — collectively called PRAM/FIFO when combined.
- **Witness replica**: A replica that stores only metadata (write receipts) rather than full data records, used to satisfy quorum majority requirements at reduced storage cost; promotes to full copy replica during failure.

## Mental Models
- Use **linearizability** when correctness is non-negotiable (financial transactions, leader election state): think of the system as a single sequential machine — every operation appears to happen instantly at one point in time.
- Think of **CAP** as a dial, not a triangle: partition tolerance is not optional in real networks; you only choose between CP (reject writes/reads during a partition) and AP (serve potentially stale data).
- Think of **CRDTs** as math with commutativity: if `merge(A, B) = merge(B, A)` always holds, order of delivery never matters — you get convergence for free.
- Use **R + W > N** as a quick sanity check: if your quorum settings don't satisfy this inequality, you can read stale data even when the system is healthy.

## Anti-patterns
- **Confusing CAP consistency with ACID consistency**: CAP consistency means linearizability (atomic operations across replicas); ACID consistency means transaction invariants are preserved. They are orthogonal concepts; mixing them leads to wrong trade-off decisions.
- **Setting W=1, R=1 in an N=3 cluster**: No quorum overlap — reads can return stale data even without failures. Use R + W > N for any consistency guarantee.
- **Using LWW without synchronized clocks**: LWW relies on timestamps to resolve conflicts; clock skew across nodes can cause newer writes to be silently discarded. Use logical/vector clocks when physical clock accuracy is not guaranteed.
- **Stacking eventually consistent systems**: Combining two AP stores does not produce a stronger consistency guarantee. Consistency models are per-system; cross-system operations require explicit coordination.
- **Treating eventual consistency as "consistent enough"**: Eventual is a liveness guarantee with no time bound. Under high write rates with poor anti-entropy, replicas may diverge indefinitely in practice.

## Reference Tables

### Consistency Model Hierarchy (strongest to weakest)

| Model | Order Guarantee | Stale Reads | Implementation Cost | Real-Time Bound |
|---|---|---|---|---|
| Strict consistency | Global instantaneous | None | Impossible in practice | Yes |
| Linearizability | Total, real-time | None | High (consensus) | Yes |
| Sequential consistency | Total, program-order | Possible (no time bound) | Medium | No |
| Causal consistency | Causal order only | For unrelated writes | Medium (vector clocks) | No |
| PRAM / FIFO | Same-origin order only | For cross-origin writes | Low | No |
| Eventual consistency | None guaranteed | Yes | Low | No |

### Session Guarantees

| Guarantee | What It Ensures | Example Violation Without It |
|---|---|---|
| Read-your-writes | After write(x, V), read(x) returns V or later | User updates profile; immediately re-reads old value |
| Monotonic reads | read(x) never returns a value older than a previous read | User refreshes feed; sees older posts |
| Monotonic writes | Writes from same client propagate in program order | Client's write V2 appears before V1 on replicas |
| Writes-follow-reads | Write after read is ordered after the read's write | Responding to a post that hasn't propagated yet |

### Quorum Configuration Trade-offs (N = 3)

| W | R | R+W>N? | Consistency | Availability |
|---|---|---|---|---|
| 3 | 1 | Yes (4>3) | Strong (any node has latest) | Low (all nodes must be up for write) |
| 2 | 2 | Yes (4>3) | Strong (quorum overlap) | Medium (tolerates 1 failure) |
| 1 | 3 | Yes (4>3) | Strong (all nodes read) | Low (all nodes must be up for read) |
| 1 | 1 | No | Eventual | High |
| 2 | 1 | No | Eventual | Medium |

### Conflict Resolution Strategies

| Strategy | Mechanism | Data Loss Risk | Complexity |
|---|---|---|---|
| Last-Write-Wins (LWW) | Highest timestamp survives | Yes (concurrent writes) | Low |
| Vector clocks | Causal history tracked; conflicts surfaced | No (conflicts visible) | Medium |
| CRDT | Merge function guarantees convergence | No | Low-Medium (data-type dependent) |
| Multi-value register | All conflicting versions stored for app to resolve | No | High (app must reconcile) |

## Worked Example
**Tunable Consistency — Cassandra N=3, W=2, R=2:**
1. Client writes `user:42 → {name: "Alice"}` to coordinator.
2. Coordinator forwards to all 3 replicas; waits for 2 acks (W=2). Node 3 is slow.
3. Write succeeds after nodes 1 and 2 ack. Node 3 gets the write asynchronously via anti-entropy.
4. Client reads `user:42`; coordinator contacts nodes 1 and 2 (R=2). Since W+R=4 > N=3, at least one of the read nodes has the latest value.
5. Coordinator returns the most recent version seen across the R responses.

**CRDT Grow-Only Counter — 3 nodes, network partition:**
1. Partition isolates Node 1 from Nodes 2, 3.
2. Node 1 increments: vector `[1→3, 2→0, 3→0]`. Nodes 2 and 3 increment: vectors become `[1→0, 2→2, 3→1]`.
3. Partition heals. Nodes merge: `merge([3,0,0], [0,2,1]) = [3,2,1]`. Sum = 6. No writes were lost.

## Key Takeaways
1. Replication and consistency are inseparable: the moment you have more than one copy, you must choose which consistency model governs their divergence.
2. Linearizability is the gold standard but requires coordination equivalent to consensus — use it only where correctness is more important than latency.
3. R + W > N is the quorum inequality that guarantees a read will always overlap with the most recent completed write; verify your cluster settings satisfy it.
4. CAP partition tolerance is not tunable — networks partition; you only choose how to behave when they do (reject requests vs. serve stale data).
5. Session guarantees (read-your-writes, monotonic reads, monotonic writes, writes-follow-reads) are the client-centric contract that makes eventually consistent systems usable in practice.
6. CRDTs provide Strong Eventual Consistency for specific data types by making conflict resolution a mathematical property of the data structure itself, eliminating the need for coordination.
7. Witness replicas reduce storage overhead in quorum systems without sacrificing the overlap guarantee, by temporarily storing full records only during failures.

## Connects To
- **Ch09**: Failure detection determines when replicas are considered down, which affects quorum availability calculations.
- **Ch10**: Leader election establishes the single writer in primary-replica replication, and epoch/term fencing prevents split-brain writes from corrupting replicated state.
- **Ch12**: Anti-entropy protocols (read repair, Merkle trees, gossip) are the mechanisms that drive convergence in eventually consistent systems toward the guarantees described here.
- **Ch14**: Consensus algorithms (Paxos, Raft) implement linearizable replication by combining leader election, quorum writes, and epoch-based fencing into a unified protocol.
- **Ch05**: ACID consistency (transaction invariants) is a different and orthogonal property from CAP consistency (linearizability across replicas) — both matter, but they solve different problems.
