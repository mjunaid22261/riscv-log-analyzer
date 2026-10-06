# riscv-log-analyzer

A shell-based tool that analyzes RISC-V simulation logs and reports pass/fail
counts, failing test names, and timing statistics. Built for MEDS Module 1.

## Installation

```bash
git clone git@github.com:YOUR_USERNAME/riscv-log-analyzer.git
cd riscv-log-analyzer
make setup
```

Requires: bash, grep, awk, sed, sort, date, make, git.

## Usage

```bash
./scripts/analyze.sh test_data/sample_fail.log
./scripts/analyze.sh test_data/sample_sim.log --format csv --output output/sim.csv
make test      # run the built-in checks
make report    # reports for all sample logs in output/
make help      # list all targets
```

Exit codes: `0` all tests passed, `1` some test failed, `2` bad input.

## Sample output

```
--- Results Summary ---
Total tests: 7
Passed:      4 ( 57.1%)
Failed:      2 ( 28.6%)
Skipped:     1 ( 14.3%)

--- Failed Tests ---
  1. rv32i-sll
  2. rv32i-beq

--- Verdict: FAIL ---
```

See [docs/USAGE.md](docs/USAGE.md) for the full reference.

## Project layout

`scripts/` (analyze, setup, report), `test_data/` (sample logs),
`output/` (generated, gitignored), `docs/` (usage guide).

Status: analyzer script and Makefile implemented
