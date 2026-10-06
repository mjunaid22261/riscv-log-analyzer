# Makefile for riscv-log-analyzer
SHELL    := /bin/bash
ANALYZE  := scripts/analyze.sh
DATA_DIR := test_data
OUT_DIR  := output
LOGS     := $(wildcard $(DATA_DIR)/*.log)
REPORTS  := $(patsubst $(DATA_DIR)/%.log,$(OUT_DIR)/%.txt,$(LOGS))

.PHONY: all test report clean help setup

all: $(REPORTS) ## Run the analyzer on every log in test_data/
	@echo "Reports written to $(OUT_DIR)/"

# Pattern rule: one report per log. Exit code 1 means "some tests failed",
# which is expected for some logs, so only that code is tolerated.
$(OUT_DIR)/%.txt: $(DATA_DIR)/%.log $(ANALYZE) | $(OUT_DIR)
	$(ANALYZE) $< --output $@ || [ $$? -eq 1 ]

$(OUT_DIR):
	mkdir -p $@

test: ## Run the analyzer on each sample log and verify exit codes and output
	@echo "Running tests..."
	@$(ANALYZE) $(DATA_DIR)/sample_pass.log > /dev/null; test $$? -eq 0 \
	  && echo "  ok   sample_pass exits 0" || { echo "  FAIL sample_pass exit code"; exit 1; }
	@$(ANALYZE) $(DATA_DIR)/sample_pass.log | grep 'Verdict: PASS' > /dev/null \
	  && echo "  ok   sample_pass verdict PASS" || { echo "  FAIL sample_pass verdict"; exit 1; }
	@$(ANALYZE) $(DATA_DIR)/sample_fail.log > /dev/null; test $$? -eq 1 \
	  && echo "  ok   sample_fail exits 1" || { echo "  FAIL sample_fail exit code"; exit 1; }
	@$(ANALYZE) $(DATA_DIR)/sample_fail.log | grep 'Total tests: 7' > /dev/null \
	  && echo "  ok   sample_fail total is 7" || { echo "  FAIL sample_fail total"; exit 1; }
	@$(ANALYZE) $(DATA_DIR)/sample_fail.log | grep '1. rv32i-sll' > /dev/null \
	  && echo "  ok   sample_fail lists rv32i-sll" || { echo "  FAIL sample_fail names"; exit 1; }
	@$(ANALYZE) $(DATA_DIR)/sample_fail.log --format csv | grep ',7,4,2,1,' > /dev/null \
	  && echo "  ok   sample_fail csv counts" || { echo "  FAIL csv counts"; exit 1; }
	@$(ANALYZE) $(DATA_DIR)/sample_sim.log > /dev/null; test $$? -eq 1 \
	  && echo "  ok   sample_sim exits 1" || { echo "  FAIL sample_sim exit code"; exit 1; }
	@$(ANALYZE) no_such_file.log 2> /dev/null; test $$? -eq 2 \
	  && echo "  ok   missing file exits 2" || { echo "  FAIL missing file exit code"; exit 1; }
	@echo "All tests passed"

report: ## Generate text and CSV reports plus a summary in output/
	./scripts/generate_report.sh $(OUT_DIR)

clean: ## Remove all generated files in output/
	find $(OUT_DIR) -mindepth 1 ! -name .gitkeep -delete

setup: ## Check that all required tools are installed
	@./scripts/setup_env.sh

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-8s %s\n", $$1, $$2}'
