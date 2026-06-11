# Chapter 6: B-Tree Variants

## Core Idea
Every B-Tree variant makes a different trade-off to reduce write amplification, space amplification, or lock contention: the key techniques are copy-on-write immutability, in-memory buffering (lazy), fractional-cascading over immutable runs (FD-Tree), and append-only delta chains (Bw-Tree).

## Frameworks Introduced
- **Copy-on-Write (LMDB)**: Modify a parallel copy of the path from root to leaf; atomically swap the root pointer when done.
  - When to use: When you want lock-free readers and crash safety without a WAL or page cache.
  - How: Copy every branch node on the write path → update the copy → CAS the topmost root pointer; old pages reclaimed after all readers finish.

- **Lazy B-Tree (WiredTiger / LA-Tree)**: Buffer writes in an in-memory structure attached to nodes or subtrees; reconcile lazily on flush.
  - When to use: Workloads with many repeated writes to the same pages.
  - How: Keep an update buffer (skiplist in WiredTiger; cascaded per-subtree buffer in LA-Tree) → background thread merges buffer into the on-disk page.

- **FD-Tree (Flash Disk Tree)**: Small mutable head B-Tree + multiple immutable sorted runs connected by fractional cascading.
  - When to use: SSDs where random writes are expensive and you want bounded random-write surface area.
  - How: Fill head tree → flush to run L1 → when L1 exceeds threshold merge into L2 … (like LSM compaction); use fractional cascading bridges between runs to speed searches.

- **Bw-Tree**: Logical nodes = base node + prepended delta chain stored append-only; in-memory mapping table resolves logical IDs to physical disk offsets using CAS.
  - When to use: Latch-free concurrent write-heavy workloads; new hardware (NVM / SSD) where small writes are cheap.
  - How: Write delta node → CAS mapping table entry to new delta location → consolidate chain periodically; epoch-based reclamation for GC.

## Key Concepts
- **Write amplification**: Extra bytes written to disk per logical byte of user data; in-place B-Trees suffer because even a 1-byte change rewrites an entire page.
- **Space amplification**: Reserved empty space in B-Tree nodes that is wasted but required for future splits.
- **Copy-on-Write B-Tree**: An immutable B-Tree variant where modified pages are written to new locations; old pages remain accessible to concurrent readers until reclaimed.
- **Lazy B-Tree**: A B-Tree that defers writing updates to disk by buffering them in memory-resident structures (e.g., skiplists or per-subtree buffers).
- **Fractional cascading**: A technique that pulls every Nth element from a lower sorted array into the higher one to build bridges (fences), reducing the search cost in cascaded sorted arrays from O(log n) per level to O(1) after the first level.
- **FD-Tree**: A structure combining a small mutable head B-Tree with logarithmically sized immutable sorted runs linked by fractional cascading; limits random-write surface to the head tree.
- **Bw-Tree**: A lock-free B-Tree variant that writes base nodes and delta updates separately in an append-only log; a mapping table provides indirection from logical node IDs to physical locations.
- **Delta node**: An incremental update record in a Bw-Tree that is prepended to the logical node's chain without rewriting the base node.
- **Epoch-based reclamation**: A GC scheme where obsolete nodes are freed only after all readers that started before or during the same epoch have finished, ensuring no live reader references the freed node.
- **Cache-oblivious B-Tree**: A B-Tree laid out using the van Emde Boas recursive subtree layout so that it achieves asymptotically optimal block-transfer counts for any memory hierarchy without tuning block-size parameters.

## Mental Models
- Use **Copy-on-Write** when you want zero-latch reads and atomic durability without a WAL — think of old tree versions as snapshots that persist until all readers using them finish.
- Use **Lazy B-Tree buffering** when the same pages get hit repeatedly — think of the in-memory buffer as an inbox that drains in bulk rather than one letter at a time.
- Use **FD-Tree / immutable runs** when you want to confine all random writes to one small area — think of the head tree as a narrow airlock and the immutable runs as sealed chambers.
- Use **Bw-Tree delta chaining** when you need lock-free concurrency — think of each node as a linked list of sticky notes; you CAS a new sticky note to the front, and GC consolidates them periodically.

