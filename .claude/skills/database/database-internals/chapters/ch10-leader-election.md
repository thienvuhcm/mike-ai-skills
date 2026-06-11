# Chapter 10: Leader Election

## Core Idea
A designated leader reduces coordination overhead in distributed systems, but all classical election algorithms are vulnerable to split-brain; preventing it requires epoch/term-based fencing combined with quorum majority votes.

## Frameworks Introduced
- **Bully Algorithm**:
  - When to use: Small clusters with stable, ranked nodes where simplicity is valued over message efficiency.
  - How: The process that notices the missing leader sends Election messages to higher-ranked peers; if no higher-ranked peer responds within a timeout, the sender declares itself leader and broadcasts Elected to lower-ranked peers; if a higher-ranked peer responds, it takes over the election. O(N²) messages in the worst case.

- **Ring Algorithm**:
  - When to use: Systems where nodes are already arranged in a logical ring topology.
  - How: The detecting node sends an election message around the ring, each node appending itself; when the message completes the circuit, the highest-ranked live node in the collected set is announced as leader in a second traversal. Skips unreachable nodes by contacting the next successor.

- **Raft Leader Election** (referenced):
  - When to use: Consensus-based replication systems needing a single writer with guaranteed safety under network partitions.
  - How: Each node starts a randomized election timeout; the first to expire increments its term and sends RequestVote RPCs; a candidate wins if it collects votes from a majority of nodes; a newly discovered higher term immediately demotes the old leader (term-based fencing).

## Key Concepts
- **Leader / Coordinator**: The single designated process that collects global state, sequences messages, and drives execution — eliminating peer-to-peer synchronization cost.
- **Split-brain**: Two leaders serving the same purpose, both unaware of each other, caused by network partitions; produces conflicting writes and data loss.
- **Epoch / Term**: A monotonically increasing logical counter that uniquely identifies a leadership period; any message or write stamped with a stale epoch is rejected, preventing old leaders from corrupting state.
- **Fencing token**: A token derived from the current epoch/term, included in every write; storage nodes reject writes with a token older than the latest seen, making split-brain writes safe to discard.
- **Bully algorithm**: Election where the highest-ranked node "bullies" others into accepting it; named for monarchial succession by rank.
- **Ring algorithm**: Election by token-passing around a logical ring, collecting the live-node set; winner is the maximum-ranked node in that set.
- **Invitation algorithm**: Each node starts as its own group leader; groups merge by invitation, avoiding a full re-election from scratch; naturally tolerates multiple concurrent leaders during merging.
- **Liveness (election)**: The guarantee that the election eventually completes and a leader is chosen; the system must not stay in an election state indefinitely.
- **Lease-based leadership**: A leader holds a time-bounded lease; it may act as leader only within the lease period, after which it must re-acquire the lease, providing a soft upper bound on split-brain duration.

## Mental Models
- Think of the **Bully algorithm** as monarchial succession: the highest-ranked surviving sibling is crowned immediately — fast, but vulnerable to unstable high-ranked nodes causing perpetual re-elections.
- Think of the **Ring algorithm** as passing a ballot around a table: each person adds their name, and the highest-ranked person on the final list is elected — safe from individual node knowledge but vulnerable to partitioned sub-rings.
- Use **epoch/term fencing** whenever you must prevent a deposed leader from writing stale data — the token acts as an access key that storage can verify independently.
- Think of **Raft's randomized timeout** as an election where the first candidate to raise their hand wins — randomness breaks the symmetry that would cause simultaneous competing elections.

## Anti-patterns
- **Relying on election alone for safety**: All algorithms discussed (Bully, Ring) allow split-brain in network partitions. Without majority quorum, you can have two concurrent leaders writing conflicting data.
- **Preference for high-ranked unstable nodes (Bully)**: If the highest-ranked node is flapping, the cluster enters a permanent re-election loop. Incorporate host-quality metrics or stability scores into rank calculation.
- **Leaderless writes after election without epoch check**: A deposed leader that is slow (not crashed) may continue issuing writes. Always stamp writes with the current term/epoch and have storage reject stale-term writes.
- **Single system-wide leader as architecture**: A single leader becomes a bottleneck. Prefer per-partition leaders (as in Spanner, Kafka) to distribute coordination load.

