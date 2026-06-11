# Chapter 8: Introduction and Overview (Part II — Distributed Systems)

## Core Idea
Distributed systems differ from single-node systems in two irreducible ways: processes have only local state and communicate exclusively by message passing, and both the network and processes are unreliable; every distributed algorithm must explicitly model timing assumptions, failure modes, and link semantics before correctness claims are meaningful.

## Frameworks Introduced
- **Link Abstraction Hierarchy**: A layered model of communication guarantees: fair-loss → stubborn → perfect link.
  - When to use: When reasoning about which delivery guarantees your protocol relies on and which must be implemented at the application layer.
  - How: Fair-loss (UDP-like, messages may be lost) → add retransmits → stubborn link (sender retries indefinitely) → add deduplication + sequence numbers → perfect link (exactly-once processing, FIFO order).

- **Failure Model Classification**: Explicit categorization of how processes can fail: crash-stop, crash-recovery, omission, arbitrary (Byzantine).
  - When to use: Before choosing or evaluating a distributed algorithm; the failure model determines which algorithms are correct and what redundancy is required.
  - How: Identify the strongest failure assumption your system can guarantee → choose algorithms proven correct under that model; crash-stop is the most common assumption in database systems.

- **System Synchrony Spectrum**: A model axis from fully asynchronous (no timing bounds) to synchronous (bounded delays and clock drift) with partially synchronous as the practical middle ground.
  - When to use: When evaluating consensus algorithms, failure detectors, or timeout-based logic.
  - How: Asynchronous = no timeouts possible → FLP Impossibility applies; synchronous = timeouts safe, leader election possible; partially synchronous = timeouts work "most of the time," covering practical systems like Raft and Paxos.

## Key Concepts
- **process (node, replica)**: An independent execution unit with local state; participants communicate only by exchanging messages, not by sharing memory.
- **fair-loss link**: The weakest link abstraction: messages may be lost or delayed, but the link will not create spurious messages, and messages sent infinitely often will eventually be delivered.
- **stubborn link**: A fair-loss link augmented with sender-side retransmits; the sender keeps resending until it receives an acknowledgment; may deliver duplicates.
- **perfect link**: A reliable, FIFO, deduplicated link built on top of stubborn delivery; guarantees exactly-once delivery for each sent message.
- **idempotent operation**: An operation that can be executed multiple times with the same effect as once; critical for at-least-once delivery semantics to be safe.
- **crash-stop failure**: A process halts execution and never recovers; the algorithm does not rely on recovery for correctness.
- **crash-recovery failure**: A process halts but may later rejoin; requires durable state and a recovery protocol; crash-recovery can look like omission failure from peers.
- **omission fault**: A process skips steps or fails to send/receive messages; captures network partitions and slow nodes.
- **arbitrary (Byzantine) fault**: A process executes steps incorrectly or maliciously — the hardest failure class to tolerate; relevant in blockchains and aerospace systems.
- **FLP Impossibility**: In a fully asynchronous system, no deterministic consensus protocol can guarantee termination in the presence of even one crash fault (Fisher, Lynch, Paterson 1985).
- **Two Generals' Problem**: A thought experiment showing that two parties cannot achieve guaranteed agreement over an asynchronous link subject to message loss; consensus requires at least some synchrony or probabilistic relaxation.
- **network partition**: A state where two or more groups of nodes cannot communicate; independent groups may proceed and produce conflicting results.
- **fallacies of distributed computing**: Peter Deutsch's 1994 list of incorrect assumptions programmers make: network is reliable, latency is zero, bandwidth is infinite, network is secure, topology doesn't change, there is one administrator, transport cost is zero, the network is homogeneous.
- **backpressure**: A flow-control strategy where consumers signal producers to slow down when they cannot keep up; prevents unbounded queue growth and cascading overload.
- **cascading failure**: A failure in one node increases load on others, raising their failure probability and potentially collapsing the entire cluster.
- **circuit breaker**: A software pattern (from electrical engineering) that monitors failures and short-circuits calls to a failing service, giving it time to recover.

## Mental Models
- Think of a distributed system as a set of isolated islands that can only communicate by sending bottles across an unreliable sea: the island cannot know if the bottle arrived unless it receives a reply bottle — and that reply might also sink.
- Use the **link hierarchy** as a checklist: if you need FIFO exactly-once delivery, you must implement sequence numbers, ACKs, and deduplication; UDP gives you only fair-loss.
- Use the **synchrony spectrum** as a correctness gating question: "does my algorithm use timeouts?" If yes, it requires at least partial synchrony; under a pure async model it may be incorrect.
- Think of **FLP Impossibility** not as "consensus is impossible" but as "consensus in bounded time under full asynchrony with crashes is impossible" — practical systems add timing assumptions or randomization to escape this.

## Anti-patterns
- **Assuming clocks are synchronized**: Wall clocks drift; using raw timestamps for ordering across nodes causes subtle ordering bugs. Use logical clocks (Lamport, vector) for causality; use bounded-uncertainty APIs (e.g., Spanner TrueTime) only when hardware supports it.
- **Hiding remote calls behind local-looking APIs**: Remote latency, partial failures, and consistency semantics are invisible; interleaving blocking remote calls with local code degrades performance and masks failures.
- **Infinite retry loops without backoff and jitter**: All clients wake up simultaneously after a timeout, amplifying load on the struggling server. Always use exponential backoff with random jitter.
- **Treating queue capacity as infinite**: Unbounded queues hide congestion and increase latency without improving throughput. Size queues based on measured processing rates and apply backpressure.
- **Ignoring partial failures**: A node can receive a request, process it, and crash before acknowledging — the client cannot distinguish this from "the request was lost." Design for exactly-once processing semantics, not just delivery.

