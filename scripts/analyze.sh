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