## Reference Tables

### Election Algorithm Comparison

| Algorithm | Message Complexity | Safety (no split-brain) | Topology Requirement | Re-election Trigger |
|---|---|---|---|---|
| Bully | O(N²) worst case | No (partition-prone) | None | Leader unresponsive |
| Bully + Next-in-line | O(1) happy path | No | Leader must publish failover list | Leader unresponsive |
| Ring | O(N) per traversal | No (partition-prone) | Logical ring | Leader unresponsive |
| Invitation | O(groups × merges) | No (multiple leaders by design during merge) | None | Merge-based |
| Raft leader election | O(N) per term | Yes (majority quorum + term fencing) | None | Election timeout expiry |

### Split-Brain Prevention Decision Table

| Situation | Mechanism | Property Gained |
|---|---|---|
| Network partition with Bully/Ring | Add quorum requirement | Safety at cost of availability |
| Old leader slow but alive | Epoch/term fencing + storage rejection | Stale writes rejected |
| Leader crash detection | Failure detector (Ch09) + election | Liveness restored |
| Time-bounded leadership validity | Lease with expiry | Bounded split-brain window |

## Worked Example
**Bully Algorithm — leader 6 fails, election from node 3:**
1. Node 3 sends `Election` to nodes 4, 5, 6 (higher-ranked).
2. Nodes 4 and 5 respond `Alive`; node 6 does not (crashed).
3. Node 3 notifies node 5 (highest responder) to proceed.
4. Node 5 broadcasts `Elected` to nodes 1, 2, 3, 4 — node 5 is the new leader.

**Raft Leader Election — term-based fencing:**
1. Follower A's election timer fires (randomized, fires first).
2. A increments term from 3 to 4, votes for itself, sends `RequestVote(term=4)`.
3. Nodes B, C, D each check: "Is my log at least as up-to-date as A's? Is term 4 fresh?" — yes on both counts, they grant votes.
4. A receives 3 of 5 votes (majority), becomes leader for term 4.
5. Old leader (term 3) receives a message from A with term 4, steps down immediately.

## Key Takeaways
1. Leader election reduces coordination overhead by centralizing sequencing decisions, but the leader is a potential bottleneck — partition by data domain to scale.
2. The Bully and Ring algorithms are simple but both allow split-brain under network partitions; use them only where partition tolerance is not required.
3. Epoch/term fencing is the essential complement to election: it ensures a deposed leader's stale writes are rejected by storage nodes.
4. Raft uses randomized timeouts to break election symmetry, term numbers as fencing tokens, and majority votes to prevent split-brain simultaneously.
5. The Invitation algorithm avoids re-election from scratch by merging groups incrementally, useful in gossip-based membership systems.
6. Leader election and consensus are equivalent problems — if you can elect a leader via majority agreement, you can solve consensus, and vice versa.
7. Failure detection (Ch09) is a hard dependency of leader election: without detecting leader crashes, liveness of the election cannot be triggered.

## Connects To
- **Ch09**: Failure detection is what triggers a new election; the quality of the failure detector directly affects how quickly and accurately leader crashes are noticed.
- **Ch11**: Replication systems need a single leader (primary) to avoid conflicting writes; epoch/term fencing prevents a deposed primary from writing stale data.
- **Ch14**: Multi-Paxos and Raft implement their own leader election as an inner loop of the consensus protocol, extending the ideas here with quorum-based safety guarantees.
- **Ch13**: ZAB (Zookeeper Atomic Broadcast) uses epoch-based leader election as its first phase before entering broadcast mode.
