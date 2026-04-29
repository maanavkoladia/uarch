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

    input bool req_served_mio,
    input bool req_served_0,
    input bool req_served_1,


    output mem_latches_t mem_latches_next_o,

    output dc_outputs_t dc_outs_o

);

    bool mem_stage_we_valid_unit_o;
    bool mem_stage_next_vaild_o;

    bool in_flight_stall;
    bool stq_stall;
    bool dep_stall;
    bool arb_stall;
    bool exp_stall;
    bool dc_stall;


    bool ld_addr_0_V;
    bool ld_addr_1_V;
    bool ld_addr_mio_V;
    p_address_t ld_addr_0;
    p_address_t ld_addr_1;
    p_address_t ld_addr_mio;

    bool shift_sr_up;
    bool shift_sr_down;
    logic [3:0] data_size_vec;
    logic [3:0] sr_data_size_vec;

    // Derive ST_OP signals (store operation present)
    bool dc_ST_OP;
    bool mem_ST_OP;
    bool exe_ST_OP;
    bool wb_ST_OP;

    assign dc_ST_OP = latches_i.cs.ST_OP;
    assign mem_ST_OP = mem_outs_i.ST_OP;
    assign exe_ST_OP = exe_outs_i.ST_OP;
    assign wb_ST_OP = wb_outs_i.ST_OP;


    p_address_t next_st_addr_0;
    p_address_t next_st_addr_1;
    bool next_st_xcl;

    //in store flight and stq stall logic accounts for valid bits
    assign dep_stall = in_flight_stall | stq_stall;

    bool ld_exception, st_exception, rr_exception;

    bool ld_segx_gp, st_segx_gp;

    assign ld_exception = (ld_neuralnet_out.DC_PF | ld_neuralnet_out.DC_GP | ld_segx_gp) && latches_i.cs.LD_OP;
    assign st_exception = (st_neuralnet_out.DC_PF | st_neuralnet_out.DC_GP | st_segx_gp) && latches_i.cs.ST_OP;
    assign rr_exception = latches_i.rr_gp;
    assign exp_stall = (ld_exception | st_exception | rr_exception) & latches_i.valid & ~exe_outs_i.br_res_out.flush; 
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
        .clk(clk),
        .rst(rst),
        .flush(exe_outs_i.br_res_out.flush),
        .valid(latches_i.valid),
        .LD_OP(latches_i.cs.LD_OP),
        .XCL(ld_neuralnet_out.xcl),
        .dep_stall(dep_stall),
        .exp_stall(exp_stall),
        .MIO(ld_neuralnet_out.mio),
        .ld_addr0(ld_neuralnet_out.PADDR0),
        .ld_addr1(ld_neuralnet_out.PADDR1),
        .ld_addrMIO(ld_neuralnet_out.PADDR1),
        .req_served_0(req_served_0),
        .req_served_1(req_served_1),
        .req_served_mio(req_served_mio),
        .mem_stage_we_valid_unit_o(mem_stage_we_valid_unit_o),
        .mem_stage_next_valid_o(mem_stage_next_vaild_o),
        .ld_addr_0_V(ld_addr_0_V),
        .ld_addr_1_V(ld_addr_1_V),
        .ld_addr_mio_V(ld_addr_mio_V),
        .ld_addr_mio(ld_addr_mio),
        .ld_addr_0(ld_addr_0),
        .ld_addr_1(ld_addr_1),
        .arb_stall(arb_stall)
    );


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
        .dr_upper8(latches_i.cs.dr_upper8),
        .sr_upper8(latches_i.cs.sr_upper8),
        .ST_OP(latches_i.cs.ST_OP),
        .LD_OP(latches_i.cs.LD_OP),
        .wb_sr(latches_i.wb_cs.WB_SR),
        .wb_eax(latches_i.wb_cs.WB_EAX),
        .shift_sr_up(shift_sr_up),
        .shift_sr_down(shift_sr_down),
        .data_size_vec_o(data_size_vec),
        .sr_data_size_vec_o(sr_data_size_vec)
    );

    npu_node2_outputs_t ld_neuralnet_out, st_neuralnet_out;
    npu_node2 ld_neuralnet_part2(
        .vaddy_start(latches_i.ld_vaddy),
        .next_page_vaddy(latches_i.next_ld_vaddy),
        .datasize(latches_i.cs.datasize),
        .write_intent(1'b0),
        .mem_op(latches_i.cs.LD_OP),
        .outputs(ld_neuralnet_out)
    );

    npu_node2 st_neuralnet_part2(
        .vaddy_start(latches_i.st_vaddy),
        .next_page_vaddy(latches_i.next_st_vaddy),
        .datasize(latches_i.cs.datasize),
        .write_intent(latches_i.cs.ST_OP),
        .mem_op(latches_i.cs.ST_OP),
        .outputs(st_neuralnet_out)
    );

    segx ld_segx(
        .laddy(latches_i.ld_laddy),
        .seg_limit(latches_i.seg0_limit_wo_datasize),
        .seg_limit_w_datasize(latches_i.seg0_limit_w_datasize),
        .segx_gp(ld_segx_gp)
    );

    segx st_segx(
        .laddy(latches_i.st_laddy),
        .seg_limit(latches_i.seg1_limit_wo_datasize),
        .seg_limit_w_datasize(latches_i.seg1_limit_w_datasize),
        .segx_gp(st_segx_gp)
    );

    push_address_gen push_addr_gen(
        .ST_PADDR_0(st_neuralnet_out.PADDR0),
        .ST_PADDR_1(st_neuralnet_out.PADDR1),
        .ST_XCL(st_neuralnet_out.xcl),
        .data_size(latches_i.cs.datasize),
        .OP_TYPE(latches_i.exe_cs.OP_TYPE),
        .ST_PADDR_0_o(next_st_addr_0),
        .ST_PADDR_1_o(next_st_addr_1),
        .ST_XCL_o(next_st_xcl)
    );



    assign dc_outs_o = '{
            valid: latches_i.valid,
            dc_eip: latches_i.EIP,
            stall: dc_stall,
            exp_pf: ld_neuralnet_out.DC_PF | st_neuralnet_out.DC_PF,
            exp_present: exp_stall,
            ld_addr_0_V: ld_addr_0_V,
            ld_addr_0: ld_addr_0,
            ld_addr_1_V: ld_addr_1_V,
            ld_addr_1: ld_addr_1,
            //mio sent to mio block not arbitration.. I think 
            ld_addr_MIO_V: ld_addr_mio_V,
            ld_addr_MIO: ld_addr_mio,
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
            sr_data_size_vec: sr_data_size_vec,
            shift_sr_down: shift_sr_down,
            shift_sr_up: shift_sr_up,
            ST_XCL: next_st_xcl,
            ST_PADDR_0: next_st_addr_0,
            ST_PADDR_1: next_st_addr_1,
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