include ../../../Make.vars
include ../../../Make.build

TARGET = loadMem


TB_FILES = \
		   tb_load.sv

PKGS = $(RTL_PKGS)

SRC_FILES = \
			$(PKGS)	\
			$(RTL_SRC_FILES) \
			$(TB_FILES)	\

.PHONY: all run clean see

all: $(TARGET)
	
$(TARGET): $(SRC_FILES)
	#@echo "$(TIME_FILE)" > master
	#@echo $(SRC_FILES) | sed 's/ /\n/g' | sed 's#//#/#g' > master
	#@cat master
	$(CC) $(CC_FLAGS) -o $@ $(SRC_FILES)

run: $(TARGET)
	./$<

view: run
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd

see:
	#@echo $(TIME_FILE)
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


