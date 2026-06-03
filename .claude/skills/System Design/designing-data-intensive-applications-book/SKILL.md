---
name: designing-data-intensive-applications-book
description: Use when you need to reason about, design, or evaluate data-intensive systems guided by the canonical Designing Data-Intensive Applications (Martin Kleppmann, O'Reilly 2017) — covering reliability/scalability/maintainability as first-class properties; relational vs document vs graph data models and their query languages; storage engines (log-structured/LSM-trees vs B-trees, SSTables, hash indexes, column-oriented storage, OLTP vs OLAP); data encoding and schema evolution (JSON/XML, Thrift/Protobuf, Avro, backward/forward compatibility); distributed replication (leader-based, multi-leader, leaderless/quorum), replication lag anomalies and their guarantees; partitioning/sharding strategies and secondary index approaches; ACID transactions, isolation levels (read committed, snapshot isolation, serializability via 2PL and SSI), lost updates, write skew, phantoms; the fundamental problems of distributed systems (unreliable networks, clocks, process pauses, Byzantine faults); consistency models and consensus (linearizability, causal consistency, total-order broadcast, distributed transactions, 2PC, Zookeeper-style coordination); batch processing with the Unix philosophy and MapReduce/Hadoop, and beyond-MapReduce dataflow engines (Spark, Flink); stream processing, event sourcing, change data capture, stateful stream operators, exactly-once semantics; and the future of data systems — integrating specialized tools, unbundling databases, dataflow programming, end-to-end correctness, and ethical considerations. This should trigger for requests such as Which database or storage engine fits this workload; How do I design a system that is both scalable and maintainable; What consistency guarantees does my replication setup provide; How do I handle write conflicts or lost updates in a distributed system; What is the difference between linearizability and causal consistency; When should I use batch vs stream processing; How should I encode data across service boundaries for schema evolution; What is the CAP theorem actually saying and when does it apply; Design a fault-tolerant distributed data pipeline; Explain SSTable/LSM-tree vs B-tree trade-offs; How do I implement exactly-once processing in a stream system. Distilled from Designing Data-Intensive Applications by Martin Kleppmann (O'Reilly, 2017).
license: Apache-2.0
metadata:
  author: Martin Kleppmann — Designing Data-Intensive Applications (O'Reilly Media, 2017, ISBN 978-1-449-37332-0). Skill synthesized from all three parts of the book.
  version: 1.0.0
---
# Designing Data-Intensive Applications — Reliable, Scalable, and Maintainable Systems

Reason about, design, review, and evaluate data-intensive systems drawing on the foundational concepts, algorithms, trade-offs, and design principles in Martin Kleppmann's *Designing Data-Intensive Applications* (O'Reilly, 2017).

**What is covered in this Skill?**

- **Part I — Foundations of Data Systems** (Chapters 1–4): the three goals that underpin every design decision (**reliability, scalability, maintainability**); the relational/document/graph data models and their query languages; how storage engines actually work (hash indexes, SSTables, LSM-trees, B-trees, column-oriented storage, OLTP vs OLAP); and how data is encoded across process boundaries with backward/forward compatibility (JSON, Protobuf, Thrift, Avro)
- **Part II — Distributed Data** (Chapters 5–9): **replication** (single-leader, multi-leader, leaderless/Dynamo-style), replication lag anomalies, read-your-writes, monotonic reads, and consistency levels; **partitioning/sharding** (key-range vs hash, secondary indexes, rebalancing, routing); **transactions** (ACID semantics, weak isolation — read committed, snapshot isolation, serializable — and the specific anomalies each prevents: dirty reads, non-repeatable reads, lost updates, write skew, phantoms); the fundamental difficulties of **distributed systems** (partial failures, unreliable networks and clocks, process pauses, Byzantine faults); and **consistency and consensus** (linearizability, causal consistency, sequence number ordering, total-order broadcast, 2PC, fault-tolerant consensus via Raft/Zab, ZooKeeper/etcd)
- **Part III — Derived Data** (Chapters 10–12): **batch processing** with the Unix philosophy, MapReduce, Hadoop, and dataflow engines (Spark, Flink, Tez); **stream processing** — messaging systems, partitioned logs (Kafka), change data capture, event sourcing, stream joins, stateful operators, exactly-once semantics; and **the future of data systems** — data integration by composing specialized tools, unbundling the database, dataflow programming models, end-to-end arguments for correctness, timeliness vs integrity, and the ethics of data collection

## The Three Goals (from Chapter 1)

| Property | What it means | Key threats |
|---|---|---|
| **Reliability** | Works correctly even when things go wrong | Hardware faults, software bugs, human errors |
| **Scalability** | Handles growth of data, traffic, or complexity | Load (throughput, latency percentiles), fan-out |
| **Maintainability** | Easy for engineers to work with over time | Operability, simplicity, evolvability |

- **Reliability**: hardware faults are random/independent → add redundancy (RAID, dual power). Software faults are systematic → careful thinking, testing, process isolation, graceful degradation, monitoring. Human errors are the biggest cause → design for the pit of success, decouple staging from production, allow rollback, instrument with metrics.
- **Scalability**: describe load with load parameters (rps, ratio of reads to writes, cache hit rate, simultaneous users). Describe performance with latency percentiles (p50, p95, p99, p999) — not averages, which hide tail latency. Scale-up (vertical) vs scale-out (horizontal / shared-nothing). Elastic scaling (auto) vs manual scaling.
- **Maintainability**: operability — make routine tasks easy, provide good observability. Simplicity — remove accidental complexity; good abstractions hide implementation detail. Evolvability — accommodate unanticipated changes, enabled by simple and well-factored systems.

## Constraints

There are no compile steps for pure system-design questions, but when producing or reviewing code that implements data-system patterns, ensure the project builds and passes tests before and after changes.

