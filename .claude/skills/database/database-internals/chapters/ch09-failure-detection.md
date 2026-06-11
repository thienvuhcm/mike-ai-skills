# Chapter 9: Failure Detection

## Core Idea
In asynchronous distributed systems it is impossible to distinguish a crashed node from a slow one, so failure detectors must make a deliberate trade-off between accuracy (avoiding false positives) and completeness (never missing a real failure).

## Frameworks Introduced
- **Phi Accrual Failure Detector (φ-accrual)**:
  - When to use: Systems that need adaptive, continuously-scaled failure suspicion rather than a hard binary up/down decision (e.g., Cassandra, Akka).
  - How: Maintain a sliding window of recent heartbeat arrival times; fit a normal distribution; compute φ = –log₁₀(probability that the next heartbeat is this late); if φ ≥ threshold → suspect. Threshold is tunable to trade false-positive rate for detection speed.

- **SWIM (Scalable Weakly-consistent Infection-style Membership)**:
  - When to use: Large clusters where direct pinging every node is prohibitively expensive.
  - How: Node P1 pings P2 directly; if no ack, P1 selects k random nodes and asks them to ping P2 indirectly; if none succeed, P2 is marked suspected. Membership changes are gossip-disseminated.

- **FUSE (Failure Notification Service)**:
  - When to use: When failure propagation through the network (including partitions) must be guaranteed.
  - How: Arrange nodes in groups; any member that detects a failure stops answering pings itself, converting individual failures into group-wide silence. Absence of communication is the propagation medium.

## Key Concepts
- **Failure detector**: A local subsystem that monitors remote processes and classifies them as alive, suspected, or dead to allow the algorithm to exclude them and preserve liveness.
- **Completeness**: Every non-faulty member must eventually detect every real failure. This is the core mandatory property of any failure detector.
- **Accuracy**: Whether the detector avoids false positives (accusing live processes). Accuracy and efficiency are mutually constrained — perfect accuracy is provably unachievable.
- **False positive**: A live process incorrectly marked as failed; hurts availability by unnecessarily excluding healthy members.
- **Heartbeat**: A periodic "I am alive" message sent proactively by a process to its peers; basis for most failure detection implementations.
- **Ping**: A query sent from one process to another expecting a response within a timeout; complementary to heartbeats.
- **Timeout-free failure detector (Heartbeat algorithm)**: Counts heartbeat propagation paths across the network without using timeouts; operates under fully asynchronous assumptions but requires threshold tuning to interpret counters.
- **Outsourced heartbeat**: The SWIM technique of delegating a secondary ping to k random peers when a direct ping fails, providing multi-path reachability evidence.
- **φ (phi) value**: A continuous suspicion level derived from the statistical distribution of heartbeat inter-arrival times; replaces a fixed binary threshold.
- **Gossip-style failure detection**: Each member maintains a heartbeat counter table for all peers, periodically exchanges it with a random neighbor, and marks nodes whose counters haven't incremented beyond a configurable timeout.

## Mental Models
- Use **φ-accrual** when network latency fluctuates widely — it self-calibrates so you don't have to hand-tune timeouts.
- Think of **SWIM indirect ping** as crowdsourcing: one negative report doesn't convict; a majority of independent witnesses needed.
- Think of **FUSE** as a fuse box: one blown fuse (failed node) causes the entire circuit (group) to go dark, guaranteeing every participant learns of the failure.
- Use **gossip failure detection** when you need failure information to survive link failures — gossip routes around broken links the same way it spreads rumors.

## Anti-patterns
- **Hard-coded fixed timeout**: Network conditions change; a fixed timeout tuned for normal latency will produce avalanche false positives during GC pauses or traffic spikes. Use φ-accrual or adaptive thresholds instead.
- **Single-node view for failure decisions**: One node's missed ping is weak evidence. Relying on a single observer without outsourced/indirect confirmation inflates false positives.
- **Ignoring the liveness/accuracy trade-off**: Aggressively tuning for fast detection (low timeout) will incorrectly evict healthy nodes under load; overly conservative timeouts delay recovery. Always characterize your workload first.

## Reference Tables

### Failure Detector Algorithm Comparison

| Algorithm | Mechanism | Timing Assumption | False Positive Tuning | Completeness | Best For |
|---|---|---|---|---|---|
| Heartbeat / Ping + Timeout | Direct periodic message | Synchronous (bounded delay) | Fixed timeout | Strong | Simple clusters, stable networks |
| Timeout-Free (Heartbeat) | Counter vectors, path aggregation | Asynchronous | Counter threshold | Strong | Asynchronous models |
| Phi Accrual | Sliding window + normal distribution | Partially synchronous | φ threshold | Strong | Variable latency, adaptive systems |
| SWIM | Direct + indirect (k-peers) ping | Partially synchronous | Indirect ping count k | Strong | Large-scale membership |
| Gossip-style | Heartbeat table + gossip | Partially synchronous | Gossip timeout | Strong | Multi-hop networks |
| FUSE | Group silence propagation | Any | Group membership | Strong | Guaranteed partition-spanning notification |

### Accuracy vs. Completeness Trade-off

| Priority | Tuning Direction | Risk |
|---|---|---|
| Fast detection | Lower timeout / lower φ threshold | More false positives |
| Fewer false positives | Higher timeout / higher φ threshold | Delayed failure detection |

## Worked Example
**Phi Accrual in Cassandra:**
1. Node A collects the last 1000 heartbeat inter-arrival times from Node B into a sliding window.
2. It fits a normal distribution: mean μ = 200ms, standard deviation σ = 30ms.
3. Current elapsed time since last heartbeat = 350ms.
4. φ = –log₁₀(P(arrival ≥ 350ms | μ=200, σ=30)) ≈ 8.
5. Cassandra's default threshold is φ = 8. Node B is now suspected.
6. If B responds at t = 380ms, the new inter-arrival time is added to the window and φ drops back below threshold — no permanent eviction occurred.

## Key Takeaways
1. Failure detection in asynchronous systems is fundamentally probabilistic — completeness and accuracy cannot both be perfect simultaneously.
2. Heartbeat/ping with a fixed timeout is the simplest approach but breaks under variable network conditions; prefer adaptive detectors (φ-accrual) in production.
3. SWIM's indirect probing provides multi-path evidence before marking a node failed, significantly reducing false positives in large clusters.
4. Gossip-based heartbeat tables survive link failures because heartbeats route through intermediate nodes.
5. FUSE converts individual failures into group-wide silence, providing a guaranteed delivery mechanism for failure notifications even across partitions.
6. The φ-accrual detector exposes a tunable threshold: lower it for faster detection, raise it to tolerate slow nodes without false alarms.
7. Failure detectors are prerequisites for consensus algorithms — without reliable failure detection, liveness of consensus protocols cannot be guaranteed.

## Connects To
- **Ch10**: Leader election depends on failure detection to recognize when the current leader has crashed and a new election must start.
- **Ch11**: Replication and consistency protocols use failure detection to remove unresponsive replicas from quorum calculations.
- **Ch14**: Consensus algorithms (Multi-Paxos, Raft, ZAB) require failure detectors to satisfy liveness: the FLP Impossibility result is overcome by coupling consensus with failure detection.
- **Ch12**: Anti-entropy and gossip dissemination mechanisms share the same gossip infrastructure used by gossip-style failure detectors.
