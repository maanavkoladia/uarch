include ../../../Make.vars
include ../../../Make.build

TARGET = DTE_Test

GEN_CONF = startUpGen.conf.json

TOP_FILE_NAME = tb_DTE

TB_FILES = \
		   tb_DTE.sv \

PKGS = $(RTL_PKGS)

SRC_FILES = \
			$(PKGS)	\
			$(RTL_SRC_FILES) \
			$(TB_FILES)	\

.PHONY: all run clean see genMem

all: $(TARGET)
	
$(TARGET): $(SRC_FILES)
	$(CC) $(CC_FLAGS) -top $(TOP_FILE_NAME)  -o $@ $(SRC_FILES) 2>&1 | tee compile.log

run: $(TARGET)
	./$< 2>&1| tee sim.log

view: run
	#./$(TARGET) -gui &
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd & 

gen:
	@echo $(MASTER_SCRIPT_GEN_SCRIPTS_PATH_JSON) | $(JSON_CLEAN_SCRIPT) > cleaned_scripts.json
	@python3.9 $(MASTER_STARTUP_SCRIPT) cleaned_scripts.json $(GEN_CONF)
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

	#rm -rf gen/

vim:
	nvim ../../../

push:
	git add -A
	git commit -m "auto make push"
	git push

