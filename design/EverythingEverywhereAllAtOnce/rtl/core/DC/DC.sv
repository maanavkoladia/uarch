import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;

module DC (
    input wire clk,
    input wire rst,

    //stage latches
    input dc_latches_t latches_i,  //assumign load input is not cache aligned

    input fetch_outputs_t fetch_outs_i,
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
    bool exp_stall;
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

    assign arb_stall = ((req_rejected_mio & ld_neuralnet_out.mio & latches_i.cs.LD_OP) 
                            | (req_rejected_0 & latches_i.cs.LD_OP)
                            | (req_rejected_1 & latches_i.cs.LD_OP & ld_neuralnet_out.xcl)
                        ) & latches_i.valid;

    assign exp_stall = (ld_neuralnet_out.DC_PF | ld_neuralnet_out.DC_GP 
                       |  st_neuralnet_out.DC_PF | st_neuralnet_out.DC_GP) 
                       & latches_i.valid;
                       

    assign dc_stall = dep_stall | arb_stall | exp_stall;


    // Check for load-store dependencies: DC's LOAD addresses vs in-flight STORE addresses
    in_flight_sb_logic in_flight_dep_check (
        .ld_paddr_0(ld_neuralnet_out.PADDR0),
        .ld_paddr_1(ld_neuralnet_out.PADDR1),
        .LD_XCL(ld_neuralnet_out.xcl),
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
        .ld_paddr_0(ld_neuralnet_out.PADDR0),
        .ld_paddr_1(ld_neuralnet_out.PADDR1),
        .LD_OP(latches_i.cs.LD_OP),
        .LD_XCL(ld_neuralnet_out.xcl),
        .stq_info(wb_outs_i.dep_check),
        .stall(stq_stall)
    );

    // Generate load request outputs
    req_gen_logic req_gen (
        .valid(latches_i.valid),
        .LD_OP(latches_i.cs.LD_OP),
        .XCL(ld_neuralnet_out.xcl),
        .dep_stall(dep_stall),
        .MIO(ld_neuralnet_out.mio),
        .ld_addr0(ld_neuralnet_out.PADDR0),
        .ld_addr1(ld_neuralnet_out.PADDR1),
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
        .data_size(latches_i.cs.datasize),
        .upper8(latches_i.cs.upper8),
        .ST_OP(latches_i.cs.ST_OP),
        .LD_OP(latches_i.cs.LD_OP),
        .rh_into_mem_o(rh_into_mem_o),
        .mem_into_rh_o(mem_into_rh_o),
        .data_size_vec_o(data_size_vec)
    );

    npu_node2_outputs_t ld_neuralnet_out, st_neuralnet_out;
    npu_node2 ld_neuralnet_part2(
        .vaddy_start(latches_i.ld_vaddy),
        .seg_limit_w_datasize(latches_i.seg0_limit_w_datasize),
        .next_page_vaddy(latches_i.next_ld_vaddy),
        .datasize(latches_i.cs.datasize),
        .write_intent(1'b0),
        .mem_op(latches_i.cs.LD_OP),
        .rr_gp(latches_i.rr_gp),
        .outputs(ld_neuralnet_out)
    );

    npu_node2 st_neuralnet_part2(
        .vaddy_start(latches_i.st_vaddy),
        .seg_limit_w_datasize(latches_i.seg1_limit_w_datasize),
        .next_page_vaddy(latches_i.next_st_vaddy),
        .datasize(latches_i.cs.datasize),
        .write_intent(latches_i.cs.ST_OP),
        .mem_op(latches_i.cs.ST_OP),
        .rr_gp(latches_i.rr_gp),
        .outputs(st_neuralnet_out)
    );



    assign dc_outs_o = '{
            valid: latches_i.valid,
            stall: dc_stall,
            exp_pf: ld_neuralnet_out.DC_PF | st_neuralnet_out.DC_PF,
            exp_present: exp_stall,
            ld_addr_0_V: ld_addr_0_V,
            ld_addr_0: ld_addr_0,
            ld_addr_1_V: ld_addr_1_V,
            ld_addr_1: ld_addr_1,
            //mio sent to mio block not arbitration.. I think 
            ld_addr_MIO_V :
            (
            ld_neuralnet_out.mio & latches_i.cs.LD_OP & ~dep_stall
            ),
            ld_addr_MIO : ld_addr_0,
            mem_stage_latch_we : mem_stage_we_valid_unit_o
        };

    //need to add valid logic once this is gened 
    

    assign mem_latches_next_o = '{
            valid: mem_stage_next_vaild_o & ~fetch_outs_i.exp_pipe_clear,
            cs: latches_i.mem_cs,
            exe_cs: latches_i.exe_cs,
            wb_cs: latches_i.wb_cs,
            br_info: latches_i.br_info,
            data_size_vec: data_size_vec,
            rh_into_mem: rh_into_mem_o,
            mem_into_rh: mem_into_rh_o,
            ST_XCL: st_neuralnet_out.xcl,
            ST_PADDR_0: st_neuralnet_out.PADDR0,
            ST_PADDR_1: st_neuralnet_out.PADDR1,
            MIO: ld_neuralnet_out.mio,  //i think we decided that only need ld location MIO (i think)
            NEIP: latches_i.NEIP,
            EIP: latches_i.EIP,
            EAX: latches_i.EAX,
            imm64: latches_i.imm64,
            sr_id: latches_i.sr_id,
            sr_data: latches_i.sr_data,
            dr_id: latches_i.dr_id,
            dr_data: latches_i.dr_data,
            LD_XCL: ld_neuralnet_out.xcl,
            swapLines: ld_neuralnet_out.bank_hi,
            LD_PADDR_0: ld_neuralnet_out.PADDR0,
            LD_PADDR_1: ld_neuralnet_out.PADDR1

        };

endmodule
