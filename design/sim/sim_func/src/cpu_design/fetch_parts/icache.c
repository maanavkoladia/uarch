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
    int offset = cpu_to_icache->SPC & 0xF;
    int index = (cpu_to_icache->SPC >> 4) & 0x1F;
    int tag = cpu_to_icache->SPC >> 9;
    
    if (cpu_to_icache->valid_req) {
        if (i_cache[index].valid && i_cache[index].tag == tag) {
            // Cache hit
            for (int i = 0; i < ICACHE_LINE_SIZE; i++) {
                icache_to_cpu->line[i] = i_cache[index].line[i];
            }
            icache_to_cpu->valid_line = true;
        } else {
            // Cache miss
            icache_to_mem->mem_addr = cpu_to_icache->SPC;
            icache_to_mem->mem_req = true;
            icache_to_cpu->valid_line = false;
            filling_flag = true;
            fill_index = index;
            beat_count = 0;
        }
    } else {
        icache_to_cpu->valid_line = false;
    }

    // Mem to Icache interface (updating cache line)
    if (mem_to_icache->valid && filling_flag) {
        i_cache[fill_index].line[3 - beat_count] = (mem_to_icache->data >> (beat_count * 8)) & 0xFF;
        if (beat_count == 3) {
            i_cache[fill_index].valid = true;
            i_cache[fill_index].tag = cpu_to_icache->SPC >> 9;
            filling_flag = false;
        } else {
            beat_count++;
        }
    }
}
