#include "../../sim_types.h"
#include "Assert_Common.h"
#include "ForLoop.h"
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

//////////////////// CONFIG //////////////////////

#define ICACHE_OFFSET(addr) ((addr) & 0xF)
#define ICACHE_INDEX(addr) (((addr) >> 4) & 0x1F)
#define ICACHE_TAG(addr) ((addr) >> 9)

//////////////////// TYPES ///////////////////////

typedef struct {
    bool valid;
    uint16_t tag;
    uint8_t line[ICACHE_LINE_SIZE];
} CacheLine_t;

typedef enum {
    IC_FILL_0 = 0,
    IC_FILL_1 = 1,
    IC_FILL_2 = 1,
    IC_FILL_3 = 1,
    IC_IDLE = 2,
} icache_fsm_e;

//////////////////// STATE ///////////////////////

static CacheLine_t i_cache[ICACHE_LINES];
static CacheLine_t i_cache_next[ICACHE_LINES];

static icache_fsm_e fsm_state;
static icache_fsm_e fsm_state_next;

static bool miss_pending;
static bool miss_pending_next;

static uint32_t miss_addr;
static uint32_t miss_addr_next;

//////////////////// PORTS ///////////////////////

static bool* reset;

static tlb_2_icache_p* tlb_to_icache;
static icache_2_qctrl_p* icache_to_qctrl;
static icache_2_mem_p* icache_to_mem;
static mem_2_icache_p* mem_to_icache;

//////////////////// HELPERS /////////////////////

void comb_logic_next_state(void) {
    int tag = ICACHE_TAG(tlb_to_icache->tlb_addr);
    int index = ICACHE_INDEX(tlb_to_icache->tlb_addr);
    switch (fsm_state) {
    case IC_FILL_0:
        fsm_state_next = (mem_to_icache->mem_valid) ? IC_FILL_1 : IC_FILL_0;
        break;
    case IC_FILL_1:
        fsm_state_next = (mem_to_icache->mem_valid) ? IC_IDLE : IC_FILL_1;
        break;
    case IC_IDLE:
        fsm_state_next = !(i_cache[index].valid && i_cache[index].tag == tag) ? IC_FILL_0 : IC_IDLE;
        break;
    }
}

void comb_logic_output_signals(void) {
    int tag = ICACHE_TAG(tlb_to_icache->tlb_addr);
    int index = ICACHE_INDEX(tlb_to_icache->tlb_addr);
    switch (fsm_state) {
    case IC_FILL_0:
        icache_to_mem->mem_addr = tlb_to_icache->tlb_addr;
        icache_to_mem->mem_req = 1;
        icache_to_qctrl->valid_line = 0;
        break;
    case IC_FILL_1:
        icache_to_mem->mem_addr = tlb_to_icache->tlb_addr;
        icache_to_mem->mem_req = 0;
        if (mem_to_icache->mem_valid) {
            icache_to_qctrl->valid_line = 1;
            FOR_LOOP_COMMON(i, ICACHE_LINE_SIZE) {
                icache_to_qctrl->cache_line[i] = i_cache[index].line[i];
            }
        } else {
            icache_to_qctrl->valid_line = 0;
        }
        break;
    case IC_IDLE:
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
        break;
    }
}

void comb_logic(void) {
    // TLB to Icache interface
    comb_logic_next_state();
    comb_logic_output_signals();
}

void seq_logic(void) {
    uint32_t index = ICACHE_INDEX(tlb_to_icache->tlb_addr);
    switch (fsm_state) {
    case IC_FILL_0:
        FOR_LOOP_COMMON(i, DRAM_BUS_WIDTH) {
            uint32_t offset = IC_FILL_0 * DRAM_BUS_WIDTH;
            i_cache_next[index].line[i + offset] = mem_to_icache->dramData[offset];
            i_cache_next[index].valid = false;
        }
        break;
    case IC_FILL_1:
        FOR_LOOP_COMMON(i, DRAM_BUS_WIDTH) {
            uint32_t offset = IC_FILL_1 * DRAM_BUS_WIDTH;
            i_cache_next[index].line[i + offset] = mem_to_icache->dramData[offset];
            i_cache_next[index].valid = false;
        }
        break;
    case IC_IDLE:
        break;
    }
}

//////////////////// COMMIT //////////////////////

static void icache_commit(void) {
    // copy the actual "SRAM" cells
    memcpy(i_cache, i_cache_next, sizeof(i_cache));

    miss_pending = miss_pending_next;
    miss_addr = miss_addr_next;
    fsm_state = fsm_state_next;
}
//////////////////// INIT ////////////////////////

void icache_Init(bool* resetWire, tlb_2_icache_p* tlb2icache, icache_2_qctrl_p* icache2qctrl,
                 icache_2_mem_p* icache2mem, mem_2_icache_p* mem2icache) {
    ASSERT_COMMON_NOT_NULL(resetWire && tlb2icache && icache2qctrl && icache2mem && mem2icache);

    reset = resetWire;
    tlb_to_icache = tlb2icache;
    icache_to_qctrl = icache2qctrl;
    icache_to_mem = icache2mem;
    mem_to_icache = mem2icache;
}

//////////////////// CYCLE ///////////////////////

void Reset_Logic() {
    FOR_LOOP_COMMON(i, ICACHE_LINES) {
        i_cache[i].valid = false;
    }
    // regs
    fsm_state_next = IC_IDLE;
    miss_pending_next = false;
    miss_addr_next = 0;

    // icache_to_qctrl->inst_valid = false;
    // icache_to_mem->mem_req = false;
    return;
}

void icache_cycle() {

    if (reset) {
        Reset_Logic();
    } else {
        comb_logic();
        seq_logic();
        icache_commit();
    }
    // DRAM
}
