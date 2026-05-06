`ifndef TB_UTILS_DEFS_H
`define TB_UTILS_DEFS_H

import tb_debug_pkg::*;

// ===================== LOG FILE =====================

// file name (string constant)
`define LOG_FD logfd

`ifndef LOG_FILE_NAME 
    `define LOG_FILE_NAME "run_default.log"
`endif

`ifndef RTL_REGDUMP_FILE_NAME 
    `define RTL_REGDUMP_FILE_NAME "rtl_regdump_default.log"
`endif

`ifndef RTL_FLAGDUMP_FILE_NAME 
    `define RTL_FLAGDUMP_FILE_NAME "rtl_flagdump_default.log"
`endif



// ===================== DUT PATHS =====================
`define FETCH_UNIT_PATH uut_AllAtOnce.core_unit.fetch_unit
`define DECODE_UNIT_PATH uut_AllAtOnce.core_unit.decode_unit
`define RR_UNIT_PATH uut_AllAtOnce.core_unit.rr_unit
`define DC_UNIT_PATH uut_AllAtOnce.core_unit.dc_unit
`define MEM_UNIT_PATH (temp)
`define EXE_UNIT_PATH uut_AllAtOnce.core_unit.execute_unit
`define WB_UNIT_PATH uut_AllAtOnce.core_unit.write_back_unit
`define DCACHE_UNIT_PATH (temp)
`define REGFILE_PATH uut_AllAtOnce.core_unit.rr_unit.RegisterFile_unit

// EXE port style. Define when EXE is the pure-Verilog-2005 EXE_structural.v
// (flat ports). Comment out / undef to fall back to SV struct ports
// (EXE_structural.sv / EXE.sv).
//`define EXE_PURE_STRUCTURAL

// ===================== DUMP FILE DESCRIPTORS =====================
`define REGDUMP_FD regdumpfd
`define FLAGDUMP_FD flagdumpfd


// ===================== INIT BLOCK =====================
// MUST BE INSIDE A MODULE THAT INCLUDES THIS HEADER


// ===================== CYCLE HEADER =====================

`define COMMON_UTILS_INIT \
    logic clk = 0;\
    task automatic DelayClks(input int cycles);\
        #(`CLK_PERIOD  * cycles);\
    endtask\
    always begin\
        #(`CLK_PERIOD/2.0);\
        clk = ~clk;\
    end\


`define PRINT_CYCLE_HEADER \
    task automatic print_cycle_header(); \
        $fdisplay(logfd, ""); \
        $fdisplay(logfd, "==================== CYCLE %0d (t=%0t) ====================", cycle_count, $time); \
    endtask \

`define DEBUG_UTILS_INIT \
    string log_file_name; \
    string regdump_file_name; \
    string flagdump_file_name; \
    integer `LOG_FD; \
    integer `REGDUMP_FD; \
    integer `FLAGDUMP_FD; \
    int cycle_count = 0; \
    `COMMON_UTILS_INIT \
    `PRINT_CYCLE_HEADER \
    initial begin \
        /* ---------------- Runtime override via plusargs ---------------- */ \
        if (!$value$plusargs("LOG_FILE_NAME=%s", log_file_name)) \
            log_file_name = `LOG_FILE_NAME; \
        if (!$value$plusargs("RTL_REGDUMP_FILE_NAME=%s", regdump_file_name)) \
            regdump_file_name = `RTL_REGDUMP_FILE_NAME; \
        if (!$value$plusargs("RTL_FLAGDUMP_FILE_NAME=%s", flagdump_file_name)) \
            flagdump_file_name = `RTL_FLAGDUMP_FILE_NAME; \
        \
        /* ---------------- Open files ---------------- */ \
        logfd = $fopen(log_file_name, "w"); \
        if (logfd == 0) begin \
            $display("ERROR: cannot open log file %s", log_file_name); \
            $finish; \
        end \
        regdumpfd = $fopen(regdump_file_name, "w"); \
        if (regdumpfd == 0) begin \
            $display("ERROR: cannot open regdump file %s", regdump_file_name); \
            $finish; \
        end \
        flagdumpfd = $fopen(flagdump_file_name, "w"); \
        if (flagdumpfd == 0) begin \
            $display("ERROR: cannot open flagdump file %s", flagdump_file_name); \
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
`include "debugUtils/debugUtils_WB.svh"
`include "debugUtils/debugUtilsEXE.svh"
//`include "debugUtils/debugUtils_Dcache.svh"
//`include "debugUtils/debugUtilsWBLatches.svh"

`endif
