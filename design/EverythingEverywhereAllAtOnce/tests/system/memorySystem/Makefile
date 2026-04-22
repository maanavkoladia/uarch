include ../../../Make.vars
include ../../../Make.build

TARGET = MemorySystem

MEM_GEN_CONF = memGen.conf.json
TEST_PROG = testProg.s

TB_FILES = \
		   memLoader.sv	\
		   tb_memSystem.sv

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
	python3.9 $(LOAD_MEM_COMPILE_SCRIPT) $(MEM_GEN_CONF)
	python3.9 $(LOAD_MEM_GEN_HEX_MEM_SCRIPT) $(MEM_GEN_CONF)
	python3.9 $(LOAD_MEM_GEN_READ_MEM_FILE) $(MEM_GEN_CONF)

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
	rm -r memGen
vim:
	nvim ../../../

push:
	git add -A
	git commit -m "auto make push"
	git push
