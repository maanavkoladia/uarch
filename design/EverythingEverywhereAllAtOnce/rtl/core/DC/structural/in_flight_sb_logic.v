// ----------------------------------------------------------------
// in_flight_sb_logic -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/in_flight_sb_logic.sv
//
// Per stage S in {mem, exe, wb}:
//   eq00_S = (ld_paddr_0[14:4] == S_st_paddr0[14:4])
//   eq01_S = (ld_paddr_0[14:4] == S_st_paddr1[14:4])
//   eq10_S = (ld_paddr_1[14:4] == S_st_paddr0[14:4])
//   eq11_S = (ld_paddr_1[14:4] == S_st_paddr1[14:4])
//
//   m00_S = eq00_S                              // no extra gate
//   m01_S = eq01_S & S_ST_XCL
//   m10_S = eq10_S & LD_XCL
//   m11_S = eq11_S & xcl_both_S                 // xcl_both_S = LD_XCL & S_ST_XCL
//   match_S = OR_4(m00_S..m11_S)
//
//   stage_active_S = S_valid & S_ST_OP          // pre-computed
//   dep_stall_S    = match_S & stage_active_S
//
// in_flight_mem_stall = AND_3( OR_3(dep_stall_mem, dep_stall_exe,
//                                    dep_stall_wb),
//                              LD_OP, valid )
//
// Critical-path notes:
//   - LD_OP & valid factored out of every per-stage term -- single
//     final AND_3 instead of three AND_4s.
//   - xcl_both_S precomputed once per stage so m11_S is just a
//     2-input AND after CMP, matching m01 and m10 timing.
//   - 11-bit CMP_N is supported directly by MPS_COMP_EQ.
// ----------------------------------------------------------------

