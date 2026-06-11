# Part II — Distributed Data (Chapters 5–9)

Distilled from *Designing Data-Intensive Applications* by Martin Kleppmann (O'Reilly, 2017). Part II moves from a single machine to data distributed across many machines.

**Why distribute?** *Scalability* (load beyond one machine), *fault tolerance / high availability* (survive machine/datacenter failure), *latency* (place data near users geographically). Two ways to spread a load: **replication** (keep copies of the same data on several nodes — Ch 5) and **partitioning/sharding** (split data into subsets on different nodes — Ch 6); usually combined.

*Shared-nothing architecture* (horizontal scaling): each node (machine/VM) has its own CPU, RAM, disk; coordination happens at the software level over a conventional network. Cheap and flexible, but pushes complexity onto the application and constrains the data model. (Contrast: *shared-memory* — one big machine, scaling-up; *shared-disk* — independent CPUs/RAM, shared disk array over a network.)

---

## Chapter 5 — Replication

Keeping a copy of the same data on multiple nodes. Hard part: handling **changes** to replicated data. Three algorithms: **single-leader, multi-leader, leaderless**.

### Leaders and followers (single-leader / master–slave)

One replica is the **leader (master/primary)**; clients send all **writes** to the leader, which writes to its local storage and sends the change to all **followers (read replicas/secondaries)** via a *replication log* / *change stream*. Followers apply changes in the same order. **Reads** can go to the leader *or* any follower; **writes** only to the leader. Built into PostgreSQL, MySQL, Oracle Data Guard, SQL Server AlwaysOn; MongoDB, RethinkDB; message brokers Kafka & RabbitMQ.

**Synchronous vs asynchronous replication:**
- *Synchronous*: leader waits for the follower's confirmation before reporting success. Pro: the follower is guaranteed up to date; if the leader fails, data is safe on the follower. Con: if the synchronous follower doesn't respond, writes block.
- *Asynchronous*: leader sends and doesn't wait. Pro: leader keeps processing even if followers lag. Con: a write confirmed to the client can be **lost** if the leader fails before propagating — durability is weakened.
- **Semi-synchronous**: usually one follower synchronous, the rest asynchronous; if the sync follower slows, an async one is promoted to sync. Guarantees an up-to-date copy on ≥2 nodes.
- Fully asynchronous is widely used despite the durability risk (especially with many or geo-distributed followers). *Chain replication* (used in Azure Storage) is a synchronous variant that performs well.

**Setting up new followers** without downtime: (1) take a consistent snapshot of the leader (no lock, as for backups), (2) copy it to the new follower, (3) the follower requests all changes since the snapshot's exact position in the replication log (PostgreSQL: *log sequence number*; MySQL: *binlog coordinates*), (4) when caught up, it processes the live change stream.

**Handling node outages:**
- *Follower failure — catch-up recovery*: each follower logs the changes it received; on restart it knows the last transaction processed and requests the rest from the leader.
- *Leader failure — failover*: promote a follower to new leader, reconfigure clients and other followers. Failover is fraught:
  - With async replication, the new leader may not have all the old leader's writes → **lost writes**. If the old leader rejoins, conflicting writes are usually *discarded*, which can violate other systems' durability (a notorious GitHub incident: discarded MySQL writes were still referenced by Redis → privacy violation).
  - **Split brain**: two nodes both believe they're leader, both accept writes, data is corrupted. Some systems shut a node down if two leaders are detected (risk: shut both down — STONITH).
  - Choosing the right *timeout* before declaring the leader dead: too short → unnecessary failovers under load spikes; too long → longer downtime.

**Implementation of replication logs:**
- *Statement-based*: ship the SQL statements. Broken by nondeterminism (`NOW()`, `RAND()`), autoincrement order, side-effecting triggers. Largely abandoned.
- *Write-ahead log (WAL) shipping*: ship the byte-level log (used by PostgreSQL, Oracle). Tightly coupled to the storage engine version → cannot run different DB versions on leader & followers (no zero-downtime upgrades).
- *Logical (row-based) log replication*: a separate log describing row-level writes (MySQL binlog in row mode). Decoupled from the storage engine → easier upgrades and external consumption (**change data capture** — Ch 11).
- *Trigger-based*: application-level triggers replicate selected data; more flexible, more overhead, more bug-prone.

### Problems with replication lag

Eventual consistency: with async followers, a read on a lagging follower returns stale data, but if writes stop, followers eventually converge. Under load, lag can be seconds or minutes — visible to users. Three specific anomalies and their guarantees:

- **Reading your own writes** (read-after-write consistency): a user who submits data and then views it must see their own update (others may see it later). Achieve by: reading user-modifiable data from the leader (or a recent-enough follower); tracking the timestamp of the user's last write and only reading from followers caught up past it; for cross-device consistency, the timestamp must be centralized.
- **Monotonic reads**: a user must not see data *moving backward in time* (reading from a fresh follower then a lagging one). Guarantee by making each user always read from the *same* replica (e.g., chosen by a hash of user ID). Weaker than strong consistency, stronger than eventual.
- **Consistent prefix reads**: if writes happen in a certain causal order, anyone reading them sees them in that order — prevents seeing an answer before its question. A problem in partitioned databases where partitions replicate independently with no global ordering. Solution: keep causally related writes in the same partition, or track causal dependencies.

The cure for many lag problems is **transactions** (single-node ones were taken for granted; distributed systems abandoned them for performance, then had to provide weaker guarantees — Ch 7, 9).

### Multi-leader replication

More than one node accepts writes; each leader is also a follower of the others. **Use cases:**
- *Multi-datacenter operation*: a leader per datacenter; writes are local (low latency), datacenters tolerate each other's outages and network problems. But conflicts can occur.
- *Clients with offline operation*: e.g., a calendar app on multiple devices — each device is a "datacenter" with a local DB (leader), syncing asynchronously (CouchDB is designed for this).
- *Real-time collaborative editing* (Google Docs, Etherpad): each user's local replica is a leader, changes sync asynchronously.

**Handling write conflicts** (the main downside): two leaders concurrently modify the same record.
- *Conflict avoidance* — route all writes for a given record through the same leader (simplest, but breaks if that leader must change).
- *Converging toward a consistent state* — every replica must end up with the same value. Strategies: **Last Write Wins (LWW)** (pick by timestamp/ID — *loses data*, and clock skew makes it unsafe); higher-replica-ID wins (loses data); merge values (e.g., concatenate); record the conflict and resolve in application code (on write or on read).
- *Custom conflict resolution logic* (application-provided handlers); automatic data structures: **CRDTs** (Conflict-free Replicated Data Types — sets, maps, counters that merge sensibly), *mergeable persistent data structures* (three-way merge like Git), *operational transformation* (the algorithm behind Google Docs).

**Multi-leader topologies** (how writes propagate among leaders): *circular*, *star*, *all-to-all*. All-to-all is most robust to a single link failure but suffers **causality problems** — an update may arrive before an insert it depends on (a consistent-prefix problem); *version vectors* are needed to order events correctly. (MySQL's default circular topology is especially fragile.)

### Leaderless replication (Dynamo-style)

No leader; any replica accepts writes directly (Amazon Dynamo internal; open-source Riak, Cassandra, Voldemort). The client (or a coordinator that does not enforce ordering) writes to *several* replicas.

- **Writing when a node is down**: the client sends a write to all *n* replicas in parallel and considers it successful after *w* acknowledgments; reads query *n* replicas and use *r* responses. The down node simply misses the write.
- **Read repair & anti-entropy**: catch up stale nodes. *Read repair* — when a read sees an old version on some replica, write the newer value back. *Anti-entropy* — a background process continuously copies missing data between replicas (no ordering guarantee, possibly significant delay).
- **Quorums**: if *w + r > n*, every read overlaps with at least one replica that has the latest write → you can read up-to-date data. Typical: *n* odd, *w = r = (n+1)/2*. Smaller *w* favors write availability; smaller *r* favors read availability.
- **Limitations of quorum consistency**: even with *w + r > n*, edge cases return stale data — sloppy quorums (below), concurrent writes (must merge), a write succeeding on some replicas and failing on others (not rolled back), a node restoring from an old replica dropping below *w* up-to-date copies, timing issues. **Quorums are not a guarantee of strong consistency**; Dynamo-style DBs are *eventually consistent*. No read-your-writes, monotonic-reads, or consistent-prefix guarantees by default.
- **Sloppy quorums and hinted handoff**: during a network partition, accept writes on *any* reachable *w* nodes (even those not among the "home" *n*) to maintain write availability; when the partition heals, those nodes forward the writes to the home nodes (*hinted handoff*). Increases write availability but further weakens the quorum guarantee.
- **Multi-datacenter**: *n* spans all datacenters; the client typically waits only for a local-datacenter quorum, replicating cross-datacenter asynchronously.

**Detecting concurrent writes:**
- Two writes are *concurrent* if neither *happened before* the other (neither knew about the other). Concurrency is about causal knowledge, not wall-clock time.
- **LWW** discards concurrent writes (data loss) — acceptable only when losing data is OK (e.g., a cache) or when keys are immutable.
- **The "happens-before" relation & version numbers** (single replica): the server keeps a version number per key, incremented on each write. A client must *read before write*, gets the latest version + all current values, then sends the write back with that version; the server keeps any values with a *higher* version (concurrent — *siblings* in Riak) and overwrites those at or below the given version. Merging siblings (e.g., set union with **tombstones** for deletes) is the application's responsibility; **CRDTs** automate it.
- **Version vectors**: with multiple replicas you need a version number *per replica per key* — the collection is a *version vector* (Riak 2.0 uses *dotted version vectors*). It tells which values to overwrite and which to keep as siblings, and lets clients merge safely without losing data.

---

## Chapter 6 — Partitioning (Sharding)

Breaking a large dataset into **partitions** (a.k.a. *shard* in MongoDB/Elasticsearch/SolrCloud, *region* in HBase, *tablet* in Bigtable, *vnode* in Cassandra/Riak, *vBucket* in Couchbase). Each record belongs to exactly one partition; each partition is a small database of its own. Main reason: **scalability** — distribute data and query load across a shared-nothing cluster. (Unrelated to *network partitions* / netsplits in Ch 8.)

**Partitioning + replication** are combined: each partition is replicated on several nodes (e.g., each partition has a leader on one node and followers on others). The choice of partitioning scheme is mostly independent of the replication scheme.

The goal is **even distribution** of data and load. Uneven = **skew**; an overloaded partition = a **hot spot**. Random assignment spreads load but makes reads query all nodes (you can't find a key), so:

### Partitioning of key-value data

- **By key range** (like an encyclopedia's volumes): each partition owns a contiguous, sorted range of keys; ranges need not be evenly spaced (chosen to balance data). Pro: efficient **range scans** (keys are sorted). Con: **hot spots** if the access pattern concentrates on adjacent keys — e.g., a timestamp key makes *all* of today's writes hit one partition. Mitigate by prefixing the key (e.g., with the sensor name) so writes spread out (but then a range scan over time requires querying all prefixes). Used by HBase, Bigtable, RethinkDB, MongoDB (older). Partitions are typically **split dynamically** when too big.
- **By hash of key**: apply a hash function to the key, give each partition a range of hashes. Pro: distributes load evenly even for sequential keys. Con: **destroys key ordering → range queries become inefficient** (must scatter to all partitions; Cassandra allows a *compound primary key* — hash the first column for partitioning, sort by the rest). ⚠️ Don't use a language's built-in hash (e.g., Java's `Object.hashCode`) — it may differ across processes.
- **Relieving hot spots**: even hash partitioning can't help a single hot key (e.g., a celebrity's user ID receiving a flood of writes). The application must split it — e.g., append a random number to the key to fan it across partitions — at the cost of extra read work to recombine.

### Partitioning and secondary indexes

Secondary indexes complicate partitioning because they don't map neatly to one partition. Two methods:

- **Document-partitioned (local) indexes**: each partition keeps the secondary index for *its own documents only*. A write touches just one partition. But a query on the secondary index must **scatter/gather** — query *all* partitions and combine (prone to tail-latency amplification). Used by MongoDB, Cassandra, Elasticsearch, SolrCloud, Riak.
- **Term-partitioned (global) indexes**: the secondary index itself is partitioned by the *indexed term/value* (possibly on different nodes from the primary data). A read goes to the single partition holding that term (fast reads). But a write may need to update *several* index partitions (slow writes; often updated asynchronously, so the index is slightly stale). Used by Amazon DynamoDB global secondary indexes, Riak's search, Oracle data warehouse.

### Rebalancing partitions

Moving load between nodes when you add/remove machines or a node fails. Requirements: distribute load fairly, keep the DB serving during rebalance, move only as much data as necessary.

- **Don't use `hash mod N`**: changing *N* moves almost every key. Bad.
- **Fixed number of partitions**: create many more partitions than nodes up front (e.g., 1000 partitions on 10 nodes); a new node *steals* whole partitions from existing nodes. Only entire partitions move; the assignment changes, not the partition of any key. (Riak, Elasticsearch, Couchbase, Voldemort.) Choosing the count is a one-time guess that bounds future scaling.
- **Dynamic partitioning**: partitions split when they exceed a size threshold and merge when they shrink (like a B-tree). The number adapts to the data volume. (HBase, RethinkDB, MongoDB.) An empty DB starts with one partition (a bottleneck until the first split — *pre-splitting* helps).
- **Partitioning proportionally to nodes**: a fixed number of partitions *per node* (Cassandra, Ketama); adding a node splits a few existing partitions randomly.
- **Operations**: fully automatic rebalancing is convenient but dangerous (it can cascade with failure detection and overload the network) — keeping a *human in the loop* is often wise.

### Request routing (service discovery)

How does a client find which node holds a key? Three approaches: (1) clients contact any node, which forwards as needed; (2) a *routing tier* / partition-aware load balancer forwards; (3) clients are partition-aware and connect directly. The routing component must learn assignment changes — often via a separate coordination service like **ZooKeeper** (which tracks the authoritative mapping and notifies subscribers). Cassandra & Riak use a *gossip protocol* among nodes instead. **Parallel query execution** (MPP — massively parallel processing) engines break a complex analytic query into stages run across many partitions in parallel.

---

## Chapter 7 — Transactions

A **transaction** groups several reads/writes into one logical unit: it either entirely **commits** (succeeds) or **aborts/rolls back** (fails, safe to retry). The point is to simplify the application's error handling by letting the database handle partial-failure and concurrency cases (*safety guarantees*). Transactions are not a law of nature; weakening or abandoning them can buy performance/availability. The question is which guarantees you need and at what cost.

### The meaning of ACID

Coined 1983 (Härder & Reuter). In practice implementations vary wildly — ACID has become a vague marketing term; *BASE* ("Basically Available, Soft state, Eventual consistency") really just means "not ACID."

- **Atomicity** — a transaction's writes are all-or-nothing; if it aborts (or the process crashes mid-way), all its writes are discarded. *Not* about concurrency. Better called *abortability*. Lets the application safely retry.
- **Consistency** — application-defined *invariants* hold true (e.g., credits = debits). This is a property of the *application*, not the database — the DB can only enforce certain constraints (foreign keys, uniqueness); the application defines what "valid" means. (The "C" arguably doesn't belong in ACID.)
- **Isolation** — concurrently executing transactions don't step on each other; the result is as if they ran *serially* (the strongest form, *serializability*). In practice databases offer *weaker* isolation levels for performance.
- **Durability** — once committed, data survives crashes (written to nonvolatile storage / WAL; in replicated systems, copied to enough nodes). Perfect durability doesn't exist (every disk can fail; every replica can be lost); it's about reducing risk.

**Single-object vs multi-object operations:** Atomicity & isolation usually apply to *multi-object* transactions (modifying several rows/documents/keys at once — e.g., an email app updating both a message and an unread counter; without atomicity, a crash leaves them inconsistent; without isolation, a concurrent reader sees one updated and the other not). Multi-object transactions need a way to tell which operations belong together (relational DBs: `BEGIN…COMMIT`). Single-object writes also need atomicity & isolation at the storage level (e.g., a partial write of a 20 KB JSON document, or a crash mid-increment). Many NoSQL DBs offer only single-object atomic operations (compare-and-set, increment) — not true multi-object transactions. *Leaderless replication is where you're most likely to need to handle retries and partial failures yourself.*

### Weak isolation levels

Serializable isolation has a performance cost, so most databases default to weaker levels that prevent *some* concurrency anomalies but not all. **You must know which anomaly each level prevents.**

- **Read Committed** (the most common default): two guarantees — (1) **no dirty reads** (you only read data that has been committed — never another transaction's uncommitted writes), (2) **no dirty writes** (you only overwrite data that has been committed — concurrent writes to the same object are serialized so the later write waits for the earlier transaction to commit/abort). Implemented by row-level locks for writes, and (to avoid readers waiting) by remembering both the old committed value and the new value, serving the old value to readers until commit. Does **not** prevent *read skew* (non-repeatable reads).
- **Snapshot Isolation and Repeatable Read**: each transaction reads from a *consistent snapshot* — all data as it was committed at the moment the transaction started. Prevents **read skew / non-repeatable reads** (e.g., a backup or analytic query that reads the DB over time seeing some rows pre-transfer and others post-transfer; or seeing different balances mid-transfer). Implemented with **MVCC (Multi-Version Concurrency Control)**: the DB keeps multiple committed versions of each object (tagged with transaction IDs); each transaction sees the versions that were committed before it began and ignores writes from later or uncommitted transactions. "Readers never block writers, writers never block readers." (PostgreSQL, MySQL/InnoDB, Oracle, SQL Server.) Confusingly named — "repeatable read" in different DBs means different things.
- **Preventing lost updates**: two transactions do read-modify-write on the same object concurrently; one overwrites the other (a *lost update*) — e.g., two increments yielding +1 instead of +2, or concurrent edits to a wiki page or JSON document. Snapshot isolation alone does *not* prevent lost updates. Solutions:
  - **Atomic write operations** (DB-provided `UPDATE … SET v = v + 1`, increment, compare-and-set) — preferred when applicable.
  - **Explicit locking** (`SELECT … FOR UPDATE`) — the application locks the rows it will modify.
  - **Automatic detection** — let transactions run in parallel; the DB detects a lost update and aborts the loser, which retries (PostgreSQL repeatable read, Oracle serializable detect this; MySQL/InnoDB repeatable read does *not*).
  - **Compare-and-set** — only write if the value hasn't changed since you read it (works only if reads see current data, not a snapshot).
  - In replicated/multi-leader/leaderless settings, atomic ops and locks don't suffice; use conflict resolution / merge siblings / commutative atomic ops (LWW loses data).
- **Write skew and phantoms**: a generalization where two transactions read *overlapping* objects, then update *different* objects, breaking an invariant that spans them. Classic example: *on-call doctors* — at least one must be on call; two doctors each check "≥2 on call, so I can go off call," both go off, leaving zero. Snapshot isolation doesn't prevent it (they update different rows). Other examples: double-booking a meeting room, double-spending, claiming a username. A **phantom** is a write in one transaction changing the *result of a search query* in another (the rows you'd lock don't exist yet, so you can't lock them). Solutions: **explicit locks** on the rows the decision depends on (`FOR UPDATE`), **materializing conflicts** (creating lock rows artificially), or — cleanly — **serializable isolation**.

### Serializability

The strongest isolation: transactions behave *as if* executed one at a time, serially — eliminating *all* race conditions including write skew and phantoms. Three implementations:

- **Actual serial execution**: literally run transactions one at a time on a *single thread* (VoltDB/H-Store, Redis, Datomic). Feasible only because RAM is cheap (datasets fit in memory) and OLTP transactions are short. Requires structuring transactions as **stored procedures** (the whole transaction submitted at once, no interactive client round-trips stalling the single thread). Throughput is limited to one CPU core; partition the data to use multiple cores (but cross-partition transactions are much slower).
- **Two-Phase Locking (2PL)** (the traditional approach for ~30 years; *different from 2PC*): readers and writers block each other. *Shared locks* (read) and *exclusive locks* (write): many readers OR one writer per object; reads block writes and writes block reads (the key difference from snapshot isolation). Locks held until end of transaction ("two-phase": acquire during execution, release at commit/abort). Prevents phantoms via **predicate locks** (lock all objects matching a search condition, even nonexistent ones) or the practical **index-range locks** (lock a broader range). Cost: greatly reduced concurrency, latency, and frequent **deadlocks** (the DB detects and aborts a victim, which retries). Unstable latencies.
- **Serializable Snapshot Isolation (SSI)** (Cawthon/Ports & Grittner, ~2008; PostgreSQL ≥9.1, FoundationDB): an **optimistic** technique — let transactions proceed on a snapshot (like snapshot isolation), and *at commit time* check whether anything they read has changed in a way that breaks serializability; if so, abort and retry. Detects "stale premises" (decisions based on data that another transaction has since modified). Much better performance than 2PL when contention is low (no blocking, only aborts), and not limited to one core like serial execution. The abort rate rises with contention. The most promising general-purpose serializable approach.

---

## Chapter 8 — The Trouble with Distributed Systems

A pessimistic catalog of everything that can go wrong once you cross the network. In a single computer, an operation is deterministic — it works or the whole machine crashes (no in-between). In distributed systems, there is **no such determinism**: you face *partial failures* — some parts work while others fail in unpredictable, nondeterministic ways.

- **Cloud vs supercomputing philosophies**: HPC/supercomputers checkpoint and treat a partial failure as a total failure (restart the job). Cloud / internet services must be *always on*, tolerate node failures continuously, use commodity hardware (higher failure rates), and span unreliable wide-area networks. We must **build a reliable system from unreliable components** — but only up to a point; the fault is contained within a known reliability budget.

### Unreliable networks

Shared-nothing systems communicate only by an **asynchronous packet network**, which gives *no guarantees*: a message may be lost, queued/delayed, the remote node may have failed, or its reply may be lost. When you send a request and get no response, **you cannot tell why** (request lost? node down? node slow? reply lost? reply delayed?). The usual handling is a **timeout**, but a timeout doesn't tell you whether the node processed the request. Network faults are common even within a datacenter (a study found ~12 faults/month). *Network partitions / netsplits* — when one part of the network is cut off — must be *handled*, not necessarily prevented; untested partition handling can do arbitrary damage.

- **Detecting faults**: load balancers must stop sending to dead nodes; failover must promote a follower when a leader dies. But you usually can't reliably tell a node is dead (you may get a TCP RST if a process died, but not if the machine is down or the network is cut). You generally rely on timeouts.
- **Timeouts and unbounded delays**: no "correct" timeout. Too short → false positives (declaring a live-but-slow node dead, double-executing actions, cascading load onto other nodes). Too long → long waits to detect real failures. Network delay is **unbounded** in practice: queueing at switches (network congestion), at the destination OS, in the destination application, and TCP retransmission/flow control all add variable latency. *Latency is highly variable under load.* You can tune timeouts adaptively (measure round-trip distribution, e.g., Phi Accrual failure detector in Cassandra/Akka). **Synchronous networks** (traditional telephone circuits with reserved bandwidth — bounded delay) vs **asynchronous packet-switched networks** (the internet/Ethernet/datacenters — optimized for bursty throughput, no bounded delay). We use the latter and pay with unpredictable latency.

### Unreliable clocks

Time is critical (timeouts, TTLs, "last write wins," scheduled jobs, performance metrics) yet clocks across nodes are unreliable. Each machine has its own quartz clock that *drifts*; **NTP** synchronizes against servers but is itself subject to network delay and can only correct so much.

- **Two kinds of clocks**:
  - *Time-of-day clock* (wall clock, `clock_gettime(CLOCK_REALTIME)`, `System.currentTimeMillis`): returns calendar date/time, synced by NTP — but can **jump backward** (NTP correction), making it unsuitable for measuring elapsed time or ordering events.
  - *Monotonic clock* (`clock_gettime(CLOCK_MONOTONIC)`, `System.nanoTime`): always moves forward, good for measuring durations/intervals on one machine, but its absolute value is meaningless and you cannot compare it across machines.
- **Clock synchronization is unreliable**: drift, NTP server errors, leap seconds (which have crashed many systems), VM clock pauses, and large network delays all introduce error. Treat synchronized clocks as having **confidence intervals**, not exact points.
- **Relying on synchronized clocks is dangerous**: **LWW conflict resolution** using timestamps silently drops writes when clocks are skewed (a node with a fast clock always wins; causally later writes can be discarded). Ordering events by timestamp across nodes is unsafe. **Google Spanner** addresses this with the *TrueTime* API, which returns an explicit `[earliest, latest]` confidence interval and *waits out* the uncertainty (commit-wait) to guarantee ordering — requiring GPS/atomic clocks in every datacenter.
- **Process pauses**: a thread/process can **stop for an arbitrary, unbounded time** without warning — **stop-the-world GC pauses** (seconds to minutes), VM suspension/live migration, laptop lid close, CPU stealing by other VMs, slow synchronous disk I/O or page faults (swap thrashing), `SIGSTOP`. A leader that paused for longer than its lease timeout may *think* it's still the leader and act on a stale lease while another node has taken over → **split brain / dangerous concurrent action**. You can't assume any code runs within a bounded time. **Fencing tokens** (below) defend against this.

### Knowledge, truth, and lies

- **The truth is defined by the majority**: a node cannot trust its own judgment of the system state — it may have been declared dead by others (because of a pause or network issue) while still believing it's alive. Distributed algorithms rely on a **quorum** (an absolute majority of nodes) to make decisions, so a single node's faulty self-view can't break the system.
- **Leader and lock fencing**: when a resource grants a lock/lease to a node, a stale lease holder (e.g., one that paused) can corrupt data. The fix is a **fencing token** — a monotonically increasing number issued with each lock grant; every write to the protected resource includes its token, and the resource *rejects any write with a token lower than one it has already seen*. This prevents a stale leader's writes from taking effect.
- **Byzantine faults**: nodes that *lie* or behave arbitrarily/maliciously (corrupted, compromised, or buggy), not just crash-stop. **Byzantine fault-tolerant (BFT)** algorithms keep working if up to one-third of nodes are Byzantine — relevant for aerospace, blockchains, and adversarial multi-party systems, but usually **not worth the cost** inside a single trusted datacenter (the book's systems assume non-Byzantine nodes, but still defend against weak lies like corrupted packets via checksums and input validation).
- **System models**: to reason rigorously, define a *timing model* — **synchronous** (bounded delay — unrealistic), **partially synchronous** (usually bounded but occasionally not — realistic), or **asynchronous** (no timing assumptions at all) — and a *node-failure model* — *crash-stop*, *crash-recovery* (nodes can come back with stable storage intact), or *Byzantine*. Most real systems target the **partially-synchronous, crash-recovery** model. *Safety* ("nothing bad happens") must always hold; *liveness* ("something good eventually happens") may require timing assumptions.

---

## Chapter 9 — Consistency and Consensus

How to build fault-tolerant distributed systems with strong guarantees, despite everything in Chapter 8. The pinnacle is **consensus** — getting all nodes to agree on something.

### Consistency guarantees

Replication produces a *spectrum* of consistency models (distinct from ACID isolation, though related). **Eventual consistency** (a weak guarantee: "if you stop writing, replicas eventually converge") is what most replicated systems offer — but it's a poor foundation for application logic, because edge cases surface only under faults or high concurrency, and the bugs are hard to find. Stronger models cost performance/availability but are easier to use correctly.

### Linearizability (atomic consistency / strong consistency)

The strongest single-object consistency model: make the system *appear as if there is only one copy of the data*, and every operation is *atomic* and takes effect at a single point in time between its start and end. Once a read returns a new value, **all subsequent reads (by any client) must return that value or newer** — no going back. It's a *recency guarantee*.

- **Linearizable vs serializable**: serializability is about transactions (multiple objects) behaving as some serial order; linearizability is about single-object reads/writes being up to date in real time. *Strict serializability* = both.
- **When linearizability is needed**: *locks and leader election* (only one leader — built on linearizable storage like ZooKeeper/etcd), *uniqueness constraints* (one user per username, no negative balance), *cross-channel timing dependencies* (a message queue tells a worker to process an image the DB hasn't yet made visible → race without linearizability).
- **Implementing it**: single-leader replication *can* be linearizable (read from the leader, or from synchronously-updated followers) — but failover/split-brain breaks it. **Consensus algorithms** (Raft, Zab, Paxos) are linearizable and safely handle leader changes. Multi-leader and leaderless (even with strict quorums `w+r>n`) are generally **not** linearizable (clock-skewed LWW, concurrent writes, read repair timing).
- **The cost of linearizability — the CAP theorem**: if the network *partitions* (nodes can't reach each other), a system must choose: stay **Consistent** (linearizable) and refuse requests on the minority side (*unavailable*), or stay **Available** and serve possibly-stale data (*not linearizable*). CAP is **only** about this partition scenario — it's "*Consistent or Available when Partitioned*," not a general "pick 2 of 3." Many systems are not linearizable simply because it's slow (linearizability requires coordination/round-trips, hurting latency), not because of CAP. There is no efficient, fault-tolerant, linearizable design — it inherently trades latency and availability.

### Ordering guarantees

Ordering, causality, and consensus are deeply connected.

- **Ordering and causality**: **causality** imposes a *partial order* — some events are causally related (a question before its answer; a row created before it's updated), others are concurrent (incomparable). A system is **causally consistent** if it preserves the causal order of operations. Causal consistency is the **strongest consistency model that does not slow down under network partitions** — it remains available, unlike linearizability. Linearizability *implies* causality (it's a total order) but is stronger (and costlier) than needed for many cases.
- **Sequence number ordering**: to track causality cheaply, assign **sequence numbers / logical timestamps** that are consistent with causality (if A happened before B, A has a lower number). A single leader can hand out monotonically increasing numbers. Without a leader, use **Lamport timestamps** (each node has a counter + node ID; attach the max counter seen to every operation) — these produce a *total order consistent with causality*. But a total order known only *after the fact* isn't enough to, e.g., reject a duplicate username at the moment of the request — for that you need the order delivered *as operations happen*, which is total order broadcast.
- **Total order broadcast (atomic broadcast)**: a protocol delivering messages to all nodes in the *same order*, reliably. Two properties: *reliable delivery* (no message lost; if delivered to one non-faulty node, delivered to all) and *totally ordered delivery* (every node sees messages in the same order). Equivalent in power to consensus. It's exactly what you need to implement a replicated state machine, a linearizable log, fencing tokens, and serializable transactions. ZooKeeper/etcd implement it.

### Distributed transactions and consensus

- **Atomic commit & Two-Phase Commit (2PC)**: a multi-node transaction must commit atomically on *all* participating nodes or *none*. **2PC** uses a **coordinator** (transaction manager): *Phase 1 (prepare)* — the coordinator asks every participant "can you commit?"; each writes its data durably and answers *yes* (a promise it *cannot* later abort) or *no*. *Phase 2 (commit/abort)* — if all said yes, the coordinator durably records "commit" (*the commit point*) and tells everyone to commit; if any said no, it tells everyone to abort. Two points of no return: a participant's *yes* and the coordinator's *commit decision*. **The fatal flaw**: if the coordinator crashes *after* participants promised but *before* sending the decision, participants are stuck **in doubt** — holding locks, unable to commit or abort unilaterally — until the coordinator recovers. So **2PC is a blocking protocol; it is not fault-tolerant** of coordinator failure.
- **Distributed transactions in practice**: they carry a heavy performance penalty (extra disk forcing, network round-trips) and operational fragility. *Database-internal* distributed transactions (within one system across its nodes) can work well. *Heterogeneous* distributed transactions across different systems via **XA (X/Open XA)** two-phase commit are problematic — a crashed coordinator leaves orphaned in-doubt transactions holding locks, requiring manual intervention; the coordinator becomes a stateful single point of failure that must itself be replicated.
- **Fault-tolerant consensus**: the real solution. A consensus algorithm lets nodes **agree on a value** such that: *uniform agreement* (no two nodes decide differently), *integrity* (a node decides at most once), *validity* (the decided value was proposed by some node), and *termination* (every non-faulty node eventually decides — the *fault-tolerance* property, requiring a majority quorum to be alive). Termination is why consensus needs a majority: it can tolerate failures of a *minority* of nodes. The **FLP result** proves consensus is impossible in a *purely asynchronous* deterministic model — circumvented in practice by using timeouts/clocks (partial synchrony) or randomization. Real algorithms — **Raft, Zab (ZooKeeper), Paxos/Multi-Paxos, Viewstamped Replication** — all elect a leader and use total order broadcast; they implement linearizable, atomic operations. They depend on a quorum to vote, define *epoch/term/ballot numbers* (a fencing mechanism so a stale leader's proposals are rejected), and avoid split-brain. *Limitations*: voting overhead per decision, sensitivity to network timing (frequent leader elections under flaky networks can stall progress), needing a fixed set of voting members (dynamic membership changes are advanced).
- **Membership and coordination services** (**ZooKeeper, etcd**): not used directly as application databases, but as a foundation. They provide: a small amount of data held in memory & replicated via total order broadcast across a majority; *linearizable atomic operations* (compare-and-set — implement distributed locks & leases with fencing tokens, since the transaction ID can serve as a monotonic token); *total ordering of operations* (fencing tokens via the *zxid*); *failure detection* (sessions & heartbeats; ephemeral nodes vanish when a client dies, releasing locks); *change notifications* (watches). Used for **leader election**, **service discovery** (where are my service instances?), **membership** (which nodes are alive?), and partition/work assignment. Outsource the hard consensus problem to a small, well-tested cluster rather than reinventing it.

---

## Part II — Key takeaways

- **Replication** copies data; **partitioning** splits it; real systems combine both. Single-leader is simplest and can be linearizable; multi-leader & leaderless trade consistency for write availability/latency and force you to handle write conflicts (LWW loses data; prefer CRDTs/version vectors).
- Replication lag produces specific anomalies — design for **read-your-writes, monotonic reads, consistent prefix** as your application requires.
- Partition by **key range** (range scans, hot-spot risk) or **hash** (even load, no range scans); **rebalance** with a fixed or dynamic partition count, never `mod N`.
- Know exactly which **anomaly** each isolation level prevents: read committed (dirty reads/writes), snapshot isolation (read skew, but **not** lost updates or write skew), serializable (everything). Achieve serializability via serial execution, 2PL, or **SSI** (optimistic).
- In distributed systems assume **partial failure**: unbounded network delays, unreliable clocks (use monotonic clocks for durations; never trust wall-clock LWW), and unbounded process pauses. Defend stale leaders with **fencing tokens** and decide truth by **quorum/majority**.
- **Linearizability** is the strong recency guarantee (costly; CAP-limited under partition). **Causal consistency** is the strongest model that stays available under partition. **Consensus** (Raft/Zab/Paxos) and **total order broadcast** are the foundations of linearizable, fault-tolerant agreement — usually obtained from **ZooKeeper/etcd** rather than built from scratch. **2PC alone is blocking and not fault-tolerant**; fault-tolerant consensus is the answer.
