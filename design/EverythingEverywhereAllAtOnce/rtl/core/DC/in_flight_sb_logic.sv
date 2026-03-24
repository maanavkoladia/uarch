import common_pkg::*;

module in_flight_sb_logic(

    input p_address_t st_paddr_0,
    input p_address_t st_paddr_1,
    input bool ST_XCL,
    input bool ST_OP,
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


    bool mem_dep0;
    bool mem_dep1;
    bool mem_dep_stall;
    assign mem_dep0 = (st_paddr_0 == mem_st_paddr0) & mem_ST_OP;
    assign mem_dep1 = (st_paddr_1 == mem_st_paddr1) & mem_ST_OP & mem_ST_XCL;
    assign mem_dep_stall = mem_valid & (mem_dep0 | mem_dep1);


    bool exe_dep0;
    bool exe_dep1;
    bool exe_dep_stall;
    assign exe_dep0 = (st_paddr_0 == exe_st_paddr0) & exe_ST_OP;
    assign exe_dep1 = (st_paddr_1 == exe_st_paddr1) & exe_ST_OP & exe_ST_XCL;
    assign exe_dep_stall = exe_valid & (exe_dep0 | exe_dep1);


    bool wb_dep0;
    bool wb_dep1;
    bool wb_dep_stall;
    assign wb_dep0 = (st_paddr_0 == wb_st_paddr0) & wb_ST_OP;
    assign wb_dep1 = (st_paddr_1 == wb_st_paddr1) & wb_ST_OP & wb_ST_XCL;
    assign wb_dep_stall = wb_valid & (wb_dep0 | wb_dep1);


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
    assign mem_addr0_eq = (st_paddr_0 == mem_st_paddr0);
    assign mem_addr1_eq = (st_paddr_1 == mem_st_paddr1);

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
    assign exe_addr0_eq = (st_paddr_0 == exe_st_paddr0);
    assign exe_addr1_eq = (st_paddr_1 == exe_st_paddr1);

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
    assign wb_addr0_eq = (st_paddr_0 == wb_st_paddr0);
    assign wb_addr1_eq = (st_paddr_1 == wb_st_paddr1);

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