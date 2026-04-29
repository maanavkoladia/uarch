export SIM_DIR PYTHON SIM_PYTHON TEST_CASE_DIR PROGRAM_BIN \
       LOG RTL_LOG NORM_RTL_LOG NORM_SIM_LOG REPORT_FILE OUT_JSON TRACE_FILE \
       SIM_REGDUMP_FILE SIM_FLAGDUMP_FILE RTL_REGDUMP_FILE RTL_FLAGDUMP_FILE DUMP_REPORT_FILE

TEST_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PROJECT_ROOT := $(shell pwd | sed -E 's|(.*EverythingEverywhereAllAtOnce).*|\1|')

LOG_DIR = $(TEST_DIR)/logDumps/

DISTRO := $(shell . /etc/os-release && echo $$ID)

TARGET = system_testing

STRUCTRURAL := false

RTL_RUN_LOG_FILE := $(LOG_DIR)/run.log
CLK_PERIOD := 8

# DCache dump cycle range (default -1 = disabled).
# Set at make time:   make DCACHE_DUMP_START=50 DCACHE_DUMP_END=100
# Or at run time:     make run SIMFLAGS="+DCACHE_DUMP_START=50 +DCACHE_DUMP_END=100"
DCACHE_DUMP_START ?= -1
DCACHE_DUMP_END   ?= -1
SIMFLAGS          ?=

SIM_DIR = $(PROJECT_ROOT)/scripts/sim/

TEST_CASE_PATH = $(TEST_DIR)/config/RepTesting/


#sim rtl vars (segmented sim consumes test-dir + program.bin)
TEST_CASE_DIR = $(TEST_CASE_PATH)
PROGRAM_BIN   = $(TEST_DIR)/gen/memGen/meta/program.bin

# Use the venv python (it has capstone installed) if it exists.
SIM_PYTHON = $(TEST_DIR)/venv/bin/python3

OUT_JSON    = $(LOG_DIR)/sim_output.json
LOG = $(LOG_DIR)/sim_run.log
TRACE_FILE  = $(LOG_DIR)/sim_trace.log
RTL_LOG    = $(RTL_RUN_LOG_FILE)
REPORT_FILE = $(LOG_DIR)/dont_read_this.txt

NORM_RTL_LOG = $(LOG_DIR)/norm_rtl.log
NORM_SIM_LOG = $(LOG_DIR)/norm_sim.log

SIM_REGDUMP_FILE  = $(LOG_DIR)/sim_regdump.log
SIM_FLAGDUMP_FILE = $(LOG_DIR)/sim_flagdump.log
RTL_REGDUMP_FILE  = $(LOG_DIR)/regdump.log
RTL_FLAGDUMP_FILE = $(LOG_DIR)/flagdump.log
DUMP_REPORT_FILE  = $(LOG_DIR)/compare_report.txt

include $(PROJECT_ROOT)/Make.vars
include $(PROJECT_ROOT)/Make.build
#include debugUtils/srcs.mk

GEN_CONF = $(TEST_CASE_PATH)/startUpGen.conf.json

TOP_MODULE_NAME = tb_stages

STARTUP_FILES = \
				gen/diskLoader.v \
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
    +define+LOG_FILE_NAME=\"$(RTL_RUN_LOG_FILE)\" \
    +define+CLK_PERIOD=$(CLK_PERIOD) \
    +define+DCACHE_LOG_FILE_NAME=\"$(LOG_DIR)/dcache_dump.log\" \
    +define+DCACHE_DUMP_START_DEFAULT=$(DCACHE_DUMP_START) \
    +define+DCACHE_DUMP_END_DEFAULT=$(DCACHE_DUMP_END) \
	+define+RTL_REGDUMP_FILE_NAME=\"$(RTL_REGDUMP_FILE)\" \
	+define+RTL_FLAGDUMP_FILE_NAME=\"$(RTL_FLAGDUMP_FILE)\" \
	

.PHONY: all run clean see gen full

all: $(TARGET) 
	
$(TARGET):  makeLogDir $(SRC_FILES) 
	$(CC) $(CC_FLAGS) -top $(TOP_MODULE_NAME)  -o $@ $(SRC_FILES) 2>&1 | tee $(LOG_DIR)/compile.log

run: all
	./$(TARGET) $(SIMFLAGS) 2>&1| tee sim.log


view: run
	#./$(TARGET) -gui &
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd & 

sim-run: makeLogDir
	$(MAKE) -C $(SIM_DIR) run

compare: makeLogDir
	$(MAKE) -C $(SIM_DIR) compare 2>&1 | tee $(LOG_DIR)/make_compare.log

gen:
	@echo $(MASTER_SCRIPT_GEN_SCRIPTS_PATH_JSON) | $(JSON_CLEAN_SCRIPT) > cleaned_scripts.json
	@$(PYTHON) $(MASTER_STARTUP_SCRIPT) cleaned_scripts.json $(GEN_CONF)
	@rm -f cleaned_scripts.json

see:
	@echo $(SRC_FILES) | sed 's/ /\n/g' | sed 's#//#/#g'	
	@echo -e "\n"

	@echo  $(CC_FLAGS)

makeLogDir:
	@mkdir -p $(LOG_DIR)

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

push: clean
	git add -A
	git commit -m "auto make push"
	git push

pull: 
	git pull

full: clean gen all run compare
