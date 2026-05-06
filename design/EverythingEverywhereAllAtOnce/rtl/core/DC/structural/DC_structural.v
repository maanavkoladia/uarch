// ----------------------------------------------------------------
// DC_structural -- top-level DC stage that wires up structural leaves.
//
// Module signature is unchanged from rtl/core/DC/DC.sv: the boundary
// keeps SV struct ports (latches_i, *_outs_i, dc_outs_o, ...).  Inside,
// the structural leaf modules are instantiated.  For modules where the
// .v structural version has the same port list as the .sv reference
// (segx, data_size_vec_logic, push_address_gen, req_gen_logic), the
// instantiation is textually identical -- the build system picks the
// .v file when DC_structural is compiled.  For wb_stq_sb_logic the .v
// flattens the stq_info struct port into 32 individual scalar ports,
// so the instantiation here unpacks wb_outs_i.dep_check.entries[]
// directly via hierarchical references.
//
// Modules still pulled in unchanged from .sv (not yet ported):
//   in_flight_sb_logic, npu_node2
// Already structural (auto-generated): mem_valid_logic
// ----------------------------------------------------------------
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import common_pkg::*;
import DC_pkg::*;

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
    input bool req_served_0, req_served_1,

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

    assign dc_ST_OP  = latches_i.cs.ST_OP;
    assign mem_ST_OP = mem_outs_i.ST_OP;
    assign exe_ST_OP = exe_outs_i.ST_OP;
    assign wb_ST_OP  = wb_outs_i.ST_OP;


    p_address_t next_st_addr_0;
    p_address_t next_st_addr_1;
    bool next_st_xcl;

    bool ld_exception, st_exception, rr_exception;
    bool ld_segx_gp, st_segx_gp;

    // dep_stall = in_flight_stall | stq_stall
    `OR_2(u_dep_stall, 1, dep_stall, in_flight_stall, stq_stall)

    // ld_exception = (ld.DC_PF | ld.DC_GP | ld_segx_gp) & LD_OP
    wire ld_exp_or;
    `OR_3 (u_ld_exp_or,    1, ld_exp_or,
           ld_neuralnet_out.DC_PF, ld_neuralnet_out.DC_GP, ld_segx_gp)
    `AND_2(u_ld_exception, 1, ld_exception, ld_exp_or, latches_i.cs.LD_OP)

    // st_exception = (st.DC_PF | st.DC_GP | st_segx_gp) & ST_OP
    wire st_exp_or;
    `OR_3 (u_st_exp_or,    1, st_exp_or,
           st_neuralnet_out.DC_PF, st_neuralnet_out.DC_GP, st_segx_gp)
    `AND_2(u_st_exception, 1, st_exception, st_exp_or, latches_i.cs.ST_OP)

    // rr_exception = latches_i.rr_gp  (wire alias)
    assign rr_exception = latches_i.rr_gp;

    // exp_stall = (ld_excep | st_excep | rr_excep) & latches_i.valid & ~flush
    wire exp_or;
    wire not_flush;
    `OR_3 (u_exp_or,    1, exp_or,
           ld_exception, st_exception, rr_exception)
    `INV_N(u_not_flush, 1, exe_outs_i.br_res_out.flush, not_flush)
    `AND_3(u_exp_stall, 1, exp_stall, exp_or, latches_i.valid, not_flush)

    // dc_stall = dep_stall | arb_stall | exp_stall
    `OR_3(u_dc_stall, 1, dc_stall, dep_stall, arb_stall, exp_stall)


    // Check for load-store dependencies: DC's LOAD addresses vs in-flight STORE addresses
    // (still .sv -- not yet ported)
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

    // Check for dependencies in store queues (structural -- flat ports).
    // Unpack wb_outs_i.dep_check.entries[16] {.address, .valid} into 32
    // individual scalar ports on the instance.
    wb_stq_sb_logic stq_dep_check (
        .valid(latches_i.valid),
        .ld_paddr_0(ld_neuralnet_out.PADDR0),
        .ld_paddr_1(ld_neuralnet_out.PADDR1),
        .LD_OP(latches_i.cs.LD_OP),
        .LD_XCL(ld_neuralnet_out.xcl),

        .stq_addr_0 (wb_outs_i.dep_check.entries[0].address),
        .stq_addr_1 (wb_outs_i.dep_check.entries[1].address),
        .stq_addr_2 (wb_outs_i.dep_check.entries[2].address),
        .stq_addr_3 (wb_outs_i.dep_check.entries[3].address),
        .stq_addr_4 (wb_outs_i.dep_check.entries[4].address),
        .stq_addr_5 (wb_outs_i.dep_check.entries[5].address),
        .stq_addr_6 (wb_outs_i.dep_check.entries[6].address),
        .stq_addr_7 (wb_outs_i.dep_check.entries[7].address),
        .stq_addr_8 (wb_outs_i.dep_check.entries[8].address),
        .stq_addr_9 (wb_outs_i.dep_check.entries[9].address),
        .stq_addr_10(wb_outs_i.dep_check.entries[10].address),
        .stq_addr_11(wb_outs_i.dep_check.entries[11].address),
        .stq_addr_12(wb_outs_i.dep_check.entries[12].address),
        .stq_addr_13(wb_outs_i.dep_check.entries[13].address),
        .stq_addr_14(wb_outs_i.dep_check.entries[14].address),
        .stq_addr_15(wb_outs_i.dep_check.entries[15].address),

        .stq_valid_0 (wb_outs_i.dep_check.entries[0].valid),
        .stq_valid_1 (wb_outs_i.dep_check.entries[1].valid),
        .stq_valid_2 (wb_outs_i.dep_check.entries[2].valid),
        .stq_valid_3 (wb_outs_i.dep_check.entries[3].valid),
        .stq_valid_4 (wb_outs_i.dep_check.entries[4].valid),
        .stq_valid_5 (wb_outs_i.dep_check.entries[5].valid),
        .stq_valid_6 (wb_outs_i.dep_check.entries[6].valid),
        .stq_valid_7 (wb_outs_i.dep_check.entries[7].valid),
        .stq_valid_8 (wb_outs_i.dep_check.entries[8].valid),
        .stq_valid_9 (wb_outs_i.dep_check.entries[9].valid),
        .stq_valid_10(wb_outs_i.dep_check.entries[10].valid),
        .stq_valid_11(wb_outs_i.dep_check.entries[11].valid),
        .stq_valid_12(wb_outs_i.dep_check.entries[12].valid),
        .stq_valid_13(wb_outs_i.dep_check.entries[13].valid),
        .stq_valid_14(wb_outs_i.dep_check.entries[14].valid),
        .stq_valid_15(wb_outs_i.dep_check.entries[15].valid),

        .stall(stq_stall)
    );

    // Generate load request outputs (structural)
    req_gen_logic req_gen (
        .clk(clk),
        .rst(rst),
        .flush(exe_outs_i.br_res_out.flush),
        .valid(latches_i.valid),
        .LD_OP(latches_i.cs.LD_OP),
        .XCL(ld_neuralnet_out.xcl),
        .dep_stall(dep_stall),
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


    // Already structural (auto-generated csv2rtl): rtl/core/DC/gen/mem_valid_logic.v
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

    // Structural
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

    // npu_node2 still .sv (not yet ported)
    // npu_node2 (structural .v) has flat-port outputs.  Capture them into
    // local wires per-instance and then repack into the SV struct vars
    // ld_neuralnet_out / st_neuralnet_out so the rest of this module
    // (which references struct fields) stays unchanged.
    wire        ld_npu_DC_PF, ld_npu_DC_GP, ld_npu_valid_mem_op;
    wire        ld_npu_bank_hi, ld_npu_xcl, ld_npu_mio;
    wire [14:0] ld_npu_PADDR0, ld_npu_PADDR1;

    wire        st_npu_DC_PF, st_npu_DC_GP, st_npu_valid_mem_op;
    wire        st_npu_bank_hi, st_npu_xcl, st_npu_mio;
    wire [14:0] st_npu_PADDR0, st_npu_PADDR1;

    npu_node2_outputs_t ld_neuralnet_out, st_neuralnet_out;

    npu_node2 ld_neuralnet_part2(
        .vaddy_start    (latches_i.ld_vaddy),
        .next_page_vaddy(latches_i.next_ld_vaddy),
        .datasize       (latches_i.cs.datasize),
        .write_intent   (1'b0),
        .mem_op         (latches_i.cs.LD_OP),
        .stack_access   (latches_i.ld_stack_access),
        .DC_PF          (ld_npu_DC_PF),
        .DC_GP          (ld_npu_DC_GP),
        .valid_mem_op   (ld_npu_valid_mem_op),
        .PADDR1         (ld_npu_PADDR1),
        .bank_hi        (ld_npu_bank_hi),
        .xcl            (ld_npu_xcl),
        .PADDR0         (ld_npu_PADDR0),
        .mio            (ld_npu_mio)
    );

    npu_node2 st_neuralnet_part2(
        .vaddy_start    (latches_i.st_vaddy),
        .next_page_vaddy(latches_i.next_st_vaddy),
        .datasize       (latches_i.cs.datasize),
        .write_intent   (latches_i.cs.ST_OP),
        .mem_op         (latches_i.cs.ST_OP),
        .stack_access   (latches_i.st_stack_access),
        .DC_PF          (st_npu_DC_PF),
        .DC_GP          (st_npu_DC_GP),
        .valid_mem_op   (st_npu_valid_mem_op),
        .PADDR1         (st_npu_PADDR1),
        .bank_hi        (st_npu_bank_hi),
        .xcl            (st_npu_xcl),
        .PADDR0         (st_npu_PADDR0),
        .mio            (st_npu_mio)
    );

    // Repack flat outputs into the SV struct vars used by downstream
    // references in this module.
    assign ld_neuralnet_out = '{
            DC_PF        : ld_npu_DC_PF,
            DC_GP        : ld_npu_DC_GP,
            valid_mem_op : ld_npu_valid_mem_op,
            PADDR1       : ld_npu_PADDR1,
            bank_hi      : ld_npu_bank_hi,
            xcl          : ld_npu_xcl,
            PADDR0       : ld_npu_PADDR0,
            mio          : ld_npu_mio
        };

    assign st_neuralnet_out = '{
            DC_PF        : st_npu_DC_PF,
            DC_GP        : st_npu_DC_GP,
            valid_mem_op : st_npu_valid_mem_op,
            PADDR1       : st_npu_PADDR1,
            bank_hi      : st_npu_bank_hi,
            xcl          : st_npu_xcl,
            PADDR0       : st_npu_PADDR0,
            mio          : st_npu_mio
        };

    // Structural
    segx ld_segx(
        .laddy(latches_i.ld_laddy),
        .seg_limit(latches_i.seg0_limit_wo_datasize),
        .seg_limit_w_datasize(latches_i.seg0_limit_w_datasize),
        .stack_access(latches_i.ld_stack_access),
        .segx_gp(ld_segx_gp)
    );

    segx st_segx(
        .laddy(latches_i.st_laddy),
        .seg_limit(latches_i.seg1_limit_wo_datasize),
        .seg_limit_w_datasize(latches_i.seg1_limit_w_datasize),
        .stack_access(latches_i.st_stack_access),
        .segx_gp(st_segx_gp)
    );

    // Structural
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



    // dc_outs_o.exp_pf = ld.DC_PF | st.DC_PF
    wire dc_outs_exp_pf;
    `OR_2(u_dc_exp_pf, 1, dc_outs_exp_pf,
          ld_neuralnet_out.DC_PF, st_neuralnet_out.DC_PF)

    assign dc_outs_o = '{
            valid: latches_i.valid,
            dc_eip: latches_i.EIP,
            stall: dc_stall,
            exp_pf: dc_outs_exp_pf,
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

    // mem_latches_next_o.valid = mem_stage_next_vaild_o & ~fetch_outs_i.exp_pipe_clear
    wire not_exp_pipe_clear;
    wire mem_latches_valid_w;
    `INV_N(u_not_exp_pipe_clear, 1, fetch_outs_i.exp_pipe_clear, not_exp_pipe_clear)
    `AND_2(u_mem_latches_valid,  1, mem_latches_valid_w,
           mem_stage_next_vaild_o, not_exp_pipe_clear)

    assign mem_latches_next_o = '{
            valid: mem_latches_valid_w,
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
