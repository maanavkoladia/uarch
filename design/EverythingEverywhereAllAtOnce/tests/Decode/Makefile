include ../../Make.vars
include ../../Make.build

TARGET = test_Decode


TB_FILES = \
		   tb_Dec.sv

PKGS = $(RTL_PKGS)

SRC_FILES = \
			$(PKGS)	\
			$(RTL_SRC_FILES)	\
			$(TB_FILES)	\

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
