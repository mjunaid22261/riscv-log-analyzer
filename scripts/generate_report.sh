#!/bin/bash
# generate_report.sh - Run the analyzer on every sample log and collect the results.
# Usage: generate_report.sh [output_dir]   (default: <repo>/output)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${1:-$ROOT/output}"
SUMMARY="$OUT_DIR/summary.txt"

mkdir -p "$OUT_DIR"
: > "$SUMMARY"                  # start with an empty summary file

for log in "$ROOT"/test_data/*.log; do
    name="$(basename "$log" .log)"
    rc=0
    # analyze.sh exits 1 when tests fail; capture the code instead of aborting
    "$ROOT/scripts/analyze.sh" "$log" --output "$OUT_DIR/$name.txt" || rc=$?
    "$ROOT/scripts/analyze.sh" "$log" --format csv --output "$OUT_DIR/$name.csv" || true
    printf '%-14s exit=%d\n' "$name" "$rc" >> "$SUMMARY"
done

echo "=== Summary ==="
cat "$SUMMARY"
echo "Reports saved in $OUT_DIR"
