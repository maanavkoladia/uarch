# ─────────────────────────────────────────────
# x86-32 Functional Simulator  –  Makefile
# ─────────────────────────────────────────────
# Usage:
#   make run                 # verbose run with default test case
#   make run TEST_CASE_DIR=path PROGRAM_BIN=path/to/program.bin
#   make quiet               # final-state only
#   make json                # export final state to JSON
#   make dump CYCLE=50       # dump regs at cycle 50
#   make compare             # diff sim vs RTL trace
# ─────────────────────────────────────────────

SIM_DIR   ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ROOT_DIR  ?= $(abspath $(SIM_DIR)/../..)
TEST_DIR  ?= $(ROOT_DIR)/tests/Stages/Harish_StageTesting

# ── Inputs (the parent stage Makefile exports these) ──
TEST_CASE_DIR ?= $(TEST_DIR)/config/TestProgs/TheBigOne
PROGRAM_BIN   ?= $(TEST_DIR)/gen/memGen/meta/program.bin

# ── Python (capstone-aware venv) ──
# Falls back to PYTHON if a venv python isn't available.
VENV_PY := $(TEST_DIR)/venv/bin/python3
ifeq ($(wildcard $(VENV_PY)),)
SIM_PYTHON ?= $(PYTHON)
else
SIM_PYTHON ?= $(VENV_PY)
endif

# ── Options ──
MAX_CYCLES  ?= 100000
CYCLE       ?=
OUT_JSON    ?= sim_output.json
LOG         ?= sim_run.log
TRACE_FILE  ?= sim_trace.log
RTL_LOG     ?= $(abspath $(TEST_DIR)/run.log)
REPORT_FILE ?= compare_report.txt

NORM_RTL_LOG ?= norm_rtl.log
NORM_SIM_LOG ?= norm_sim.log

SIM_REGDUMP_FILE  ?= sim_regdump.log
SIM_FLAGDUMP_FILE ?= sim_flagdump.log
RTL_REGDUMP_FILE  ?= $(abspath $(TEST_DIR)/regdump.log)
RTL_FLAGDUMP_FILE ?= $(abspath $(TEST_DIR)/flagdump.log)
DUMP_REPORT_FILE  ?= dump_compare_report.txt

# ── Base command ──
SIM_CMD = $(SIM_PYTHON) $(SIM_DIR)/sim.py \
          --test-dir $(TEST_CASE_DIR) \
          --bin      $(PROGRAM_BIN) \
          --max-cycles $(MAX_CYCLES)

# ── Targets ──
.PHONY: run quiet json dump trace compare clean help

run:
	$(SIM_CMD) 2>&1 | tee $(LOG)
	@echo ""
	@echo "Log written to $(LOG)"

quiet:
	$(SIM_CMD) --quiet

json:
	$(SIM_CMD) --quiet --dump-json $(OUT_JSON)
	@echo "Wrote $(OUT_JSON)"

dump:
ifndef CYCLE
	$(error Set CYCLE=<n>, e.g. make dump CYCLE=50)
endif
	$(SIM_CMD) --dump-cycle $(CYCLE)

trace:
	$(SIM_CMD) --quiet --trace-file $(TRACE_FILE)
	@echo "Sim trace written to $(TRACE_FILE)"

compare: run
	$(SIM_CMD) --quiet \
		--trace-file $(TRACE_FILE) \
		--regdump-file $(SIM_REGDUMP_FILE) \
		--flagdump-file $(SIM_FLAGDUMP_FILE)
	$(SIM_PYTHON) $(SIM_DIR)/compare.py \
		--sim $(TRACE_FILE) \
		--rtl $(RTL_LOG) \
		--out $(REPORT_FILE) \
		--norm-sim  $(NORM_SIM_LOG) \
		--norm-rtl $(NORM_RTL_LOG) \
		--regdump-sim $(SIM_REGDUMP_FILE) \
		--regdump-rtl $(RTL_REGDUMP_FILE) \
		--flagdump-sim $(SIM_FLAGDUMP_FILE) \
		--flagdump-rtl $(RTL_FLAGDUMP_FILE) \
		--dump-report $(DUMP_REPORT_FILE)
	@echo ""
	@echo "Report:          $(REPORT_FILE)"
	@echo "Dump report:     $(DUMP_REPORT_FILE)"
	@echo "Normalized SIM:  $(NORM_SIM_LOG)   (use: diff norm_sim.log norm_rtl.log)"
	@echo "Normalized RTL:  $(NORM_RTL_LOG)"

help:
	@echo "Targets:"
	@echo "  run              Verbose run (register changes per instruction)"
	@echo "  quiet            Print only final state"
	@echo "  json             Export final state to JSON (OUT_JSON=$(OUT_JSON))"
	@echo "  dump CYCLE=N     Dump full register state at cycle N"
	@echo "  trace            Run sim and write normalized trace (TRACE_FILE=$(TRACE_FILE))"
	@echo "  compare          Run sim trace + parse RTL log + diff report"
	@echo ""
	@echo "Variables (override on command line):"
	@echo "  TEST_CASE_DIR=<path>   Folder with TLB.conf.json, CoreRegs.conf.json"
	@echo "  PROGRAM_BIN=<path>     Flat 32 KiB program.bin"
	@echo "  MAX_CYCLES=<n>         Max cycles before stopping"
	@echo "  OUT_JSON=<path>        JSON output file"
	@echo "  SIM_PYTHON=<path>      Python interpreter to use (default: $(SIM_PYTHON))"
