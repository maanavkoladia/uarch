
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;

module DC (
    input wire clk,
    input wire rst,

    //stage latches
    input dc_latches_t latches_i,

    //miss stall and valid, inflight store addys
    input mem_outputs_t mem_outs_i,
    input mem_latches_t mem_latches_i,  // ADDED: needed for in-flight dependency checking

    //br flush and valid, infligh store addy
    input exe_outputs_t exe_outs_i,
    input exe_latches_t exe_latches_i,  // ADDED: needed for in-flight dependency checking

    //in flight store addys and stq addys/entries 
    input wb_outputs_t wb_outs_i,
    input wb_latches_t wb_latches_i,    // ADDED: needed for in-flight dependency checking

    output mem_latches_t mem_latches_next_o,

    output dc_outputs_t dc_outs_o

);

 
    wire in_flight_stall;
    wire stq_stall;
    wire dep_stall;
    
    wire ld_addr_0_V;
    wire ld_addr_1_V;
    p_address_t ld_addr_0;
    p_address_t ld_addr_1;

    // Derive ST_OP signals (store operation present)
    wire dc_ST_OP;
    wire mem_ST_OP;
    wire exe_ST_OP;
    wire wb_ST_OP;

    assign dc_ST_OP = latches_i.cs.ST_OP;
    assign mem_ST_OP = mem_latches_i.cs.ST_OP;
    assign exe_ST_OP = exe_latches_i.cs.ST_OP;
    assign wb_ST_OP = wb_latches_i.cs.ST_OP;

    assign dep_stall = in_flight_stall | stq_stall;



    // Check for dependencies on in-flight stores
    in_flight_sb_logic in_flight_dep_check (
        .st_paddr_0(latches_i.ST_PADDR_0),
        .st_paddr_1(latches_i.ST_PADDR_1),
        .ST_XCL(latches_i.ST_XCL),
        .ST_OP(dc_ST_OP),

        .mem_st_paddr0(mem_latches_i.ST_PADDR_0),
        .mem_st_paddr1(mem_latches_i.ST_PADDR_1),
        .mem_ST_OP(mem_ST_OP),
        .mem_ST_XCL(mem_latches_i.ST_XCL),
        .mem_valid(mem_latches_i.valid),

        .exe_st_paddr0(exe_latches_i.ST_PADDR_0),
        .exe_st_paddr1(exe_latches_i.ST_PADDR_1),
        .exe_ST_OP(exe_ST_OP),
        .exe_ST_XCL(exe_latches_i.ST_XCL),
        .exe_valid(exe_latches_i.valid),

        .wb_st_paddr0(wb_latches_i.ST_PADDR_0),
        .wb_st_paddr1(wb_latches_i.ST_PADDR_1),
        .wb_ST_OP(wb_ST_OP),
        .wb_ST_XCL(wb_latches_i.ST_XCL),
        .wb_valid(wb_latches_i.valid),

        .in_flight_mem_stall(in_flight_stall)
    );

    // Check for dependencies in store queues
    wb_stq_sb_logic stq_dep_check (
        .st_paddr_0(latches_i.ST_PADDR_0),
        .st_paddr_1(latches_i.ST_PADDR_1),
        .ST_XCL(latches_i.ST_XCL),
        .ST_OP(dc_ST_OP),
        .stq_info(wb_outs_i.dep_check),
        .stall(stq_stall)
    );

    // Generate load request outputs
    req_gen_logic req_gen (
        .valid(latches_i.valid),
        .LD_OP(latches_i.cs.LD_OP),
        .XCL(latches_i.LD_XCL),
        .dep_stall(dep_stall),
        .ld_addr0(latches_i.LD_PADDR_0),
        .ld_addr1(latches_i.LD_PADDR_1),

        .ld_addr_0_V(ld_addr_0_V),
        .ld_addr_1_V(ld_addr_1_V),
        .ld_addr_0(ld_addr_0),
        .ld_addr_1(ld_addr_1)
    );


    assign dc_outs_o.valid = latches_i.valid;
    assign dc_outs_o.stall = dep_stall;
    assign dc_outs_o.ld_addr_0_V = ld_addr_0_V;
    assign dc_outs_o.ld_addr_0 = ld_addr_0;
    assign dc_outs_o.ld_addr_1_V = ld_addr_1_V;
    assign dc_outs_o.ld_addr_1 = ld_addr_1;

    
    assign mem_latches_next_o = '{
        valid:      latches_i.valid & ~dep_stall,  // FIXME: Also need to handle br flush from exe
        cs:         '{
            MEM_OP: latches_i.cs.DC_OP,
            ST_OP:  latches_i.cs.ST_OP
        },
        br_info:    latches_i.br_info,
        ST_XCL:     latches_i.ST_XCL,
        ST_PADDR_0: latches_i.ST_PADDR_0,
        ST_PADDR_1: latches_i.ST_PADDR_1,
        MIO:        latches_i.MIO,
        NEIP:       latches_i.NEIP,
        imm64:      latches_i.imm64,
        sr_id:      latches_i.sr_id,
        sr_data:    latches_i.sr_data,
        dr_id:      latches_i.dr_id,
        dr_data:    latches_i.dr_data,
        LD_XCL:     latches_i.LD_XCL,
        swapLines:  latches_i.swapLines,
        LD_PADDR_0: latches_i.LD_PADDR_0,
        LD_PADDR_1: latches_i.LD_PADDR_1
    };

endmodule
