# Patterns — Database Internals

## B-Tree Split
**When to use**: Node overflows (at-capacity) during insert.
**How**:
1. Allocate new sibling node
2. Copy right half of elements to new node (split point = N/2)
3. Place new element in correct node based on midpoint comparison
4. Promote midpoint key to parent; recurse if parent also overflows
5. If root splits: allocate new root, old root + sibling become children, height grows by 1
**Trade-offs**: Cascading splits are rare but O(height) worst case; rebalancing with siblings can postpone splits.

## B-Tree Merge
**When to use**: Node underflows (below minimum occupancy) after delete.
**How**:
1. After removing element, check occupancy against minimum threshold
2. Try redistribution (borrow from sibling) to avoid merge
3. If redistribution not possible: copy all right-node elements to left; demote separator key from parent; remove right node pointer
4. Recurse up if parent underflows; root with 1 child → child becomes new root, height decreases
**Trade-offs**: Merge propagation bounded by O(height); lazy compaction strategies (e.g., WiredTiger) delay merges in exchange for slightly lower occupancy.

## Slotted Page Layout
**When to use**: Store variable-length records in a fixed-size disk page.
**How**:
1. Header at page start: page metadata + pointer array (slot array)
2. Each slot = offset to a cell within the page
3. Cells grow from the end toward the slot array
4. Insert: add cell at end, append pointer to slot array
5. Delete: mark slot as empty; reclaim space via compaction when needed
**Trade-offs**: Allows in-place update of pointers without moving cells; fragmentation accumulates over time; compaction required periodically.

## Write-Ahead Log (WAL)
**When to use**: Ensure durability of updates and enable crash recovery.
**How**:
1. Before modifying any page: write log record to WAL (type + page ID + before-image + after-image + LSN)
2. WAL record must be on durable storage before the dirty page can be written
3. On commit: flush log tail to disk (fsync); do not require flushing dirty pages (No-Force policy)
4. On crash: replay WAL (ARIES: Analysis → Redo → Undo phases)
**Trade-offs**: Log-before-page guarantees recoverability; sequential log writes are fast (append-only); No-Force policy improves throughput but requires UNDO records for uncommitted changes.

## ARIES Recovery
**When to use**: Crash recovery for a WAL-based storage engine.
**How**:
1. **Analysis phase**: Scan WAL from last checkpoint → reconstruct dirty page table + active transaction table
2. **Redo phase**: Replay all logged updates from analysis start LSN → restore database to crash-time state (idempotent)
3. **Undo phase**: Roll back all incomplete transactions (write CLRs to make undo idempotent if another crash occurs)
**Trade-offs**: Supports Steal + No-Force (most efficient buffer policy); complex implementation; recovery time proportional to WAL between checkpoints.

## Copy-on-Write (CoW) B-Tree
**When to use**: Need MVCC-style snapshot reads + durability without in-place mutation (e.g., LMDB).
**How**:
1. On update: copy the path from root to the modified leaf (never modify in place)
2. Write new nodes to new locations on disk
3. Update parent pointers to point to new children (all new)
4. Old version remains intact → concurrent readers see old root and see a consistent snapshot
5. Garbage collect old pages when no readers reference them
**Trade-offs**: Every write copies O(height) pages = higher write amplification; excellent for read-heavy workloads + crash recovery is atomic (pointer to new root is either written or not).

## LSM Tree Write Path
**When to use**: Write-heavy workloads where write throughput > read throughput requirement.
**How**:
1. Write to WAL for durability
2. Write to in-memory memtable (skiplist or balanced BST)
3. When memtable reaches threshold: flush to immutable SSTable (sorted, on-disk)
4. Background compaction merges SSTables to reclaim space + reduce read amplification
**Trade-offs**: Sequential writes = max disk throughput; reads require checking memtable + multiple SSTable levels; compaction I/O competes with foreground writes; bloom filters mitigate read amplification.

## LSM Leveled Compaction
**When to use**: Minimize read amplification; better for read-heavy or mixed workloads (RocksDB default).
**How**:
1. L0: freshly flushed SSTables (overlapping key ranges permitted)
2. L1: size-limited; each key appears at most once; non-overlapping SSTables
3. Ln: each level 10× larger than Ln-1
4. When level is full: merge one or more SSTables with all overlapping SSTables in next level
**Trade-offs**: Low read amplification (at most 1 SSTable per level for point queries); high write amplification (~10× per level); predictable space usage.

## LSM Size-Tiered Compaction
**When to use**: Maximize write throughput; acceptable for write-dominant workloads.
**How**:
1. Group SSTables of similar size into tiers
2. When a tier has enough files: merge all files in the tier into one larger SSTable
3. No key-range exclusivity within a tier
**Trade-offs**: Low write amplification; high read amplification (must scan all tiers); high space amplification (old + new versions coexist during compaction); Cassandra default.

## Bloom Filter (LSM Read Optimization)
**When to use**: Skip SSTables that definitely don't contain a queried key.
**How**:
1. On SSTable creation: run each key through k independent hash functions; set those k bits in a bit array
2. On point query: hash the lookup key with same k functions; if ANY of the k bits is 0 → key definitely absent → skip SSTable
3. If all bits = 1 → key possibly present → read the SSTable
**Trade-offs**: False positive rate ε = (1 - e^(-kn/m))^k where n=keys, m=bits; ~10 bits/key gives ~1% false positives; no false negatives.

## Phi Accrual Failure Detection
**When to use**: Adaptive failure detection where network conditions vary over time.
**How**:
1. Track inter-arrival times of heartbeats from monitored node
2. Build a distribution (or sliding window) of historical intervals
3. Compute φ = -log₁₀(P(T > t_now)) where P is the survival function of the distribution
4. Trigger failure suspicion when φ exceeds application-defined threshold (e.g., φ_threshold = 8)
**Trade-offs**: Self-tuning to actual network behavior; higher φ = slower failure detection but fewer false positives; threshold is a tunable precision/recall dial.

