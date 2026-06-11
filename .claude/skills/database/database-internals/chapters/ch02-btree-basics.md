# Chapter 2: B-Tree Basics

## Core Idea
B-Trees solve the fundamental problem of disk-based sorted search: binary search trees have fanout=2, forcing O(log₂N) disk seeks and fragmented locality. B-Trees increase fanout to hundreds of keys/node, reducing height and disk seeks to O(log_K N) while preserving sorted order for efficient range scans.

## Frameworks Introduced

- **Why BSTs Fail on Disk**
  - When to use: Justify the existence of B-Trees over simpler in-memory sorted structures
  - Why BSTs fail: fanout=2 → O(log₂N) seeks; no locality (child nodes may span different disk pages); frequent rebalancing = pointer updates across pages; impractical for external storage

- **B-Tree Structure (B⁺-Tree Default)**
  - When to use: Design a disk-based sorted key-value store
  - How: Root → internal nodes → leaf nodes. Each node holds up to N separator keys and N+1 child pointers. In B⁺-Trees (default in practice), values stored ONLY in leaf nodes; internal nodes hold separator keys only.
  - Key invariant: keys within a node are sorted; all keys in subtree[i] satisfy: separator[i-1] ≤ key < separator[i]
  - Leaf sibling pointers (linked list) enable efficient range scan continuation

- **B-Tree Node Split (Overflow)**
  - When to use: Insert triggers overflow (node at capacity N keys)
  - How (4 steps):
    1. Allocate new sibling node
    2. Copy right half of elements to new node (split at N/2)
    3. Place new element in correct node (< midpoint → original; ≥ midpoint → new)
    4. Promote midpoint key to parent (parent may recursively split)
  - Root split: allocate new root holding midpoint; old root + sibling become children; tree height grows by 1

- **B-Tree Node Merge (Underflow)**
  - When to use: Delete causes node to fall below minimum occupancy threshold
  - How (3 steps, after removing the element):
    1. Copy all elements from right node to left node
    2. Remove right node pointer from parent (demote separator key for nonleaf merges)
    3. Remove right node
  - Merge can propagate to root; root merge reduces tree height by 1

- **Rebalancing (Alternative to Merge)**
  - Redistribute keys between siblings before resorting to merge — reduces split/merge frequency

## Key Concepts

- **Fanout**: number of child pointers per node; higher fanout = lower tree height = fewer disk seeks
- **Occupancy**: ratio of currently held keys to node capacity; B-Trees guarantee ≥50%
- **Separator key / divider cell**: key in internal node that splits subtrees
- **Overflow**: node exceeds capacity → requires split
- **Underflow**: node falls below minimum occupancy → requires merge or rebalance
- **Split point (midpoint)**: index N/2 at which a full node is split
- **B⁺-Tree**: default B-Tree variant — values only in leaf nodes; internal nodes = keys only; enables SIMD-friendly sequential range scans via leaf linked list
- **Promotion**: midpoint key moved up to parent during split
- **Demotion**: separator key pulled down from parent during nonleaf merge
- **Paged binary tree**: BST variant grouping nodes into pages — marginally better locality but still inadequate for disk

## Mental Models

- Think of a B-Tree as "wide and shallow": each node is a full disk page with hundreds of keys; you need only 3–4 page reads to find any key among billions.
- Fanout and height are inversely proportional: double fanout → halve height.
- A B⁺-Tree's leaf level is a doubly-linked sorted list: range scans are a seek to first key + sequential traversal.
- Root splits are the only event that increases tree height — height only grows by 1 when every level is full.

## Anti-patterns

- **Using BSTs for disk indexes**: O(log₂N) seeks → 30+ seeks for 1B items; B-Trees reduce this to 3–4.
- **Frequent in-place updates to nonleaf nodes**: cascading splits and rebalancing are expensive; B-Tree variants (lazy B-Trees, Ch06) batch these via node-level buffers.
- **Confusing B-Tree with B⁺-Tree**: most databases use B⁺-Trees where internal nodes are key-only → smaller internal nodes → higher fanout.

## Reference Tables

| Property | BST | B-Tree (K=200 keys/node) |
|---|---|---|
| Fanout | 2 | 200 |
| Height for 10⁹ items | ~30 | ~4 |
| Disk seeks for lookup | ~30 | ~4 |
| Balancing cost | High (rotation after each op) | Low (split/merge amortized) |
| Range scan | In-order traversal | Leaf linked-list traversal |

| Operation | Trigger | Steps | Propagation |
|---|---|---|---|
| Split | Node overflow | Allocate sibling, copy half, promote midpoint | Up to root |
| Merge | Underflow after delete | Copy right→left, remove right pointer, demote separator | Up to root |
| Rebalance | Neighbor has excess keys | Redistribute between siblings | No propagation |

## Worked Example

**Inserting key 11 into a full leaf node (B⁺-Tree, max 4 keys/node):**

Before: leaf `[7, 9, 10, 12]` is full. Parent holds separator `[9, 13]`.

1. Leaf overflows on insert of 11.
2. Split point = index 2. Left leaf: `[7, 9]`. Right (new) leaf: `[10, 11, 12]`.
3. Promote midpoint key `10` to parent → parent becomes `[9, 10, 13]`.
4. No parent overflow → done. Tree height unchanged.

**Range scan for keys 9–12 after insert:**
- Seek: traverse root → leaf containing 9.
- Scan: read `9` from left leaf → follow sibling pointer → read `10, 11, 12` → stop.
- Total disk reads: 1 (root, cached) + 1 (left leaf) + 1 (right leaf) = 3 page reads.

## Key Takeaways

1. B-Trees achieve high fanout + low height by packing many keys per node — disk seeks from O(log₂N) to O(log_K N) where K ≈ hundreds.
2. B⁺-Trees store values only in leaf nodes; leaf level = sorted linked list → efficient range scans.
3. Splits propagate up (to root); merges propagate up; both bounded by tree height (~4 for billion-item trees).
4. Minimum 50% occupancy guarantee; rebalancing between siblings can delay merges.
5. Foundation for Ch04 (on-disk implementation) and Ch06 (variants: Lazy B-Trees, Bw-Tree, FD-Tree).

## Connects To

- **Ch04**: Implementing B-Trees on disk — page formats, concurrency (Blink-Tree), crash recovery
- **Ch06**: B-Tree Variants — Lazy B-Trees, FD-Trees, Bw-Trees, Fractal Trees
- **Ch01**: Mutable storage = in-place update (B-Tree); ordered storage = key-sorted on disk
- **DDIA Ch3**: B-Tree vs LSM-Tree trade-offs (write amplification, read performance)
