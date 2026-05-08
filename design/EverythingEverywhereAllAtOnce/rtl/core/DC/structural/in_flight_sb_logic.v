// ----------------------------------------------------------------
// in_flight_sb_logic -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/in_flight_sb_logic.sv
//
// Address split (mirrors wb_stq_sb_logic):
//   *_paddr_*_offset[7:0]  = paddr[11:4]   (8-bit page offset, pre-TLB ready)
//   *_paddr_*_pfn[2:0]     = paddr[14:12]  (3-bit PFN, ld is post-TLB,
//                                           in-flight stores are flop outputs)
//   paddr[3:0] (intra-line offset) is NOT compared and not exposed here.
//
// Per stage S in {mem, exe, wb}:
//   PRE-TLB phase (hides behind TLB delay):
//     eq_off_00 = (ld0_off == S_st0_off)        [8-bit CMP_N]
//     eq_off_01 = (ld0_off == S_st1_off)
//     eq_off_10 = (ld1_off == S_st0_off)
//     eq_off_11 = (ld1_off == S_st1_off)
//     pre_match_00 = eq_off_00                       (no XCL gate)
//     pre_match_01 = eq_off_01 & S_ST_XCL
//     pre_match_10 = eq_off_10 & LD_XCL
//     pre_match_11 = eq_off_11 & S_xcl_both          (S_xcl_both = LD_XCL & S_ST_XCL)
//
//   POST-TLB phase (kicks off when ld_paddr_*_pfn arrives):
//     eq_pfn_00 = (ld0_pfn == S_st0_pfn)        [3-bit CMP_N]
//     eq_pfn_01 = (ld0_pfn == S_st1_pfn)
//     eq_pfn_10 = (ld1_pfn == S_st0_pfn)
//     eq_pfn_11 = (ld1_pfn == S_st1_pfn)
//     nand_match_n_LXSY = NAND2(pre_match_LXSY, eq_pfn_LXSY)   [active-low slot match]
//
// Per-stage NAND4 across the 4 ld*st combinations gives any_match (active-high)
// by DeMorgan:  NAND4(nand_match_n_00..nand_match_n_11) = OR over LXSY of
// (pre_match_LXSY & eq_pfn_LXSY).
//
// Final reduction (off-CP gate folded earlier, same as before):
//   S_dep_stall_n = NAND2(S_any_match, S_gate)             [active-low per stage]
//   in_flight_mem_stall = NAND3(mem_dep_stall_n, exe_dep_stall_n, wb_dep_stall_n)
//
// Critical-path summary post-TLB (after eq_pfn_* arrives):
//   CMP_N(3) -> nand2 -> nand4 -> nand2 -> nand3
//   = ~2 + 1 + 1 + 1 + 1 = 6 NAND-equivalent levels
// vs the prior CMP_N(11) + and2 + or4 + nand2 + nand3 ~= 8 levels.
// ----------------------------------------------------------------

