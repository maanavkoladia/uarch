`define WB_LATCHES

    wire        wb_latches_valid;
    wire        wb_latches_cs_ST_OP;
    wire        wb_latches_cs_WB_DR;
    wire        wb_latches_cs_WB_SR;
    wire        wb_latches_cs_WB_EAX;
    wire        wb_latches_ST_XCL;
    wire [14:0] wb_latches_ST_PADDR_0;
    wire [15:0] wb_latches_ST_BIT_VEC_0;
    wire [14:0] wb_latches_ST_PADDR_1;
    wire [15:0] wb_latches_ST_BIT_VEC_1;
    wire        wb_latches_MIO;
    wire [31:0] wb_latches_EIP;
    wire [255:0] wb_latches_res_buf;
    wire [4:0]  wb_latches_sr_id;
    wire [63:0] wb_latches_sr_data;
    wire [4:0]  wb_latches_dr_id;
    wire [63:0] wb_latches_dr_data;
    wire [31:0] wb_latches_EAX;


        WB_Latches wb_latches_unit (
        .clk            (clk),
        .rst            (rst),
        .write_enable_i (exe_outputs_wb_stage_latch_we),

        // ---- nextLatches_i (flat) -- driven by EXE flat outputs ----
        .nextLatches_valid_i        (wb_latches_next_valid),
        .nextLatches_cs_ST_OP_i     (wb_latches_next_cs_ST_OP),
        .nextLatches_cs_WB_DR_i     (wb_latches_next_cs_WB_DR),
        .nextLatches_cs_WB_SR_i     (wb_latches_next_cs_WB_SR),
        .nextLatches_cs_WB_EAX_i    (wb_latches_next_cs_WB_EAX),
        .nextLatches_ST_XCL_i       (wb_latches_next_ST_XCL),
        .nextLatches_ST_PADDR_0_i   (wb_latches_next_ST_PADDR_0),
        .nextLatches_ST_BIT_VEC_0_i (wb_latches_next_ST_BIT_VEC_0),
        .nextLatches_ST_PADDR_1_i   (wb_latches_next_ST_PADDR_1),
        .nextLatches_ST_BIT_VEC_1_i (wb_latches_next_ST_BIT_VEC_1),
        .nextLatches_MIO_i          (wb_latches_next_MIO),
        .nextLatches_EIP_i          (wb_latches_next_EIP),
        .nextLatches_res_buf_i      (wb_latches_next_res_buf),
        .nextLatches_sr_id_i        (wb_latches_next_sr_id),
        .nextLatches_sr_data_i      (wb_latches_next_sr_data),
        .nextLatches_dr_id_i        (wb_latches_next_dr_id),
        .nextLatches_dr_data_i      (wb_latches_next_dr_data),
        .nextLatches_EAX_i          (wb_latches_next_EAX),

        // ---- latches_o (flat) -- consumed by WB module flat inputs ----
        .latches_valid_o            (wb_latches_valid),
        .latches_cs_ST_OP_o         (wb_latches_cs_ST_OP),
        .latches_cs_WB_DR_o         (wb_latches_cs_WB_DR),
        .latches_cs_WB_SR_o         (wb_latches_cs_WB_SR),
        .latches_cs_WB_EAX_o        (wb_latches_cs_WB_EAX),
        .latches_ST_XCL_o           (wb_latches_ST_XCL),
        .latches_ST_PADDR_0_o       (wb_latches_ST_PADDR_0),
        .latches_ST_BIT_VEC_0_o     (wb_latches_ST_BIT_VEC_0),
        .latches_ST_PADDR_1_o       (wb_latches_ST_PADDR_1),
        .latches_ST_BIT_VEC_1_o     (wb_latches_ST_BIT_VEC_1),
        .latches_MIO_o              (wb_latches_MIO),
        .latches_EIP_o              (wb_latches_EIP),
        .latches_res_buf_o          (wb_latches_res_buf),
        .latches_sr_id_o            (wb_latches_sr_id),
        .latches_sr_data_o          (wb_latches_sr_data),
        .latches_dr_id_o            (wb_latches_dr_id),
        .latches_dr_data_o          (wb_latches_dr_data),
        .latches_EAX_o              (wb_latches_EAX)
    );