module in_flight_sb_logic (
    input  wire [14:0] ld_paddr_0,
    input  wire [14:0] ld_paddr_1,
    input  wire        LD_XCL,
    input  wire        LD_OP,
    input  wire        valid,

    input  wire [14:0] mem_st_paddr0,
    input  wire [14:0] mem_st_paddr1,
    input  wire        mem_ST_OP,
    input  wire        mem_ST_XCL,
    input  wire        mem_valid,

    input  wire [14:0] exe_st_paddr0,
    input  wire [14:0] exe_st_paddr1,
    input  wire        exe_ST_OP,
    input  wire        exe_ST_XCL,
    input  wire        exe_valid,

    input  wire [14:0] wb_st_paddr0,
    input  wire [14:0] wb_st_paddr1,
    input  wire        wb_ST_OP,
    input  wire        wb_ST_XCL,
    input  wire        wb_valid,

    output wire        in_flight_mem_stall
);

    // ----------------------------------------------------------------
    // Aligned address slices [14:4] (cache-line aligned, 11 bits)
    // ----------------------------------------------------------------
    wire [10:0] aligned_ld_paddr0;
    wire [10:0] aligned_ld_paddr1;
    assign aligned_ld_paddr0 = ld_paddr_0[14:4];
    assign aligned_ld_paddr1 = ld_paddr_1[14:4];

    wire [10:0] aligned_mem_st_paddr0;
    wire [10:0] aligned_mem_st_paddr1;
    wire [10:0] aligned_exe_st_paddr0;
    wire [10:0] aligned_exe_st_paddr1;
    wire [10:0] aligned_wb_st_paddr0;
    wire [10:0] aligned_wb_st_paddr1;
    assign aligned_mem_st_paddr0 = mem_st_paddr0[14:4];
    assign aligned_mem_st_paddr1 = mem_st_paddr1[14:4];
    assign aligned_exe_st_paddr0 = exe_st_paddr0[14:4];
    assign aligned_exe_st_paddr1 = exe_st_paddr1[14:4];
    assign aligned_wb_st_paddr0  = wb_st_paddr0[14:4];
    assign aligned_wb_st_paddr1  = wb_st_paddr1[14:4];

    // ----------------------------------------------------------------
    // Pre-computed per-stage scalars: stage_active = valid & ST_OP,
    // xcl_both = LD_XCL & S_ST_XCL.  These hide behind the slow
    // address compares.
    // ----------------------------------------------------------------
    wire mem_active, exe_active, wb_active;
    `AND_2(u_mem_active, 1, mem_active, mem_valid, mem_ST_OP)
    `AND_2(u_exe_active, 1, exe_active, exe_valid, exe_ST_OP)
    `AND_2(u_wb_active,  1, wb_active,  wb_valid,  wb_ST_OP)

    wire mem_xcl_both, exe_xcl_both, wb_xcl_both;
    `AND_2(u_mem_xcl_both, 1, mem_xcl_both, LD_XCL, mem_ST_XCL)
    `AND_2(u_exe_xcl_both, 1, exe_xcl_both, LD_XCL, exe_ST_XCL)
    `AND_2(u_wb_xcl_both,  1, wb_xcl_both,  LD_XCL, wb_ST_XCL)

    // ----------------------------------------------------------------
    // MEM stage: 4x CMP_N + match gating + OR_4 + AND_2
    // ----------------------------------------------------------------
    wire mem_eq00, mem_eq01, mem_eq10, mem_eq11;
    `CMP_N(u_mem_eq00, 11, mem_eq00, aligned_ld_paddr0, aligned_mem_st_paddr0)
    `CMP_N(u_mem_eq01, 11, mem_eq01, aligned_ld_paddr0, aligned_mem_st_paddr1)
    `CMP_N(u_mem_eq10, 11, mem_eq10, aligned_ld_paddr1, aligned_mem_st_paddr0)
    `CMP_N(u_mem_eq11, 11, mem_eq11, aligned_ld_paddr1, aligned_mem_st_paddr1)

    wire mem_match_ld0_st0;
    wire mem_match_ld0_st1;
    wire mem_match_ld1_st0;
    wire mem_match_ld1_st1;
    assign mem_match_ld0_st0 = mem_eq00;                              // no XCL gate
    `AND_2(u_mem_m01, 1, mem_match_ld0_st1, mem_eq01, mem_ST_XCL)
    `AND_2(u_mem_m10, 1, mem_match_ld1_st0, mem_eq10, LD_XCL)
    `AND_2(u_mem_m11, 1, mem_match_ld1_st1, mem_eq11, mem_xcl_both)

    wire mem_any_match;
    `OR_4(u_mem_any, 1, mem_any_match,
          mem_match_ld0_st0, mem_match_ld0_st1,
          mem_match_ld1_st0, mem_match_ld1_st1)

    wire mem_dep_stall;
    `AND_2(u_mem_dep, 1, mem_dep_stall, mem_any_match, mem_active)

    // ----------------------------------------------------------------
    // EXE stage
    // ----------------------------------------------------------------
    wire exe_eq00, exe_eq01, exe_eq10, exe_eq11;
    `CMP_N(u_exe_eq00, 11, exe_eq00, aligned_ld_paddr0, aligned_exe_st_paddr0)
    `CMP_N(u_exe_eq01, 11, exe_eq01, aligned_ld_paddr0, aligned_exe_st_paddr1)
    `CMP_N(u_exe_eq10, 11, exe_eq10, aligned_ld_paddr1, aligned_exe_st_paddr0)
    `CMP_N(u_exe_eq11, 11, exe_eq11, aligned_ld_paddr1, aligned_exe_st_paddr1)

    wire exe_match_ld0_st0;
    wire exe_match_ld0_st1;
    wire exe_match_ld1_st0;
    wire exe_match_ld1_st1;
    assign exe_match_ld0_st0 = exe_eq00;
    `AND_2(u_exe_m01, 1, exe_match_ld0_st1, exe_eq01, exe_ST_XCL)
    `AND_2(u_exe_m10, 1, exe_match_ld1_st0, exe_eq10, LD_XCL)
    `AND_2(u_exe_m11, 1, exe_match_ld1_st1, exe_eq11, exe_xcl_both)

    wire exe_any_match;
    `OR_4(u_exe_any, 1, exe_any_match,
          exe_match_ld0_st0, exe_match_ld0_st1,
          exe_match_ld1_st0, exe_match_ld1_st1)

    wire exe_dep_stall;
    `AND_2(u_exe_dep, 1, exe_dep_stall, exe_any_match, exe_active)

    // ----------------------------------------------------------------
    // WB stage
    // ----------------------------------------------------------------
    wire wb_eq00, wb_eq01, wb_eq10, wb_eq11;
    `CMP_N(u_wb_eq00, 11, wb_eq00, aligned_ld_paddr0, aligned_wb_st_paddr0)
    `CMP_N(u_wb_eq01, 11, wb_eq01, aligned_ld_paddr0, aligned_wb_st_paddr1)
    `CMP_N(u_wb_eq10, 11, wb_eq10, aligned_ld_paddr1, aligned_wb_st_paddr0)
    `CMP_N(u_wb_eq11, 11, wb_eq11, aligned_ld_paddr1, aligned_wb_st_paddr1)

    wire wb_match_ld0_st0;
    wire wb_match_ld0_st1;
    wire wb_match_ld1_st0;
    wire wb_match_ld1_st1;
    assign wb_match_ld0_st0 = wb_eq00;
    `AND_2(u_wb_m01, 1, wb_match_ld0_st1, wb_eq01, wb_ST_XCL)
    `AND_2(u_wb_m10, 1, wb_match_ld1_st0, wb_eq10, LD_XCL)
    `AND_2(u_wb_m11, 1, wb_match_ld1_st1, wb_eq11, wb_xcl_both)

    wire wb_any_match;
    `OR_4(u_wb_any, 1, wb_any_match,
          wb_match_ld0_st0, wb_match_ld0_st1,
          wb_match_ld1_st0, wb_match_ld1_st1)

    wire wb_dep_stall;
    `AND_2(u_wb_dep, 1, wb_dep_stall, wb_any_match, wb_active)

    // ----------------------------------------------------------------
    // Final reduction: any stage matched, gate by LD_OP and valid.
    // ----------------------------------------------------------------
    wire any_dep_stall;
    `OR_3 (u_or_stages, 1, any_dep_stall,
           mem_dep_stall, exe_dep_stall, wb_dep_stall)
    `AND_3(u_out,       1, in_flight_mem_stall,
           any_dep_stall, LD_OP, valid)

endmodule