module in_flight_sb_logic (
    // Load 0 / Load 1 (split paddr: offset = paddr[11:4], pfn = paddr[14:12])
    input  wire [7:0]  ld_paddr_0_offset,
    input  wire [2:0]  ld_paddr_0_pfn,
    input  wire [7:0]  ld_paddr_1_offset,
    input  wire [2:0]  ld_paddr_1_pfn,
    input  wire        LD_XCL,
    input  wire        LD_OP,
    input  wire        valid,

    // MEM stage in-flight store paddrs
    input  wire [7:0]  mem_st_paddr0_offset,
    input  wire [2:0]  mem_st_paddr0_pfn,
    input  wire [7:0]  mem_st_paddr1_offset,
    input  wire [2:0]  mem_st_paddr1_pfn,
    input  wire        mem_ST_OP,
    input  wire        mem_ST_XCL,
    input  wire        mem_valid,

    // EXE stage in-flight store paddrs
    input  wire [7:0]  exe_st_paddr0_offset,
    input  wire [2:0]  exe_st_paddr0_pfn,
    input  wire [7:0]  exe_st_paddr1_offset,
    input  wire [2:0]  exe_st_paddr1_pfn,
    input  wire        exe_ST_OP,
    input  wire        exe_ST_XCL,
    input  wire        exe_valid,

    // WB stage in-flight store paddrs
    input  wire [7:0]  wb_st_paddr0_offset,
    input  wire [2:0]  wb_st_paddr0_pfn,
    input  wire [7:0]  wb_st_paddr1_offset,
    input  wire [2:0]  wb_st_paddr1_pfn,
    input  wire        wb_ST_OP,
    input  wire        wb_ST_XCL,
    input  wire        wb_valid,

    output wire        in_flight_mem_stall
);

    // ----------------------------------------------------------------
    // Off-CP scalars: stage_active = valid & ST_OP, and the gate that
    // folds in LD_OP / valid so the post-TLB back-end is one nand2 to
    // dep_stall_n. xcl_both = LD_XCL & S_ST_XCL feeds the m11 pre_match.
    // All inputs are flop outputs at clock edge; resolves before any
    // address compare finishes.
    // ----------------------------------------------------------------
    wire mem_active, exe_active, wb_active;
    `AND_2(u_mem_active, 1, mem_active, mem_valid, mem_ST_OP)
    `AND_2(u_exe_active, 1, exe_active, exe_valid, exe_ST_OP)
    `AND_2(u_wb_active,  1, wb_active,  wb_valid,  wb_ST_OP)

    wire mem_gate, exe_gate, wb_gate;
    `AND_3(u_mem_gate, 1, mem_gate, mem_active, LD_OP, valid)
    `AND_3(u_exe_gate, 1, exe_gate, exe_active, LD_OP, valid)
    `AND_3(u_wb_gate,  1, wb_gate,  wb_active,  LD_OP, valid)

    wire mem_xcl_both, exe_xcl_both, wb_xcl_both;
    `AND_2(u_mem_xcl_both, 1, mem_xcl_both, LD_XCL, mem_ST_XCL)
    `AND_2(u_exe_xcl_both, 1, exe_xcl_both, LD_XCL, exe_ST_XCL)
    `AND_2(u_wb_xcl_both,  1, wb_xcl_both,  LD_XCL, wb_ST_XCL)

    // ----------------------------------------------------------------
    // MEM stage: pre-TLB offset compares + XCL gating, post-TLB PFN
    // compares + nand2 combine, nand4 across the 4 ld*st combos.
    // ----------------------------------------------------------------
    wire mem_eq_off_00, mem_eq_off_01, mem_eq_off_10, mem_eq_off_11;
    `CMP_N(u_mem_eq_off_00, 8, mem_eq_off_00, ld_paddr_0_offset, mem_st_paddr0_offset)
    `CMP_N(u_mem_eq_off_01, 8, mem_eq_off_01, ld_paddr_0_offset, mem_st_paddr1_offset)
    `CMP_N(u_mem_eq_off_10, 8, mem_eq_off_10, ld_paddr_1_offset, mem_st_paddr0_offset)
    `CMP_N(u_mem_eq_off_11, 8, mem_eq_off_11, ld_paddr_1_offset, mem_st_paddr1_offset)

    wire mem_pre_match_00, mem_pre_match_01, mem_pre_match_10, mem_pre_match_11;
    assign mem_pre_match_00 = mem_eq_off_00;                       // no XCL gate
    `AND_2(u_mem_pm01, 1, mem_pre_match_01, mem_eq_off_01, mem_ST_XCL)
    `AND_2(u_mem_pm10, 1, mem_pre_match_10, mem_eq_off_10, LD_XCL)
    `AND_2(u_mem_pm11, 1, mem_pre_match_11, mem_eq_off_11, mem_xcl_both)

    wire mem_eq_pfn_00, mem_eq_pfn_01, mem_eq_pfn_10, mem_eq_pfn_11;
    `CMP_N(u_mem_eq_pfn_00, 3, mem_eq_pfn_00, ld_paddr_0_pfn, mem_st_paddr0_pfn)
    `CMP_N(u_mem_eq_pfn_01, 3, mem_eq_pfn_01, ld_paddr_0_pfn, mem_st_paddr1_pfn)
    `CMP_N(u_mem_eq_pfn_10, 3, mem_eq_pfn_10, ld_paddr_1_pfn, mem_st_paddr0_pfn)
    `CMP_N(u_mem_eq_pfn_11, 3, mem_eq_pfn_11, ld_paddr_1_pfn, mem_st_paddr1_pfn)

    wire mem_nand_match_n_00, mem_nand_match_n_01, mem_nand_match_n_10, mem_nand_match_n_11;
    nand2$ u_mem_nm00 (.out(mem_nand_match_n_00), .in0(mem_pre_match_00), .in1(mem_eq_pfn_00));
    nand2$ u_mem_nm01 (.out(mem_nand_match_n_01), .in0(mem_pre_match_01), .in1(mem_eq_pfn_01));
    nand2$ u_mem_nm10 (.out(mem_nand_match_n_10), .in0(mem_pre_match_10), .in1(mem_eq_pfn_10));
    nand2$ u_mem_nm11 (.out(mem_nand_match_n_11), .in0(mem_pre_match_11), .in1(mem_eq_pfn_11));

    // NAND4 of nand_match_n[0..3] = OR of match[0..3] = any_match (active-high)
    wire mem_any_match;
    nand4$ u_mem_any (.out(mem_any_match),
        .in0(mem_nand_match_n_00), .in1(mem_nand_match_n_01),
        .in2(mem_nand_match_n_10), .in3(mem_nand_match_n_11));

    wire mem_dep_stall_n;
    nand2$ u_mem_dep_n (.out(mem_dep_stall_n), .in0(mem_any_match), .in1(mem_gate));

    // ----------------------------------------------------------------
    // EXE stage
    // ----------------------------------------------------------------
    wire exe_eq_off_00, exe_eq_off_01, exe_eq_off_10, exe_eq_off_11;
    `CMP_N(u_exe_eq_off_00, 8, exe_eq_off_00, ld_paddr_0_offset, exe_st_paddr0_offset)
    `CMP_N(u_exe_eq_off_01, 8, exe_eq_off_01, ld_paddr_0_offset, exe_st_paddr1_offset)
    `CMP_N(u_exe_eq_off_10, 8, exe_eq_off_10, ld_paddr_1_offset, exe_st_paddr0_offset)
    `CMP_N(u_exe_eq_off_11, 8, exe_eq_off_11, ld_paddr_1_offset, exe_st_paddr1_offset)

    wire exe_pre_match_00, exe_pre_match_01, exe_pre_match_10, exe_pre_match_11;
    assign exe_pre_match_00 = exe_eq_off_00;
    `AND_2(u_exe_pm01, 1, exe_pre_match_01, exe_eq_off_01, exe_ST_XCL)
    `AND_2(u_exe_pm10, 1, exe_pre_match_10, exe_eq_off_10, LD_XCL)
    `AND_2(u_exe_pm11, 1, exe_pre_match_11, exe_eq_off_11, exe_xcl_both)

    wire exe_eq_pfn_00, exe_eq_pfn_01, exe_eq_pfn_10, exe_eq_pfn_11;
    `CMP_N(u_exe_eq_pfn_00, 3, exe_eq_pfn_00, ld_paddr_0_pfn, exe_st_paddr0_pfn)
    `CMP_N(u_exe_eq_pfn_01, 3, exe_eq_pfn_01, ld_paddr_0_pfn, exe_st_paddr1_pfn)
    `CMP_N(u_exe_eq_pfn_10, 3, exe_eq_pfn_10, ld_paddr_1_pfn, exe_st_paddr0_pfn)
    `CMP_N(u_exe_eq_pfn_11, 3, exe_eq_pfn_11, ld_paddr_1_pfn, exe_st_paddr1_pfn)

    wire exe_nand_match_n_00, exe_nand_match_n_01, exe_nand_match_n_10, exe_nand_match_n_11;
    nand2$ u_exe_nm00 (.out(exe_nand_match_n_00), .in0(exe_pre_match_00), .in1(exe_eq_pfn_00));
    nand2$ u_exe_nm01 (.out(exe_nand_match_n_01), .in0(exe_pre_match_01), .in1(exe_eq_pfn_01));
    nand2$ u_exe_nm10 (.out(exe_nand_match_n_10), .in0(exe_pre_match_10), .in1(exe_eq_pfn_10));
    nand2$ u_exe_nm11 (.out(exe_nand_match_n_11), .in0(exe_pre_match_11), .in1(exe_eq_pfn_11));

    wire exe_any_match;
    nand4$ u_exe_any (.out(exe_any_match),
        .in0(exe_nand_match_n_00), .in1(exe_nand_match_n_01),
        .in2(exe_nand_match_n_10), .in3(exe_nand_match_n_11));

    wire exe_dep_stall_n;
    nand2$ u_exe_dep_n (.out(exe_dep_stall_n), .in0(exe_any_match), .in1(exe_gate));

    // ----------------------------------------------------------------
    // WB stage
    // ----------------------------------------------------------------
    wire wb_eq_off_00, wb_eq_off_01, wb_eq_off_10, wb_eq_off_11;
    `CMP_N(u_wb_eq_off_00, 8, wb_eq_off_00, ld_paddr_0_offset, wb_st_paddr0_offset)
    `CMP_N(u_wb_eq_off_01, 8, wb_eq_off_01, ld_paddr_0_offset, wb_st_paddr1_offset)
    `CMP_N(u_wb_eq_off_10, 8, wb_eq_off_10, ld_paddr_1_offset, wb_st_paddr0_offset)
    `CMP_N(u_wb_eq_off_11, 8, wb_eq_off_11, ld_paddr_1_offset, wb_st_paddr1_offset)

    wire wb_pre_match_00, wb_pre_match_01, wb_pre_match_10, wb_pre_match_11;
    assign wb_pre_match_00 = wb_eq_off_00;
    `AND_2(u_wb_pm01, 1, wb_pre_match_01, wb_eq_off_01, wb_ST_XCL)
    `AND_2(u_wb_pm10, 1, wb_pre_match_10, wb_eq_off_10, LD_XCL)
    `AND_2(u_wb_pm11, 1, wb_pre_match_11, wb_eq_off_11, wb_xcl_both)

    wire wb_eq_pfn_00, wb_eq_pfn_01, wb_eq_pfn_10, wb_eq_pfn_11;
    `CMP_N(u_wb_eq_pfn_00, 3, wb_eq_pfn_00, ld_paddr_0_pfn, wb_st_paddr0_pfn)
    `CMP_N(u_wb_eq_pfn_01, 3, wb_eq_pfn_01, ld_paddr_0_pfn, wb_st_paddr1_pfn)
    `CMP_N(u_wb_eq_pfn_10, 3, wb_eq_pfn_10, ld_paddr_1_pfn, wb_st_paddr0_pfn)
    `CMP_N(u_wb_eq_pfn_11, 3, wb_eq_pfn_11, ld_paddr_1_pfn, wb_st_paddr1_pfn)

    wire wb_nand_match_n_00, wb_nand_match_n_01, wb_nand_match_n_10, wb_nand_match_n_11;
    nand2$ u_wb_nm00 (.out(wb_nand_match_n_00), .in0(wb_pre_match_00), .in1(wb_eq_pfn_00));
    nand2$ u_wb_nm01 (.out(wb_nand_match_n_01), .in0(wb_pre_match_01), .in1(wb_eq_pfn_01));
    nand2$ u_wb_nm10 (.out(wb_nand_match_n_10), .in0(wb_pre_match_10), .in1(wb_eq_pfn_10));
    nand2$ u_wb_nm11 (.out(wb_nand_match_n_11), .in0(wb_pre_match_11), .in1(wb_eq_pfn_11));

    wire wb_any_match;
    nand4$ u_wb_any (.out(wb_any_match),
        .in0(wb_nand_match_n_00), .in1(wb_nand_match_n_01),
        .in2(wb_nand_match_n_10), .in3(wb_nand_match_n_11));

    wire wb_dep_stall_n;
    nand2$ u_wb_dep_n (.out(wb_dep_stall_n), .in0(wb_any_match), .in1(wb_gate));

    // ----------------------------------------------------------------
    // Final reduction: NAND_3 of three active-low stage signals.
    //   in_flight_mem_stall = NAND3(mem_dep_stall_n, exe_dep_stall_n,
    //                               wb_dep_stall_n)
    //                       = OR over stages of (any_match & gate)  by DeMorgan.
    // ----------------------------------------------------------------
    nand3$ u_in_flight_mem_stall (.out(in_flight_mem_stall),
        .in0(mem_dep_stall_n), .in1(exe_dep_stall_n), .in2(wb_dep_stall_n));

endmodule