- **JUSTIFY TRADE-OFFS**: every design choice in a data system trades something off (consistency vs availability, read vs write performance, durability vs throughput). Name the trade-off explicitly; do not present any single option as universally superior.
- **NAME THE ANOMALY, NOT JUST THE LEVEL**: weak isolation levels allow specific anomalies. Identify the anomaly (dirty read, lost update, write skew, phantom) and state which isolation level prevents it.
- **DISTINGUISH CONSISTENCY MODELS**: "consistency" means different things in ACID (consistency = application-defined invariants) vs replication (eventual, causal, read-your-writes, linearizable). Clarify which model is being discussed.
- **CAP IS OFTEN MISAPPLIED**: CAP applies only when a network partition occurs and forces a choice between consistency and availability. Most systems are not constantly partitioned; latency and fault tolerance under normal operation are more relevant concerns.
- **DISTRIBUTED SYSTEMS HAVE PARTIAL FAILURES**: nodes can be running but slow, messages can be delayed, clocks drift. Design assuming these conditions, not assuming a synchronous model.
- **READ THE REFERENCES**: for authoritative detail, read the reference files in `references/`.

## When to use this skill

- Choose between **relational, document, or graph** models for a new application
- Explain how a **storage engine** works (B-tree vs LSM-tree/SSTables, column vs row storage) and when each is appropriate
- Design for **schema evolution** across rolling deployments using Avro, Protobuf, or Thrift
- Analyze **replication** topologies (single-leader, multi-leader, leaderless), identify which replication lag anomalies each can produce, and determine what consistency guarantees are achievable
- Design a **partitioning/sharding** strategy and explain how secondary indexes, rebalancing, and request routing work
- Reason about **transactions**: ACID properties, weak isolation levels, what anomalies each level prevents, and when to use serializable isolation (2PL, SSI, serial execution)
- Understand why **distributed systems are hard** — unbounded network delays, clock uncertainty (NTP, monotonic vs wall-clock), process pauses (GC, VM migration), split brain
- Evaluate **consistency models** — linearizability (strongest), causal consistency, eventual consistency — and when each is necessary or sufficient
- Explain **consensus algorithms** (Raft, Zab, Paxos family), why 2PC is not fault-tolerant, and how ZooKeeper-style coordination services are used
- Architect a **batch processing** pipeline using the Unix philosophy / MapReduce / dataflow engines for ETL, search index building, or training data generation
- Design a **stream processing** system with partitioned logs (Kafka), stateful operators, change data capture, event sourcing, and exactly-once delivery
- Reason about **data integration** — how to compose heterogeneous specialized data systems and keep them in sync
- Evaluate the **correctness** of a data system end-to-end (idempotency, deduplication, constraint enforcement under distributed conditions)
- Raise **ethical considerations** around predictive analytics, data collection, privacy, and the social impact of data-intensive applications

## Workflow

1. **Identify the question domain**: Is the question about data modeling (Part I)? Replication/partitioning/transactions (Part II)? Batch/stream processing (Part III)? Or about the high-level goals of reliability, scalability, maintainability?
2. **Read the relevant reference file**:
   - `references/part-1-foundations.md` — data models, storage engines, encoding
   - `references/part-2-distributed-data.md` — replication, partitioning, transactions, distributed system problems, consistency and consensus
   - `references/part-3-derived-data.md` — batch processing, stream processing, future data systems
3. **Name the trade-offs explicitly**: state what each design choice optimizes for and what it sacrifices.
4. **Cite the chapter and concept**: e.g., "As Kleppmann explains in Chapter 7 (Transactions), snapshot isolation prevents non-repeatable reads but does not prevent write skew — only serializable isolation eliminates write skew."
5. **Connect to concrete systems**: the book grounds every concept in real databases and frameworks (PostgreSQL, MySQL, Cassandra, Kafka, HBase, Spark, Flink, ZooKeeper, etc.). Where possible, name the real system that implements the pattern.

## Reference

This skill ships three reference files — read the one(s) relevant to the request:

1. **[references/part-1-foundations.md](references/part-1-foundations.md)** — Chapters 1–4. The three goals; relational vs document vs graph data models; SQL, MapReduce, Cypher, SPARQL; storage engines (hash indexes, SSTables, LSM-trees, B-trees, column-oriented storage, data warehousing); data encoding (JSON/XML, Thrift, Protobuf, Avro) and backward/forward compatibility; modes of dataflow (databases, REST/RPC, message queues).
2. **[references/part-2-distributed-data.md](references/part-2-distributed-data.md)** — Chapters 5–9. Replication (single-leader, multi-leader, leaderless), replication lag anomalies and consistency guarantees; partitioning/sharding strategies, secondary indexes, rebalancing; transactions — ACID, isolation levels, lost updates, write skew, phantoms, serializability (2PL, SSI); the trouble with distributed systems (partial failures, unreliable networks, clocks, process pauses, Byzantine faults); consistency and consensus (linearizability, causal consistency, total-order broadcast, 2PC, fault-tolerant consensus, ZooKeeper).
3. **[references/part-3-derived-data.md](references/part-3-derived-data.md)** — Chapters 10–12. Batch processing (Unix philosophy, MapReduce, Hadoop ecosystem, dataflow engines); stream processing (messaging systems, partitioned logs, change data capture, event sourcing, stream joins, fault tolerance, exactly-once); the future of data systems (data integration, unbundling databases, dataflow programming, end-to-end correctness, ethics).

When answering a question, cite the source: chapter number and title, plus the specific concept or section (e.g., "Chapter 7, Snapshot Isolation and Repeatable Read"; "Chapter 5, Handling Write Conflicts in Multi-Leader Replication"; "Chapter 11, Event Sourcing").
