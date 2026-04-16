STRUCTRURAL := true

include ../../../Make.vars
include ../../../Make.build
include debugUtils/srcs.mk


TARGET = FasterTransfers_Test

GEN_CONF = startUpGen.conf.json

TOP_MODULE_NAME = tb_execute

STARTUP_FILES = \
				gen/memLoader.sv \
				gen/dcache_loader.sv \
				gen/icache_loader.sv


		   #$(DEBUG_UTILS) \

TB_FILES = \
		   $(STARTUP_FILES) \
		   debugUtils/debug_pkg.sv \
		   tb_execute.sv

SRC_FILES :=

ifeq ($(STRUCTRURAL), true)
	SRC_FILES += $(RTL_PKGS) $(RTL_STRUCTURAL_HEADERS) $(RTL_STRUCTURAL_SRC_FILES) $(TB_FILES)	
else
	SRC_FILES += $(RTL_PKGS) $(RTL_SRC_FILES) $(TB_FILES)	
endif


.PHONY: all run clean see gen

all: $(TARGET)
	
$(TARGET): $(SRC_FILES)
	$(CC) $(CC_FLAGS) -top $(TOP_MODULE_NAME)  -o $@ $(SRC_FILES) 2>&1 | tee compile.log

run: $(TARGET)
	./$< 2>&1| tee sim.log

view: run
	#./$(TARGET) -gui &
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd & 

gen:
	@echo $(MASTER_SCRIPT_GEN_SCRIPTS_PATH_JSON) | $(JSON_CLEAN_SCRIPT) > cleaned_scripts.json
	@python3.11 $(MASTER_STARTUP_SCRIPT) cleaned_scripts.json $(GEN_CONF)
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

vim:
	nvim ../../../

push:
	git add -A
	git commit -m "auto make push"
	git push

