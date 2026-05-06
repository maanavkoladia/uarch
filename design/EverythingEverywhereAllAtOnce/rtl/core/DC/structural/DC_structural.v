// ----------------------------------------------------------------
// DC_structural -- top-level DC stage in pure Verilog-2005.
//
// All SystemVerilog constructs (struct, typedef, enum, package import,
// `bool`/`p_address_t`/`uint*_t`/`reg_ids_e`) have been removed.  Each
// struct field is exposed as a separate flat scalar/vector port whose
// name follows the original `struct.field` path with `.` replaced by
// `_` (e.g. `latches_i.cs.LD_OP` -> `latches_cs_LD_OP`).
//
// Type-to-width mapping used here:
//   bool                       -> 1 bit
//   p_address_t                -> 15 bits ($clog2(PHY_MEM_SIZE=1<<15))
//   v_address_t / l_address_t  -> 32 bits (address_t)
//   uint32_t                   -> 32 bits
//   uint64_t                   -> 64 bits
//   reg_ids_e                  -> 5 bits ($clog2(NUM_REGS=26))
//   exe_cs_operation_type_e    -> 6 bits (matches EXE flat-port convention)
//   source_selector_e          -> 5 bits (matches EXE flat-port convention)
//
// Internal leaf modules already have flat Verilog-2005 ports:
//   in_flight_sb_logic, wb_stq_sb_logic, req_gen_logic, mem_valid_logic,
//   data_size_vec_logic, npu_node2, segx, push_address_gen.
// ----------------------------------------------------------------

