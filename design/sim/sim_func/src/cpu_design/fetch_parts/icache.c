#include "../../sim_types.h"
#include "Assert_Common.h"
#include "ForLoop.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

////////////////////TYPES//////////////////////////

#define ICACHE_OFFSET(addr) ((addr) & 0xF)
#define ICACHE_INDEX(addr) (((addr) >> 4) & 0x1F)
#define ICACHE_TAG(addr) ((addr) >> 9)

typedef struct {
    bool valid;
    uint16_t tag;
    uint8_t line[ICACHE_LINE_SIZE];
} CacheLine_t;

typedef enum {
    BYTE_0 = 0,
    BYTE_1 = 1,
    BYTE_2 = 2,
    BYTE_3 = 3, // load in the ms byte into the desired cacheline
    IDLE,
} ld_line_fsm_state_e;

////////////////////REGS//////////////////////////

static CacheLine_t i_cache[ICACHE_LINES];

static CacheLine_t i_cache_next[ICACHE_LINES];

static ld_line_fsm_state_e cacheLineLoadState, cacheLineLoadState_next;

////////////////////SIGNALS//////////////////////////
/* Reset wire */
static bool* reset;

////////////////////DESIGN//////////////////////////

/* Port handles */
static tlb_2_icache_p* tlb_to_icache;
static icache_2_qctrl_p* icache_to_qctrl;
static icache_2_mem_p* icache_to_mem;
static mem_2_icache_p* mem_to_icache;

void comb_logic(void) {
    // TLB to Icache interface
    int tag = ICACHE_TAG(tlb_to_icache->tlb_addr);
    int index = ICACHE_INDEX(tlb_to_icache->tlb_addr);

    if (tlb_to_icache->valid_req_addr) {
        if (i_cache[index].valid && i_cache[index].tag == tag) {
            // Cache hit
            for (int i = 0; i < ICACHE_LINE_SIZE; i++) {
                icache_to_qctrl->cache_line[i] = i_cache[index].line[i];
            }
            icache_to_qctrl->valid_line = true;
        } else {
            // Cache miss, assumming nonblocking
            icache_to_mem->mem_addr = tlb_to_icache->tlb_addr;
            icache_to_mem->mem_req = true;
            icache_to_qctrl->valid_line = false;
        }
    } else {
        icache_to_qctrl->valid_line = false;
    }
}

void seq_logic(void) {
    if (mem_to_icache->mem_valid && tlb_to_icache->valid_req_addr) {
        uint32_t index = ICACHE_INDEX(tlb_to_icache->tlb_addr);
        switch (cacheLineLoadState) {
        case BYTE_0:
            FOR_LOOP_COMMON(i, DRAM_BUS_WIDTH) {
                uint32_t offset = BYTE_0 * DRAM_BUS_WIDTH;
                i_cache_next[index].line[i + offset] = mem_to_icache->dramData[offset];
                i_cache_next[index].valid = false;
            }
            break;
        case BYTE_1:
            FOR_LOOP_COMMON(i, DRAM_BUS_WIDTH) {
                uint32_t offset = BYTE_1 * DRAM_BUS_WIDTH;
                i_cache_next[index].line[i + offset] = mem_to_icache->dramData[offset];
            }
            break;
        case BYTE_2:
            FOR_LOOP_COMMON(i, DRAM_BUS_WIDTH) {
                uint32_t offset = BYTE_2 * DRAM_BUS_WIDTH;
                i_cache_next[index].line[i + offset] = mem_to_icache->dramData[offset];
            }
            break;
        case BYTE_3:
            FOR_LOOP_COMMON(i, DRAM_BUS_WIDTH) {
                uint32_t offset = BYTE_3 * DRAM_BUS_WIDTH;
                i_cache_next[index].line[i + offset] = mem_to_icache->dramData[offset];
                i_cache_next[index].tag = ICACHE_TAG(tlb_to_icache->tlb_addr);
                i_cache_next[index].valid = true;
            }
            break;
        case IDLE:
            break;
        }
    } else {
    }

    switch (cacheLineLoadState) {
    case BYTE_0:
        cacheLineLoadState_next = (mem_to_icache->mem_valid) ? BYTE_1 : BYTE_0;
        break;
    case BYTE_1:
        cacheLineLoadState_next = (mem_to_icache->mem_valid) ? BYTE_2 : BYTE_1;
        break;
    case BYTE_2:
        cacheLineLoadState_next = (mem_to_icache->mem_valid) ? BYTE_3 : BYTE_2;
        break;
    case BYTE_3:
        cacheLineLoadState_next = (mem_to_icache->mem_valid) ? IDLE : BYTE_3;
        break;
    case IDLE:
        cacheLineLoadState_next =
            !(i_cache[index].valid && i_cache[index].tag == tag) ? BYTE_0 : IDLE;
        break;
    }
}

void icache_Init(bool* resetWire, tlb_2_icache_p* tlb2icache, icache_2_qctrl_p* icache2qctrl,
                 icache_2_mem_p* icache2mem, mem_2_icache_p* mem2icache) {
    ASSERT_COMMON_NOT_NULL(resetWire && tlb2icache && icache2qctrl && icache2mem && mem2icache);

    /* Wire up reset */
    reset = resetWire;

    /* Wire up ports */
    tlb_to_icache = tlb2icache;
    icache_to_qctrl = icache2qctrl;
    icache_to_mem = icache2mem;
    mem_to_icache = mem2icache;
}

void icache_cycle() {

    if (reset) {
        FOR_LOOP_COMMON(i, ICACHE_LINES) {
            i_cache[i].valid = false;
        }
        icache_to_qctrl->valid_line = false;
        icache_to_mem->mem_req = false;
        cacheLineLoadState = IDLE;
    } else {
        comb_logic();
        seq_logic();
    }

    // DRAM
}
