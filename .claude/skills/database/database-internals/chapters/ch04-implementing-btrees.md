# Chapter 4: Implementing B-Trees

## Core Idea
Real B-Tree implementations require concrete decisions about page headers, pointer layouts, traversal bookkeeping, and maintenance processes that the abstract algorithm omits — the gap between algorithm and working code is bridged by sibling links, rightmost pointers, high keys, breadcrumbs, and background vacuum.

## Frameworks Introduced
- **Breadcrumb Trail (BTStack)**: in-memory stack of (node, child-index) pairs collected during root-to-leaf traversal to enable upward propagation of splits and merges
  - When to use: any insert or delete that may cause a split or merge (i.e., always — you don't know until you reach the leaf)
  - How: push each visited (page_id, cell_index) onto a stack as you descend; if leaf splits, pop the top entry to locate the immediate parent and insert the promoted key; repeat until no split occurs or the stack is empty (root split)

- **Latch Crabbing (Latch Coupling)**: release parent latch as soon as child is proven safe from structural changes
  - When to use: concurrent B-Tree traversal to minimize latch hold time
  - How: acquire write latch on root; descend to child, acquire child latch; if child is not full (insert) or above half-full (delete), release parent latch and proceed; else retain parent latch

- **Blink-Tree Sibling Links + High Keys**: allow a split node to be visible through its sibling pointer before the parent is updated
  - When to use: concurrent B-Tree where holding a parent lock during split causes contention or deadlock risk
  - How: each non-root node holds a high key (maximum key for its subtree) and a right-sibling pointer; during search, if the search key exceeds a node's high key (half-split state), follow the sibling pointer instead of aborting; update parent pointer lazily

## Key Concepts
- **Page Header**: per-page metadata block at fixed offset 0 — typically contains: magic number, node type flags, cell count, lower/upper free-space offsets, rightmost pointer or high-key pointer, and page-level checksum
- **Magic Number**: multibyte constant (e.g., `0x50414745` = "PAGE") placed in header to validate page identity and alignment during reads
- **Rightmost Pointer**: the N+1th child pointer in an internal node that has no paired separator key; stored in the page header (SQLite approach) because there are always one more pointers than keys
- **High Key**: the maximum key value storable in a node's subtree, stored as an explicit cell in the node (PostgreSQL/Blink-Tree approach); allows pairing every pointer with a key, eliminating the special-case rightmost pointer
- **Overflow Page**: secondary page linked from a primary page when cell payload exceeds `max_payload_size = page_size / fanout`; multiple overflow pages chained via next-page-ID in each overflow page header
- **Sibling Link**: forward/backward pointer between adjacent nodes at the same level stored in page headers; enables lateral traversal without ascending to parent; must be updated on splits and merges
- **Binary Search with Indirection**: B-Tree page binary search operates on the sorted pointer array (not cell data directly) — pick the mid pointer, follow it to the cell, compare, bisect; preserves sort order without physically moving cells
- **Rebalancing**: transferring keys between sibling nodes to delay splits/merges and improve node occupancy; B*-Trees delay until both siblings are full, then split two nodes into three (each 2/3 full) instead of one into two (each 1/2 full)
- **Right-Only Appends (fastpath/quickbalance)**: optimization for monotonically increasing keys — insert goes directly to the cached rightmost leaf, bypassing full tree traversal (PostgreSQL fastpath); on overflow, allocate a fresh rightmost node instead of splitting (SQLite quickbalance)
- **Bulk Loading**: build a B-Tree from pre-sorted data bottom-up — write leaf pages in sorted order, propagate each leaf's first key to a parent using the normal algorithm; only rightmost splits occur; avoids random I/O
- **Vacuum / Compaction**: background process that rewrites fragmented pages in cell key order, reclaims space from dead cells, and returns freed page IDs to the free page list (freelist)
- **Freelist**: persistent list of page IDs available for reuse (e.g., SQLite trunk pages); must survive restarts to prevent space leaks

## Mental Models
- Think of the rightmost pointer as a virtual key `+∞` — it always wins any comparison, so it never needs an explicit separator key
- Think of the high key as giving every pointer an explicit upper bound — this trades the `+∞` special case for a concrete value, simplifying concurrent correctness
- Use breadcrumbs (stack) when you don't know up front if a structural change will propagate — collect the trail cheaply on the way down, use it only if needed
- Think of overflow pages as 4 KB growth increments — the node grows in page-sized steps rather than being resized; most comparisons use the trimmed primary-page key portion

## Anti-patterns
- **Holding all ancestor latches during insert**: creates a latch convoy from root to leaf — use latch crabbing to release parent latches as soon as the child is proven stable
- **Compacting pages synchronously on every delete**: causes write amplification on hot pages — defer compaction to background vacuum; compact synchronously only when physical contiguous space is exhausted
- **Storing parent pointers on disk**: they become stale on every rebalance, split, or merge; keep parent references only in memory (breadcrumb stack or transient pointer)
- **Splitting before trying to balance**: splitting creates two half-empty nodes; transferring to a sibling first (B*-Tree style) defers splits and keeps occupancy higher
- **Compressing entire index files**: requires full decompression to address any page and full recompression on any write — compress at page granularity instead

## Reference Tables

### Page Header Fields (Typical)
| Field               | Purpose                                              | Example Systems        |
|---------------------|------------------------------------------------------|------------------------|
| Magic number        | Identity/corruption check                            | SQLite, PostgreSQL     |
| Node type / flags   | Leaf vs. internal, variable vs. fixed size           | All                    |
| Cell count          | Number of live cells                                 | SQLite, InnoDB         |
| Lower free offset   | Next write position for cell pointers (grows right)  | PostgreSQL             |
| Upper free offset   | Next write position for cell data (grows left)       | PostgreSQL             |
| Rightmost pointer   | N+1th child pointer (no paired key)                  | SQLite                 |
| High key pointer    | Upper bound key for this node's subtree              | PostgreSQL (Blink-Tree)|
| Overflow page ID    | ID of first overflow page, if any                    | SQLite, InnoDB         |
| Page checksum       | CRC for corruption detection                         | PostgreSQL, InnoDB     |

### Rightmost Pointer vs. High Key
| Aspect               | Rightmost Pointer (SQLite style)         | High Key (PostgreSQL/Blink-Tree)           |
|----------------------|------------------------------------------|--------------------------------------------|
| Storage location     | Page header                              | Explicit rightmost cell                    |
| Key coverage         | N keys paired with N of N+1 pointers     | N+1 keys paired with N+1 pointers          |
| Split update         | Reassign rightmost ptr in parent header  | Update high key in split node              |
| Concurrency benefit  | Simpler structure                        | Enables half-split state; reduces parent lock hold time |

### Optimization Techniques Summary
| Technique          | When it helps                              | Trade-off                                 |
|--------------------|--------------------------------------------|--------------------------------------------|
| Rebalancing        | High write load with random keys           | Extra complexity; reduces splits and tree height |
| B*-Tree splitting  | High occupancy requirement                 | Defers splits; needs tracking of both siblings |
| Right-only appends | Monotonically increasing primary keys      | Leaves new rightmost node near-empty briefly |
| Bulk loading       | Initial load or full tree rebuild          | Requires pre-sorted input; no random inserts during load |
| Compression (page) | Large datasets; read-heavy workloads       | CPU cost for (de)compress; compressed page may span block boundary |

## Worked Example

**Breadcrumb-guided split propagation**

Tree state: root (R) → internal node (A) → leaf (L). Insert causes L to overflow.

1. Descend root→A→L, pushing breadcrumbs: stack = `[(R, child_idx=1), (A, child_idx=3)]`
2. L is full: split L into L and L'. Promoted key K' must go into L's parent.
3. Pop breadcrumb `(A, cell_idx=3)`. Insert K' into A at position 3.
4. A is not full: done. Stack unused remainder `(R, …)` is discarded.

If A were also full:
4b. Split A into A and A'. Pop breadcrumb `(R, cell_idx=1)`. Insert A's promoted key into R at position 1.
5. R is not full: done. Stack is now empty.

If R were also full:
5b. Split R → create new root R'. Height increases by 1. Stack empty; recursion stops.

**Binary search with indirection**

Page has pointer array: `[ptr2, ptr0, ptr3, ptr1]` (sorted by key). Cells stored at offsets `[ptr0…ptr3]` in insertion order.

To find key K:
- mid = index 1 → follow `ptr0` → compare key at cell0 with K
- If K > cell0_key: search right half `[ptr3, ptr1]`
- mid = index 2 → follow `ptr3` → compare key at cell3 with K
- Continue bisecting until found or insertion point identified

No cells are physically moved; only pointer indices are tracked during search.

## Key Takeaways
1. Every internal B-Tree node has one more child pointer than separator keys; the rightmost pointer must be explicitly tracked either in the header or as a high-key cell
2. High keys (Blink-Tree) enable lazy parent-pointer updates after splits, dramatically reducing concurrent latch contention
3. Breadcrumbs (in-memory stack) are the practical substitute for on-disk parent pointers — cheaper to maintain, sufficient for cascading split/merge propagation
4. Binary search in slotted pages works on the sorted pointer array, not the cells; follow each pointer only to compare, preserving sorted order without cell relocation
5. Rebalancing/B*-Tree splits improve average node occupancy and reduce tree height at the cost of additional sibling tracking logic
6. Right-only append and bulk loading are high-value optimizations for sequential primary-key workloads; implement them as isolated additions after the core algorithm works
7. Vacuum is mandatory, not optional — without background compaction, fragmented pages will accumulate garbage cells that waste I/O bandwidth and degrade search performance

## Connects To
- **Ch03**: Slotted page cell layouts, overflow pages, and fragmentation concepts from Ch03 are directly applied here
- **Ch05**: Latch crabbing and Blink-Trees in Ch04 connect to the concurrency control section of Ch05 (locks vs. latches, Blink-Tree concurrent access)
- **Ch06** (LSM Trees): Bulk loading and append-only construction patterns contrast with the mutable in-place update model described here
