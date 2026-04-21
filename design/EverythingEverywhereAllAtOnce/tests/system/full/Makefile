export SIM_DIR PYTHON ASM TLB CORE_REGS LOG RTL_LOG NORM_RTL_LOG NORM_SIM_LOG 

TEST_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT_ROOT := $(shell pwd | sed -E 's|(.*EverythingEverywhereAllAtOnce).*|\1|')


DISTRO := $(shell . /etc/os-release && echo $$ID)

TARGET = SystemTest

STRUCTRURAL := true

RTL_RUN_LOG_FILE := $(TEST_DIR)/logDumps/run.log
CLK_PERIOD := 8

SIM_DIR = $(PROJECT_ROOT)/scripts/sim/

#sim rtl var
ASM       = $(TEST_DIR)/config/TestProgs/StagesProgJmp.s
TLB       = $(TEST_DIR)/config/TLB.conf.json
CORE_REGS = $(TEST_DIR)/config/CoreRegs.conf.json

OUT_JSON    = $(TEST_DIR)/logDumps/sim_output.json
LOG = $(TEST_DIR)/logDumps/sim_run.log
TRACE_FILE  = $(TEST_DIR)/logDumps/sim_trace.log
RTL_LOG    = $(RTL_RUN_LOG_FILE)
REPORT_FILE = $(TEST_DIR)/logDumps/compare_report.txt

NORM_RTL_LOG = $(TEST_DIR)/logDumps/norm_rtl.log
NORM_SIM_LOG = $(TEST_DIR)/logDumps/norm_sim.log

include $(PROJECT_ROOT)/Make.vars
include $(PROJECT_ROOT)Make.build
#include debugUtils/srcs.mk

GEN_CONF = config/startUpGen.conf.json

TOP_MODULE_NAME = tb_stages

STARTUP_FILES = \
				gen/memLoader.sv \
				gen/dcache_loader.sv \
				gen/icache_loader.sv \
				gen/coreRegLoader.sv \
				gen/tlb_loader.sv

TB_FILES = \
		   $(STARTUP_FILES) \
		   debugUtils/debug_pkg.sv \
		   tb_stages.sv

SRC_FILES :=

ifeq ($(STRUCTRURAL), true)
	SRC_FILES += $(RTL_PKGS) $(RTL_STRUCTURAL_HEADERS) $(RTL_STRUCTURAL_SRC_FILES) $(TB_FILES)	
else
	SRC_FILES += $(RTL_PKGS) $(RTL_SRC_FILES) $(TB_FILES)	
endif

#adding define
CC_FLAGS += \
			$(RTL_RUN_LOG_FILE) \
			$(CLK_PERIOD) \

.PHONY: all run clean see gen

all: $(TARGET)
	
$(TARGET): $(SRC_FILES)
	$(CC) $(CC_FLAGS) -top $(TOP_MODULE_NAME)  -o $@ $(SRC_FILES) 2>&1 | tee compile.log

run: $(TARGET)
	./$< 2>&1| tee sim.log


view: run
	#./$(TARGET) -gui &
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd & 

sim-run:
	$(MAKE) -C $(SIM_DIR) run

compare:
	$(MAKE) -C $(SIM_DIR) compare

gen:
	@echo $(MASTER_SCRIPT_GEN_SCRIPTS_PATH_JSON) | $(JSON_CLEAN_SCRIPT) > cleaned_scripts.json
	@$(PYTHON) $(MASTER_STARTUP_SCRIPT) cleaned_scripts.json $(GEN_CONF)
	@rm -f cleaned_scripts.json

see:
	@echo $(SRC_FILES) | sed 's/ /\n/g' | sed 's#//#/#g'	
	@echo -e "\n"

clean:
	rm -f *.vcd
	rm -f *.vpd
	rm -f $(TARGET)
	rm -rf *.daidir
	rm -rf csrc
	rm -f master
	rm -f *.log
	rm -f ucli.key
	rm -rf gen/
	rm -rf logDumps/
	mkdir logDumps/

push: clean
	git add -A
	git commit -m "auto make push"
	git push

pull: 
	git pull

