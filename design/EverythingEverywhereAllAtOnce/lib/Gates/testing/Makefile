TARGET=test_ram

CC = iverilog

COMMON_LIB_FILES = \
			   ../../Common/LOG.v	\
			   ../../Common/utils.v	\

SRC_FILES = \
    ../lib1 \
    ../lib2 \
    ../lib3 \
    ../lib4 \
    ../lib6

TEST_FILE = \
			tb_ram.sv

RTL_FILES = $(COMMON_LIB_FILES) $(TEST_FILE) $(SRC_FILES)

CC_FLAGS = -g2012 -Wall -Wno-implicit -Ttyp -gspecify
OUTPUT = test

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(RTL_FILES)
	$(CC) $(CC_FLAGS) -o $@ $(RTL_FILES)

run: all $(TARGET)
	vvp $(TARGET)

view: run
	gtkwave test.vcd &

clean:
	rm -f *.vcd
	rm -f $(TARGET)
