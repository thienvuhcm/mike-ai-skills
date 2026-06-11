# Chapter 3: File Formats

## Core Idea
On-disk data structures require explicit binary encoding, page layout management, and fragmentation handling that memory-resident structures never need — the page (slotted or fixed) is the universal unit that bridges the gap between bytes on disk and logical records.

## Frameworks Introduced
- **Slotted Page Layout**: variable-size record storage inside a fixed-size page
  - When to use: any time page must hold variable-length data (strings, BLOBs, variable-size keys/values)
  - How: grow cell pointers from the left, grow cells from the right; sorted pointer array preserves key order without relocating cells; availability list tracks freed segments for reuse

- **Availability List + First/Best Fit**: reclaim fragmented space inside a page
  - When to use: after deletes leave gaps too small or non-contiguous for the next insert
  - How: first fit takes the earliest segment that fits (fast, may waste tail); best fit scans for smallest adequate segment (lower waste, slower); defragment and rewrite page when fragmented free space is sufficient but contiguous space is not

## Key Concepts
- **Endianness**: byte-order of multi-byte numeric values — big-endian stores MSB at lowest address; little-endian stores LSB at lowest address; sender and receiver must agree
- **IEEE 754**: standard binary representation of floating-point numbers — 32-bit single-precision: 1 sign bit + 8 exponent bits + 23 fraction bits; result is an approximation
- **Pascal String (UCSD String)**: variable-length string encoding as `uint16 size` followed by `size` bytes; enables O(1) length lookup vs. O(n) null-terminated scan
- **Slotted Page**: page layout where a pointer array (left side) and cell data (right side) grow toward each other; external references use slot IDs, not absolute offsets
- **Cell**: the atomic record unit inside a page — key cell holds `key_size | page_id | key_bytes`; key-value cell holds `flags | key_size | value_size | key_bytes | value_bytes`
- **Overflow Page**: extension page linked from a primary page when payload exceeds `max_payload_size = page_size / fanout`; linked as a chain via next-overflow-page-ID in each header
- **Fragmentation**: state where a page has enough total free bytes but not enough contiguous free bytes to fit a new cell — resolved by page defragmentation (compaction/vacuum)
- **Magic Number**: fixed multibyte constant in a file or page header used for validation and version identification (e.g., `50 41 47 45` = "PAGE")
- **CRC (Cyclic Redundancy Check)**: detects burst errors in stored pages via polynomial division; stored per-page in the header; recomputed on read and compared
- **Bit-Packed Flags**: boolean page metadata packed into a single byte using power-of-two bitmasks; set with `|=`, clear with `&= ~mask`, test with `& mask != 0`

## Mental Models
- Think of a slotted page as a two-stack page: pointers stack grows right-to-left, data stack grows left-to-right; free space is the gap between them
- Use big-endian for network/cross-platform formats (most standards); use native endian internally and convert at the boundary
- Think of variable-size fields as: fixed header (sizes/offsets) first, variable payload last — this makes fixed-field access O(1) with static offsets
- Use page-level checksums rather than file-level — smaller scope means fewer false negatives, and a single corrupt page does not discard the entire file

## Anti-patterns
- **Null-terminated strings for binary formats**: requires O(n) length scan and cannot contain embedded nulls — use Pascal strings instead
- **Storing variable-size fields before fixed-size fields**: forces runtime offset calculation for every fixed field — put fixed-size fields first
- **Relocating cells on every insert/delete**: O(n) cost and breaks external references — use slotted pages with pointer-only reordering
- **File-level checksum**: must read entire file to validate and must recompute entirely on any write — use per-page checksums
- **Ignoring platform endianness**: encoding on little-endian and decoding on big-endian silently corrupts numeric values

## Reference Tables

