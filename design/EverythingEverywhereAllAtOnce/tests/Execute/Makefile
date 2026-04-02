include ../../Make.vars
include ../../Make.build

# Include only EXE source files
ROOT = ../..
CORE_PATH_INTERNAL = $(ROOT)/rtl/core
include $(CORE_PATH_INTERNAL)/EXE/srcs.mk

TARGET = test_EXE


TB_FILES = \
           tb_exe.sv

# Only include packages needed by EXE
PKGS = \
       $(ROOT)/rtl/pkgs/common_pkg.sv \
	   $(ROOT)/rtl/pkgs/interconnect_pkg.sv \
       $(ROOT)/rtl/pkgs/types_pkg.sv \
       $(CORE_PATH_INTERNAL)/pkgs/control_store_pkg.sv \
       $(CORE_PATH_INTERNAL)/pkgs/reg_ids_pkg.sv \
       $(CORE_PATH_INTERNAL)/pkgs/core_common_pkg.sv \
       $(CORE_PATH_INTERNAL)/pkgs/core_stage_latches_pkg.sv \

SRC_FILES = \
            $(PKGS) \
            $(EXE_SRC_FILES) \
            $(TB_FILES) \

.PHONY: all run clean see

all: $(TARGET)

$(TARGET): $(SRC_FILES)
	$(CC) $(CC_FLAGS) -o $@ $(SRC_FILES)

run: $(TARGET)
	./$<

view: run
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd

see:
	@echo $(SRC_FILES) | sed 's/ /\n/g'

clean:
	rm -f *.vcd
	rm -f *.vpd
	rm -f $(TARGET)
	rm -rf *.daidir/
	rm -rf csrc
	rm -f ucli.key
