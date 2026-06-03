# Part III — Derived Data (Chapters 10–12)

Distilled from *Designing Data-Intensive Applications* by Martin Kleppmann (O'Reilly, 2017). Part III is about integrating *multiple* data systems — no single database satisfies all access patterns, so real applications combine datastores, indexes, caches, and analytics systems and move data between them.

### Systems of record vs derived data — the central distinction

- **System of record (source of truth)**: holds the *authoritative* version of the data. New data is written here first; each fact appears exactly once (normalized). On any discrepancy, the system of record is correct by definition.
- **Derived data system**: the result of *transforming or processing* data from another system. If lost, it can be **recreated from the source**. Examples: caches, denormalized values, secondary indexes, materialized views, recommendation/predictive summaries from logs. Derived data is *redundant* (it duplicates information) but essential for read performance.

A database is just a tool — whether it's a system of record or a derived system depends on *how you use it*. Being explicit about which data is derived from which other data **clarifies the dataflow** through an otherwise confusing architecture. This is the running theme of Part III.

---

## Chapter 10 — Batch Processing

Three styles of system:
- **Services (online)**: wait for a request, respond as fast as possible. Measured by *response time* and *availability*.
- **Batch processing (offline)**: take a large bounded input, run a job, produce output. Measured by *throughput* (time to crunch a dataset). No user waiting.
- **Stream processing (near-real-time)**: between the two — operates on events shortly after they happen (Chapter 11).

### Batch processing with Unix tools

A simple log analysis (counting top URLs from a web server log) with a pipeline `cat | awk | sort | uniq -c | sort -r | head` outperforms a naive in-memory program because `sort` *spills to disk and parallelizes* automatically. This illustrates the **Unix philosophy** (Doug McIlroy, 1964; Kernighan & Pike):
1. Make each program do *one thing* well.
2. Expect the output of every program to become the *input* to another (yet unknown) program — *uniform interface*.
3. Design and build to be tried early; throw away clumsy parts and rebuild.
4. Use *tools* to lighten a programming task.

The uniform interface is a **file (a stream of bytes), usually lines of text**. *Separation of logic and wiring* (`stdin`/`stdout`) lets programs compose freely. *Transparency* — inputs are immutable, you can inspect the pipeline at any stage, and you can write intermediate results to files for restartability. The limitation: pipes run on a *single machine* — that's where Hadoop/MapReduce comes in.

### MapReduce and distributed filesystems

MapReduce is "Unix tools writ large across thousands of machines." Where Unix tools use `stdin`/`stdout`, MapReduce reads and writes files on a **distributed filesystem** — **HDFS** (Hadoop Distributed File System), an open-source implementation of the Google File System idea: a *shared-nothing* design where each machine's disks are pooled into one large filesystem, with data **replicated** across machines (and erasure coding) for fault tolerance. HDFS scales to petabytes cheaply on commodity hardware.

**A MapReduce job** has four steps mirroring Unix:
1. Read input files, break into *records* (lines).
2. Call the **mapper** function on each record → it emits any number of `(key, value)` pairs (extract & transform; stateless, processes one record at a time).
3. **Sort** all key-value pairs by key (the framework does this, spilling to disk — the big distributed equivalent of Unix `sort`).
4. Call the **reducer** function on each key with its sorted collection of values → it produces output (aggregate).

**Distributed execution**: the scheduler places mapper tasks on machines that *already hold a copy of the input file* (**putting the computation near the data** to save network bandwidth). Mapper output is partitioned by key (hash) and sorted; reducers pull their partitions from all mappers (the *shuffle*). Materializing intermediate state to disk gives **fault tolerance** — a failed task is simply re-run.

**Reduce-side joins and grouping**: to join two datasets (e.g., user activity events × user profile DB) without slow per-record remote DB queries, MapReduce uses a **sort-merge join** — both inputs are mappers emitting the *join key* as the MapReduce key; the framework brings all records with the same key (activity events + the profile) together at the same reducer, which joins them. Also supports **GROUP BY** (emit the grouping key) — but watch for **skew / hot keys** (a celebrity user) causing one reducer to do far more work (mitigated by *skewed/sharded joins*).

**Map-side joins** (faster when applicable, no sort/reduce): a **broadcast hash join** loads a small dataset entirely into an in-memory hash table in every mapper (like a stream-table enrichment); a **partitioned hash join** works when both inputs are partitioned the same way; a **map-side merge join** works when both are partitioned *and sorted* the same way.

**Output of batch workflows**: not OLTP queries and not analytics reports, but typically **building derived data** — search indexes (Lucene/Solr/Elasticsearch index files built in bulk by MapReduce), or machine-learning models / recommendation systems / key-value stores to be loaded into a serving system. *Philosophy*: inputs are immutable, output is a *fresh complete dataset* (no in-place mutation). This makes jobs **idempotent and retryable** (a buggy run can be rolled back by reverting to the previous output — *human fault tolerance*), supports easy experimentation, and minimizes coupling (*separation of concerns* — the team producing data and the team consuming it are decoupled by the file interface).

**MapReduce vs distributed databases**: MPP (massively parallel processing) databases focus on efficient parallel SQL analytics. MapReduce offers more freedom (arbitrary code, any data format — *schema-on-read*, *"sushi principle": raw data is better*) and graceful fault tolerance at very large scale (frequent task failures over hours-long jobs). It pioneered taking *unstructured/messy* data and processing it without first loading it into a strict schema.

### Beyond MapReduce

MapReduce is robust but has drawbacks: every job **materializes intermediate state to HDFS** (replicated writes — slow), the next job can't start until the previous fully finishes (no pipelining), and mappers are often redundant. **Dataflow engines** — **Spark, Tez, Flink** — generalize MapReduce into a DAG of operators:
- They handle the whole workflow as one job, avoiding writing intermediate state to a distributed filesystem (keep it in memory or local disk).
- Operators are more flexible than the rigid map→reduce pattern; the scheduler can place operators to enable data locality.
- Fault tolerance: Spark uses **RDDs** (resilient distributed datasets) and tracks *lineage* (the deterministic computation that produced data) so lost data is recomputed rather than re-read from a replicated copy.

**Graphs and iterative processing**: for algorithms like PageRank that iterate over a graph repeatedly, the **Pregel / bulk synchronous parallel (BSP)** model has vertices "send messages" to each other across iterations, with state kept in memory between rounds (Apache Giraph, Spark GraphX, Flink Gelly).

**High-level APIs and languages**: Hive, Pig, Cascading, Spark DataFrames/SQL, Flink Table API let you write declarative joins and transformations; the engine chooses the join algorithm and optimizes — bringing the **declarative query optimizer** advantage to batch processing while retaining the freedom to drop into arbitrary code.

---

## Chapter 11 — Stream Processing

Batch processing operates on *bounded* data (known, finite size) — but real data is *unbounded* and arrives gradually. **Stream processing** runs continuously over an **unbounded** input, processing each event shortly after it occurs, giving lower latency than batch's fixed-window cadence. An **event** is a small, self-contained, immutable record of *something that happened* at a point in time, usually with a timestamp.

### Transmitting event streams

A *producer* (publisher/sender) generates events; *consumers* (subscribers/recipients) process them. Related events are grouped into a **topic** or **stream**. Polling a datastore is inefficient at low latency, so use dedicated tools:

- **Messaging systems** (publish/subscribe): two key questions characterize each — *(1) what if producers outpace consumers?* (drop messages, buffer in a queue, or apply backpressure/flow control); *(2) what if a node crashes — can messages be lost?* (durability via disk/replication costs throughput).
  - *Direct messaging* (UDP multicast, ZeroMQ, webhooks) — fast, but the application must handle loss.
  - **Message brokers** (RabbitMQ, ActiveMQ, message queues) — a durable server between producers and consumers that buffers, redelivers on crash, and decouples sender from recipient. Traditional brokers (JMS/AMQP style) use the *consume-and-delete* model: a message is deleted once acknowledged; multiple consumers on a queue *share* the load (load balancing) or *fan out* (each gets a copy). Ordering across consumers is not preserved when load-balancing with redelivery.
- **Partitioned logs** (Apache Kafka, Amazon Kinesis, Twitter DistributedLog) — a hybrid combining the durability of a database with the low latency of messaging. A **log** is an *append-only sequence of records* on disk, **partitioned** across machines (each partition a separate log) and **replicated**. Each message gets a monotonically increasing **offset** within its partition. A consumer reads sequentially and tracks its own offset; the broker doesn't delete on consume. Key consequences:
  - *Messages are retained* (until a size/time-based retention limit), so a slow or crashed consumer simply resumes from its last offset — **no message loss**, and you can *replay* old messages (re-process from any offset). This is impossible with consume-and-delete brokers.
  - *Order is preserved within a partition*.
  - *Consumer groups* parallelize by assigning whole partitions to consumers (parallelism is bounded by the number of partitions).
  - Acts as a durable, ordered, replayable buffer — the backbone of modern streaming architectures.

### Databases and streams

A **replication log** *is* a stream of database write events — Part II's leader-follower replication is stream processing. This insight unifies databases and streams:

- **Keeping systems in sync**: applications maintain copies of the same data in several systems (the OLTP database, a cache, a search index, a data warehouse). Keeping them consistent via *dual writes* (the app writes to each) is fraught — race conditions cause divergence, and partial failures break atomicity. Better: make one system the leader and **derive** the others from its change stream.
- **Change Data Capture (CDC)**: observe all writes to a system-of-record database (by parsing its replication log / binlog) and **emit them as a stream** that other systems (search indexes, caches, warehouses) subscribe to. The database is the leader; the derived systems are followers. (Debezium, Kafka Connect, Bottled Water, Maxwell.) With an initial *snapshot* + the ongoing change stream + *log compaction* (Kafka keeps the latest value per key forever, discarding older overwrites), you can rebuild a derived system from scratch at any time.
- **Event sourcing** (from the DDD community): instead of storing only the *current state* (and mutating it in place), store the **full, immutable, append-only log of events** that describe everything that happened ("user added item X to cart," "user removed item X"). The current state is a *derivation* (a left-fold/replay) of the event log. Differs from CDC: event-sourcing events are *application-level facts at the domain level* (the source of truth), modeled deliberately; CDC events are low-level row changes derived from a mutable DB. Benefits: a complete audit trail, the ability to reconstruct past states (time travel) and build *new* derived views (read models) retroactively from history, and easier debugging. Events are **immutable** — you never edit or delete a past event; a correction is a *new* compensating event.
- **State, streams, and immutability**: an immutable event log + materialized derived state generalizes the database. The same log can feed *many* read-optimized views (this is **CQRS** — Command Query Responsibility Segregation: separate the write side, which appends events, from the read side, which is any number of derived views optimized for queries). Advantages over mutable state: complete history for audit/recovery, ability to add new views later, recovery from buggy code by reprocessing. Costs: the log grows (mitigated by compaction/snapshots), and concurrency control / handling truly destructive deletes (e.g., GDPR erasure) need care.

### Processing streams

What you do with a stream once you have it:
- **Uses**: *complex event processing (CEP)* — search for patterns of events (Esper, fraud/intrusion detection); *stream analytics* — rolling aggregations and metrics over **windows** (count, average, rate over the last 5 minutes); *materialized view maintenance* — keep a cache/index/derived dataset up to date; *search on streams* — match each event against stored queries.
- **Reasoning about time** — the hardest part. Distinguish **event time** (when the event actually happened, per the producer's clock) from **processing time** (when the stream processor handles it). They differ because of buffering, network delays, broker queueing, consumer restarts, and reprocessing. Aggregating by processing time gives wrong results when events are delayed. **Straggler events** arrive after their window has been "closed" — you must decide to ignore them or emit a *correction*. A **watermark** declares "no more events earlier than time *t* are expected," letting windows finalize. *Window types*: **tumbling** (fixed, non-overlapping), **hopping** (fixed, overlapping), **sliding** (events within an interval of each other), **session** (group a user's activity, end after inactivity). Producer clock skew complicates assigning event time — record three timestamps (event time per device, send time per device, receive time per server) to correct for it.
- **Stream joins** (more challenging than batch joins because new events arrive anytime):
  - **Stream-stream join (window join)**: join two event streams within a time window — e.g., match a *search* event with a later *click* event by session ID, within one hour, to compute click-through rate. The processor maintains *state* (recent events indexed by join key) and emits a match (or a "no click" event when a search's window expires).
  - **Stream-table join (stream enrichment)**: augment each event with data from a database — e.g., add user-profile info to each activity event. To avoid slow per-event remote lookups, keep a **local copy** of the table in the stream processor (in-memory hash table or local index) and keep it fresh by *subscribing to the table's CDC changelog*. Effectively a join between the activity stream and the profile-changes stream (a conceptually infinite window where newer versions overwrite older).
  - **Table-table join (materialized view maintenance)**: maintain a derived materialized view from two changelogs — e.g., the Twitter home-timeline cache: when *u* tweets, append to every follower's timeline; on delete/unfollow, remove. The output is a continuously-maintained materialized view kept consistent with both input change streams.
  - *Time-dependence*: join results depend on state that changes over time, so reprocessing the same input may produce different results unless you version the state.
- **Fault tolerance & exactly-once**: batch processing achieves effective exactly-once semantics easily (re-run a failed task; discard partial output) because output is only visible when a job completes. Streams run forever, so you can't wait for "completion." Techniques:
  - **Microbatching** (Spark Streaming): break the stream into tiny batches (e.g., 1 s) and use batch fault tolerance per batch.
  - **Checkpointing** (Flink): periodically snapshot operator state to durable storage; on failure, roll back to the last checkpoint and replay.
  - These give **exactly-once semantics** (more precisely *effectively-once*) *only* if side effects are handled: make outputs **idempotent** (safe to apply twice — e.g., keyed writes, dedup by a monotonic ID), or use **distributed transactions / atomic commit** to tie the output and the offset advance together. Restarting from a checkpoint and replaying must not double-count.

---

## Chapter 12 — The Future of Data Systems

Kleppmann's synthesis: how to combine the tools from the whole book into correct, evolvable, humane applications.

### Data integration — composing specialized tools

No single tool does everything, so most applications combine several. The recurring answer is to **funnel all writes through an ordered event log and derive every other system from it asynchronously** — making the dataflow explicit (system of record → derived systems).

- **Combining specialized tools by deriving data**: when you need an OLTP store *and* a search index *and* a cache *and* a warehouse, don't dual-write — pick a system of record and use **CDC / event sourcing** to keep the derived systems in sync via a totally-ordered log. The log gives a single, authoritative ordering of writes, resolving the conflicts that plague dual writes.
- **Derived data vs distributed transactions**: distributed transactions (2PC, linearizable) achieve consistency by tight coupling and mutual exclusion, but are fragile and don't scale across heterogeneous systems. Log-based derived data achieves consistency *asynchronously* (eventually) but is far more robust, loosely coupled, and operationally simpler. Kleppmann argues **log-based derivation is the more promising approach** for large-scale integration, accepting some staleness.
- **Reprocessing data for evolution**: because derived data can be rebuilt from the log, you can **gradually evolve schemas and migrate to new systems** by running old and new derived views side by side (a *dual-running / gradual migration*), then switching over — far safer than a big-bang migration.
- **Lambda architecture and beyond**: the *Lambda architecture* runs a batch system (accurate, reprocessable, high-latency) alongside a stream system (fast, approximate) over the same immutable event log, merging their outputs. It's complex (two codebases). The trend (*Kappa* / *unifying batch and stream*) is toward a single engine that does both — treating batch as a bounded special case of streaming (Flink, Spark) and using log replay for reprocessing.

### Unbundling databases

A database bundles together a storage engine, a secondary-index/materialized-view mechanism, a replication system, and a query optimizer. Kleppmann's vision: **"unbundle" the database** into composable pieces connected by streams — treat the whole operating system / dataflow as one loosely-coupled database.

- **Composing storage technologies**: an index is a derived dataset; replication is a stream; a materialized view is a derived view. Build these *across* systems with a log as the integration backbone, rather than inside one monolithic DB. The log provides the ordering and durability; specialized systems provide the read paths.
- **Designing applications around dataflow**: think of application code as the **transformation functions** (the derivation logic) between a stream of input events and derived output state — "**dataflow: the application becomes a set of derivation functions**," analogous to a spreadsheet where changing one cell automatically propagates. *Stream processors and message logs become the substrate*; the application is the map/reduce/join logic. This blurs the line between database and application.
- **Observing derived state**: a **read** is also a derived view of the write log; you can push state to clients (subscribe to changes) instead of polling — extending the stream/dataflow model all the way to the user's device (real-time UIs that subscribe to a changelog), unbundling the read path too.

### Aiming for correctness

In a world of asynchronous, eventually-consistent derived data, how do you keep things correct?

- **The end-to-end argument**: low-level reliability mechanisms (TCP checksums, DB transactions) are *necessary but not sufficient*. True correctness (e.g., *exactly-once* processing, no duplicate payments) must be enforced **end to end**, at the application semantic level — typically with a unique **operation/request ID** that lets every layer deduplicate. You can't bolt correctness on solely at the storage layer.
- **Enforcing constraints** (uniqueness, "no negative balance," "no double-booking") in a distributed, log-based system without distributed transactions: route all operations affecting one constraint through a **single partition of an ordered log** so they're processed sequentially (the log's total order acts as the serialization point). Uniqueness becomes "the first event in the log to claim the value wins." This gives the strong constraint without 2PC, at the cost of partition-local coordination.
- **Timeliness and integrity**: separate two notions usually conflated under "consistency." **Timeliness** = users see *up-to-date* state (violations are temporary staleness — usually tolerable, self-correcting). **Integrity** = the data is *not corrupted*, no lost or duplicated facts (violations are permanent and serious). Log-based dataflow with idempotent, deterministic derivation gives *strong integrity* (no corruption) while relaxing *timeliness* (some lag) — often exactly the right trade-off. Most applications need integrity far more than they need linearizable timeliness.
- **Trust, but verify**: don't blindly assume hardware/software never corrupts data. Build systems that **continuously audit** their own integrity (checksums, comparing derived data against the source, self-validating), because over enough data and time, silent corruption *will* happen. Auditable systems (immutable event logs, deterministic derivations) make verification possible.

### Doing the right thing — ethics

Engineers building data-intensive systems carry real responsibility:
- **Predictive analytics** can encode and *amplify* bias (feedback loops in policing, hiring, credit scoring), discriminate, and deny people opportunities with no accountability or recourse. Correlation is not justification.
- **Privacy and surveillance**: pervasive tracking treats data collection as a default. Data is collected far beyond its stated purpose; "consent" is often meaningless; data is an asset that can leak, be breached, or be repurposed. Mass behavioral data collection has the character of surveillance.
- Kleppmann's call: treat user data with respect, collect only what's needed, be transparent, build in privacy and accountability, and *consider the human impact* of the systems we build — "this book is dedicated to everyone working toward the good."

---

## Part III — Key takeaways

- Distinguish the **system of record** (source of truth, written first) from **derived data** (caches, indexes, materialized views — recreatable from the source). Making derivation explicit clarifies the whole architecture.
- **Batch processing** (MapReduce / Spark / Flink) follows the **Unix philosophy** — immutable inputs, composable operators, fresh complete outputs — giving idempotency, easy experimentation, and human fault tolerance. Use it to build derived data (search indexes, ML models) at scale.
- **Stream processing** applies the same ideas to **unbounded** data with low latency. A **partitioned, replayable log (Kafka)** is the backbone; a database's replication log *is* a stream.
- **CDC** and **event sourcing** turn writes into a stream so you can keep heterogeneous systems in sync and rebuild derived views; **CQRS** separates the append-only write side from many read-optimized views. Always reason carefully about **event time vs processing time**, windowing, and stragglers.
- Prefer **log-based asynchronous derivation over distributed transactions** for integrating many systems — looser coupling, better fault tolerance, at the cost of eventual (not immediate) consistency.
- Enforce correctness **end-to-end** (idempotency via operation IDs), express constraints through a **single ordered log partition**, and value **integrity** (no corruption) above mere **timeliness** (no staleness). Build **auditable, self-verifying** systems — and weigh the **ethical** consequences of predictive analytics and data collection.
