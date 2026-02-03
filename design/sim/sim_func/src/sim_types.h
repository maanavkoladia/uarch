#pragma once
#include "sim_common.h"
#include <stdbool.h>
#include <stdint.h>

#define x86_32_NUM_REGS (8)

typedef uint32_t cs_t;
typedef uint32_t mem_addr_t;
typedef bool valid_bit_t;

typedef enum {
    SIM_RUNNING,
    SIM_HALTED,
    SIM_DEAD,
} sim_state_t;

typedef union {
    uint32_t regs[x86_32_NUM_REGS];
} reg_file_t;

// exceptions psossible
// gen exception and page fault

typedef struct {
} PreDecode_cs_t;

typedef struct {
    PreDecode_cs_t cs_s;

    uint32_t valid_bit;
} PreDecodeLatches_t;

typedef struct {
    // need CS signals from DECODE, this should be the first set of latches that use them
    uint32_t imm32;
    uint32_t dr_id;
    uint32_t dr_data;
    uint32_t sr_id;
    uint32_t sr_data;
    uint32_t mem_addr; // comes from SIB address gen logic
    uint32_t valid_bit;
} LD_MEM_latches_t;

typedef struct {
    cs_t imm_size_mask; // maybe a mask, or a bit field indicating how many bits in the imm are
                        // valid, this would inherently fix the invalid problem if done properly
    cs_t ld_mem_needed;
} MEM_CS_t;

typedef struct {
    cs_t imm_size_mask; // maybe a mask, or a bit field indicating how many bits in the imm are
                        // valid, this would inherently fix the invalid problem if done properly
    cs_t ld_mem_needed;
} Decode_CS_t;

typedef struct {

} sim_latches_t;

typedef struct {
    mem_addr_t tlb_addr;
    valid_bit_t valid_req_addr;
} tlb_2_icache_p;

typedef struct {
    uint8_t cache_line[ICACHE_LINE_SIZE];
    valid_bit_t valid_line;
} icache_2_qctrl_p;

typedef struct {
    mem_addr_t mem_addr;
    valid_bit_t mem_req;
} icache_2_mem_p;

typedef struct {
    uint8_t dramData[DRAM_BUS_WIDTH];
    valid_bit_t mem_valid;
} mem_2_icache_p;
