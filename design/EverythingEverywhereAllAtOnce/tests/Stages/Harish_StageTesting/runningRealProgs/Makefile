.PHONY: clean debug

TARGET=prog

SRC_FILE = prog.s

FLAGS = \
		-m32 \
		-g \
		-nostdlib \


$(TARGET): $(SRC_FILE)
	gcc  $< -o $@ $(FLAGS)

debug: $(TARGET)
	gdb -x gdb.init.local ./$<

clean: 
	rm -f $(TARGET)
