# Makefile for ICache Test

CC = gcc
CFLAGS = -Wall -Wextra -g -I../../../ -I../../ -I../
LDFLAGS = 

# Source files
TEST_SRC = test_icache.c
ICACHE_SRC = ../icache.c

# Object files
OBJS = test_icache.o icache.o

# Target executable
TARGET = test_icache

# Default target
all: $(TARGET)

# Link
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS)
	@echo "Build complete: $(TARGET)"

# Compile test
test_icache.o: $(TEST_SRC)
	$(CC) $(CFLAGS) -c $(TEST_SRC)

# Compile icache
icache.o: $(ICACHE_SRC)
	$(CC) $(CFLAGS) -c $(ICACHE_SRC)

# Run the test
run: $(TARGET)
	@echo "Running ICache tests..."
	./$(TARGET)

# Clean build artifacts
clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).exe
	@echo "Clean complete"

# Help
help:
	@echo "Available targets:"
	@echo "  all   - Build the test executable (default)"
	@echo "  run   - Build and run the tests"
	@echo "  clean - Remove build artifacts"
	@echo "  help  - Show this help message"

.PHONY: all run clean help
