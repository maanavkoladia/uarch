`ifndef TB_UTILS_DEFS_H
`define TB_UTILS_DEFS_H

//include all the different latches

import tb_debug_pkg::*;

// ===================== PRINT TASKS =====================
// --- HEADER ---
`define PRINT_CYCLE_HEADER \
    task automatic print_cycle_header(); \
        $fdisplay(`LOG_FD, ""); \
        $fdisplay(`LOG_FD, "==================== CYCLE %0d  (t=%0t) ====================", `CYCLE_COUNT, $time); \
    endtask

`define FETCH_UNIT_PATH ()
`define DECODE_UNIT_PATH ()
`define RR_UNIT_PATH ()
`define DC_UNIT_PATH ()
`define MEM_UNIT_PATH ()
`define EXE_UNIT_PATH ()
`define WB_UNIT_PATH (wb_stage)

`define DCACHE_UNIT_PATH ()


//`include "debugUtilsFetch.svh"
//`include "debugUtilsDecode.svh"
//`include "debugUtilsRR.svh"
//`include "debugUtilsDC.svh"
//`include "debugUtilsMEM.svh"
//`include "debugUtilsEXE.svh"
//`include "debugUtils_Dcache.svh"
`include "debugUtils_WB.svh"

//include all the sub headers

`endif