## Gossip Protocol (Membership + Dissemination)
**When to use**: Propagate state updates to all nodes in a large cluster without centralized coordination.
**How**:
1. Each node maintains a member list with (address, heartbeat_counter, timestamp)
2. Periodically: pick k random nodes and send your member list (merge rules: higher heartbeat wins)
3. Nodes increment their own heartbeat counter each cycle
4. Mark node as suspected failed if its heartbeat hasn't incremented within failure timeout
5. Remove confirmed-dead nodes after cleanup timeout
**Trade-offs**: O(log N) rounds for full convergence; scales to thousands of nodes; eventual consistency of membership view; SWIM variant adds indirect probing to reduce false positives.

## Leader Election (Raft)
**When to use**: Elect a single leader in a replicated group using Raft consensus.
**How**:
1. All nodes start as followers; reset election timer on each heartbeat from leader
2. If election timer fires without heartbeat: become candidate, increment term, vote for self, send RequestVote RPCs
3. Vote granted if: recipient has not voted this term AND candidate's log is at least as up-to-date
4. Candidate that collects majority votes → becomes leader; sends heartbeats to suppress other elections
5. Randomized election timeout (150–300ms) prevents split votes
**Trade-offs**: Guaranteed at most one leader per term; randomized timeouts prevent perpetual split votes; log completeness check ensures only candidates with all committed entries can win.

## Two-Phase Commit (2PC)
**When to use**: Atomically commit a transaction across multiple distributed participants.
**How**:
1. **Prepare phase**: coordinator sends Prepare to all participants; each participant writes to WAL and votes Commit/Abort
2. **Commit phase**: if all voted Commit → coordinator writes Commit to WAL, sends Commit to all participants; else sends Abort
3. Participants acknowledge; coordinator writes completion to log
**Trade-offs**: Blocking: if coordinator fails after Phase 1, participants are stuck (hold locks); solutions: presumed-abort logging, 3PC (adds non-blocking phase but not partition-tolerant), or Paxos-based coordinators.

## Paxos Consensus
**When to use**: Reach agreement on a single value in a distributed system with crash-stop failures.
**How**:
1. **Phase 1a (Prepare)**: proposer sends Prepare(n) with ballot n to majority of acceptors
2. **Phase 1b (Promise)**: acceptor promises not to accept any ballot < n; returns highest accepted value if any
3. **Phase 2a (Accept)**: proposer sends Accept(n, v) where v = highest returned value or proposer's own value
4. **Phase 2b (Accepted)**: acceptor accepts if ballot still ≥ its promised ballot
5. Value is committed when a majority accepts
**Trade-offs**: Correct under crash-stop failures; two round trips minimum; Multi-Paxos optimizes steady-state to one round trip by electing a stable leader.

## Raft Log Replication
**When to use**: Replicate a totally ordered command log across a cluster.
**How**:
1. Client sends command to leader
2. Leader appends to local log with current term + index
3. Leader sends AppendEntries RPC to all followers in parallel
4. Entry committed when majority acknowledges
5. Leader applies command to state machine and responds to client
6. Leader includes commit index in next heartbeat/AppendEntries; followers apply when they see commit advance
**Trade-offs**: Linearizable reads require either log-round-trip or lease-based reads; followers can serve stale reads; leader failure triggers new election (brief unavailability).

## Merkle Tree Anti-Entropy
**When to use**: Efficiently detect and repair divergence between two replicas that may have millions of keys.
**How**:
1. Partition key space into leaf ranges; compute hash of each leaf's data
2. Build binary tree bottom-up: internal node hash = hash(left_child || right_child)
3. To sync: exchange root hashes; if equal → done; if different → recurse into differing subtrees
4. Leaf ranges that differ → exchange actual data to repair
**Trade-offs**: O(k log N) messages to find k differences among N keys; tree must be rebuilt/updated on writes (or built lazily on demand); used in Cassandra, Riak, DynamoDB for background repair.

## Read Repair
**When to use**: Lazy anti-entropy on the read path in a quorum-replicated system.
**How**:
1. Read coordinator contacts all replicas for a key (even if only R out of N required for quorum)
2. Compare versions using timestamps or vector clocks
3. If any replica returns a stale version → coordinator sends the latest version to the stale replica asynchronously
**Trade-offs**: Self-healing without a background job; read latency is the max of all contacted replicas; read-heavy workloads converge faster; write-heavy or infrequently-read keys may stay stale.

## Hinted Handoff
**When to use**: Maintain write availability when a target replica is temporarily unavailable.
**How**:
1. When write cannot reach replica R (it's down), another node stores the write with a "hint" (metadata: intended for R)
2. When R recovers, the hint-holding node forwards the deferred write
3. Hint is deleted after successful forwarding
**Trade-offs**: Prevents write loss during temporary failures; hints can pile up during extended outages; hint holder needs its own durable storage; works best with short outages.

## MVCC (Multiversion Concurrency Control)
**When to use**: Allow reads and writes to execute concurrently without blocking each other.
**How**:
1. Each write creates a new version of the record (old version retained)
2. Each transaction gets a read timestamp at start
3. Reader sees the latest version with write_timestamp ≤ read_timestamp (snapshot isolation)
4. Writer creates new version with write_timestamp = current time
5. Old versions GC'd when no active transaction has a read timestamp before them
**Trade-offs**: Readers never block writers; writers never block readers; storage bloat from multiple versions requires periodic vacuum/GC; write-write conflicts still possible (detect at commit time).
