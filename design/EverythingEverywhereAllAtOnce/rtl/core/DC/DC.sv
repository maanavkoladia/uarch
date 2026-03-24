
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

    //br flush and valid, infligh store addy
    input exe_outputs_t exe_outs_i,

    //in flight store addys and stq addys/entries 
    input wb_outputs_t wb_outs_i,

    input dcache_2_core_t reqs,

    output mem_latches_t mem_latches_next_o,

    output dc_outputs_t dc_outs_o

);

 
    bool in_flight_stall;
    bool stq_stall;
    bool dep_stall;
    bool arb_stall;

    
    bool ld_addr_0_V;
    bool ld_addr_1_V;
    p_address_t ld_addr_0;
    p_address_t ld_addr_1;

    // Derive ST_OP signals (store operation present)
    bool dc_ST_OP;
    bool mem_ST_OP;
    bool exe_ST_OP;
    bool wb_ST_OP;

    assign dc_ST_OP = latches_i.cs.ST_OP;
    assign mem_ST_OP = mem_outs_i.ST_OP;
    assign exe_ST_OP = exe_outs_i.cs.ST_OP;
    assign wb_ST_OP = wb_outs_i.cs.ST_OP;

    //in store flight and stq stall logic accounts for valid bits
    assign dep_stall = in_flight_stall | stq_stall;

    assign arb_stall = ((req.req_rejected_mio & latches_i.MIO) 
                            | (req.req_rejected_0 & latches_i.cs.LD_OP)
                            | (req.req_rejected_1 & latches_i.cs.ST_OP)
                        ) & latches_i.valid;



    // Check for dependencies on in-flight stores
    in_flight_sb_logic in_flight_dep_check (
        .st_paddr_0(latches_i.ST_PADDR_0),
        .st_paddr_1(latches_i.ST_PADDR_1),
        .ST_XCL(latches_i.ST_XCL),
        .ST_OP(dc_ST_OP),
        .valid(latches_i.valid),

        .mem_st_paddr0(mem_outs_i.ST_PADDR_0),
        .mem_st_paddr1(mem_outs_i.ST_PADDR_1),
        .mem_ST_OP(mem_ST_OP),
        .mem_ST_XCL(mem_outs_i.ST_XCL),
        .mem_valid(mem_outs_i.valid),

        .exe_st_paddr0(exe_outs_i.ST_PADDR_0),
        .exe_st_paddr1(exe_outs_i.ST_PADDR_1),
        .exe_ST_OP(exe_ST_OP),
        .exe_ST_XCL(exe_outs_i.ST_XCL),
        .exe_valid(exe_outs_i.valid),

        .wb_st_paddr0(wb_outs_i.ST_PADDR_0),
        .wb_st_paddr1(wb_outs_i.ST_PADDR_1),
        .wb_ST_OP(wb_ST_OP),
        .wb_ST_XCL(wb_outs_i.ST_XCL),
        .wb_valid(wb_outs_i.valid),

        .in_flight_mem_stall(in_flight_stall)
    );

    // Check for dependencies in store queues
    wb_stq_sb_logic stq_dep_check (
        .valid(latches_i.valid),
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


    assign dc_outs_o = '{
        valid:       latches_i.valid,
        stall:       dep_stall | arb_stall,
        ld_addr_0_V: ld_addr_0_V,
        ld_addr_0:   ld_addr_0,
        ld_addr_1_V: ld_addr_1_V,
        ld_addr_1:   ld_addr_1
    };

    
    assign mem_latches_next_o = '{
        valid:      latches_i.valid & ~dep_stall,  // FIXME: Also need to handle br flush from exe
        cs:         latches_i.mem_cs,
        exe_cs:     latches_i.exe_cs,
        wb_cs:      latches_i.wb_cs,
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