## Reference Tables

### Link Abstraction Summary

| Link Type | Lost Messages | Duplicates | Ordering | Analogy |
|---|---|---|---|---|
| Fair-loss | Possible | No infinite repetition | Not guaranteed | UDP |
| Stubborn | No (infinite retry) | Possible | Not guaranteed | UDP + sender retry loop |
| Perfect | No | No | FIFO | TCP (single session) |

### Failure Model Comparison

| Failure Model | Process Behavior | Recovery? | Detectable? | Algorithm Difficulty |
|---|---|---|---|---|
| Crash-stop | Halts completely | No (for algorithm purposes) | Eventually (via timeout) | Low |
| Crash-recovery | Halts then rejoins | Yes (with durable state) | Eventually | Medium |
| Omission | Skips steps / drops messages | Implicit | Hard | Medium |
| Arbitrary (Byzantine) | Wrong or malicious execution | — | Very hard | High (requires 3f+1 nodes) |

### Synchrony Model Comparison

| Model | Timing Bounds | Clock Drift Bound | Timeouts Possible? | FLP Applies? |
|---|---|---|---|---|
| Asynchronous | None | None | No | Yes — consensus not guaranteed |
| Partially synchronous | Hold most of the time | Bounded most of the time | Yes (may misfire) | Bounded-time consensus not guaranteed |
| Synchronous | Always bounded | Always bounded | Yes (reliable) | No — consensus achievable |

### Fallacies of Distributed Computing (Deutsch 1994)

| Fallacy | Safe Assumption |
|---|---|
| Network is reliable | Design for packet loss and retransmit |
| Latency is zero | Measure and bound; never assume instant |
| Bandwidth is infinite | Rate-limit and apply backpressure |
| Network is secure | Authenticate, encrypt, validate |
| Topology doesn't change | Discover topology dynamically |
| There is one administrator | Coordinate across ownership boundaries |
| Transport cost is zero | Account for serialization and connection overhead |
| Network is homogeneous | Nodes may differ in speed, OS, version |

## Worked Example

**Building a perfect link from fair-loss:**

Problem: Process A needs to send message M to B exactly once, even if packets are lost.

Step 1 — Add sequence numbers: A tags M as M(n=42).

Step 2 — Add ACKs: B sends ACK(42) on receipt. A waits for ACK; if not received within timeout T, A resends M(42).

Step 3 — Add deduplication: B tracks `n_processed = 41` (highest fully processed sequence number). On receiving M(42): n > n_processed → process and advance n_processed to 42; send ACK(42). If M(42) arrives again (duplicate): n ≤ n_processed → discard silently; send ACK(42) again.

Step 4 — Handle reordering: B buffers out-of-order messages (e.g., M(44) arrives before M(43)) in a reorder buffer; delivers to application only when the sequence is consecutive up to n_consecutive.

Result: A has reliable, deduplicated, in-order delivery — a perfect link — built entirely on top of a fair-loss channel.

**Why exactly-once delivery requires common knowledge:** For A to know B has processed M exactly once, A needs ACK. For B to know A knows, B needs ACK-of-ACK. This regress is the Two Generals' Problem — it terminates only by accepting that the last message may be lost and introducing application-level deduplication as a substitute.

## Key Takeaways
1. The fundamental difference between distributed and single-node systems is not scale but the absence of shared memory: all coordination must happen through explicit message passing over unreliable links.
2. Every distributed algorithm must state its timing model (async / partial / sync), failure model (crash-stop / omission / Byzantine), and link model (fair-loss / perfect); changing any assumption may invalidate correctness proofs.
3. FLP Impossibility is not a dead end — it means bounded-time consensus requires synchrony or randomization; practical systems (Raft, Paxos) add timing assumptions or leader election to escape it.
4. Exactly-once delivery is not achievable at the transport layer without application-level deduplication; the correct framing is "exactly-once processing" via idempotency or explicit message IDs.
5. Backoff with jitter is mandatory for retries; raw retry loops amplify load on a struggling server and can cause cascading failures.
6. Physical clocks are not a reliable ordering mechanism across nodes; use logical clocks (Lamport timestamps) for causality or vector clocks for full partial-order tracking.
7. Design for partial failures first: a node can process a request and crash before acknowledging; the calling node cannot distinguish this from a lost request, so systems must be prepared for re-delivery.

## Connects To
- **Ch09 (Failure Detection)**: Builds directly on synchrony models and link abstractions introduced here — failure detectors require timing assumptions to work.
- **Ch10 (Leader Election)**: Uses crash-stop failure model and synchronous or partially synchronous timing assumptions; relies on perfect link semantics.
- **Ch11 (Replication and Consistency)**: Consistency models introduced conceptually here (state divergence, conflict resolution) are formalized in Ch11.
- **Ch07 (Log-Structured Storage)**: Single-node durability (WAL, memtable flush) is prerequisite knowledge before distributed replication of LSM-based engines.
