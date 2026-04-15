import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import control_store_pkg::*;
import reg_ids_pkg::*;
import Fetch_pkg::*;
import DCache_common_pkg::*;
import WriteBack_pkg::*;

`define CLK_PERIOD (8)


module tb_execute ();

    //localparam int Clk_PERIOD = 8;
    `include "debugUtils/tb_utils_defs.svh"

    //task automatic DelayClks(input int cycles);
    //    #(Clk_PERIOD * cycles);
    //endtask

    `DEBUG_UTILS_INIT;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end


    // ================= CLOCK / RESET =================
    logic rst;
    logic wb_rst;
    wire [ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;

    byte_t ld_buf[EXE_BUFFER_SIZE];

    // ================= SIGNALS =================
    wb_cs_t wb_cs;
    br_info_t br_info;
    exe_cs_t exe_cs;

    wb_latches_t wb_latches;
    wb_latches_t next_wb_latches;
    exe_latches_t exe_latches;
    exe_outputs_t exe_outs;
    wb_outputs_t wb_outs;
    core_2_icache_t core_2_icache;
    core_2_dcache_t core_2_dcache;
    icache_2_core_t icache_2_core;
    dcache_2_core_t dcache_2_core;
    dma_controller_2_core_t dma_2_core;

    assign core_2_icache = '{default: '0};


    // ================= DUT INSTANTIATION =================
    EXE execute_stage (
        .clk(clk),
        .rst(rst),

        .latches_i(exe_latches),     // input exe stage latches
        .wb_outs_i(wb_outs),         // WB feedback inputs

        .wb_latches_next_o(next_wb_latches), // output to WB stage
        .outs_o(exe_outs)            // EXE outputs
    );

    // Everywhere_TOP u_everywhere_top (
    //     .clk(clk),
    //     .rst(rst),
    //     .core2icache_i(core_2_icache),
    //     .icache2core_o(icache_2_core),
    //     .core2dcache_i(core_2_dcache),
    //     .dcache2core_o(dcache_2_core),
    //     .dma2core_o(dma_2_core)
    // );

    // icache_loader icacheLoader ();
    // dcache_loader dcache_loader_unit ();
    // tb_memGen_InitRitual memLoader ();


task automatic print_info(input string test_name); begin
    $fdisplay(`LOG_FD, "test name: %s", test_name);
    print_cycle_header();
    print_exe_info();
    $fdisplay(`LOG_FD, "\n\n\n");
end
endtask

task automatic build_exe_cs(
    input  logic ST_OP,
    input  exe_cs_operation_type_e OP_TYPE,
    input  source_selector_e alu_inputA_sel,
    input  source_selector_e alu_inputB_sel,
    input  source_selector_e branch_target_sel,
    input  logic shift_by_one,
    input  logic br_ucond,
    input  logic relative_branch,
    input  logic special_br,
    input  logic is_far,
    input  logic second_flag_needed,
    output exe_cs_t cs
);
begin
    cs = '{
        ST_OP: ST_OP,
        OP_TYPE: OP_TYPE,
        alu_inputA_sel: alu_inputA_sel,
        alu_inputB_sel: alu_inputB_sel,
        branch_target_sel: branch_target_sel,
        shift_by_one: shift_by_one,
        br_ucond: br_ucond,
        relative_branch: relative_branch,
        special_br: special_br,
        is_far: is_far,
        second_flag_needed: second_flag_needed
    };
end
endtask

task automatic drive_exe_latches(
    input logic valid,

    // CS structs (prebuilt)
    input exe_cs_t exe_cs,
    input wb_cs_t  wb_cs,

    input logic [3:0] data_size_vec,
    input logic rh_into_mem,
    input logic mem_into_rh,

    input logic ST_XCL,
    input logic [14:0] ST_PADDR_0,
    input logic [14:0] ST_PADDR_1,
    input logic MIO,

    input br_info_t br_info,

    input logic [31:0] NEIP,
    input logic [31:0] EIP,
    input logic [31:0] EAX,

    input logic [63:0] imm64,
    input byte_t ld_buf[EXE_BUFFER_SIZE],

    input reg_ids_e sr_id,
    input logic [63:0] sr_data,
    input reg_ids_e dr_id,
    input logic [63:0] dr_data,

    input logic [14:0] ld_addy,

    input string test_name
);
begin
    exe_latches.valid = valid;

    exe_latches.cs    = exe_cs;
    exe_latches.wb_cs = wb_cs;

    exe_latches.data_size_vec = data_size_vec;
    exe_latches.rh_into_mem   = rh_into_mem;
    exe_latches.mem_into_rh   = mem_into_rh;

    exe_latches.ST_XCL     = ST_XCL;
    exe_latches.ST_PADDR_0 = ST_PADDR_0;
    exe_latches.ST_PADDR_1 = ST_PADDR_1;
    exe_latches.MIO        = MIO;

    exe_latches.br_info = br_info;

    exe_latches.NEIP = NEIP;
    exe_latches.EIP  = EIP;
    exe_latches.EAX  = EAX;

    exe_latches.imm64 = imm64;
    exe_latches.ld_buf = ld_buf;

    exe_latches.sr_id   = sr_id;
    exe_latches.sr_data = sr_data;
    exe_latches.dr_id   = dr_id;
    exe_latches.dr_data = dr_data;

    exe_latches.ld_addy = ld_addy;

    #3;
    print_info(test_name);
end
endtask

// ===================== TEST SEQUENCE =====================
    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        rst = 0;
    

        DelayClks(10);
        rst = 1;


        // -------------------------------------
        // 1. BUILD EXE CONTROL STRUCT
        // -------------------------------------
        build_exe_cs(
            1,              // ST_OP → this is a store op
            OR,             // OP_TYPE → ALU does ADD
            DR_REGISTER,        // alu_inputA_sel → A = register
            SR_REGISTER,        // alu_inputB_sel → B = immediate
            IMM32,      // branch_target_sel → not branching
            0,              // shift_by_one
            0,              // br_ucond
            0,              // relative_branch
            0,              // special_br
            0,              // is_far
            0,              // second_flag_needed
            exe_cs          // OUTPUT → filled struct
        );
        // -------------------------------------
        // 3. PREP DATA BUFFERS
        // -------------------------------------
        for (int i = 0; i < EXE_BUFFER_SIZE; i++) begin
            ld_buf[i] = i;   // 00 01 02 ... 1F
        end

        br_info = '{
            valid: 0,
            br_eip: 32'h1000,
            br_xcl: 0,
            br_pred_taken: 0,
            speculative_target: 32'h1000
        };
        // -------------------------------------
        // 2. BUILD WB CONTROL (inline)
        // -------------------------------------
        wb_cs = '{
            ST_OP: 0,   // no store at WB stage
            WB_DR: 1,   // write destination register
            WB_SR: 0
        };
        // -------------------------------------
        // 4. DRIVE EXE LATCHES
        // -------------------------------------
        drive_exe_latches(
            1,              // valid
            exe_cs,         // ← from build_exe_cs
            wb_cs,          // WB behavior
            4'hF,           // data_size_vec (all bytes active)
            0,              // rh_into_mem
            0,              // mem_into_rh
            1,              // ST_XCL
            15'h1000,       // ST_PADDR_0 (unaligned)
            15'h1010,       // ST_PADDR_1 (aligned)
            0,              // MIO
            br_info,        // branch info
            32'h2000,       // NEIP
            32'h1000,       // EIP
            32'hDEADBEEF,   // EAX
            64'h12345678ABCDEF00, // imm64
            ld_buf,         // load buffer
            EAX,            // sr_id
            64'hAAAAAAAAAAAAAAAA,
            ECX,            // dr_id
            64'hBBBBBBBBBBBBBBBB,
            15'h0200,       // ld_addy
            "EXE: ADD store test"
        );




        print_info("starting print statement");
        DelayClks(10);
      $finish;
    end

endmodule