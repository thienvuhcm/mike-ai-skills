# Part I — Foundations of Data Systems (Chapters 1–4)

Distilled from *Designing Data-Intensive Applications* by Martin Kleppmann (O'Reilly, 2017). Part I covers concepts that apply to all data systems, whether running on a single machine or distributed across a cluster.

---

## Chapter 1 — Reliable, Scalable, and Maintainable Applications

### Thinking about data systems

A "data system" is an umbrella term. A single application increasingly stitches together many tools — databases, caches, search indexes, message queues, stream processors, batch processors — because no single tool meets all needs. The application code becomes responsible for keeping these systems consistent with each other. When you combine tools into a single service exposing one API, you have created a new, composite data system with its own guarantees.

Three concerns dominate the design of any data system:

- **Reliability** — the system continues to work *correctly* (right function, right performance) even in the face of *adversity* (faults).
- **Scalability** — as the system grows (data volume, traffic, complexity), there are reasonable ways of coping with that growth.
- **Maintainability** — over time, many people work on the system, and they can all do so productively.

### Reliability

A *fault* is one component deviating from spec; a *failure* is the system as a whole stopping service. You cannot reduce the probability of faults to zero, so design **fault-tolerant** systems that prevent faults from causing failures. Counterintuitively, it can make sense to *deliberately induce faults* (e.g., Netflix's Chaos Monkey) to test and exercise the fault-tolerance machinery.

**Three categories of faults:**

| Fault type | Nature | Mitigation |
|---|---|---|
| **Hardware faults** | Random, independent (disk crash ~MTTF 10–50 yrs, RAM errors, power loss) | Redundancy: RAID, dual power supplies, hot-swappable CPUs, backup generators. Increasingly also software fault-tolerance so whole machines can fail (rolling upgrades). |
| **Software errors** | Systematic, correlated across nodes (bad input triggers a bug in all instances, runaway process consuming a shared resource, cascading failures) | No quick fix: careful assumption checking, thorough testing, process isolation, allowing crash & restart, measuring/monitoring/alerting on behavior in production. |
| **Human errors** | Operators are the leading cause of outages | Well-designed abstractions/APIs/interfaces (make the right thing easy), decouple sandboxes from production, test thoroughly at all levels, allow quick & easy recovery (fast rollback, gradual rollout), detailed/clear monitoring, good management & training. |

### Scalability

Scalability describes the system's ability to cope with increased load. It is not a one-dimensional label ("X is scalable") — ask "if the system grows in a particular way, what are our options for coping?"

**Describing load** with *load parameters* — chosen for the architecture: requests/sec to a web server, ratio of reads to writes in a database, simultaneously active users in a chat room, cache hit rate. *Twitter's home timeline* is the book's example: the fan-out problem — should a tweet be (a) inserted into a global collection and pulled at read time (read-heavy join), or (b) fanned out to a per-user timeline cache at write time (write-heavy)? Twitter moved to (b), then a hybrid: celebrities with millions of followers are excepted from fan-out and merged in at read time.

**Describing performance:**
- *Throughput* — records processed per second (batch systems).
- *Response time* — the time between a client sending a request and receiving a response, as seen by the client (includes network delays and queueing). Distinct from *latency* (the duration a request is waiting to be handled).
- Use **percentiles, not the mean**: p50 (median) is the typical experience; **p95/p99/p999 (tail latencies)** matter because the slowest requests often belong to the most valuable customers (most data). Amazon targets p999 internally. *Head-of-line blocking*: a few slow requests hold up subsequent ones. *Tail latency amplification*: when one user request fans out to many backend calls, the slowest backend call dominates — so a backend's p99 becomes common at the user level.

**Approaches for coping with load:**
- *Scaling up* (vertical, a more powerful machine) vs *scaling out* (horizontal, distributing across many machines / shared-nothing).
- *Elastic* systems add resources automatically on load detection; others scale manually (simpler, fewer surprises).
- There is **no magic "scalable architecture"** — an architecture is built around assumptions about which operations are common and which are rare (the load parameters). Premature scaling for load you don't have is wasted effort and inflexible design.

### Maintainability

The majority of software cost is in ongoing maintenance, not initial development. Three design principles:

- **Operability** — make it easy for operations teams to keep the system running smoothly: good monitoring, support for automation & standard tools, avoiding single-machine dependency, good documentation, predictable behavior, self-healing defaults with manual override.
- **Simplicity** — manage complexity so new engineers can understand the system. Distinguish *essential* complexity (inherent in the problem) from *accidental* complexity (arising from the implementation only). The best tool for removing accidental complexity is **abstraction** — a good abstraction hides implementation detail behind a clean facade and is reusable.
- **Evolvability** (extensibility / modifiability / plasticity) — make it easy to adapt to changing requirements. Closely tied to simplicity: simple, well-abstracted systems are easier to change. Agile working patterns and TDD/refactoring operate at the code level; this is the data-system-level analogue.

---

## Chapter 2 — Data Models and Query Languages

Data models are the most important part of developing software: they shape not just how the software is written but how we *think about the problem*. Each layer hides the complexity of the layers below by providing a clean data model.

### Relational model versus document model

- **Relational model** (Codd, 1970; SQL): data organized into *relations* (tables) of *tuples* (rows). Dominated for decades, generalizing far beyond its original business-data-processing scope. Roots in *business data processing* — transaction processing and batch processing.
- **The birth of NoSQL** (2010s): driven by (1) need for greater scalability (huge datasets, high write throughput) than relational easily achieves, (2) preference for FOSS, (3) specialized queries unsupported by relational, (4) frustration with rigid relational schemas. The likely future is **polyglot persistence** — relational alongside non-relational.

**The object-relational mismatch** ("impedance mismatch"): OO application code needs an awkward translation layer (ORM) between objects and the relational tabular model. For a résumé/profile (one-to-many: one user → many jobs, education entries, contact details), a **document model** (JSON) has better *locality* — the whole document is one self-contained tree, fetched in one read, no joins.

**Many-to-one and many-to-many relationships:** Normalizing (using IDs for `region`, `industry`, etc., instead of free-text) removes duplication and gives a single source of truth — but a many-to-one reference (many people live in one region) doesn't fit the document model well, because **document databases have weak join support**. As features grow, data tends to become *more interconnected* (recommendations, references between entities), pushing toward joins and many-to-many relationships.

**Are document databases repeating history?** The 1970s *hierarchical model* (IBM IMS) was tree-of-records like JSON and had the same join/many-to-many weaknesses. Two solutions competed: the *relational model* (which won) and the *network/CODASYL model* (access-path navigation, which lost due to complexity).

**Relational vs document today:**
- *Document strengths*: schema flexibility, better locality, closer to application object structures; good when data is a self-contained document tree with few cross-document references.
- *Relational strengths*: better support for joins, many-to-one and many-to-many relationships.
- **Schema-on-read vs schema-on-write**: Document DBs are *schema-on-read* (schema is implicit, interpreted by the application reading the data) — analogous to dynamic/runtime type checking. Relational is *schema-on-write* — explicit schema enforced on write, like static/compile-time type checking. Schema-on-read shines for heterogeneous data or when the structure is determined by external systems that change.
- *Locality* applies only when you need large parts of the document at once; updates typically rewrite the whole document. Some relational DBs (Google Spanner, Oracle multi-table index cluster tables, Bigtable column families) provide locality too. **Convergence**: most relational DBs now support JSON/XML columns; document DBs (RethinkDB, some MongoDB drivers) support relational-like joins.

### Query languages for data

- **Declarative** (SQL, relational algebra, CSS): specify the *pattern of the result* — what you want, the conditions, how to transform — but not *how* to achieve it. The query optimizer decides indexes, join order, execution. Declarative languages hide engine internals (so the engine can improve without query changes) and **parallelize** well (they specify only patterns, not sequential ordering). Imperative code (a step-by-step loop) is hard to parallelize.
- **MapReduce querying** (between declarative and imperative): `map` and `reduce` functions (must be *pure* — no side effects, no extra DB queries — so they can be re-run and reordered). MongoDB's MapReduce; a purely declarative aggregation pipeline can express the same thing more simply.

### Graph-like data models

When many-to-many relationships dominate, model data as a **graph** of *vertices* (nodes/entities) and *edges* (relationships/arcs). Examples: social graphs, web graph, road/rail networks. Graphs can store *heterogeneous* data (Facebook stores people, locations, events, checkins, comments as vertices, with edges typing the relationships).

- **Property graph model** (Neo4j, Titan, InfiniteGraph): each vertex has a unique ID, outgoing & incoming edges, and a property collection (key-value pairs). Each edge has a unique ID, a tail vertex (start), a head vertex (end), a label describing the relationship, and properties. Great flexibility & evolvability: any vertex can connect to any other; no fixed schema constraining which kinds connect.
- **Cypher query language** (Neo4j's declarative language): pattern matching like `(person) -[:BORN_IN]-> (location)`. Many-step traversals are concise; the equivalent recursive SQL using `WITH RECURSIVE` (recursive common table expressions) is far more verbose.
- **Triple-stores and SPARQL** (RDF, Semantic Web): all data as three-part statements `(subject, predicate, object)`, e.g., `(Jim, likes, bananas)`. SPARQL is the query language; the *Turtle*/*N-Triples* format is a readable serialization.
- **Datalog** (older, foundation of Cypher & SPARQL): rules of the form `predicate(subject, object) :- conditions`. Rules can build on other rules and be recursive, enabling powerful, composable queries — a different style that takes more learning but is very expressive for complex data.

---

## Chapter 3 — Storage and Retrieval

How databases store the data you give them and find it again. You won't build a storage engine from scratch, but you must **select and tune** one. The fundamental distinction: storage engines optimized for **transactional (OLTP)** vs **analytic (OLAP)** workloads.

### Data structures that power your database

The world's simplest database is an append-only log (`db_set` appends `key,value`; `db_get` greps for the last occurrence). Appending is very efficient (O(1) writes), but `db_get` is O(n). To make reads fast you need an **index** — an *additional* structure *derived* from the primary data. **Fundamental trade-off**: a well-chosen index speeds reads but *slows writes* (the index must be updated on every write). So databases don't index everything by default — you choose indexes from knowledge of query patterns.

### Hash indexes

Keep an *in-memory hash map* of every key → byte offset in the append-only data file. Write = append + update map; read = look up offset, seek, read. This is essentially **Bitcask** (Riak's default engine): high read/write performance, *provided all keys fit in RAM*. Great for many writes per key (e.g., a counter), few distinct keys.

To stop the log growing forever: break it into **segments** of fixed size; perform **compaction** (throw away duplicate keys, keep only the most recent value per key) and **merge** segments in the background. Practical issues: file format (binary length-prefixed, not CSV), deleting records (append a special *tombstone*), crash recovery (rebuild maps — Bitcask snapshots each segment's map), partially written records (checksums), concurrency (one writer thread, many readers; segments are append-only/immutable).

*Why append-only?* Sequential writes are far faster than random writes (especially on disk, also SSD); concurrency & crash recovery are simpler; merging avoids fragmentation. *Limitations*: the hash table must fit in memory; range queries are inefficient (keys aren't ordered).

### SSTables and LSM-Trees

**SSTable** (Sorted String Table): require each segment's key-value pairs to be *sorted by key*, and each key appears once per segment. Advantages over hash-indexed logs:
1. **Merging is efficient** — like mergesort, even if files are bigger than memory: read input segments side by side, take the lowest key, keep the most recent on collisions.
2. **Sparse in-memory index** — you don't need every key in memory; an index of *some* keys (every few KB) suffices, then scan within the range. Reads jump close and scan.
3. **Compression** — group records into blocks, compress before writing; the sparse index points to block starts (saves disk I/O & space).

**Constructing & maintaining SSTables — the LSM-Tree (Log-Structured Merge-Tree):**
- Writes go to an in-memory balanced tree (*memtable*, e.g., red-black tree).
- When the memtable exceeds a threshold, write it to disk as a new SSTable segment (already sorted).
- Reads check the memtable, then the most recent on-disk segment, then older segments.
- Periodically merge & compact segments in the background.
- Crash safety: an append-only log on disk records every write so the memtable can be restored after a crash; discard it once the memtable is written out.
- **Optimizations**: *Bloom filters* (probabilistic set membership) avoid disk reads for keys that don't exist. *Compaction strategies*: **size-tiered** (newer/smaller SSTables merged into older/larger — Cassandra, HBase) and **leveled** (key range split into smaller SSTables, older data moved to separate "levels," more incremental, less disk usage — LevelDB, RocksDB, Cassandra).

Used in: LevelDB, RocksDB, Cassandra, HBase, Lucene (the term dictionary for full-text search). LSM-trees sustain very high write throughput because all writes are sequential.

### B-Trees

The most widely used indexing structure (standard in nearly all relational DBs, many non-relational). Like SSTables, keys are sorted (enabling efficient key lookups and range queries) — but the design is fundamentally different:
- Break the database into fixed-size **pages/blocks** (traditionally 4 KB), read/write one page at a time.
- Pages form a **tree**: one designated root; each page contains keys and references to child pages; a leaf page contains values (or references to them).
- The **branching factor** (number of child references per page) is typically several hundred; depth of O(log n) means a 4-level tree of 4 KB pages addresses ~256 TB.
- **Updates**: find the leaf, change the value in place, write the whole page back. **Inserts**: if a leaf has no room, split into two half-full pages and update the parent.
- B-trees **overwrite pages in place** (unlike LSM's append-only). A crash mid-write can corrupt the tree, so B-trees use a **write-ahead log (WAL / redo log)** — an append-only file every modification is written to *before* applying it to the tree, for crash recovery. Concurrency requires **latches** (lightweight locks).

### Comparing B-Trees and LSM-Trees

| Aspect | B-Trees | LSM-Trees |
|---|---|---|
| Reads | Typically faster | Must check memtable + several SSTables (Bloom filters help) |
| Writes | Slower (write WAL + page, often a whole page for a small change) | Faster, sustained high write throughput (sequential) |
| Write amplification | Each write → WAL + page write | Repeated compaction rewrites data, but writes are sequential |
| Disk usage / fragmentation | Pages can be partly empty (fragmentation) | Better compression, lower fragmentation; compaction reclaims space |
| Compaction impact | None | Background compaction can interfere with reads/writes; can fall behind under heavy write load |
| Transactions | Each key in exactly one place → easy to attach locks for strong transactional isolation | Multiple copies in different segments |

Rule of thumb: **LSM-trees for write-heavy workloads, B-trees for read-heavy / strong-transaction needs** — but always benchmark for your workload.

### Other indexing structures

- **Secondary indexes** — not unique, multiple rows can share a value; store a list of matching row IDs or make keys unique by appending a row identifier.
- **Storing values within the index**: the index value can be the actual row (*clustered index*, e.g., MySQL InnoDB primary key) or a reference to the row stored elsewhere in a *heap file* (avoids duplication). A *covering index* (index with included columns) stores some columns so some queries are answered from the index alone.
- **Multi-column indexes**: *concatenated index* (combine fields in one key, order matters) for queries on a prefix; *multi-dimensional indexes* (R-trees) for geospatial / multiple-range queries.
- **Full-text & fuzzy indexes** — Lucene allows search for words within an edit distance; its in-memory index is a finite state automaton over characters (like a trie).
- **Keeping everything in memory** — *in-memory databases* (Memcached for caching-only; Redis, VoltDB, MemSQL, RAMCloud for durability via logging/snapshots/replication). Faster not mainly because they avoid disk reads (the OS caches anyway) but because they **avoid the overhead of encoding in-memory data structures into a disk-writable form**. They also offer data models hard to do on disk (Redis: priority queues, sets). The *anti-caching* approach evicts least-recently-used data to disk, allowing datasets larger than memory.

### Transaction processing or analytics? (OLTP vs OLAP)

| Property | OLTP (transaction processing) | OLAP (analytics) |
|---|---|---|
| Main read pattern | Small number of records per query, fetched by key | Aggregate over a large number of records |
| Main write pattern | Random-access, low-latency writes from user input | Bulk import (ETL) or event stream |
| Primarily used by | End user / customer, via a web application | Internal analyst, for decision support |
| Data represents | Latest state of data (current point in time) | History of events over time |
| Dataset size | Gigabytes to terabytes | Terabytes to petabytes |
| Bottleneck | Disk seek time | Disk bandwidth |

### Data warehousing

A separate read-only database analysts query without affecting OLTP. Data is loaded via **ETL** (Extract–Transform–Load) from OLTP systems. Lets the warehouse be optimized for analytic access patterns independently.

**Stars and snowflakes — schemas for analytics:** The **star schema** (dimensional modeling) has a central **fact table** (each row = an event, e.g., one sale) referencing **dimension tables** via foreign keys (who, what, where, when, how, why). The **snowflake schema** further normalizes dimensions into sub-dimensions. Fact tables are huge (often >100 columns); a typical query touches few columns but many rows.

### Column-oriented storage

Since analytic queries read few columns but many rows, **store all values from each column together** rather than all values from each row together. To reassemble a row, the *n*th entry of each column belongs to the same row.

- **Column compression**: columns have repetitive values → compress well. **Bitmap encoding** (one bitmap per distinct value; run-length-encode the sparse bitmaps) makes `WHERE col IN (...)` a bitwise OR and `WHERE a AND b` a bitwise AND — extremely fast. Also helps fit data in CPU L1 cache for *vectorized processing* (SIMD).
- **Sort order in column storage**: store rows in an order useful for queries (e.g., by date then product). The sort column compresses especially well (long runs). *C-Store / Vertica* keep **several differently-sorted copies** of the data (redundant, but a query picks the best-sorted version).
- **Writing to column-oriented storage**: in-place updates are hard (inserting a row means rewriting all column files). Solution: an **LSM-tree approach** — buffer writes in an in-memory row store, merge into column files in bulk in the background.
- **Aggregation: data cubes and materialized views**: A **materialized view** is a precomputed, cached query result (an actual copy on disk, refreshed on data change — unlike a virtual view, which is just a query alias). A **data cube / OLAP cube** is a grid of aggregates over multiple dimensions; lookups are fast, but it's less flexible than querying raw data.

---

## Chapter 4 — Encoding and Evolution

Applications change over time, so data formats and schemas change. Old and new code, old and new data, must coexist — especially during *rolling upgrades* (server side) and slow client updates (mobile apps). This demands compatibility in **both** directions:

- **Backward compatibility** — newer code can read data written by older code (usually easy; you know the old format).
- **Forward compatibility** — older code can read data written by newer code (trickier; old code must ignore additions it doesn't understand).

### Formats for encoding data

Two representations: **in memory** (objects, structs, lists, hash tables, trees, optimized for CPU access via pointers) and a **byte sequence** (for files/network — pointers are meaningless across processes). Translation: in-memory → bytes = **encoding** (a.k.a. serialization, marshalling); bytes → in-memory = **decoding** (parsing, deserialization, unmarshalling). *(Note: "serialization" is overloaded — Chapter 7 uses it for transaction isolation; the book uses "encoding" here.)*

**Language-specific formats** (Java `Serializable`, Ruby `Marshal`, Python `pickle`, Kryo): convenient but deeply problematic — tied to one language; decoding instantiates arbitrary classes (a **security hole**); versioning/compatibility is an afterthought; efficiency is poor. **Avoid for anything but transient purposes.**

**JSON, XML, and binary variants** (textual, widely interoperable): issues — ambiguity around number encoding (XML/CSV can't distinguish numbers from strings; JSON can't distinguish integers from floats and loses precision on large numbers like 2^53, biting Twitter's 64-bit tweet IDs); no binary string support (must Base64, +33% size); optional schema support that many tools ignore; CSV has no schema and brittle escaping. Despite flaws, they're "good enough" for many purposes, especially as a data interchange format between organizations.

**Binary encodings** of JSON (MessagePack, BSON, BJSON, etc.) shrink the size but still embed all field names in every record.

### Thrift and Protocol Buffers

Binary encoding libraries (Thrift from Facebook, Protocol Buffers from Google) that **require a schema** (an IDL). A code-generation tool produces classes in many languages. Each field in the schema has a **field tag (number)** and a type. The encoded data references **field tags, not field names** — making it compact.

**Schema evolution rules:**
- **Add a new field**: give it a new tag number. Old code reading new data ignores unknown tags (forward compatible). New code reading old data sees a missing field — so **new fields must be optional or have a default** (backward compatible). You can never reuse or change an existing tag number.
- **Remove a field**: only remove *optional* fields, and never reuse the tag.
- Thrift has *required* fields with a runtime check; making a field required breaks compatibility if old data lacks it.
- Changing a field's data type risks losing precision or truncation.

### Avro

A different binary format (from Hadoop). The schema (Avro IDL or JSON) has **no tag numbers**. The encoding is just concatenated values with *no field identifiers or types* — you **cannot parse it without the exact schema**.

- **Writer's schema** (used to encode) vs **reader's schema** (the code's expected schema) need not be identical — only *compatible*. Avro resolves differences by matching field **names** (reordering, ignoring writer fields absent in reader, filling reader fields absent in writer with defaults).
- **How the reader knows the writer's schema** depends on context: a large file embeds the writer's schema once in a header (Hadoop); a database row tags each record with a *version number* and keeps a schema registry; over a network, schemas are negotiated on connection setup (Avro RPC).
- **Schema evolution**: add/remove only fields *with defaults* for both forward & backward compatibility.
- **Strength — dynamically generated schemas**: because there are no tag numbers, Avro can auto-generate a schema from, e.g., a relational table; if columns change, generate a new writer's schema — no manual tag bookkeeping. Friendlier than Thrift/Protobuf for dynamically generated schemas.

**The merits of schemas:** binary schema-based encodings are far more compact than binary JSON variants; the schema is valuable documentation that stays in sync with the data; a schema database enables checking compatibility before deployment; code generation enables compile-time type checking in statically typed languages.

### Modes of dataflow — how encoded data travels between processes

1. **Dataflow through databases** — the process writing encodes; the process(es) reading decode. Forward compatibility is essential because a *newer* version of the app writes a field that an *older* version (during a rolling upgrade) reads and must not destroy. ⚠️ A subtle bug: old code reads a record (missing its knowledge of a new field), modifies it, and writes it back — **silently dropping the new field**. Encoding formats can preserve unknown fields to avoid this. *Different values written at different times* coexist ("data outlives code") — *migrating* (rewriting) data into a new schema is expensive, so most DBs allow simple changes (e.g., a new column with NULL default) without rewriting old rows.

2. **Dataflow through services: REST and RPC** — clients and servers communicate over the network. *Web services* use HTTP. **REST** is a *design philosophy* built on HTTP principles (resources by URL, HTTP methods for cache control/auth/content negotiation) — RESTful APIs use simple formats. **SOAP** is the XML-based, heavyweight, standards-driven alternative (WSDL, code generation), now declining. **RPC (Remote Procedure Call)** tries to make a network call *look like* a local function call (*location transparency*) — but this is a flawed abstraction: a network call is unpredictable (may be lost, slow, or the response lost — *idempotence* matters for retries), has wildly variable latency, must encode all parameters as bytes (problematic for large objects), and crosses language boundaries. Modern RPC frameworks (Thrift, gRPC over Protobuf, Finagle, Rest.li) are explicit about the difference (futures/promises, streams, service discovery). RPC's main use is internal service-to-service within one organization/datacenter. *Compatibility*: RPC evolution is coupled — you can typically upgrade servers first, then clients; so backward compatibility on requests and forward compatibility on responses (using the underlying encoding's evolution rules).

3. **Message-passing dataflow** — asynchronous communication via a **message broker** / message queue (RabbitMQ, ActiveMQ, Kafka, etc.) between RPC (low-latency direct) and databases (durable storage). A sender *produces* a message to a named *queue*/*topic*; the broker delivers it to one or more *consumers*/*subscribers*. Advantages: buffers when the recipient is overloaded/unavailable (improving reliability), automatically redelivers to crashed processes (no message loss), decouples sender from recipient (the sender needn't know the recipient's address), supports one-to-many. Usually *one-way* (asynchronous) — the sender doesn't wait for a reply. **Actor model** (Akka, Orleans, Erlang OTP): concurrency as communicating *actors* (each one client/entity with local state, communicating only by async messages); a *distributed actor framework* transparently scales actors across nodes, integrating message-passing into the programming model — but messages must still survive rolling upgrades, so the same forward/backward compatibility rules apply.

---

## Part I — Key takeaways

- Design every system around **reliability, scalability, maintainability** — and state which load parameters and growth dimensions you're optimizing for.
- Use **percentiles (p95/p99/p999), not averages**, to describe and SLA performance; beware tail-latency amplification under fan-out.
- Choose the data model that fits the data's shape and relationships: **document** for self-contained trees, **relational** for many-to-one/many-to-many joins, **graph** for highly interconnected data with arbitrary traversals.
- Prefer **declarative query languages** — they hide engine internals and parallelize.
- **LSM-trees (SSTables)** for write-heavy and high-throughput; **B-trees** for read-heavy and strong transactions. **Column-oriented storage + compression** for analytics (OLAP); row-oriented for OLTP.
- Use **schema-based binary encodings (Avro, Protobuf, Thrift)** for cross-process data, and design every schema change for **both backward and forward compatibility** to survive rolling upgrades and long-lived data.
