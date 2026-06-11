# Chapter 14: Consensus

## Core Idea
Distributed consensus — the problem of making all correct processes agree on a single value despite failures — is theoretically impossible to solve perfectly (FLP), but practically solvable with safety guarantees and a liveness dependency on an external failure detector; Paxos, Raft, and ZAB are the three dominant practical algorithms.

## Frameworks Introduced
- **Paxos**: Two-phase consensus with proposers, acceptors, and learners
  - When to use: Foundation for replicated state machines, distributed locks, and coordination services
  - How: Phase 1 (Prepare/Promise) establishes leader and learns any previously accepted values; Phase 2 (Accept!/Learn) replicates and commits the chosen value to a quorum of acceptors

- **Multi-Paxos**: Paxos with a persistent leader (distinguished proposer) that skips Phase 1 for subsequent values
  - When to use: Steady-state replication with infrequent leader changes; log replication, metadata stores
  - How: Leader elected once; subsequent values go straight to Phase 2 Accept; leader uses leases to serve linearizable reads without extra quorum round-trips

- **ZAB (ZooKeeper Atomic Broadcast)**: Three-phase atomic broadcast (Discovery, Synchronization, Broadcast) with epoch-based leader uniqueness
  - When to use: ZooKeeper coordination service; systems needing total-order delivery with efficient failure recovery
  - How: New leader runs Discovery (learns latest epoch) → Synchronization (delivers committed history to followers) → Broadcast (steady-state 2-round message pipeline)

- **Raft**: Consensus algorithm that makes leader a first-class citizen, separating leader election, log replication, and safety
  - When to use: Systems where understandability and correct implementation matter; etcd, CockroachDB, Consul
  - How: Followers elect a Candidate by majority vote; elected Leader appends entries to log, replicates via AppendEntries, commits after quorum ACK; term numbers provide total ordering

- **EPaxos (Egalitarian Paxos)**: Leaderless consensus using dependency tracking to establish commit order
  - When to use: Geographically distributed systems where a single leader is a latency bottleneck
  - How: Any replica can be a command leader; Pre-Accept phase collects dependency information; fast path if replicas agree on dependencies, slow path if not

- **Flexible Paxos**: Relaxes quorum requirements so that only Phase 1 and Phase 2 quorums must intersect, not necessarily both be majorities
  - When to use: Tuning latency-vs-availability trade-off; reducing replication quorum when leader is stable
  - How: If Phase 1 quorum = Q1 and Phase 2 quorum = Q2, require only Q1 + Q2 > N; shrink Q2 for lower latency at steady state, accept larger Q1 requirement for leader election

- **PBFT (Practical Byzantine Fault Tolerance)**: Three-phase consensus (Pre-prepare, Prepare, Commit) for adversarial environments
  - When to use: Systems with untrusted participants, adversarial networks, or Byzantine failures (malicious/corrupted nodes)
  - How: Primary broadcasts Pre-prepare; backups cross-validate via Prepare and Commit phases with 2f+1 matching responses required; requires 3f+1 total nodes to tolerate f Byzantine failures

## Key Concepts
- **Agreement**: All correct processes decide on the same value — the defining property of consensus
- **Validity**: The decided value was proposed by one of the processes (prevents trivially agreeing on a default)
- **Termination**: All correct processes eventually decide (liveness; cannot be guaranteed in purely async systems per FLP)
- **FLP Impossibility**: In a fully asynchronous system with even one possible crash failure, no deterministic consensus algorithm can guarantee termination — solved in practice by using failure detectors or randomization
- **Atomic Broadcast (Total Order Multicast)**: Reliable delivery of messages to all non-failed processes in the same order; equivalent to consensus in async crash-failure systems
- **Quorum**: Minimum set of participants required to make progress; any two quorums must intersect to ensure at least one common node can break ties and prevent conflicting decisions
- **Proposer / Acceptor / Learner**: Paxos roles; proposers initiate rounds, acceptors vote to accept values, learners store committed outcomes; typically colocated in one process
- **Term / Epoch**: Monotonically increasing identifier for the current leader's tenure; a new election produces a new term; messages from stale leaders (lower term) are rejected
- **Leader Lease**: Time-bounded agreement from followers to reject other leaders; allows the current leader to serve linearizable reads locally without a quorum round; requires bounded clock drift
- **Log Entry Commitment (Raft)**: An entry is committed once replicated to a majority of nodes; committed entries can never be overwritten by any future leader
- **Virtual Synchrony**: Group communication model delivering totally ordered messages to a dynamic membership; view changes serve as delivery barriers
- **Byzantine Fault**: A process that behaves arbitrarily or maliciously (not just crash-stop); tolerating f Byzantine faults requires 3f+1 nodes vs. 2f+1 for crash-stop failures

