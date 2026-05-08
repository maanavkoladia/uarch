import common_pkg::*;

// ----------------------------------------------------------------
// in_flight_sb_logic -- SystemVerilog reference (sim/lint).
//
// Split into pre-TLB offset compares (8-bit) and post-TLB pfn
// compares (3-bit) so the post-TLB critical path is short. The
// structural Verilog 2005 port at
// rtl/core/DC/structural/in_flight_sb_logic.v is the synthesis
// authoritative; this file mirrors its port shape and behavior.
//
// Address split:
//   *_paddr_*_offset[7:0] = paddr[11:4]   (pre-TLB on the load side)
//   *_paddr_*_pfn[2:0]    = paddr[14:12]  (post-TLB on the load side)
//   paddr[3:0] (intra-line) is not compared.
// ----------------------------------------------------------------
module in_flight_sb_logic(

    input  logic [7:0] ld_paddr_0_offset,
    input  logic [2:0] ld_paddr_0_pfn,
    input  logic [7:0] ld_paddr_1_offset,
    input  logic [2:0] ld_paddr_1_pfn,
    input  bool        LD_XCL,
    input  bool        LD_OP,
    input              valid,

    input  logic [7:0] mem_st_paddr0_offset,
    input  logic [2:0] mem_st_paddr0_pfn,
    input  logic [7:0] mem_st_paddr1_offset,
    input  logic [2:0] mem_st_paddr1_pfn,
    input  bool        mem_ST_OP,
    input  bool        mem_ST_XCL,
    input  bool        mem_valid,

    input  logic [7:0] exe_st_paddr0_offset,
    input  logic [2:0] exe_st_paddr0_pfn,
    input  logic [7:0] exe_st_paddr1_offset,
    input  logic [2:0] exe_st_paddr1_pfn,
    input  bool        exe_ST_OP,
    input  bool        exe_ST_XCL,
    input  bool        exe_valid,

    input  logic [7:0] wb_st_paddr0_offset,
    input  logic [2:0] wb_st_paddr0_pfn,
    input  logic [7:0] wb_st_paddr1_offset,
    input  logic [2:0] wb_st_paddr1_pfn,
    input  bool        wb_ST_OP,
    input  bool        wb_ST_XCL,
    input  bool        wb_valid,

    output bool        in_flight_mem_stall
);

    // MEM stage
    bool mem_match_ld0_st0, mem_match_ld0_st1, mem_match_ld1_st0, mem_match_ld1_st1;
    bool mem_dep_stall;
    assign mem_match_ld0_st0 = (ld_paddr_0_offset == mem_st_paddr0_offset)
                             & (ld_paddr_0_pfn    == mem_st_paddr0_pfn);
    assign mem_match_ld0_st1 = (ld_paddr_0_offset == mem_st_paddr1_offset)
                             & (ld_paddr_0_pfn    == mem_st_paddr1_pfn) & mem_ST_XCL;
    assign mem_match_ld1_st0 = (ld_paddr_1_offset == mem_st_paddr0_offset)
                             & (ld_paddr_1_pfn    == mem_st_paddr0_pfn) & LD_XCL;
    assign mem_match_ld1_st1 = (ld_paddr_1_offset == mem_st_paddr1_offset)
                             & (ld_paddr_1_pfn    == mem_st_paddr1_pfn) & LD_XCL & mem_ST_XCL;
    assign mem_dep_stall = mem_valid & mem_ST_OP & LD_OP &
                           (mem_match_ld0_st0 | mem_match_ld0_st1 |
                            mem_match_ld1_st0 | mem_match_ld1_st1);

    // EXE stage
    bool exe_match_ld0_st0, exe_match_ld0_st1, exe_match_ld1_st0, exe_match_ld1_st1;
    bool exe_dep_stall;
    assign exe_match_ld0_st0 = (ld_paddr_0_offset == exe_st_paddr0_offset)
                             & (ld_paddr_0_pfn    == exe_st_paddr0_pfn);
    assign exe_match_ld0_st1 = (ld_paddr_0_offset == exe_st_paddr1_offset)
                             & (ld_paddr_0_pfn    == exe_st_paddr1_pfn) & exe_ST_XCL;
    assign exe_match_ld1_st0 = (ld_paddr_1_offset == exe_st_paddr0_offset)
                             & (ld_paddr_1_pfn    == exe_st_paddr0_pfn) & LD_XCL;
    assign exe_match_ld1_st1 = (ld_paddr_1_offset == exe_st_paddr1_offset)
                             & (ld_paddr_1_pfn    == exe_st_paddr1_pfn) & LD_XCL & exe_ST_XCL;
    assign exe_dep_stall = exe_valid & exe_ST_OP & LD_OP &
                           (exe_match_ld0_st0 | exe_match_ld0_st1 |
                            exe_match_ld1_st0 | exe_match_ld1_st1);

    // WB stage
    bool wb_match_ld0_st0, wb_match_ld0_st1, wb_match_ld1_st0, wb_match_ld1_st1;
    bool wb_dep_stall;
    assign wb_match_ld0_st0 = (ld_paddr_0_offset == wb_st_paddr0_offset)
                            & (ld_paddr_0_pfn    == wb_st_paddr0_pfn);
    assign wb_match_ld0_st1 = (ld_paddr_0_offset == wb_st_paddr1_offset)
                            & (ld_paddr_0_pfn    == wb_st_paddr1_pfn) & wb_ST_XCL;
    assign wb_match_ld1_st0 = (ld_paddr_1_offset == wb_st_paddr0_offset)
                            & (ld_paddr_1_pfn    == wb_st_paddr0_pfn) & LD_XCL;
    assign wb_match_ld1_st1 = (ld_paddr_1_offset == wb_st_paddr1_offset)
                            & (ld_paddr_1_pfn    == wb_st_paddr1_pfn) & LD_XCL & wb_ST_XCL;
    assign wb_dep_stall = wb_valid & wb_ST_OP & LD_OP &
                          (wb_match_ld0_st0 | wb_match_ld0_st1 |
                           wb_match_ld1_st0 | wb_match_ld1_st1);

    assign in_flight_mem_stall = (mem_dep_stall | exe_dep_stall | wb_dep_stall) & valid;

endmodule
