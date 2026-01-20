PROJECT = sim
BUILD_DIR = build
TARGET = $(BUILD_DIR)/$(PROJECT)

CC = gcc
C_FLAGS = \
		  -Wextra	\
		  -Wall	\
		  -O0	\
		  -g3	\

LD_FLAGS = \
		   -lm \
		   -lreadline	\

#=====LIBS=====
MPS_LIB_DIR = ./libs/mpsLibC
MPS_LIB_OBJ_STATIC = $(MPS_LIB_DIR)/build/mpsLibC.a

SRC_FILES = \
			src/main.c	\
			src/sim_helpers.c 	\
			src/cpu_design/RISC_FETCH.c	\

INCLUDES = \
		   -I$(MPS_LIB_DIR)/common

OBJS = $(patsubst src/%.c, $(BUILD_DIR)/%.o, $(SRC_FILES))

HDR_FILES = \
			$(wildcard src/*.h) \
			$(wildcard src/cpu_design/*.h) \
			$(wildcard src/mem_design/*.h)

.PHONY: all clean run

all:$(TARGET)

$(MPS_LIB_OBJ_STATIC): $(MPS_LIB_DIR)
	$(MAKE) -C $(MPS_LIB_DIR) all
	

$(TARGET): $(OBJS) $(MPS_LIB_OBJ_STATIC) | $(BUILD_DIR)
	$(CC) -o $@ $(OBJS) $(LIB_OBJ) $(LD_FLAGS)

$(BUILD_DIR)/%.o: src/%.c $(HDR_FILES) | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CC) $(C_FLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

run:
	./$(TARGET)

clean:
	rm -rf ./$(BUILD_DIR)
	rm -rf $(TARGET)
	$(MAKE) -C $(MPS_LIB_DIR) clean