## Anti-patterns
- **Reading a long Bw-Tree delta chain without consolidation**: Every read must apply all deltas; an unbounded chain degrades read latency linearly — set a consolidation threshold.
- **Relying on copy-on-write without timely page reclamation**: Old page versions accumulate if long-running readers are not tracked; LMDB holds only two root versions, which limits this, but other CoW implementations must track reader lifetimes explicitly.
- **FD-Tree with frequent small merges**: Merging every time the head fills creates compaction pressure similar to LSM; set the head tree large enough to amortize merge cost.
- **Assuming cache-oblivious structures are production-ready**: As of the book's writing, no non-academic cache-oblivious B-Tree implementations exist; the van Emde Boas layout has the same asymptotic block-transfer complexity as cache-aware B-Trees.

## Reference Tables

### B-Tree Variant Trade-off Matrix

| Variant | Write Amplification | Space Amplification | Read Overhead | Latch-Free? | Key Innovation |
|---|---|---|---|---|---|
| Classic B-Tree | High (full page rewrite) | High (reserved space) | Low | No | — |
| Copy-on-Write (LMDB) | Moderate (path copy) | Moderate (two root versions) | Low | Readers yes | Atomic root CAS |
| Lazy B-Tree (WiredTiger) | Reduced (batch flush) | High (reserved space) | Low + merge cost | Partial | In-memory update buffer |
| LA-Tree | Reduced (cascaded flush) | High | Low + merge cost | No | Per-subtree cascaded buffer |
| FD-Tree | Low (append + merge) | Low (immutable runs) | Higher (multi-run search) | No | Fractional cascading + immutable runs |
| Bw-Tree | Low (append delta) | Low (no pre-alloc) | Higher (apply deltas) | Yes | Mapping table + CAS |

## Worked Example

**Bw-Tree insert for key k5, value v5:**

1. Traverse logical tree from root → leaf via mapping table to find the target logical node L3.
2. Create a new delta node D: `{insert: k5→v5, next_ptr: current_head_of_L3}`.
3. CAS the mapping table entry for L3 from `old_ptr` to the address of D. If the CAS fails (another thread raced), retry from step 1.
4. Reads issued after step 3 see D as the head of L3's chain; reads issued before step 3 still see `old_ptr`.
5. When delta chain length for L3 exceeds threshold T: consolidate — apply all deltas to the base node, write a new base node to disk, CAS the mapping table entry to the new base node address, schedule old nodes for epoch-based GC.

## Key Takeaways
1. Write amplification in classic B-Trees comes from rewriting entire pages for small updates; buffering (lazy) or append-only deltas (Bw-Tree) amortize this cost.
2. Space amplification comes from reserved empty space; immutable structures like FD-Trees and Bw-Trees eliminate pre-allocation.
3. Copy-on-Write gives lock-free readers at the cost of writing entire root-to-leaf paths on every write; it eliminates the WAL but multiplies write I/O by tree depth.
4. FD-Trees confine random writes to a small head B-Tree; fractional cascading bridges make multi-run searches sub-linear after the first binary search.
5. Bw-Tree's mapping table is the linchpin: it decouples logical node identity from physical location and makes lock-free CAS updates possible.
6. Epoch-based reclamation is the standard GC strategy for latch-free structures where readers hold no explicit locks.
7. Cache-oblivious B-Trees are theoretically elegant but have no known production implementations; the dominant production technique remains tuning node size to hardware block size.

## Connects To
- **Ch04 (B-Tree Implementation)**: Ch06 variants refine the on-disk B-Tree mechanics introduced in Ch04 — splits, merges, and page layout all apply.
- **Ch07 (Log-Structured Storage)**: FD-Trees and Bw-Trees borrow append-only ideas from LSM Trees; Ch07 takes buffering + immutability further with full LSM structures.
- **Ch05 (Transaction Processing / Concurrency)**: Bw-Tree's compare-and-swap and epoch-based reclamation are concurrency primitives that connect to latch/lock discussions in Ch05.
