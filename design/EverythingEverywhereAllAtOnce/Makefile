TARGET=test_ram

CC = iverilog
SIM = vvp

COMMON_LIB_FILES = \
				   ./lib/Common/LOG.v	\
				   ./lib/Common/utils.v  \

UARCH_STD_CELL_LIB = \
					 ./lib/Gates/lib1 \
					 ./lib/Gates/lib2 \
					 ./lib/Gates/lib3 \
					 ./lib/Gates/lib4 \
					 ./lib/Gates/lib6 \

#					 ./lib/Gates/lib5

STRUCTURAL_GATES_LIB = \
					   ./lib/RegisterWrapper/reg1b.sv	\



SRC_FILES = \

TEST_FILE = \

RTL_FILES = $(COMMON_LIB_FILES) $(UARCH_STD_CELL_LIB) $(STRUCTURAL_GATES_LIB) $(SRC_FILES) $(TEST_FILE)

CC_FLAGS = -g2012 -Wall -Wno-implicit -Ttyp -gspecify
OUTPUT = test

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(RTL_FILES)
	$(CC) $(CC_FLAGS) -o $@ $(RTL_FILES)

gen:
	echo "Recreating all Gen Files, all sv are being overwritten"
	python ./scripts/generateStructural.py ./config/gen.conf.json

run: all $(TARGET)
	$(SIM) $(TARGET)

view: run
	gtkwave test.vcd &

clean:
	rm -f *.vcd
	rm -rf *.pla *espresso.out
	rm -f $(TARGET)

