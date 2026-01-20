#pragma once
#include <stdint.h>
#include "sim_common.h"


typedef enum {
    SIM_RUNNING,
    SIM_HALTED,
    SIM_DEAD,
}sim_state_t;

typedef union {
    uint32_t regs[x86_32_NUM_REGS];
}reg_file_t;

typedef struct {

}sim_latches_t;


