builddir=build

buildmode = $(DEBUG)

CFLAGS = \
    -g3 \
    -Wall \
    -Wextra \
    -std=c99 \

ifeq ($(buildmode), DEBUG)
	CFLAGS+=-DDEBUG
endif

SRC_FILE = lc3bsim6_km.c
CC = gcc
TARGET = $(builddir)/exe

all: $(TARGET).elf

$(TARGET).elf: $(SRC_FILE)
	$(CC) $(CFLAGS) -o $@ $^

clean: 
	rm -r $(builddir)/*
