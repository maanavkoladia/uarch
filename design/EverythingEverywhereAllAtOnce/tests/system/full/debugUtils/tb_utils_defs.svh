`ifndef TB_UTILS_DEFS_H
`define TB_UTILS_DEFS_H

import tb_debug_pkg::*;

// ===================== LOG FILE =====================

// file name (string constant)
`define LOG_FILE_NAME "run.log.default"

// file descriptor macro (IMPORTANT FIX)
`define LOG_FD logfd

// ===================== DUT PATHS =====================
`define FETCH_UNIT_PATH (temp)
`define DECODE_UNIT_PATH (temp)
`define RR_UNIT_PATH (temp)
`define DC_UNIT_PATH (temp)
`define MEM_UNIT_PATH (temp)
`define EXE_UNIT_PATH uut_AllAtOnce.core_unit.execute_unit
`define WB_UNIT_PATH (temp)
`define WB_UNIT_PATH (temp)
`define DCACHE_UNIT_PATH (temp)


// ===================== INIT BLOCK =====================
// MUST BE INSIDE A MODULE THAT INCLUDES THIS HEADER


// ===================== CYCLE HEADER =====================

`define COMMON_UTILS_INIT \
    logic clk = 0;\
    task automatic DelayClks(input int cycles);\
        #(`CLK_PERIOD  * cycles);\
    endtask\
    always begin\
        #(`CLK_PERIOD/2);\
        clk = ~clk;\
    end\


`define PRINT_CYCLE_HEADER \
    task automatic print_cycle_header(); \
        $fdisplay(logfd, ""); \
        $fdisplay(logfd, "==================== CYCLE %0d (t=%0t) ====================", cycle_count, $time); \
    endtask \

`define WAVEFORM_GEN_INIT \
    initial begin\
        $vcdpluson;\
        $vcdplusmemon;\
    end

`define DEBUG_UTILS_INIT \
    integer `LOG_FD; \
    int cycle_count = 0; \
    `COMMON_UTILS_INIT \
    `PRINT_CYCLE_HEADER \
    `WAVEFORM_GEN_INIT \
    initial begin \
        logfd = $fopen(`LOG_FILE_NAME, "w"); \
        if (logfd == 0) begin \
            $display("ERROR: cannot open log file"); \
            $finish; \
        end \
    end \
    always @(posedge clk) cycle_count++; \



// ===================== SUB-HEADERS =====================
//
//`include "debugUtils/debugUtilsFetch.svh"
//`include "debugUtils/debugUtilsDecode.svh"
//`include "debugUtils/debugUtilsRR.svh"
//`include "debugUtils/debugUtilsDC.svh"
//`include "debugUtils/debugUtilsMEM.svh"
`include "debugUtils/debugUtilsEXE.svh"
//`include "debugUtils/debugUtils_Dcache.svh"
//`include "debugUtils/debugUtils_WB.svh"
//`include "debugUtils/debugUtilsWBLatches.svh"

`endif
