import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;

module DC (
    input wire clk,
    input wire rst,

    //stage latches
    input dc_latches_t latches_i,  //assumign load input is not cache aligned

    //miss stall and valid, inflight store addys
    input mem_outputs_t mem_outs_i,

    //br flush and valid, infligh store addy
    input exe_outputs_t exe_outs_i,

    //in flight store addys and stq addys/entries 
    input wb_outputs_t wb_outs_i,

    input bool req_rejected_mio,
    input bool req_rejected_0,
    input bool req_rejected_1,

    output mem_latches_t mem_latches_next_o,

    output dc_outputs_t dc_outs_o

);


    bool in_flight_stall;
    bool stq_stall;
    bool dep_stall;
    bool arb_stall;
    bool dc_stall;


    bool ld_addr_0_V;
    bool ld_addr_1_V;
    p_address_t ld_addr_0;
    p_address_t ld_addr_1;

    bool rh_into_mem_o;
    bool mem_into_rh_o;
    logic [3:0] data_size_vec;

    // Derive ST_OP signals (store operation present)
    bool dc_ST_OP;
    bool mem_ST_OP;
    bool exe_ST_OP;
    bool wb_ST_OP;

    assign dc_ST_OP = latches_i.cs.ST_OP;
    assign mem_ST_OP = mem_outs_i.ST_OP;
    assign exe_ST_OP = exe_outs_i.ST_OP;
    assign wb_ST_OP = wb_outs_i.ST_OP;

    //in store flight and stq stall logic accounts for valid bits
    assign dep_stall = in_flight_stall | stq_stall;

    assign arb_stall = ((req_rejected_mio & latches_i.MIO & latches_i.cs.LD_OP) 
                            | (req_rejected_0 & latches_i.cs.LD_OP)
                            | (req_rejected_1 & latches_i.cs.LD_OP & latches_i.LD_XCL)
                        ) & latches_i.valid;

    assign dc_stall = dep_stall | arb_stall;


    // Check for load-store dependencies: DC's LOAD addresses vs in-flight STORE addresses
    in_flight_sb_logic in_flight_dep_check (
        .ld_paddr_0(latches_i.LD_PADDR_0),
        .ld_paddr_1(latches_i.LD_PADDR_1),
        .LD_XCL(latches_i.LD_XCL),
        .LD_OP(latches_i.cs.LD_OP),
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
        .ld_paddr_0(latches_i.LD_PADDR_0),
        .ld_paddr_1(latches_i.LD_PADDR_1),
        .LD_OP(latches_i.cs.LD_OP),
        .LD_XCL(latches_i.LD_XCL),
        .stq_info(wb_outs_i.dep_check),
        .stall(stq_stall)
    );

    // Generate load request outputs
    req_gen_logic req_gen (
        .valid(latches_i.valid),
        .LD_OP(latches_i.cs.LD_OP),
        .XCL(latches_i.LD_XCL),
        .dep_stall(dep_stall),
        .MIO(latches_i.MIO),
        .ld_addr0(latches_i.LD_PADDR_0),
        .ld_addr1(latches_i.LD_PADDR_1),
        .ld_addr_0_V(ld_addr_0_V),
        .ld_addr_1_V(ld_addr_1_V),
        .ld_addr_0(ld_addr_0),
        .ld_addr_1(ld_addr_1)
    );

    bool mem_stage_we_valid_unit_o;
    bool mem_stage_next_vaild_o;
    mem_valid_logic mem_valid_unit (
        .MEM_we_o(mem_stage_we_valid_unit_o),
        .N_MEM_V_o(mem_stage_next_vaild_o),
        .DC_stall_i(dc_stall),
        .DC_V_i(latches_i.valid),
        .MEM_V_i(mem_outs_i.valid),
        .MEM_stall_i(mem_outs_i.stall),
        .EXE_V_i(exe_outs_i.valid),
        .WB_stall_i(wb_outs_i.wb_stall)
    );

    data_size_vec_logic data_vec_uint(
        .data_size(latches_i.cs.data_size),
        .upper8(latches_i.cs.upper8),
        .ST_OP(latches_i.cs.ST_OP),
        .LD_OP(latches_i.cs.LD_OP),
        .rh_into_mem_o(rh_into_mem_o),
        .mem_into_rh_o(mem_into_rh_o),
        .data_size_vec_o(data_size_vec)
    );



    assign dc_outs_o = '{
            valid: latches_i.valid,
            stall: dc_stall,
            ld_addr_0_V: ld_addr_0_V,
            ld_addr_0: ld_addr_0,
            ld_addr_1_V: ld_addr_1_V,
            ld_addr_1: ld_addr_1,
            //mio sent to mio block not arbitration.. I think 
            ld_addr_MIO_V :
            (
            latches_i.MIO & latches_i.cs.LD_OP & ~dep_stall
            ),
            ld_addr_MIO : ld_addr_0,
            mem_stage_latch_we : mem_stage_we_valid_unit_o
        };

    //need to add valid logic once this is gened 
    

    assign mem_latches_next_o = '{
            valid: mem_stage_next_vaild_o,
            cs: latches_i.mem_cs,
            exe_cs: latches_i.exe_cs,
            wb_cs: latches_i.wb_cs,
            br_info: latches_i.br_info,
            data_size_vec: data_size_vec,
            rh_into_mem: rh_into_mem_o,
            mem_into_rh: mem_into_rh_o,
            ST_XCL: latches_i.ST_XCL,
            ST_PADDR_0: latches_i.ST_PADDR_0,
            ST_PADDR_1: latches_i.ST_PADDR_1,
            MIO: latches_i.MIO,
            NEIP: latches_i.NEIP,
            EIP: latches_i.EIP,
            EAX: latches_i.EAX,
            imm64: latches_i.imm64,
            sr_id: latches_i.sr_id,
            sr_data: latches_i.sr_data,
            dr_id: latches_i.dr_id,
            dr_data: latches_i.dr_data,
            LD_XCL: latches_i.LD_XCL,
            swapLines: latches_i.swapLines,
            LD_PADDR_0: latches_i.LD_PADDR_0,
            LD_PADDR_1: latches_i.LD_PADDR_1

        };

endmodule
