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
            4'h7,           // data_size_vec (32-bit)
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




        // =============================================
        // ADD ENCODING TESTS
        // Covers all 14 encodings from the x86 manual.
        // For each: result visible in [WB NEXT LATCHES] dr_data.
        // Flags visible in [EXE OUTS] ZF (updated after posedge).
        // =============================================
        br_info = '{valid: 0, br_eip: 0, br_xcl: 0, br_pred_taken: 0, speculative_target: 0};
        wb_cs   = '{ST_OP: 0, WB_DR: 1, WB_SR: 0};
        for (int i = 0; i < EXE_BUFFER_SIZE; i++) ld_buf[i] = 0;

        // ── 1. ADD EAX,imm32  (05 id, 32-bit short form) ────────────────────────
        // EAX=0x10000000, imm32=0x20000000 → 0x30000000, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hBEEFDEAD20000000, ld_buf,
            EAX, 64'h0, EAX, 64'hAAAA555510000000, 15'h0,
            "ADD EAX,imm32: 0x10000000+0x20000000=0x30000000");
        DelayClks(1);
        // ── 1. ADD EAX,imm32  (05 id, 32-bit short form) ────────────────────────
        // EAX=0x10000000, imm32=0x20000000 → 0x30000000, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hBEEFDEAD7FFFFFFF, ld_buf,
            EAX, 64'h0, EAX, 64'hAAAA555500000020, 15'h0,
            "ADD EAX,imm32: 0x10000000+0x20000000=0x30000000");
        DelayClks(1);


        // ── 2. ADD AX,imm16  (05 iw, 16-bit) ────────────────────────────────────
        // AX=0x0100, imm16=0x0200 → 0x0300, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h3, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hBEEFDEADCAFE0200, ld_buf,
            EAX, 64'h0, EAX, 64'hAAAA5555DEAD0100, 15'h0,
            "ADD AX,imm16: 0x0100+0x0200=0x0300");
        DelayClks(1);

        // ── 3. ADD AL,imm8  (04 ib, 8-bit) ──────────────────────────────────────
        // AL=0x10, imm8=0x20 → 0x30, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hA5A5A5A5A5A5A57F, ld_buf,
            EAX, 64'h0, EAX, 64'hF0F0F0F0F0F0F001, 15'h0,
            "ADD AL,imm8: 0x10+0x20=0x30");
        DelayClks(1);

        // ── 4. ADD r/m32,imm32  (81 /0 id) ──────────────────────────────────────
        // ECX=0x100, imm32=0x50 → 0x150, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hDEADCAFE00000050, ld_buf,
            ECX, 64'h0, ECX, 64'hCCCC333300000100, 15'h0,
            "ADD r/m32,imm32(ECX): 0x100+0x50=0x150");
        DelayClks(1);

        // ── 5. ADD r/m16,imm16  (81 /0 iw) ──────────────────────────────────────
        // CX=0x100, imm16=0x50 → 0x150, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h3, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hDEADCAFEBEEF0050, ld_buf,
            ECX, 64'h0, ECX, 64'hCCCC3333DEAD0100, 15'h0,
            "ADD r/m16,imm16(CX): 0x0100+0x0050=0x0150");
        DelayClks(1);

        // ── 6. ADD r/m8,imm8  (80 /0 ib) ────────────────────────────────────────
        // CL=0x10, imm8=0x05 → 0x15, no flags
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hB7B7B7B7B7B7B705, ld_buf,
            ECX, 64'h0, ECX, 64'hA5A5A5A5A5A5A510, 15'h0,
            "ADD r/m8,imm8(CL): 0x10+0x05=0x15");
        DelayClks(1);

        // ── 7. ADD r/m32,imm8(sext)  (83 /0 ib, 32-bit, positive sext) ──────────
        // ECX=0x100, sext(0x7F)=+127 → 0x17F, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SEXT8, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hDEADDEADCAFE007F, ld_buf,
            ECX, 64'h0, ECX, 64'hCCCC333300000100, 15'h0,
            "ADD r/m32,sext8(+127)(ECX): 0x100+0x7F=0x17F");
        DelayClks(1);

        // ── 8. ADD r/m16,imm8(sext)  (83 /0 ib, 16-bit, positive sext) ──────────
        // CX=0x100, sext(0x7F)=+127 → 0x17F, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SEXT8, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h3, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hDEADDEADCAFE007F, ld_buf,
            ECX, 64'h0, ECX, 64'hCCCC3333DEAD0100, 15'h0,
            "ADD r/m16,sext8(+127)(CX): 0x0100+0x7F=0x017F");
        DelayClks(1);

        // ── 9. ADD r/m32,r32  (01 /r) ────────────────────────────────────────────
        // ECX(dr)=0x100, EAX(sr)=0x200 → ECX=0x300, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            EAX, 64'hAAAA555500000200, ECX, 64'hCCCC333300000100, 15'h0,
            "ADD r/m32,r32(ECX+EAX): 0x100+0x200=0x300");
        DelayClks(1);

        // ── 10. ADD r/m16,r16  (01 /r, 16-bit) ───────────────────────────────────
        // CX(dr)=0x100, AX(sr)=0x200 → CX=0x300, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h3, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            EAX, 64'hAAAA5555CAFE0200, ECX, 64'hCCCC3333DEAD0100, 15'h0,
            "ADD r/m16,r16(CX+AX): 0x0100+0x0200=0x0300");
        DelayClks(1);

        // ── 11. ADD r/m8,r8  (00 /r) ─────────────────────────────────────────────
        // CL(dr)=0x10, AL(sr)=0x20 → CL=0x30, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            EAX, 64'hB5B5B5B5B5B5B520, ECX, 64'hA5A5A5A5A5A5A510, 15'h0,
            "ADD r/m8,r8(CL+AL): 0x10+0x20=0x30");
        DelayClks(1);

        // ── 12. ADD r32,r/m32  (03 /r) ───────────────────────────────────────────
        // Decode swaps who is dr/sr vs encoding 01 /r.
        // EAX(dr)=0x100, ECX(sr)=0x200 → EAX=0x300, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            ECX, 64'hCCCC333300000200, EAX, 64'hAAAA555500000100, 15'h0,
            "ADD r32,r/m32(EAX+ECX): 0x100+0x200=0x300");
        DelayClks(1);

        // ── 13. ADD r16,r/m16  (03 /r, 16-bit) ───────────────────────────────────
        // AX(dr)=0x100, CX(sr)=0x200 → AX=0x300, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h3, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            ECX, 64'hCCCC3333CAFE0200, EAX, 64'hAAAA5555DEAD0100, 15'h0,
            "ADD r16,r/m16(AX+CX): 0x0100+0x0200=0x0300");
        DelayClks(1);

        // ── 14. ADD r8,r/m8  (02 /r) ─────────────────────────────────────────────
        // AL(dr)=0x10, CL(sr)=0x20 → AL=0x30, no flags
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            ECX, 64'hA5A5A5A5A5A5A520, EAX, 64'hB5B5B5B5B5B5B510, 15'h0,
            "ADD r8,r/m8(AL+CL): 0x10+0x20=0x30");
        DelayClks(1);

        // =============================================
        // FLAG TESTS
        // flags_reg is sequential: it captures the combinational flag outputs on
        // posedge clk. print_exe_info waits CLK_PERIOD-1 after the posedge fires,
        // so outs_o.ZF reflects the computation of THIS instruction.
        // Expected flags annotated on each test.
        // =============================================

        // ── ZF + CF: 32-bit wrap-around to zero ──────────────────────────────────
        // 0xFFFFFFFF + 0x00000001 = 0x1_00000000 → lower 32 = 0  → ZF=1, CF=1, PF=1
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            EAX, 64'hAAAA555500000001, ECX, 64'hCCCC3333FFFFFFFF, 15'h0,
            "ADD flag ZF+CF: 0xFFFFFFFF+0x1=0x0 (ZF=1,CF=1,PF=1)");
        DelayClks(1);

        // ── SF + OF: 32-bit signed overflow, max positive + 1 ────────────────────
        // 0x7FFFFFFF + 0x00000001 = 0x80000000 → SF=1, OF=1
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            EAX, 64'hAAAA555500000001, ECX, 64'hCCCC33337FFFFFFF, 15'h0,
            "ADD flag SF+OF: 0x7FFFFFFF+0x1=0x80000000 (SF=1,OF=1)");
        DelayClks(1);

        // ── CF only: 32-bit carry, non-zero result ────────────────────────────────
        // 0xFFFFFFFF + 0x00000002 = 0x1_00000001 → lower 32 = 0x1 → CF=1, ZF=0
        build_exe_cs(0, ADD, DR_REGISTER, SR_REGISTER, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'h0, ld_buf,
            EAX, 64'hAAAA555500000002, ECX, 64'hCCCC3333FFFFFFFF, 15'h0,
            "ADD flag CF: 0xFFFFFFFF+0x2=0x1 (CF=1,ZF=0)");
        DelayClks(1);

        // ── AF: half-carry from bit 3 into bit 4, 8-bit ──────────────────────────
        // 0x0F + 0x01 = 0x10  → AF=1
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hB7B7B7B7B7B7B701, ld_buf,
            ECX, 64'h0, ECX, 64'hA5A5A5A5A5A5A50F, 15'h0,
            "ADD flag AF: 0x0F+0x01=0x10 (AF=1)");
        DelayClks(1);

        // ── PF: even parity on low byte, 8-bit ───────────────────────────────────
        // 0x02 + 0x01 = 0x03 = 0b00000011 → 2 bits set → even parity → PF=1
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hB7B7B7B7B7B7B701, ld_buf,
            ECX, 64'h0, ECX, 64'hA5A5A5A5A5A5A502, 15'h0,
            "ADD flag PF: 0x02+0x01=0x03 (PF=1)");
        DelayClks(1);

        // ── SF + OF: 8-bit signed overflow ───────────────────────────────────────
        // 0x70(+112) + 0x20(+32) = 0x90(-112 as s8) → SF=1, OF=1
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hB7B7B7B7B7B7B720, ld_buf,
            ECX, 64'h0, ECX, 64'hA5A5A5A5A5A5A570, 15'h0,
            "ADD flag SF+OF(8b): 0x70+0x20=0x90 (SF=1,OF=1)");
        DelayClks(1);

        // ── ZF + CF: 8-bit wrap-around ───────────────────────────────────────────
        // 0xFF + 0x01 = 0x100 → lower 8 = 0x00 → ZF=1, CF=1, PF=1
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h1, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hB7B7B7B7B7B7B701, ld_buf,
            ECX, 64'h0, ECX, 64'hA5A5A5A5A5A5A5FF, 15'h0,
            "ADD flag ZF+CF(8b): 0xFF+0x01=0x00 (ZF=1,CF=1,PF=1)");
        DelayClks(1);

        // ── sext8(-1): 32-bit add with negative sign-extended immediate ───────────
        // ECX=0x10, sext(0xFF)=0xFFFFFFFF(-1) → ECX=0x0F, CF=1
        build_exe_cs(0, ADD, DR_REGISTER, SEXT8, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hDEADDEADCAFE00FF, ld_buf,
            ECX, 64'h0, ECX, 64'hCCCC333300000010, 15'h0,
            "ADD r/m32,sext8(-1): 0x10+0xFFFFFFFF=0x0F (CF=1)");
        DelayClks(1);

        // ── No flags: baseline clean 32-bit add ──────────────────────────────────
        // 0x01 + 0x01 = 0x02, all flags clear
        build_exe_cs(0, ADD, DR_REGISTER, IMM64, IMM32, 0, 0, 0, 0, 0, 0, exe_cs);
        drive_exe_latches(1, exe_cs, wb_cs, 4'h7, 0, 0, 0, 0, 0, 0, br_info,
            32'h0, 32'h1000, 32'h0, 64'hDEADCAFE00000001, ld_buf,
            ECX, 64'h0, ECX, 64'hCCCC333300000001, 15'h0,
            "ADD no flags: 0x1+0x1=0x2 (all flags clear)");
        DelayClks(1);

        DelayClks(5);
        $finish;
    end

endmodule