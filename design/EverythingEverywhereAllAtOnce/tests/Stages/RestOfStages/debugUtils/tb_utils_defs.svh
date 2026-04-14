`ifndef TB_UTILS_DEFS_H
`define TB_UTILS_DEFS_H

import tb_debug_pkg::*;

// ===================== LOG FILE =====================

// file name (string constant)
`define LOG_FILE_NAME "run.log"

// file descriptor macro (IMPORTANT FIX)
`define LOG_FD logfd


// ===================== DUT PATHS =====================
`define FETCH_UNIT_PATH (temp)
`define DECODE_UNIT_PATH (temp)
`define RR_UNIT_PATH (temp)
`define DC_UNIT_PATH (temp)
`define MEM_UNIT_PATH (temp)
`define EXE_UNIT_PATH (temp)
`define WB_UNIT_PATH wb_stage
`define DCACHE_UNIT_PATH (temp)


// ===================== INIT BLOCK =====================
// MUST BE INSIDE A MODULE THAT INCLUDES THIS HEADER

`define DEBUG_UTILS_INIT \
    integer logfd; \
    int cycle_count; \
    initial begin \
        logfd = $fopen(`LOG_FILE_NAME, "w"); \
        if (logfd == 0) begin \
            $display("ERROR: cannot open log file"); \
            $finish; \
        end \
    end


// ===================== CYCLE HEADER =====================

`define PRINT_CYCLE_HEADER \
    task automatic print_cycle_header(); \
        $fdisplay(logfd, ""); \
        $fdisplay(logfd, "==================== CYCLE %0d (t=%0t) ====================", cycle_count, $time); \
    endtask


// ===================== SUB-HEADERS =====================

`include "debugUtils/debugUtilsFetch.svh"
`include "debugUtils/debugUtilsDecode.svh"
`include "debugUtils/debugUtilsRR.svh"
`include "debugUtils/debugUtilsDC.svh"
`include "debugUtils/debugUtilsMEM.svh"
`include "debugUtils/debugUtilsEXE.svh"
`include "debugUtils/debugUtils_Dcache.svh"
`include "debugUtils/debugUtils_WB.svh"

`endif