### Primitive Type Sizes
| Type    | Size (bytes) | Notes                                      |
|---------|-------------|--------------------------------------------|
| byte    | 1           | signed or unsigned 8-bit                   |
| short   | 2           | 16-bit integer                             |
| int     | 4           | 32-bit integer                             |
| long    | 8           | 64-bit integer                             |
| float   | 4           | IEEE 754 single-precision (1+8+23 bits)    |
| double  | 8           | IEEE 754 double-precision                  |
| boolean | 1 (or 1 bit)| pack 8 booleans into 1 byte with bitmasks  |

### Page Space Management Strategies
| Strategy   | How it works                          | Trade-off                              |
|------------|---------------------------------------|----------------------------------------|
| First fit  | Take first free segment ≥ needed size | Fast; may leave unusable tail gaps     |
| Best fit   | Scan for smallest adequate segment    | Lower waste; slower scan               |
| Defragment | Rewrite page, pack cells contiguously | Eliminates all fragmentation; expensive|

### File Format Versioning Approaches (used in real systems)
| Approach               | Example              | Trade-off                              |
|------------------------|----------------------|----------------------------------------|
| Version in filename    | Apache Cassandra `na-` prefix | No file open needed; file rename on upgrade |
| Version in separate file | PostgreSQL `PG_VERSION` | Simple; extra file to manage         |
| Version in file header | Most B-Tree files    | Self-contained; header format must be stable |
| Magic number in header | SQLite, many others  | Doubles as corruption check            |

## Worked Example

**Slotted page insert sequence (names: Tom → Leslie → Ron)**

Initial state: empty page, header at offset 0, free space fills the rest.

1. Insert "Tom": append cell bytes for "Tom" at the upper end of free space. Add offset pointer `[ptr→Tom]` at the left side of the pointer block.
   ```
   [hdr][ptr→Tom]...(free)...[Tom cell]
   ```

2. Insert "Leslie": append "Leslie" cell at the new upper boundary of free space. Add offset pointer, re-sort pointer block to alphabetical order (Leslie < Tom).
   ```
   [hdr][ptr→Leslie][ptr→Tom]...(free)...[Tom cell][Leslie cell]
   ```
   Cells are in insertion order (Tom, Leslie); pointers are in logical order (Leslie, Tom).

3. Insert "Ron": append "Ron" cell at the upper boundary. Insert Ron's offset pointer between Leslie and Tom in the pointer array (shift Tom's pointer right by one slot).
   ```
   [hdr][ptr→Leslie][ptr→Ron][ptr→Tom]...(free)...[Tom][Leslie][Ron]
   ```

External code references only `slot_id`, never raw offsets. If "Tom" is deleted, its pointer is nullified; the cell bytes remain but are invisible. Page is compacted only when needed.

## Key Takeaways
1. Design binary formats from primitives up: fixed-size fields → variable-size fields with length prefixes → cells → slotted pages → file hierarchy
2. Endianness must be uniform across the entire read/write path; choose at format design time and enforce at the boundary
3. Slotted pages solve variable-size record management by decoupling logical order (pointer array) from physical order (cell data), enabling O(1) insert without cell relocation
4. Store fixed-size fields before variable-size ones in any cell layout so static offsets reach them without scanning
5. Use page-level CRCs written at page flush time and validated at page read time to detect disk/memory corruption early
6. Overflow pages extend a node beyond a single fixed-size page in `page_size / fanout` increments; key trimming allows most comparisons to avoid following the overflow chain
7. Defragmentation (vacuum/compaction) is a background concern — don't pay the full rewrite cost on every delete; pay it periodically or when physical contiguous space is exhausted

## Connects To
- **Ch02**: B-Tree node structure explained logically; Ch03 shows how those nodes are physically encoded on disk
- **Ch04**: Builds directly on slotted pages and cell layouts to implement page headers, rightmost pointers, overflow pages, and binary search with indirection pointers
- **Ch05**: Page cache manages slotted pages in memory; WAL records reference page IDs and cell offsets defined by these formats
