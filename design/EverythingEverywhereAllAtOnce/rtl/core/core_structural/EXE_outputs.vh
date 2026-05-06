`define EXE_OUTPUTS 

    wire        wb_latches_next_valid;
    wire        wb_latches_next_cs_ST_OP;
    wire        wb_latches_next_cs_WB_DR;
    wire        wb_latches_next_cs_WB_SR;
    wire        wb_latches_next_cs_WB_EAX;
    wire        wb_latches_next_ST_XCL;
    wire [14:0] wb_latches_next_ST_PADDR_0;
    wire [15:0] wb_latches_next_ST_BIT_VEC_0;
    wire [14:0] wb_latches_next_ST_PADDR_1;
    wire [15:0] wb_latches_next_ST_BIT_VEC_1;
    wire        wb_latches_next_MIO;
    wire [31:0] wb_latches_next_EIP;
    wire [255:0] wb_latches_next_res_buf;
    wire [4:0]  wb_latches_next_sr_id;
    wire [63:0] wb_latches_next_sr_data;
    wire [4:0]  wb_latches_next_dr_id;
    wire [63:0] wb_latches_next_dr_data;
    wire [31:0] wb_latches_next_EAX;