import common_pkg::*;

module in_flight_sb_logic(

    input p_address_t ld_paddr_0,
    input p_address_t ld_paddr_1,
    input bool LD_XCL,
    input bool LD_OP,
    input valid,

    input p_address_t mem_st_paddr0,
    input p_address_t mem_st_paddr1,
    input bool mem_ST_OP,
    input bool mem_ST_XCL,
    input bool mem_valid,

    input p_address_t exe_st_paddr0,
    input p_address_t exe_st_paddr1,
    input bool exe_ST_OP,
    input bool exe_ST_XCL,
    input bool exe_valid,

    input p_address_t wb_st_paddr0,
    input p_address_t wb_st_paddr1,
    input bool wb_ST_OP,
    input bool wb_ST_XCL,
    input bool wb_valid,

    output bool in_flight_mem_stall
);

    //made claude make this very structural

    // MEM stage: Check all combinations of DC's load addresses vs MEM's store addresses
    bool mem_match_ld0_st0, mem_match_ld0_st1, mem_match_ld1_st0, mem_match_ld1_st1;
    bool mem_dep_stall;
    
    //compare addy 0 to addy0 
    //then compare add0 to addy1
    //then see ld1 to st0 and ld1 to st1 and ld_xcl
    assign mem_match_ld0_st0 = (ld_paddr_0 == mem_st_paddr0);
    assign mem_match_ld0_st1 = (ld_paddr_0 == mem_st_paddr1) & mem_ST_XCL;  // Only if MEM has XCL store
    assign mem_match_ld1_st0 = (ld_paddr_1 == mem_st_paddr0) & LD_XCL;      // Only if DC has XCL load
    assign mem_match_ld1_st1 = (ld_paddr_1 == mem_st_paddr1) & LD_XCL & mem_ST_XCL;
    
    assign mem_dep_stall = mem_valid & mem_ST_OP & LD_OP & 
                           (mem_match_ld0_st0 | mem_match_ld0_st1 | mem_match_ld1_st0 | mem_match_ld1_st1);

    // EXE stage: Check all combinations of DC's load addresses vs EXE's store addresses
    bool exe_match_ld0_st0, exe_match_ld0_st1, exe_match_ld1_st0, exe_match_ld1_st1;
    bool exe_dep_stall;
    
    assign exe_match_ld0_st0 = (ld_paddr_0 == exe_st_paddr0);
    assign exe_match_ld0_st1 = (ld_paddr_0 == exe_st_paddr1) & exe_ST_XCL;
    assign exe_match_ld1_st0 = (ld_paddr_1 == exe_st_paddr0) & LD_XCL;
    assign exe_match_ld1_st1 = (ld_paddr_1 == exe_st_paddr1) & LD_XCL & exe_ST_XCL;
    
    assign exe_dep_stall = exe_valid & exe_ST_OP & LD_OP &
                           (exe_match_ld0_st0 | exe_match_ld0_st1 | exe_match_ld1_st0 | exe_match_ld1_st1);

    // WB stage: Check all combinations of DC's load addresses vs WB's store addresses
    bool wb_match_ld0_st0, wb_match_ld0_st1, wb_match_ld1_st0, wb_match_ld1_st1;
    bool wb_dep_stall;
    
    assign wb_match_ld0_st0 = (ld_paddr_0 == wb_st_paddr0);
    assign wb_match_ld0_st1 = (ld_paddr_0 == wb_st_paddr1) & wb_ST_XCL;
    assign wb_match_ld1_st0 = (ld_paddr_1 == wb_st_paddr0) & LD_XCL;
    assign wb_match_ld1_st1 = (ld_paddr_1 == wb_st_paddr1) & LD_XCL & wb_ST_XCL;
    
    assign wb_dep_stall = wb_valid & wb_ST_OP & LD_OP &
                          (wb_match_ld0_st0 | wb_match_ld0_st1 | wb_match_ld1_st0 | wb_match_ld1_st1);

    assign in_flight_mem_stall = (mem_dep_stall | exe_dep_stall | wb_dep_stall) & valid;


    /* STRUCTURAL VERSION (claude)
    //======================================
    // MEM Stage Dependency Check (structural)
    //======================================
    wire mem_addr0_eq;
    wire mem_addr1_eq;
    wire mem_dep0;
    wire mem_dep1;
    wire mem_dep_stall_raw;
    wire mem_dep_stall;

    // Address comparisons (to be replaced with structural comparators)
    assign mem_addr0_eq = (ld_paddr_0 == mem_st_paddr0);
    assign mem_addr1_eq = (ld_paddr_1 == mem_st_paddr1);

    // mem_dep0 = mem_addr0_eq & mem_ST_OP
    and2$ mem_dep0_gate (.out(mem_dep0), .in0(mem_addr0_eq), .in1(mem_ST_OP));

    // mem_dep1 = mem_addr1_eq & mem_ST_OP & mem_ST_XCL
    wire mem_dep1_partial;
    and2$ mem_dep1_gate1 (.out(mem_dep1_partial), .in0(mem_addr1_eq), .in1(mem_ST_OP));
    and2$ mem_dep1_gate2 (.out(mem_dep1), .in0(mem_dep1_partial), .in1(mem_ST_XCL));

    // mem_dep_stall_raw = mem_dep0 | mem_dep1
    or2$ mem_dep_or (.out(mem_dep_stall_raw), .in0(mem_dep0), .in1(mem_dep1));

    // mem_dep_stall = mem_dep_stall_raw & mem_valid
    and2$ mem_valid_gate (.out(mem_dep_stall), .in0(mem_dep_stall_raw), .in1(mem_valid));


    //======================================
    // EXE Stage Dependency Check (structural)
    //======================================
    wire exe_addr0_eq;
    wire exe_addr1_eq;
    wire exe_dep0;
    wire exe_dep1;
    wire exe_dep_stall_raw;
    wire exe_dep_stall;

    // Address comparisons
    assign exe_addr0_eq = (ld_paddr_0 == exe_st_paddr0);
    assign exe_addr1_eq = (ld_paddr_1 == exe_st_paddr1);

    // exe_dep0 = exe_addr0_eq & exe_ST_OP
    and2$ exe_dep0_gate (.out(exe_dep0), .in0(exe_addr0_eq), .in1(exe_ST_OP));

    // exe_dep1 = exe_addr1_eq & exe_ST_OP & exe_ST_XCL
    wire exe_dep1_partial;
    and2$ exe_dep1_gate1 (.out(exe_dep1_partial), .in0(exe_addr1_eq), .in1(exe_ST_OP));
    and2$ exe_dep1_gate2 (.out(exe_dep1), .in0(exe_dep1_partial), .in1(exe_ST_XCL));

    // exe_dep_stall_raw = exe_dep0 | exe_dep1
    or2$ exe_dep_or (.out(exe_dep_stall_raw), .in0(exe_dep0), .in1(exe_dep1));

    // exe_dep_stall = exe_dep_stall_raw & exe_valid
    and2$ exe_valid_gate (.out(exe_dep_stall), .in0(exe_dep_stall_raw), .in1(exe_valid));


    //======================================
    // WB Stage Dependency Check (structural)
    //======================================
    wire wb_addr0_eq;
    wire wb_addr1_eq;
    wire wb_dep0;
    wire wb_dep1;
    wire wb_dep_stall_raw;
    wire wb_dep_stall;

    // Address comparisons
    assign wb_addr0_eq = (ld_paddr_0 == wb_st_paddr0);
    assign wb_addr1_eq = (ld_paddr_1 == wb_st_paddr1);

    // wb_dep0 = wb_addr0_eq & wb_ST_OP
    and2$ wb_dep0_gate (.out(wb_dep0), .in0(wb_addr0_eq), .in1(wb_ST_OP));

    // wb_dep1 = wb_addr1_eq & wb_ST_OP & wb_ST_XCL
    wire wb_dep1_partial;
    and2$ wb_dep1_gate1 (.out(wb_dep1_partial), .in0(wb_addr1_eq), .in1(wb_ST_OP));
    and2$ wb_dep1_gate2 (.out(wb_dep1), .in0(wb_dep1_partial), .in1(wb_ST_XCL));

    // wb_dep_stall_raw = wb_dep0 | wb_dep1
    or2$ wb_dep_or (.out(wb_dep_stall_raw), .in0(wb_dep0), .in1(wb_dep1));

    // wb_dep_stall = wb_dep_stall_raw & wb_valid
    and2$ wb_valid_gate (.out(wb_dep_stall), .in0(wb_dep_stall_raw), .in1(wb_valid));


    //======================================
    // Combine All Stage Dependencies
    //======================================
    // in_flight_mem_stall = mem_dep_stall | exe_dep_stall | wb_dep_stall
    wire partial_stall;
    or2$ stage_or1 (.out(partial_stall), .in0(mem_dep_stall), .in1(exe_dep_stall));
    or2$ stage_or2 (.out(in_flight_mem_stall), .in0(partial_stall), .in1(wb_dep_stall));
    */

endmodule