#!/bin/bash
# analyze.sh - Analyze a RISC-V simulation log and print a summary report.
# Exit codes: 0 = all tests passed, 1 = at least one test failed,
#             2 = usage or input error
set -euo pipefail

FORMAT="text"
OUTPUT=""
VERBOSE=0
LOG_FILE=""

usage() {
    cat <<EOF
Usage: $(basename "$0") <logfile> [options]

Options:
  --format text|csv   Output format (default: text)
  --output <path>     Write the report to a file (default: stdout)
  --verbose           Print extra diagnostic messages to stderr
  --help              Show this help

Exit codes: 0 all tests passed, 1 some test failed, 2 usage or input error
EOF
}

# Print an error to stderr and exit with code 2 (input problem, not a test failure)
die() {
    echo "Error: $*" >&2
    echo "Try '$(basename "$0") --help' for usage." >&2
    exit 2
}

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "[verbose] $*" >&2
    fi
}

# Manual option parsing: while + shift handles options that take a value
while [ $# -gt 0 ]; do
    case "$1" in
        --format)
            [ $# -ge 2 ] || die "--format needs a value"
            FORMAT="$2"
            shift 2
            ;;
        --output)
            [ $# -ge 2 ] || die "--output needs a value"
            OUTPUT="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            die "unknown option: $1"
            ;;
        *)
            [ -z "$LOG_FILE" ] || die "only one log file is allowed"
            LOG_FILE="$1"
            shift
            ;;
    esac
done

# Validate input
[ -n "$LOG_FILE" ] || die "missing required argument: <logfile>"
[ -f "$LOG_FILE" ] || die "file not found: $LOG_FILE"
[ -r "$LOG_FILE" ] || die "file not readable: $LOG_FILE"
case "$FORMAT" in
    text|csv) ;;
    *) die "invalid format '$FORMAT' (use text or csv)" ;;
esac

# ---------- parsing helpers ----------

# One line per finished test: <name> <STATUS> <seconds or ->
# Fields of "[date time] TEST PASS: name (0.82s)" are: $4=PASS: $5=name $6=(0.82s)
parse_results() {
    awk '
        /\] TEST (PASS|FAIL|SKIP):/ {
            status = $4
            sub(/:$/, "", status)        # strip the trailing colon
            t = $6
            gsub(/[()]/, "", t)          # (0.82s) becomes 0.82s
            if (t ~ /^[0-9.]+s$/) { sub(/s$/, "", t) } else { t = "-" }
            print $5, status, t
        }
    ' "$LOG_FILE"
}

# Count results with a given status. Uses awk, not grep -c, because grep exits 1
# on zero matches and that would kill the script under set -e.
count_status() {
    printf '%s\n' "$RESULTS" | awk -v s="$1" '$2 == s { n++ } END { print n + 0 }'
}

failed_names() {
    printf '%s\n' "$RESULTS" | awk '$2 == "FAIL" { print $1 }'
}

# Prints: min min_name max max_name avg  (or five NA when no timing exists)
timing_stats() {
    printf '%s\n' "$RESULTS" | awk '
        NF == 3 && $3 != "-" {
            t = $3 + 0
            if (n == 0 || t < min) { min = t; minname = $1 }
            if (n == 0 || t > max) { max = t; maxname = $1 }
            sum += t
            n++
        }
        END {
            if (n == 0) { print "NA NA NA NA NA"; exit }
            printf "%.2f %s %.2f %s %.2f\n", min, minname, max, maxname, sum / n
        }'
}

# pct <part> <whole> -> percentage with one decimal, safe when whole is 0
pct() {
    awk -v a="$1" -v b="$2" 'BEGIN { if (b == 0) printf "0.0"; else printf "%.1f", a * 100 / b }'
}

# Compare our counts with the SUMMARY line the log itself reports (verbose only)
check_summary() {
    local line
    line=$(grep 'SUMMARY:' "$LOG_FILE" | tail -n 1 || true)
    if [ -z "$line" ]; then
        log_verbose "no SUMMARY line found in log"
        return 0
    fi
    log_verbose "log says: ${line#*SUMMARY: }"
    log_verbose "we counted: $TOTAL tests, $PASSED passed, $FAILED failed, $SKIPPED skipped"
}
