# Usage Guide

## analyze.sh

```
./scripts/analyze.sh <logfile> [--format text|csv] [--output <path>] [--verbose] [--help]
```

| Option | Meaning |
|---|---|
| `<logfile>` | Required. Path to a simulation log |
| `--format` | `text` (default) or `csv` |
| `--output` | Write the report to this file instead of stdout |
| `--verbose` | Diagnostics on stderr, including a check against the log's own SUMMARY line |
| `--help` | Print usage and exit 0 |

### Exit codes
- 0: every executed test passed
- 1: at least one test failed
- 2: usage error, missing or unreadable file, or no test results found

### Log format
Lines such as `[2026-05-01 10:23:46] TEST PASS: rv32i-add (0.82s)`. Statuses are
PASS, FAIL and SKIP. Skipped tests have no time and are excluded from timing stats.

### CSV columns
`log_file,total,passed,failed,skipped,pass_rate,min_time,max_time,avg_time,verdict`

## setup_env.sh
Checks that required tools exist and creates `output/`.

## generate_report.sh [output_dir]
Creates `<name>.txt` and `<name>.csv` for each sample log, plus `summary.txt`.

## Make targets
`make all`, `make test`, `make report`, `make clean`, `make setup`, `make help`.

## Troubleshooting
- `missing separator` in Make: recipe lines need a TAB.
- `bad interpreter: /bin/bash^M`: CRLF line endings, run `sed -i 's/\r$//' scripts/*.sh`.
