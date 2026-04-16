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
    assign wb_outs = '{default: '0};


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

// ===================== EXPECTED ADD RESULT =====================
// Computes expected result + flags for an ADD operation and prints
// them to the log so you can compare against [EXE OUTS] / [WB NEXT LATCHES].
task automatic print_expected_add(
    input logic [63:0]       dr_data,
    input logic [63:0]       sr_data,
    input logic [63:0]       imm64,
    input logic [3:0]        data_size_vec,
    input source_selector_e  inputB_sel
);
    logic [63:0] opA, opB, mask, result;
    logic [64:0] result_wide;
    logic        ZF, CF, SF, OF, PF, AF;
    logic [4:0]  af_tmp;

    case (data_size_vec)
        4'h1:    mask = 64'h00000000000000FF;
        4'h3:    mask = 64'h000000000000FFFF;
        4'h7:    mask = 64'h00000000FFFFFFFF;
        4'hF:    mask = 64'hFFFFFFFFFFFFFFFF;
        default: mask = 64'h00000000FFFFFFFF;
    endcase

    opA = dr_data & mask;
    case (inputB_sel)
        SR_REGISTER: opB = sr_data & mask;
        IMM64:       opB = imm64   & mask;
        SEXT8:       opB = {{56{imm64[7]}}, imm64[7:0]} & mask;
        default:     opB = imm64   & mask;
    endcase

    result_wide = {1'b0, opA} + {1'b0, opB};
    result      = result_wide[63:0] & mask;

    ZF = (result == '0);
    PF = ~^result[7:0];
    af_tmp = {1'b0, opA[3:0]} + {1'b0, opB[3:0]};
    AF = af_tmp[4];

    case (data_size_vec)
        4'h1: begin
            CF = result_wide[8];
            SF = result[7];
            OF = (~opA[7]  & ~opB[7]  &  result[7]) |
                 ( opA[7]  &  opB[7]  & ~result[7]);
        end
        4'h3: begin
            CF = result_wide[16];
            SF = result[15];
            OF = (~opA[15] & ~opB[15] &  result[15]) |
                 ( opA[15] &  opB[15] & ~result[15]);
        end
        4'h7: begin
            CF = result_wide[32];
            SF = result[31];
            OF = (~opA[31] & ~opB[31] &  result[31]) |
                 ( opA[31] &  opB[31] & ~result[31]);
        end
        4'hF: begin
            CF = result_wide[64];
            SF = result[63];
            OF = (~opA[63] & ~opB[63] &  result[63]) |
                 ( opA[63] &  opB[63] & ~result[63]);
        end
        default: begin CF = 0; SF = 0; OF = 0; end
    endcase

    $fdisplay(`LOG_FD, "[EXPECTED ADD]  opA=0x%016h  opB=0x%016h  result=0x%016h",
              opA, opB, result);
    $fdisplay(`LOG_FD, "  AF=%0b CF=%0b OF=%0b PF=%0b SF=%0b ZF=%0b",
              AF, CF, OF, PF, SF, ZF);
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
    input logic [3:0] sr_data_size_vec,
    input logic shift_sr_up,
    input logic shift_sr_down,

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
    exe_latches.sr_data_size_vec = sr_data_size_vec;
    exe_latches.shift_sr_down   = shift_sr_down;
    exe_latches.shift_sr_up   = shift_sr_up;

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
    print_expected_add(dr_data, sr_data, imm64, data_size_vec, exe_cs.alu_inputB_sel);
    print_info(test_name);

end
endtask
//
//add rm32 r32
//add r32 rm32
//add rm16 r16
//add r16 rm16
//add rm8 r8
//add r8 rm8
//add rm8 AH
//add AH rm8
//ADD EAX imm32
//ADD rm32 imm32 etc


//
// ===================== TEST SEQUENCE =====================
    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        rst = 0;
    

        DelayClks(10);
        rst = 1;




        // =============================================
        // ADD ENCODING TESTS
        // Covers all 14 encodings from the x86 manual.
        // For each: result visible in [WB NEXT LATCHES] dr_data.
        // Flags visible in [EXE OUTS] ZF (updated after posedge).
        // =============================================
        br_info = '{valid: 0, br_eip: 0, br_xcl: 0, br_pred_taken: 0, speculative_target: 0};
        wb_cs   = '{ST_OP: 1, WB_DR: 0, WB_SR: 0, WB_EAX: 0};

        for (int i = 0; i < EXE_BUFFER_SIZE; i++) ld_buf[i] = i;


        DelayClks(5);
        $finish;
    end

endmodule