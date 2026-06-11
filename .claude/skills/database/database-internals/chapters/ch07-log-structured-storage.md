# Chapter 7: Log-Structured Storage

## Core Idea
LSM Trees achieve low-cost writes by never modifying files in place: all writes go to an in-memory memtable (backed by a WAL for durability), which is periodically flushed to immutable SSTables on disk; periodic compaction merges SSTables to reclaim space and bound read amplification.

## Frameworks Introduced
- **Two-Component LSM Tree**: One memtable + one disk-resident B-Tree (100% node occupancy); flush merges a memtable subtree with the corresponding disk subtree.
  - When to use: Conceptual baseline; high write amplification makes it rare in production.
  - How: Advance iterators over both sorted sources in lockstep → write merged result to new disk segment → atomically swap pointer.

- **Multicomponent LSM Tree**: One memtable + multiple immutable SSTable levels; flush writes entire memtable contents as a new SSTable; compaction merges SSTables.
  - When to use: Write-heavy workloads needing low write latency (Cassandra, RocksDB, LevelDB).
  - How: Write to WAL + memtable → flush memtable to L0 SSTable → background compaction merges across levels.

- **Leveled Compaction**: SSTables organized into levels with non-overlapping key ranges (except L0); compaction picks tables from two consecutive levels and merges.
  - When to use: Read-optimized LSM (RocksDB default); minimizes read amplification by ensuring at most one SSTable per key range per level.
  - How: L0 allows overlap → on L0 threshold, merge all L0 into L1; on Lk size threshold, pick one Lk table + all overlapping Lk+1 tables → produce new Lk+1 tables.

- **Size-Tiered Compaction**: SSTables grouped by size; small tables merge into medium, medium into large.
  - When to use: Write-optimized LSM (Cassandra default); lower write amplification than leveled but higher space and read amplification.
  - How: When N same-size tables accumulate, merge them → write result to the next larger tier.

- **Bitcask (Unordered LSM)**: Append-only logfiles + in-memory hashmap (keydir) mapping each key to the offset of its latest value.
  - When to use: Point-query-only workloads needing maximum write throughput (Riak).
  - How: Append key+value to logfile → update keydir → on read, follow keydir pointer → compact logfiles periodically, rebuild keydir on restart.

- **WiscKey (Key-Value Separation)**: Keys sorted in an LSM Tree; values stored in unordered append-only vLog files; LSM values are offsets into vLog.
  - When to use: Large-value workloads where compacting values wastes I/O (SSD-targeted).
  - How: Write key+offset to LSM + value to vLog → range scan traverses LSM in order, fetches values by random vLog reads → GC scans vLog using head/tail pointers validated against LSM.

## Key Concepts
- **memtable**: The mutable, in-memory sorted structure (typically a skiplist or balanced tree) that receives all writes; flushed to disk as an SSTable when it reaches a size threshold.
- **WAL (Write-Ahead Log)**: An append-only on-disk log ensuring that memtable contents survive crashes; truncated after the corresponding memtable is fully flushed.
- **SSTable (Sorted String Table)**: An immutable on-disk file containing key-value pairs in sorted key order, paired with an index file (B-Tree or hashtable) and optionally a Bloom filter.
- **compaction**: A background process that reads multiple SSTables, merges and reconciles their contents using multiway merge-sort, writes the result to a new SSTable, and discards the inputs.
- **tombstone**: A special delete marker inserted into the memtable (and propagated through compaction) to signal that a key has been deleted; prevents older copies from "resurrecting" on read.
- **leveled compaction**: A compaction strategy where each level beyond L0 has non-overlapping key ranges and grows exponentially; limits the number of SSTables checked per read to one per level.
- **size-tiered compaction**: A compaction strategy that groups SSTables by size and merges same-size groups; trades lower write amplification for higher space and read amplification.
- **Bloom filter**: A space-efficient probabilistic set-membership structure (bit array + k hash functions) attached to each SSTable; returns "definitely not present" or "possibly present," eliminating unnecessary disk reads for absent keys.
- **skiplist**: A probabilistically balanced linked-list hierarchy used as the in-memory data structure for the memtable; offers O(log n) insert/lookup without rotations and has a good concurrency profile.
- **RUM Conjecture**: The Read-Update-Memory trade-off principle: optimizing any two of these overhead dimensions necessarily increases the third. B-Trees are read-optimized; LSM Trees are write/space-optimized.
- **read amplification**: Extra disk reads required to answer a query because data may be spread across multiple SSTables; mitigated by Bloom filters and leveled compaction.
- **write amplification**: Extra bytes written per logical byte of user data; in LSM Trees this comes from compaction rewriting data as it migrates across levels.
- **WiscKey**: An LSM variant that stores only keys in sorted LSM Trees and values in unordered vLog files, dramatically reducing compaction I/O for large-value workloads.
- **Bitcask**: An unordered log-structured storage engine using an in-memory hashmap (keydir) for all keys; supports only point queries; requires full keydir rebuild on startup.

## Mental Models
- Think of LSM write path as a funnel: memtable (fast, small) → L0 (freshest) → L1 → … → Ln (oldest, largest). Data flows downhill through compaction.
- Think of a Bloom filter as a "definitely no / maybe yes" gate per SSTable: read the gate before paying the disk I/O cost.
- Use **leveled compaction** when reads must be fast (at most one SSTable per level per key) and you can afford more write I/O; use **size-tiered** when write throughput is the bottleneck and you can tolerate more space usage.
- Think of tombstones as expiration dates: they must travel all the way to the bottom level before being discarded, because any level above might still hold the old value they shadow.

