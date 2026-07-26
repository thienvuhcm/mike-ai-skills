#!/usr/bin/env bash
# Overwrites the global CLAUDE.md (~/.claude/CLAUDE.md) with this repo's CLAUDE.md.
# Backs up the previous global file before overwriting (kept as CLAUDE.md.bak.<timestamp>).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/CLAUDE.md"
DEST="$HOME/.claude/CLAUDE.md"

if [ ! -f "$SRC" ]; then
    echo "sync-claude-md: source not found: $SRC" >&2
    exit 1
fi

if [ -f "$DEST" ] && ! cmp -s "$SRC" "$DEST"; then
    cp "$DEST" "$DEST.bak.$(date +%Y%m%d%H%M%S)"
fi

cp "$SRC" "$DEST"
echo "sync-claude-md: synced $SRC -> $DEST"
