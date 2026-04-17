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
ROOT_DIR  := $(abspath $(SIM_DIR)/../..)   # repo root
TEST_DIR  := $(ROOT_DIR)/tests/Stages/Harish_StageTesting/config

# ── Inputs (override on command line) ──
ASM       ?= $(TEST_DIR)/SingleAdd.s
TLB       ?= $(TEST_DIR)/TLB.conf.json
CORE_REGS ?= $(TEST_DIR)/CoreRegs.conf.json

# ── Options ──
MAX_CYCLES ?= 100000
CYCLE      ?=
OUT_JSON   ?= sim_output.json
LOG        ?= sim_run.log

# ── Base command ──
SIM_CMD = python3 $(SIM_DIR)sim.py \
            --asm $(ASM) \
            --tlb $(TLB) \
            --core-regs $(CORE_REGS) \
            --max-cycles $(MAX_CYCLES)

# ── Targets ──
.PHONY: run quiet json dump clean help

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

clean:
	rm -f $(OUT_JSON) $(LOG)

help:
	@echo "Targets:"
	@echo "  run           Verbose run (register changes per instruction)"
	@echo "  quiet         Print only final state"
	@echo "  json          Export final state to JSON (OUT_JSON=$(OUT_JSON))"
	@echo "  dump CYCLE=N  Dump full register state at cycle N"
	@echo "  clean         Remove generated files"
	@echo ""
	@echo "Variables (override on command line):"
	@echo "  ASM=<path>        Assembly source file"
	@echo "  TLB=<path>        TLB config JSON"
	@echo "  CORE_REGS=<path>  Core registers config JSON"
	@echo "  MAX_CYCLES=<n>    Max cycles before stopping"
	@echo "  OUT_JSON=<path>   JSON output file"
