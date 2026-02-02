#include "../../sim_types.h"
#include "Assert_Common.h"
#include "Fetch.h"
#include "ForLoop.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    bool valid;
    uint16_t tag;
    bool fillingFlag;
    uint8_t line[ICACHE_LINE_SIZE];
} CacheLine_t;

static CacheLine_t i_cache[ICACHE_LINES];

/* Reset wire */
static bool* reset;

/* Port handles */
static cpu_2_icache_p* cpu_to_icache;
static icache_2_cpu_p* icache_to_cpu;
static icache_2_mem_p* icache_to_mem;
static mem_2_icache_p* mem_to_icache;

void icache_Init(bool* resetWire, cpu_2_icache_p* cpu2icache, icache_2_cpu_p* icache2cpu,
                 icache_2_mem_p* icache2mem, mem_2_icache_p* mem2icache) {
    ASSERT_COMMON_NOT_NULL(resetWire && cpu2icache && icache2cpu && icache2mem && mem2icache);

    /* Wire up reset */
    reset = resetWire;

    /* Wire up ports */
    cpu_to_icache = cpu2icache;
    icache_to_cpu = icache2cpu;
    icache_to_mem = icache2mem;
    mem_to_icache = mem2icache;
}

void icache_cycle() {

    if (reset) {
        FOR_LOOP_COMMON(i, ICACHE_LINES) {
            i_cache[i].valid = false;
        }
        icache_to_cpu->valid_line = false;
        icache_to_mem->mem_req = false;

        return;
    }

    // CPU to Icache interface
    int offset = SPC & 0xF;
    int index = (SPC >> 4) & 0x1F;
    int tag = SPC >> 9;
    if (valid_req) {
        if (valid[index] && tags[index] == tag) {
            // Cache hit
            for (int i = 0; i < ICACHE_LINE_SIZE; i++) {
                (*cache_line)[i] = cache[index][i];
            }
            *valid_line = true;
        } else {
            // Cache miss
            *mem_addr = SPC;
            *mem_req = true;
            *valid_line = false;
            filling_flag = true;
            fill_index = index;
            beat_count = 0;
        }
    } else {
        *valid_line = false;
    }

    // Mem to Icache interface (updating cache line)
    if (mem_valid && filling_flag) {
        cache[fill_index][3 - beat_count] = (mem_data >> (beat_count * 8)) & 0xFF;
        if (beat_count == 3) {
            valid[fill_index] = true;
            tags[fill_index] = SPC >> 9;
            filling_flag = false;
        } else {
            beat_count++;
        }
    }
}
