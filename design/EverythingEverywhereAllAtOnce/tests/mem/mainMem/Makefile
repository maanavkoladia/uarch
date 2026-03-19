include ../../../Make.vars
include ../../../Make.build

TARGET = mainMem

MEM_GEN_CONF = memGen/mainMem_memGen.conf.json
TEST_PROG = memGen/testProg.s

TB_FILES = \
		   tb_mainMem.sv

PKGS = $(RTL_PKGS)

SRC_FILES = \
			$(PKGS)	\
			$(RTL_SRC_FILES) \
			$(TB_FILES)	\

.PHONY: all run clean see genMem

all: $(TARGET)
	
$(TARGET): $(SRC_FILES)
	$(CC) $(CC_FLAGS) -o $@ $(SRC_FILES) 2>&1 | tee compile.log

run: $(TARGET)
	./$< 2>&1| tee sim.log

view: run
	#./$(TARGET) -gui &
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) -vpd *.vpd & 

genMem: 
	python3 ../../../scripts/LoadMem/compile.py $(MEM_GEN_CONF)
	python3 ../../../scripts/LoadMem/genHexMem.py $(MEM_GEN_CONF)

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
	rm -rf memGen


