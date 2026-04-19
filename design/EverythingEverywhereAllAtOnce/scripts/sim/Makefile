# ─────────────────────────────────────────────
# x86-32 Functional Simulator  –  Makefile
# ─────────────────────────────────────────────
# Usage:
#   make run                 # verbose run with default program
#   make run ASM=path/to.s   # run a different program
#   make quiet               # final-state only
#   make json                # export final state to JSON
#   make dump CYCLE=50       # dump regs at cycle 50
#   make clean               # remove generated outputs
# ─────────────────────────────────────────────

SIM_DIR   := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ROOT_DIR  := $(abspath $(SIM_DIR)/../..)
TEST_DIR  := $(ROOT_DIR)/tests/Stages/Harish_StageTesting/config

# ── Inputs (override on command line) ──
ASM       ?= $(TEST_DIR)/AAA_ADC.s
TLB       ?= $(TEST_DIR)/TLB.conf.json
CORE_REGS ?= $(TEST_DIR)/CoreRegs.conf.json

# ── Options ──
MAX_CYCLES  ?= 100000
CYCLE       ?=
OUT_JSON    ?= sim_output.json
LOG         ?= sim_run.log
TRACE_FILE  ?= sim_trace.log
RTL_LOG     ?= $(abspath $(TEST_DIR)/../run.log)
REPORT_FILE ?= compare_report.txt

# ── Base command ──
SIM_CMD = python3 $(SIM_DIR)sim.py --asm $(ASM) --tlb $(TLB) --core-regs $(CORE_REGS) --max-cycles $(MAX_CYCLES)

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

compare:
	$(SIM_CMD) --quiet --trace-file $(TRACE_FILE)
	python3 $(SIM_DIR)compare.py \
		--sim $(TRACE_FILE) \
		--rtl $(RTL_LOG) \
		--out $(REPORT_FILE) \
		--norm-sim norm_sim.log \
		--norm-rtl norm_rtl.log
	@echo ""
	@echo "Report:          $(REPORT_FILE)"
	@echo "Normalized SIM:  norm_sim.log   (use: diff norm_sim.log norm_rtl.log)"
	@echo "Normalized RTL:  norm_rtl.log"

clean:
	rm -f $(OUT_JSON) $(LOG) $(TRACE_FILE) $(REPORT_FILE) norm_sim.log norm_rtl.log

help:
	@echo "Targets:"
	@echo "  run              Verbose run (register changes per instruction)"
	@echo "  quiet            Print only final state"
	@echo "  json             Export final state to JSON (OUT_JSON=$(OUT_JSON))"
	@echo "  dump CYCLE=N     Dump full register state at cycle N"
	@echo "  trace            Run sim and write normalized trace (TRACE_FILE=$(TRACE_FILE))"
	@echo "  compare          Run sim trace + parse RTL log + diff report"
	@echo "                   RTL_LOG defaults to $(RTL_LOG)"
	@echo "                   Override: make compare RTL_LOG=/path/to/pipeline_debug.log"
	@echo "  clean         Remove generated files"
	@echo ""
	@echo "Variables (override on command line):"
	@echo "  ASM=<path>        Assembly source file"
	@echo "  TLB=<path>        TLB config JSON"
	@echo "  CORE_REGS=<path>  Core registers config JSON"
	@echo "  MAX_CYCLES=<n>    Max cycles before stopping"
	@echo "  OUT_JSON=<path>   JSON output file"