## Mental Models
- Use **Paxos** as a write-once register: Phase 1 claims ownership of the slot; Phase 2 writes the value — and the write sticks forever once a quorum accepts it
- Think of **Multi-Paxos / Raft** as an append-only log: a stable leader sequences all writes, each entry identified by (term, index); this log is the source of truth for state machine replication
- Think of **consensus quorums** like overlapping voting majorities: any two majorities share at least one member who "knows both sides," preventing two conflicting values from both being committed
- Use **EPaxos** when geography makes a single leader expensive: non-conflicting commands from different regions can commit in parallel on their local replicas without routing to a central leader

## Anti-patterns
- **Assuming FLP is solved by your algorithm**: FLP shows termination is not guaranteed in async systems; consensus algorithms guarantee safety always, but rely on a failure detector (timeouts, heartbeats) for liveness — misconfigured timeouts cause unnecessary leader elections or permanent stalls
- **Reading from a non-leader in Raft/Multi-Paxos without leases**: A follower may have stale state; reads must either go through the leader or use lease-based linearizability to avoid returning stale data
- **Competing proposers in classic Paxos without backoff**: Two proposers constantly invalidating each other's Phase 1 promises creates a livelock; solve with random backoff or a distinguished proposer (Multi-Paxos / Raft)
- **Using crash-tolerant consensus in adversarial environments**: Paxos and Raft assume non-Byzantine failures (nodes follow the protocol in good faith); in adversarial settings, use PBFT or similar BFT algorithms
- **Under-provisioning for fault tolerance**: Paxos/Raft need 2f+1 nodes for crash-stop tolerance; PBFT needs 3f+1 for Byzantine tolerance — running with exactly 3 nodes means zero crash-stop tolerance for consensus progress

## Reference Tables

### Consensus Algorithm Comparison

| Algorithm | Leader | Fault Model | Min Nodes for f failures | Phase Count | Key Use Case |
|---|---|---|---|---|---|
| Classic Paxos | Per-round | Crash-stop | 2f+1 | 2 | Foundational algorithm |
| Multi-Paxos | Persistent | Crash-stop | 2f+1 | 1 (steady state) | Replicated logs, etcd |
| Fast Paxos | Persistent (coordinator) | Crash-stop | 3f+1 | 1 (fast path) | Reduced round-trips |
| EPaxos | Per-command | Crash-stop | 2f+1 | 1 (fast) / 2 (slow) | Geo-distributed, leaderless |
| Flexible Paxos | Persistent | Crash-stop | 2f+1 | 1 (tunable quorums) | Latency/availability tuning |
| ZAB | Persistent per epoch | Crash-stop | 2f+1 | 3 (with recovery) | ZooKeeper |
| Raft | Persistent per term | Crash-stop | 2f+1 | 2 | etcd, CockroachDB, Consul |
| PBFT | Per view | Byzantine | 3f+1 | 3 | Adversarial/untrusted systems |

### Paxos Phase Summary

| Phase | Message | Sender → Receiver | Purpose |
|---|---|---|---|
| Phase 1a (Prepare) | `Prepare(n)` | Proposer → Acceptors | Claim leadership for proposal n |
| Phase 1b (Promise) | `Promise(n, v_accepted)` | Acceptors → Proposer | Promise not to accept lower proposals; report any prior accepted value |
| Phase 2a (Accept) | `Accept!(n, v)` | Proposer → Acceptors | Replicate chosen value v with proposal n |
| Phase 2b (Accepted) | `Accepted(n, v)` | Acceptors → Learners | Notify learners of accepted value |

### ZAB Phase Summary

| Phase | Purpose | Key Action |
|---|---|---|
| Discovery | Establish new epoch; learn latest epoch from followers | Proposer proposes new epoch > all follower epochs |
| Synchronization | Recover from prior leader failure; bring followers up to date | New leader delivers committed history from prior epochs to all followers |
| Broadcast | Steady-state operation | Leader proposes → quorum ACKs → leader commits; repeats until leader failure |