module DC (
    input  wire        clk,
    input  wire        rst,

    // ====================================================================
    // dc_latches_t  (latches_i)
    // ====================================================================
    input  wire        latches_valid,

    // dc_cs_t (latches_i.cs)
    input  wire        latches_cs_LD_OP,
    input  wire        latches_cs_ST_OP,
    input  wire        latches_cs_dr_upper8,
    input  wire        latches_cs_sr_upper8,
    input  wire [1:0]  latches_cs_datasize,

    // mem_cs_t (latches_i.mem_cs) -- forwarded to mem_latches_next.cs
    input  wire        latches_mem_cs_ST_OP,
    input  wire        latches_mem_cs_LD_OP,

    // exe_cs_t (latches_i.exe_cs) -- forwarded to mem_latches_next.exe_cs
    input  wire        latches_exe_cs_ST_OP,
    input  wire [5:0]  latches_exe_cs_OP_TYPE,
    input  wire [4:0]  latches_exe_cs_alu_inputA_sel,
    input  wire [4:0]  latches_exe_cs_alu_inputB_sel,
    input  wire [4:0]  latches_exe_cs_branch_target_sel,
    input  wire        latches_exe_cs_shift_by_one,
    input  wire        latches_exe_cs_br_ucond,
    input  wire        latches_exe_cs_relative_branch,
    input  wire        latches_exe_cs_special_br,
    input  wire        latches_exe_cs_is_far,
    input  wire        latches_exe_cs_is_call,
    input  wire        latches_exe_cs_second_flag_needed,
    input  wire        latches_exe_cs_rep_no_zf_update,

    // wb_cs_t (latches_i.wb_cs)
    input  wire        latches_wb_cs_ST_OP,
    input  wire        latches_wb_cs_WB_DR,
    input  wire        latches_wb_cs_WB_SR,
    input  wire        latches_wb_cs_WB_EAX,

    // br_info_t (latches_i.br_info)
    input  wire        latches_br_info_valid,
    input  wire [31:0] latches_br_info_br_eip,
    input  wire        latches_br_info_br_xcl,
    input  wire        latches_br_info_br_pred_taken,
    input  wire [31:0] latches_br_info_speculative_target,

    input  wire        latches_rr_gp,

    // load-side address / segmentation info
    input  wire [31:0] latches_ld_vaddy,
    input  wire [31:0] latches_seg0_limit_w_datasize,
    input  wire [31:0] latches_seg0_limit_wo_datasize,
    input  wire [31:0] latches_next_ld_vaddy,
    input  wire [31:0] latches_ld_laddy,
    input  wire        latches_ld_stack_access,

    // store-side address / segmentation info
    input  wire [31:0] latches_st_vaddy,
    input  wire [31:0] latches_seg1_limit_w_datasize,
    input  wire [31:0] latches_seg1_limit_wo_datasize,
    input  wire [31:0] latches_next_st_vaddy,
    input  wire [31:0] latches_st_laddy,
    input  wire        latches_st_stack_access,

    input  wire [31:0] latches_NEIP,
    input  wire [31:0] latches_EIP,
    input  wire [31:0] latches_EAX,
    input  wire [63:0] latches_imm64,

    input  wire [4:0]  latches_sr_id,
    input  wire [63:0] latches_sr_data,
    input  wire [4:0]  latches_dr_id,
    input  wire [63:0] latches_dr_data,

    // ====================================================================
    // fetch_outputs_t (fetch_outs_i) -- only exp_pipe_clear consumed
    // ====================================================================
    input  wire        fetch_outs_exp_pipe_clear,

    // ====================================================================
    // mem_outputs_t (mem_outs_i)
    // ====================================================================
    input  wire        mem_outs_valid,
    input  wire        mem_outs_stall,
    input  wire        mem_outs_ST_OP,
    input  wire        mem_outs_ST_XCL,
    input  wire [14:0] mem_outs_ST_PADDR_0,
    input  wire [14:0] mem_outs_ST_PADDR_1,

    // ====================================================================
    // exe_outputs_t (exe_outs_i)
    // ====================================================================
    input  wire        exe_outs_valid,
    input  wire        exe_outs_ST_OP,
    input  wire        exe_outs_ST_XCL,
    input  wire [14:0] exe_outs_ST_PADDR_0,
    input  wire [14:0] exe_outs_ST_PADDR_1,
    input  wire        exe_outs_br_res_flush,

    // ====================================================================
    // wb_outputs_t (wb_outs_i)
    // ====================================================================
    input  wire        wb_outs_valid,
    input  wire        wb_outs_wb_stall,
    input  wire        wb_outs_ST_OP,
    input  wire        wb_outs_ST_XCL,
    input  wire [14:0] wb_outs_ST_PADDR_0,
    input  wire [14:0] wb_outs_ST_PADDR_1,

    // wb_outputs_t.dep_check.entries[0..15]
    input  wire        wb_outs_dep_check_entry_0_valid,
    input  wire [14:0] wb_outs_dep_check_entry_0_address,
    input  wire        wb_outs_dep_check_entry_1_valid,
    input  wire [14:0] wb_outs_dep_check_entry_1_address,
    input  wire        wb_outs_dep_check_entry_2_valid,
    input  wire [14:0] wb_outs_dep_check_entry_2_address,
    input  wire        wb_outs_dep_check_entry_3_valid,
    input  wire [14:0] wb_outs_dep_check_entry_3_address,
    input  wire        wb_outs_dep_check_entry_4_valid,
    input  wire [14:0] wb_outs_dep_check_entry_4_address,
    input  wire        wb_outs_dep_check_entry_5_valid,
    input  wire [14:0] wb_outs_dep_check_entry_5_address,
    input  wire        wb_outs_dep_check_entry_6_valid,
    input  wire [14:0] wb_outs_dep_check_entry_6_address,
    input  wire        wb_outs_dep_check_entry_7_valid,
    input  wire [14:0] wb_outs_dep_check_entry_7_address,
    input  wire        wb_outs_dep_check_entry_8_valid,
    input  wire [14:0] wb_outs_dep_check_entry_8_address,
    input  wire        wb_outs_dep_check_entry_9_valid,
    input  wire [14:0] wb_outs_dep_check_entry_9_address,
    input  wire        wb_outs_dep_check_entry_10_valid,
    input  wire [14:0] wb_outs_dep_check_entry_10_address,
    input  wire        wb_outs_dep_check_entry_11_valid,
    input  wire [14:0] wb_outs_dep_check_entry_11_address,
    input  wire        wb_outs_dep_check_entry_12_valid,
    input  wire [14:0] wb_outs_dep_check_entry_12_address,
    input  wire        wb_outs_dep_check_entry_13_valid,
    input  wire [14:0] wb_outs_dep_check_entry_13_address,
    input  wire        wb_outs_dep_check_entry_14_valid,
    input  wire [14:0] wb_outs_dep_check_entry_14_address,
    input  wire        wb_outs_dep_check_entry_15_valid,
    input  wire [14:0] wb_outs_dep_check_entry_15_address,

    // ====================================================================
    // dcache request-served handshakes
    // ====================================================================
    input  wire        req_served_mio,
    input  wire        req_served_0,
    input  wire        req_served_1,

    // ====================================================================
    // mem_latches_t (mem_latches_next_o)
    // ====================================================================
    output wire        mem_latches_next_valid,

    // mem_cs_t (mem_latches_next_o.cs)
    output wire        mem_latches_next_cs_ST_OP,
    output wire        mem_latches_next_cs_LD_OP,

    // exe_cs_t (mem_latches_next_o.exe_cs)
    output wire        mem_latches_next_exe_cs_ST_OP,
    output wire [5:0]  mem_latches_next_exe_cs_OP_TYPE,
    output wire [4:0]  mem_latches_next_exe_cs_alu_inputA_sel,
    output wire [4:0]  mem_latches_next_exe_cs_alu_inputB_sel,
    output wire [4:0]  mem_latches_next_exe_cs_branch_target_sel,
    output wire        mem_latches_next_exe_cs_shift_by_one,
    output wire        mem_latches_next_exe_cs_br_ucond,
    output wire        mem_latches_next_exe_cs_relative_branch,
    output wire        mem_latches_next_exe_cs_special_br,
    output wire        mem_latches_next_exe_cs_is_far,
    output wire        mem_latches_next_exe_cs_is_call,
    output wire        mem_latches_next_exe_cs_second_flag_needed,
    output wire        mem_latches_next_exe_cs_rep_no_zf_update,

    // wb_cs_t (mem_latches_next_o.wb_cs)
    output wire        mem_latches_next_wb_cs_ST_OP,
    output wire        mem_latches_next_wb_cs_WB_DR,
    output wire        mem_latches_next_wb_cs_WB_SR,
    output wire        mem_latches_next_wb_cs_WB_EAX,

    // br_info_t (mem_latches_next_o.br_info)
    output wire        mem_latches_next_br_info_valid,
    output wire [31:0] mem_latches_next_br_info_br_eip,
    output wire        mem_latches_next_br_info_br_xcl,
    output wire        mem_latches_next_br_info_br_pred_taken,
    output wire [31:0] mem_latches_next_br_info_speculative_target,

    output wire [3:0]  mem_latches_next_data_size_vec,
    output wire [3:0]  mem_latches_next_sr_data_size_vec,
    output wire        mem_latches_next_shift_sr_up,
    output wire        mem_latches_next_shift_sr_down,

    output wire        mem_latches_next_ST_XCL,
    output wire [14:0] mem_latches_next_ST_PADDR_0,
    output wire [14:0] mem_latches_next_ST_PADDR_1,
    output wire        mem_latches_next_MIO,

    output wire [31:0] mem_latches_next_NEIP,
    output wire [31:0] mem_latches_next_EIP,
    output wire [31:0] mem_latches_next_EAX,
    output wire [63:0] mem_latches_next_imm64,

    output wire [4:0]  mem_latches_next_sr_id,
    output wire [63:0] mem_latches_next_sr_data,
    output wire [4:0]  mem_latches_next_dr_id,
    output wire [63:0] mem_latches_next_dr_data,

    output wire        mem_latches_next_LD_XCL,
    output wire        mem_latches_next_swapLines,
    output wire [14:0] mem_latches_next_LD_PADDR_0,
    output wire [14:0] mem_latches_next_LD_PADDR_1,

    // ====================================================================
    // dc_outputs_t (dc_outs_o)
    // ====================================================================
    output wire        dc_outs_valid,
    output wire [31:0] dc_outs_dc_eip,
    output wire        dc_outs_stall,
    output wire        dc_outs_exp_pf,
    output wire        dc_outs_exp_present,
    output wire        dc_outs_ld_addr_0_V,
    output wire [14:0] dc_outs_ld_addr_0,
    output wire        dc_outs_ld_addr_1_V,
    output wire [14:0] dc_outs_ld_addr_1,
    output wire        dc_outs_ld_addr_MIO_V,
    output wire [14:0] dc_outs_ld_addr_MIO,
    output wire        dc_outs_mem_stage_latch_we
);

    // ----------------------------------------------------------------
    // Internal nets (formerly bool / p_address_t / logic[3:0])
    // ----------------------------------------------------------------
    wire        mem_stage_we_valid_unit_o;
    wire        mem_stage_next_vaild_o;

    wire        in_flight_stall;
    wire        stq_stall;
    wire        dep_stall;
    wire        arb_stall;
    wire        exp_stall;
    wire        dc_stall;

    wire        ld_addr_0_V;
    wire        ld_addr_1_V;
    wire        ld_addr_mio_V;
    wire [14:0] ld_addr_0;
    wire [14:0] ld_addr_1;
    wire [14:0] ld_addr_mio;

    wire        shift_sr_up;
    wire        shift_sr_down;
    wire [3:0]  data_size_vec;
    wire [3:0]  sr_data_size_vec;

    wire [14:0] next_st_addr_0;
    wire [14:0] next_st_addr_1;
    wire        next_st_xcl;

    wire        ld_exception, st_exception, rr_exception;
    wire        ld_segx_gp, st_segx_gp;

    // Per-stage ST_OP aliases (kept for readability vs. original .sv)
    wire        dc_ST_OP;
    wire        mem_ST_OP;
    wire        exe_ST_OP;
    wire        wb_ST_OP;

    assign dc_ST_OP  = latches_cs_ST_OP;
    assign mem_ST_OP = mem_outs_ST_OP;
    assign exe_ST_OP = exe_outs_ST_OP;
    assign wb_ST_OP  = wb_outs_ST_OP;

    // ----------------------------------------------------------------
    // npu_node2 flat outputs (replace SV `npu_node2_outputs_t` struct).
    // Naming follows `ld_neuralnet_out.<field>` -> `ld_neuralnet_out_<field>`
    // ----------------------------------------------------------------
    wire        ld_neuralnet_out_DC_PF;
    wire        ld_neuralnet_out_DC_GP;
    wire        ld_neuralnet_out_valid_mem_op;
    wire [14:0] ld_neuralnet_out_PADDR1;
    wire        ld_neuralnet_out_bank_hi;
    wire        ld_neuralnet_out_xcl;
    wire [14:0] ld_neuralnet_out_PADDR0;
    wire        ld_neuralnet_out_mio;

    wire        st_neuralnet_out_DC_PF;
    wire        st_neuralnet_out_DC_GP;
    wire        st_neuralnet_out_valid_mem_op;
    wire [14:0] st_neuralnet_out_PADDR1;
    wire        st_neuralnet_out_bank_hi;
    wire        st_neuralnet_out_xcl;
    wire [14:0] st_neuralnet_out_PADDR0;
    wire        st_neuralnet_out_mio;

    // ----------------------------------------------------------------
    // dep_stall = in_flight_stall | stq_stall
    // ----------------------------------------------------------------
    `OR_2(u_dep_stall, 1, dep_stall, in_flight_stall, stq_stall)

    // ----------------------------------------------------------------
    // ld_exception = (ld.DC_PF | ld.DC_GP | ld_segx_gp) & LD_OP
    // ----------------------------------------------------------------
    wire ld_exp_or;
    `OR_3 (u_ld_exp_or,    1, ld_exp_or,
           ld_neuralnet_out_DC_PF, ld_neuralnet_out_DC_GP, ld_segx_gp)
    `AND_2(u_ld_exception, 1, ld_exception, ld_exp_or, latches_cs_LD_OP)

    // ----------------------------------------------------------------
    // st_exception = (st.DC_PF | st.DC_GP | st_segx_gp) & ST_OP
    // ----------------------------------------------------------------
    wire st_exp_or;
    `OR_3 (u_st_exp_or,    1, st_exp_or,
           st_neuralnet_out_DC_PF, st_neuralnet_out_DC_GP, st_segx_gp)
    `AND_2(u_st_exception, 1, st_exception, st_exp_or, latches_cs_ST_OP)

    // rr_exception = latches_i.rr_gp  (wire alias)
    assign rr_exception = latches_rr_gp;

    // ----------------------------------------------------------------
    // exp_stall = (ld_excep | st_excep | rr_excep) & latches_i.valid & ~flush
    // ----------------------------------------------------------------
    wire exp_or;
    wire not_flush;
    `OR_3 (u_exp_or,    1, exp_or,
           ld_exception, st_exception, rr_exception)
    `INV_N(u_not_flush, 1, exe_outs_br_res_flush, not_flush)
    `AND_3(u_exp_stall, 1, exp_stall, exp_or, latches_valid, not_flush)

    // ----------------------------------------------------------------
    // dc_stall = dep_stall | arb_stall | exp_stall
    // ----------------------------------------------------------------
    `OR_3(u_dc_stall, 1, dc_stall, dep_stall, arb_stall, exp_stall)


    // ----------------------------------------------------------------
    // Load-vs-in-flight-store dependency check
    // ----------------------------------------------------------------
    in_flight_sb_logic in_flight_dep_check (
        .ld_paddr_0    (ld_neuralnet_out_PADDR0),
        .ld_paddr_1    (ld_neuralnet_out_PADDR1),
        .LD_XCL        (ld_neuralnet_out_xcl),
        .LD_OP         (latches_cs_LD_OP),
        .valid         (latches_valid),

        .mem_st_paddr0 (mem_outs_ST_PADDR_0),
        .mem_st_paddr1 (mem_outs_ST_PADDR_1),
        .mem_ST_OP     (mem_ST_OP),
        .mem_ST_XCL    (mem_outs_ST_XCL),
        .mem_valid     (mem_outs_valid),

        .exe_st_paddr0 (exe_outs_ST_PADDR_0),
        .exe_st_paddr1 (exe_outs_ST_PADDR_1),
        .exe_ST_OP     (exe_ST_OP),
        .exe_ST_XCL    (exe_outs_ST_XCL),
        .exe_valid     (exe_outs_valid),

        .wb_st_paddr0  (wb_outs_ST_PADDR_0),
        .wb_st_paddr1  (wb_outs_ST_PADDR_1),
        .wb_ST_OP      (wb_ST_OP),
        .wb_ST_XCL     (wb_outs_ST_XCL),
        .wb_valid      (wb_outs_valid),

        .in_flight_mem_stall (in_flight_stall)
    );

    // ----------------------------------------------------------------
    // Store-queue dependency check (16 entries flattened)
    // ----------------------------------------------------------------
    wb_stq_sb_logic stq_dep_check (
        .valid       (latches_valid),
        .ld_paddr_0  (ld_neuralnet_out_PADDR0),
        .ld_paddr_1  (ld_neuralnet_out_PADDR1),
        .LD_OP       (latches_cs_LD_OP),
        .LD_XCL      (ld_neuralnet_out_xcl),

        .stq_addr_0  (wb_outs_dep_check_entry_0_address),
        .stq_addr_1  (wb_outs_dep_check_entry_1_address),
        .stq_addr_2  (wb_outs_dep_check_entry_2_address),
        .stq_addr_3  (wb_outs_dep_check_entry_3_address),
        .stq_addr_4  (wb_outs_dep_check_entry_4_address),
        .stq_addr_5  (wb_outs_dep_check_entry_5_address),
        .stq_addr_6  (wb_outs_dep_check_entry_6_address),
        .stq_addr_7  (wb_outs_dep_check_entry_7_address),
        .stq_addr_8  (wb_outs_dep_check_entry_8_address),
        .stq_addr_9  (wb_outs_dep_check_entry_9_address),
        .stq_addr_10 (wb_outs_dep_check_entry_10_address),
        .stq_addr_11 (wb_outs_dep_check_entry_11_address),
        .stq_addr_12 (wb_outs_dep_check_entry_12_address),
        .stq_addr_13 (wb_outs_dep_check_entry_13_address),
        .stq_addr_14 (wb_outs_dep_check_entry_14_address),
        .stq_addr_15 (wb_outs_dep_check_entry_15_address),

        .stq_valid_0  (wb_outs_dep_check_entry_0_valid),
        .stq_valid_1  (wb_outs_dep_check_entry_1_valid),
        .stq_valid_2  (wb_outs_dep_check_entry_2_valid),
        .stq_valid_3  (wb_outs_dep_check_entry_3_valid),
        .stq_valid_4  (wb_outs_dep_check_entry_4_valid),
        .stq_valid_5  (wb_outs_dep_check_entry_5_valid),
        .stq_valid_6  (wb_outs_dep_check_entry_6_valid),
        .stq_valid_7  (wb_outs_dep_check_entry_7_valid),
        .stq_valid_8  (wb_outs_dep_check_entry_8_valid),
        .stq_valid_9  (wb_outs_dep_check_entry_9_valid),
        .stq_valid_10 (wb_outs_dep_check_entry_10_valid),
        .stq_valid_11 (wb_outs_dep_check_entry_11_valid),
        .stq_valid_12 (wb_outs_dep_check_entry_12_valid),
        .stq_valid_13 (wb_outs_dep_check_entry_13_valid),
        .stq_valid_14 (wb_outs_dep_check_entry_14_valid),
        .stq_valid_15 (wb_outs_dep_check_entry_15_valid),

        .stall (stq_stall)
    );

    // ----------------------------------------------------------------
    // Load request-generation logic
    // ----------------------------------------------------------------
    req_gen_logic req_gen (
        .clk       (clk),
        .rst       (rst),
        .flush     (exe_outs_br_res_flush),
        .valid     (latches_valid),
        .LD_OP     (latches_cs_LD_OP),
        .XCL       (ld_neuralnet_out_xcl),
        .dep_stall (dep_stall),
        .MIO       (ld_neuralnet_out_mio),

        .ld_addr0   (ld_neuralnet_out_PADDR0),
        .ld_addr1   (ld_neuralnet_out_PADDR1),
        .ld_addrMIO (ld_neuralnet_out_PADDR1),

        .req_served_0   (req_served_0),
        .req_served_1   (req_served_1),
        .req_served_mio (req_served_mio),

        .mem_stage_we_valid_unit_o (mem_stage_we_valid_unit_o),
        .mem_stage_next_valid_o    (mem_stage_next_vaild_o),

        .ld_addr_0_V   (ld_addr_0_V),
        .ld_addr_1_V   (ld_addr_1_V),
        .ld_addr_mio_V (ld_addr_mio_V),
        .ld_addr_mio   (ld_addr_mio),
        .ld_addr_0     (ld_addr_0),
        .ld_addr_1     (ld_addr_1),
        .arb_stall     (arb_stall)
    );

    // ----------------------------------------------------------------
    // Stage-valid / latch-write-enable logic (auto-generated)
    // ----------------------------------------------------------------
    mem_valid_logic mem_valid_unit (
        .MEM_we_o    (mem_stage_we_valid_unit_o),
        .N_MEM_V_o   (mem_stage_next_vaild_o),
        .DC_stall_i  (dc_stall),
        .DC_V_i      (latches_valid),
        .MEM_V_i     (mem_outs_valid),
        .MEM_stall_i (mem_outs_stall),
        .EXE_V_i     (exe_outs_valid),
        .WB_stall_i  (wb_outs_wb_stall)
    );

    // ----------------------------------------------------------------
    // data_size_vec_logic
    // ----------------------------------------------------------------
    data_size_vec_logic data_vec_uint (
        .data_size          (latches_cs_datasize),
        .dr_upper8          (latches_cs_dr_upper8),
        .sr_upper8          (latches_cs_sr_upper8),
        .ST_OP              (latches_cs_ST_OP),
        .LD_OP              (latches_cs_LD_OP),
        .wb_sr              (latches_wb_cs_WB_SR),
        .wb_eax             (latches_wb_cs_WB_EAX),
        .shift_sr_up        (shift_sr_up),
        .shift_sr_down      (shift_sr_down),
        .data_size_vec_o    (data_size_vec),
        .sr_data_size_vec_o (sr_data_size_vec)
    );

    // ----------------------------------------------------------------
    // npu_node2 (load + store)
    // ----------------------------------------------------------------
    npu_node2 ld_neuralnet_part2 (
        .vaddy_start    (latches_ld_vaddy),
        .next_page_vaddy(latches_next_ld_vaddy),
        .datasize       (latches_cs_datasize),
        .write_intent   (1'b0),
        .mem_op         (latches_cs_LD_OP),
        .stack_access   (latches_ld_stack_access),
        .DC_PF          (ld_neuralnet_out_DC_PF),
        .DC_GP          (ld_neuralnet_out_DC_GP),
        .valid_mem_op   (ld_neuralnet_out_valid_mem_op),
        .PADDR1         (ld_neuralnet_out_PADDR1),
        .bank_hi        (ld_neuralnet_out_bank_hi),
        .xcl            (ld_neuralnet_out_xcl),
        .PADDR0         (ld_neuralnet_out_PADDR0),
        .mio            (ld_neuralnet_out_mio)
    );

    npu_node2 st_neuralnet_part2 (
        .vaddy_start    (latches_st_vaddy),
        .next_page_vaddy(latches_next_st_vaddy),
        .datasize       (latches_cs_datasize),
        .write_intent   (latches_cs_ST_OP),
        .mem_op         (latches_cs_ST_OP),
        .stack_access   (latches_st_stack_access),
        .DC_PF          (st_neuralnet_out_DC_PF),
        .DC_GP          (st_neuralnet_out_DC_GP),
        .valid_mem_op   (st_neuralnet_out_valid_mem_op),
        .PADDR1         (st_neuralnet_out_PADDR1),
        .bank_hi        (st_neuralnet_out_bank_hi),
        .xcl            (st_neuralnet_out_xcl),
        .PADDR0         (st_neuralnet_out_PADDR0),
        .mio            (st_neuralnet_out_mio)
    );

    // ----------------------------------------------------------------
    // segx (load + store)
    // ----------------------------------------------------------------
    segx ld_segx (
        .laddy                (latches_ld_laddy),
        .seg_limit            (latches_seg0_limit_wo_datasize),
        .seg_limit_w_datasize (latches_seg0_limit_w_datasize),
        .stack_access         (latches_ld_stack_access),
        .segx_gp              (ld_segx_gp)
    );

    segx st_segx (
        .laddy                (latches_st_laddy),
        .seg_limit            (latches_seg1_limit_wo_datasize),
        .seg_limit_w_datasize (latches_seg1_limit_w_datasize),
        .stack_access         (latches_st_stack_access),
        .segx_gp              (st_segx_gp)
    );

    // ----------------------------------------------------------------
    // push_address_gen (OP_TYPE port is 32 bits in the leaf; zero-extend
    // the 6-bit exe_cs_operation_type_e from the latch interface).
    // ----------------------------------------------------------------
    push_address_gen push_addr_gen (
        .ST_PADDR_0   (st_neuralnet_out_PADDR0),
        .ST_PADDR_1   (st_neuralnet_out_PADDR1),
        .ST_XCL       (st_neuralnet_out_xcl),
        .data_size    (latches_cs_datasize),
        .OP_TYPE      ({26'b0, latches_exe_cs_OP_TYPE}),
        .ST_PADDR_0_o (next_st_addr_0),
        .ST_PADDR_1_o (next_st_addr_1),
        .ST_XCL_o     (next_st_xcl)
    );


    // ----------------------------------------------------------------
    // dc_outs_o.exp_pf = ld.DC_PF | st.DC_PF
    // ----------------------------------------------------------------
    wire dc_outs_exp_pf_w;
    `OR_2(u_dc_exp_pf, 1, dc_outs_exp_pf_w,
          ld_neuralnet_out_DC_PF, st_neuralnet_out_DC_PF)

    // ----------------------------------------------------------------
    // dc_outs_o assignments (flat)
    // ----------------------------------------------------------------
    assign dc_outs_valid              = latches_valid;
    assign dc_outs_dc_eip             = latches_EIP;
    assign dc_outs_stall              = dc_stall;
    assign dc_outs_exp_pf             = dc_outs_exp_pf_w;
    assign dc_outs_exp_present        = exp_stall;
    assign dc_outs_ld_addr_0_V        = ld_addr_0_V;
    assign dc_outs_ld_addr_0          = ld_addr_0;
    assign dc_outs_ld_addr_1_V        = ld_addr_1_V;
    assign dc_outs_ld_addr_1          = ld_addr_1;
    assign dc_outs_ld_addr_MIO_V      = ld_addr_mio_V;
    assign dc_outs_ld_addr_MIO        = ld_addr_mio;
    assign dc_outs_mem_stage_latch_we = mem_stage_we_valid_unit_o;

    // ----------------------------------------------------------------
    // mem_latches_next_o.valid = mem_stage_next_vaild_o & ~exp_pipe_clear
    // ----------------------------------------------------------------
    wire not_exp_pipe_clear;
    wire mem_latches_valid_w;
    `INV_N(u_not_exp_pipe_clear, 1, fetch_outs_exp_pipe_clear, not_exp_pipe_clear)
    `AND_2(u_mem_latches_valid,  1, mem_latches_valid_w,
           mem_stage_next_vaild_o, not_exp_pipe_clear)

    // ----------------------------------------------------------------
    // mem_latches_next_o assignments (flat)
    // ----------------------------------------------------------------
    assign mem_latches_next_valid                       = mem_latches_valid_w;

    // mem_cs_t pass-through
    assign mem_latches_next_cs_ST_OP                    = latches_mem_cs_ST_OP;
    assign mem_latches_next_cs_LD_OP                    = latches_mem_cs_LD_OP;

    // exe_cs_t pass-through
    assign mem_latches_next_exe_cs_ST_OP                = latches_exe_cs_ST_OP;
    assign mem_latches_next_exe_cs_OP_TYPE              = latches_exe_cs_OP_TYPE;
    assign mem_latches_next_exe_cs_alu_inputA_sel       = latches_exe_cs_alu_inputA_sel;
    assign mem_latches_next_exe_cs_alu_inputB_sel       = latches_exe_cs_alu_inputB_sel;
    assign mem_latches_next_exe_cs_branch_target_sel    = latches_exe_cs_branch_target_sel;
    assign mem_latches_next_exe_cs_shift_by_one         = latches_exe_cs_shift_by_one;
    assign mem_latches_next_exe_cs_br_ucond             = latches_exe_cs_br_ucond;
    assign mem_latches_next_exe_cs_relative_branch      = latches_exe_cs_relative_branch;
    assign mem_latches_next_exe_cs_special_br           = latches_exe_cs_special_br;
    assign mem_latches_next_exe_cs_is_far               = latches_exe_cs_is_far;
    assign mem_latches_next_exe_cs_is_call              = latches_exe_cs_is_call;
    assign mem_latches_next_exe_cs_second_flag_needed   = latches_exe_cs_second_flag_needed;
    assign mem_latches_next_exe_cs_rep_no_zf_update     = latches_exe_cs_rep_no_zf_update;

    // wb_cs_t pass-through
    assign mem_latches_next_wb_cs_ST_OP                 = latches_wb_cs_ST_OP;
    assign mem_latches_next_wb_cs_WB_DR                 = latches_wb_cs_WB_DR;
    assign mem_latches_next_wb_cs_WB_SR                 = latches_wb_cs_WB_SR;
    assign mem_latches_next_wb_cs_WB_EAX                = latches_wb_cs_WB_EAX;

    // br_info_t pass-through
    assign mem_latches_next_br_info_valid               = latches_br_info_valid;
    assign mem_latches_next_br_info_br_eip              = latches_br_info_br_eip;
    assign mem_latches_next_br_info_br_xcl              = latches_br_info_br_xcl;
    assign mem_latches_next_br_info_br_pred_taken       = latches_br_info_br_pred_taken;
    assign mem_latches_next_br_info_speculative_target  = latches_br_info_speculative_target;

    // data_size_vec_logic outputs
    assign mem_latches_next_data_size_vec               = data_size_vec;
    assign mem_latches_next_sr_data_size_vec            = sr_data_size_vec;
    assign mem_latches_next_shift_sr_down               = shift_sr_down;
    assign mem_latches_next_shift_sr_up                 = shift_sr_up;

    // push_address_gen outputs
    assign mem_latches_next_ST_XCL                      = next_st_xcl;
    assign mem_latches_next_ST_PADDR_0                  = next_st_addr_0;
    assign mem_latches_next_ST_PADDR_1                  = next_st_addr_1;

    // only the load location MIO is needed downstream
    assign mem_latches_next_MIO                         = ld_neuralnet_out_mio;

    // pass-through scalars
    assign mem_latches_next_NEIP                        = latches_NEIP;
    assign mem_latches_next_EIP                         = latches_EIP;
    assign mem_latches_next_EAX                         = latches_EAX;
    assign mem_latches_next_imm64                       = latches_imm64;
    assign mem_latches_next_sr_id                       = latches_sr_id;
    assign mem_latches_next_sr_data                     = latches_sr_data;
    assign mem_latches_next_dr_id                       = latches_dr_id;
    assign mem_latches_next_dr_data                     = latches_dr_data;

    // load-address fields from npu_node2
    assign mem_latches_next_LD_XCL                      = ld_neuralnet_out_xcl;
    assign mem_latches_next_swapLines                   = ld_neuralnet_out_bank_hi;
    assign mem_latches_next_LD_PADDR_0                  = ld_neuralnet_out_PADDR0;
    assign mem_latches_next_LD_PADDR_1                  = ld_neuralnet_out_PADDR1;

endmodule
