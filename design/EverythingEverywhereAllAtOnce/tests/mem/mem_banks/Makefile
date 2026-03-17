include ../../../Make.vars
include ../../../Make.build

TARGET = mem_banks


TB_FILES = \
		   tb_memBanks.sv

PKGS = $(RTL_PKGS)

SRC_FILES = \
			$(PKGS)	\
			$(RTL_SRC_FILES) \
			$(TB_FILES)	\

.PHONY: all run clean see

all: $(TARGET)
	
$(TARGET): $(SRC_FILES)
	$(CC) $(CC_FLAGS) -o $@ $(SRC_FILES)

run: $(TARGET)
	./$<

view: run
	#./$(TARGET) -gui &
	$(SIM_TOOL) $(SIM_TOOL_FLAGS) *.vpd &

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