### Raft Election vs. Log Replication

| Concern | Mechanism | Safety Rule |
|---|---|---|
| Leader uniqueness | Monotonic term numbers | Node votes for at most one candidate per term |
| Log completeness | Candidate must have most up-to-date log to win | Vote denied if follower's log is newer (higher term or longer) |
| Entry commitment | AppendEntries + quorum ACK | Entry committed only after majority ACK; committed entries never overwritten |
| Split vote prevention | Randomized election timeout | Random backoff reduces probability of simultaneous elections |

## Worked Example

**Paxos failure scenario — proposer P1 fails mid-round:**

1. P1 wins Phase 1 with proposal number `n=1`. Acceptors A1, A2, A3 promise.
2. P1 sends `Accept!(1, V1)` but only A1 receives it before P1 crashes.
3. P2 starts a new round with `n=2`, sends `Prepare(2)` to A1, A2, A3.
4. A1 responds `Promise(2, V1)` — it already accepted V1.
   A2 and A3 respond `Promise(2, null)` — no prior accepted value.
5. P2 receives a quorum of responses. A1 reported `V1`, so P2 **must** propose V1 (not its own value).
6. P2 sends `Accept!(2, V1)`. A1, A2, A3 accept. Consensus reached on V1.

**Why this is safe**: The Promise invariant forces P2 to adopt V1 — any prior partially committed value is preserved across proposer failures, guaranteeing agreement.

**Raft log replication — normal case:**

1. Client sends command `x=8` to Leader P1.
2. P1 appends `(term=3, index=7, x=8)` to its local log.
3. P1 sends `AppendEntries(term=3, prevIndex=6, prevTerm=3, entries=[x=8])` to all followers.
4. Followers F2, F3 append the entry and ACK. F4 is slow.
5. Leader P1 receives ACKs from F2, F3 — a majority (3/5 including itself). Entry committed.
6. P1 marks index 7 committed, applies to state machine, responds to client.
7. Next `AppendEntries` carries the new `commitIndex=7`, causing followers to commit their local copy.

## Key Takeaways
1. Consensus algorithms guarantee safety (agreement) always; liveness (termination) depends on an external failure detector — understanding this distinction explains why leader elections can stall and why timeouts must be tuned carefully
2. FLP impossibility is theoretical: practical systems circumvent it by using synchrony assumptions (timeouts, heartbeats) as failure detectors rather than trying to achieve pure asynchronous consensus
3. The quorum intersection invariant is the core of all Paxos-family algorithms: as long as any two quorums overlap, at least one node "knows" about any prior commitment, preventing contradictory decisions
4. Multi-Paxos / Raft optimize consensus for the common case (stable leader, no failures) by skipping the election phase; their performance degrades gracefully to full two-phase Paxos only during leader changes
5. Raft's primary contribution is clarity and correctness by design: first-class leadership, explicit term numbers, and a well-defined log matching property make it easier to implement correctly than classic Paxos
6. EPaxos and Flexible Paxos show that Paxos is a family of algorithms, not a single fixed protocol — quorums can be tuned and leadership can be decentralized to match system topology
7. Byzantine fault tolerance (PBFT) costs significantly more: N² messages per step, 3f+1 nodes minimum — only use BFT when the threat model genuinely includes malicious or compromised participants
8. Consensus is the building block for distributed locks, leader election, metadata stores (etcd, ZooKeeper), and distributed transaction coordination (Calvin sequencer, Spanner Paxos groups)

## Connects To
- **Ch09 (Failure Detection)**: Failure detectors (SWIM, heartbeats) are the practical mechanism that provides the liveness guarantee consensus algorithms cannot provide on their own
- **Ch10 (Leader Election)**: Raft and ZAB leader election are consensus problems themselves; this chapter formalizes what was introduced operationally in Ch10
- **Ch11 (Replication)**: Consensus algorithms are the strongest form of replication — atomic broadcast is equivalent to consensus, and replicated state machines use consensus to order all writes
- **Ch12 (Anti-Entropy)**: Anti-entropy is the weaker (eventually consistent) alternative to consensus; when strong ordering and atomicity are needed, consensus replaces anti-entropy
- **Ch13 (Distributed Transactions)**: Calvin uses Paxos to order transaction epochs; Spanner uses Paxos groups as 2PC cohorts; consensus is the fault-tolerant substrate under distributed transactions