## Anti-patterns
- **Dropping tombstones too early during compaction**: Old value copies in lower levels are resurrected. Tombstones must reach the bottommost level (RocksDB) or survive the GC grace period (Cassandra) before removal.
- **Ignoring log stacking**: Running an LSM Tree on a log-structured filesystem on an SSD (which also has its own FTL log) triples write amplification and fragmentation. Align segment sizes and minimize cross-layer duplication.
- **Unbounded L0 table accumulation**: L0 allows key-range overlap; too many L0 tables forces every read to check all of them. Trigger compaction on an L0 count threshold, not just on total size.
- **Bitcask for range queries**: keydir is an unordered hashmap; range scans require a full log scan. Bitcask is point-query-only.
- **WiscKey for update-heavy workloads**: GC must cross-reference the key LSM to determine value liveness; frequent updates mean GC overhead is high relative to reclaimed space.

## Reference Tables

### LSM Compaction Strategy Comparison

| Strategy | Write Amplification | Read Amplification | Space Amplification | Key Invariant | Used By |
|---|---|---|---|---|---|
| Leveled | Higher | Low (1 file/level/key) | Lower | No key-range overlap per level (L1+) | RocksDB, LevelDB |
| Size-Tiered | Lower | Higher | Higher | Same-size tables grouped | Cassandra (default) |
| Time-Window | Low (drops whole files) | Varies | Low for expired data | Data grouped by write time | Cassandra (time-series TTL) |

### Storage Structure RUM Position

| Structure | Read Overhead | Update Overhead | Memory/Space Overhead |
|---|---|---|---|
| B-Tree | Low | High (page rewrite) | High (reserved space) |
| LSM Tree (leveled) | Moderate | Low | Moderate |
| LSM Tree (size-tiered) | High | Very low | High |
| Bitcask | Very low (point only) | Very low | High (all keys in RAM) |
| WiscKey | Moderate (random vLog reads for range) | Low | Low (compact key LSM) |

### LSM Read Path (Multicomponent)

```
Query key K
  1. Check active memtable           → return if found
  2. Check flushing memtable(s)      → return if found
  3. For each SSTable (L0 first, then L1..Ln):
       a. Check Bloom filter          → skip if "definitely not"
       b. Check key range metadata    → skip if K outside range
       c. Binary search SSTable index → fetch data block
  4. Reconcile all found versions by timestamp → return latest non-tombstoned value
```

## Worked Example

**Leveled compaction: L0 threshold reached (4 tables), key range [a–z]**

State before:
- L0: T1[a–m], T2[b–p], T3[c–z], T4[a–k]  (overlapping key ranges — 4 tables → trigger)
- L1: T5[a–e], T6[f–n], T7[o–z]            (non-overlapping)

Compaction steps:
1. Collect all L0 tables (T1–T4) + all L1 tables whose ranges overlap with L0's combined range [a–z] → T5, T6, T7.
2. Open iterators over T1–T7; use priority-queue multiway merge-sort.
3. Reconcile same-key records: keep the one with the highest timestamp; discard tombstoned keys if they have reached L1 (bottommost here for this example).
4. Write merged output, partitioned into new L1 tables: N1[a–e], N2[f–n], N3[o–z] (same target sizes as original L1 tables).
5. Atomically replace T1–T4 and T5–T7 with N1–N3 in the table view.
6. Delete T1–T7 after all in-flight reads referencing them complete.

**Result**: L0 is empty; L1 has fresh non-overlapping tables; next read for any key in [a–z] checks at most 1 L1 table after the Bloom filter pass.

## Key Takeaways
1. LSM Trees trade read amplification for write amplification: writes never locate existing records on disk, but reads may consult multiple SSTables.
2. The WAL provides crash durability for the memtable; it can be truncated only after the corresponding memtable is fully flushed to disk.
3. Tombstones must persist through compaction until no older copies of the same key can exist in lower levels; premature deletion causes data resurrection.
4. Bloom filters are the single most impactful read optimization in LSM Trees: they eliminate disk I/O for absent keys with very low false-positive rates.
5. Leveled compaction bounds read amplification (one SSTable per level per key) at the cost of more write I/O; size-tiered compaction reduces write I/O at the cost of higher read and space amplification.
6. WiscKey reduces compaction I/O dramatically for large values by separating keys (sorted, small) from values (unsorted, large vLog) but complicates GC and range-scan performance.
7. Log stacking (LSM on a log-structured filesystem on an SSD with FTL) multiplies write amplification across layers; align writes to hardware block size and consider Open-Channel SSDs for extreme workloads.

## Connects To
- **Ch06 (B-Tree Variants)**: FD-Trees and Bw-Trees borrow LSM ideas (immutable runs, append-only writes); Ch07 shows the full LSM design those variants drew from.
- **Ch03 (File Formats)**: SSTable on-disk layout (sorted cells, index blocks, compression) directly applies the binary file format concepts from Ch03.
- **Ch04 (B-Tree Implementation)**: B-Trees are often used as the internal index structure inside SSTables; two-component LSM Trees use a B-Tree as the disk component.
- **Ch08+ (Distributed Systems)**: LSM compaction and tombstone propagation have distributed analogs in eventual consistency and anti-entropy; understanding single-node LSM is prerequisite for distributed LSM (e.g., Cassandra, ScyllaDB).
