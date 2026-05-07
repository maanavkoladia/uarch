`default_nettype none
// Bring macro definitions into scope. These files contain ONLY `define
// directives now; the bodies expand at the `<NAME> invocation sites below.
// `include "fetch_outputs.vh"
// `include "IDM_outputs.vh"
// `include "decode_outputs.vh"
// `include "RR_outputs.vh"
// `include "DC_outputs.vh"
// `include "MEM_outputs.vh"
// `include "EXE_outputs.vh"
// `include "WB_outputs.vh"
// `include "fetch_stage.vh"
// `include "IDM_stage.vh"
// `include "decode_stage.vh"
// `include "RR_latches.vh"
// `include "RR_stage.vh"
// `include "DC_latches.vh"
// `include "DC_stage.vh"
// `include "MEM_latches.vh"
// `include "MEM_stage.vh"
// `include "EXE_latches.vh"
// `include "EXE_stage.vh"
// `include "WB_latches.vh"
// `include "WB_stage.vh"

module EveryThing_TOP (
    input wire clk,
    input wire rst,

    //icache 2 core
    input wire         out_hit,
    input wire [127:0] out_instruction_line,

    //dma to core
    input wire inFromDMA_i,

    //core 2 dcache
    input wire         dcache2Core_reqServed_0_o,
    input wire         dcache2Core_reqServed_1_o,
    input wire         dcache2Core_hit_0_o,
    input wire         dcache2Core_hit_1_o,
    input wire         dcache2Core_hit_2_o,
    input wire         dcache2Core_hit_3_o,
    input wire [127:0] dcache2Core_cacheline_0_o,
    input wire [127:0] dcache2Core_cacheline_1_o,
    input wire [127:0] dcache2Core_cacheline_2_o,
    input wire [127:0] dcache2Core_cacheline_3_o,
    input wire         dcache2Core_writeSuccess_0_o,
    input wire         dcache2Core_writeSuccess_1_o,
    input wire         dcache2Core_writeSuccess_2_o,
    input wire         dcache2Core_writeSuccess_3_o,
    input wire         dcache2Core_writeSuccess_MIO_o,
    input wire         dcache2Core_hit_MIO_o,
    input wire         dcache2Core_reqServed_MIO_o,
    input wire [127:0] dcache2Core_line_MIO_o,

    // ----- core_2_dcache_t inFromCore_i (unpacked) -----
    output  wire        core_ld_addr_0_V_i,
    output  wire [14:0] core_ld_addr_0_i,
    output  wire        core_ld_addr_1_V_i,
    output  wire [14:0] core_ld_addr_1_i,
    output  wire        core_stq_full_0_i,
    output  wire        core_stq_full_1_i,
    output  wire        core_stq_full_2_i,
    output  wire        core_stq_full_3_i,
    output  wire        core_stq_empty_0_i,
    output  wire        core_stq_empty_1_i,
    output  wire        core_stq_empty_2_i,
    output  wire        core_stq_empty_3_i,
    output  wire [14:0] core_stq_addr_0_i,
    output  wire [14:0] core_stq_addr_1_i,
    output  wire [14:0] core_stq_addr_2_i,
    output  wire [14:0] core_stq_addr_3_i,
    output  wire [15:0] core_stq_bitvec_0_i,
    output  wire [15:0] core_stq_bitvec_1_i,
    output  wire [15:0] core_stq_bitvec_2_i,
    output  wire [15:0] core_stq_bitvec_3_i,
    output  wire [127:0] core_stq_data_0_i,
    output  wire [127:0] core_stq_data_1_i,
    output  wire [127:0] core_stq_data_2_i,
    output  wire [127:0] core_stq_data_3_i,
    output  wire        core_ld_addr_MIO_V_i,
    output  wire [14:0] core_ld_addr_MIO_i,
    output  wire        core_stq_info_mio_empty_i,
    output  wire [14:0] core_stq_info_mio_addr_i,
    output  wire [127:0] core_stq_info_mio_data_i,
    output  wire        core_memStage_CLR_REQ_0_i,
    output  wire        core_memStage_CLR_REQ_1_i,
    output  wire        core_memStage_CLR_REQ_2_i,
    output  wire        core_memStage_CLR_REQ_3_i,
    output  wire        core_memStage_CLR_REQ_MIO_i,

    //core_2_icache
    output  wire         icache_en,
    output  wire [14:0]  p_addr,
    output  wire [31:0]  v_addr_i,
    output  wire [2:0]   num_valid_IDM_slots
);

    // ---- wire-declaration macros (per-stage *_outputs.vh) ----
    `FETCH_OUTPUTS
    `IDM_OUTPUTS
    `DECODE_OUTPUTS
    `RR_OUTPUTS
    `DC_OUTPUTS
    `MEM_OUTPUTS
    `EXE_OUTPUTS
    `WB_OUTPUTS

    // ---- stage / latch instantiation macros ----
    `FETCH_STAGE
    `IDM_STAGE
    `DECODE_STAGE
    `RR_LATCHES
    `RR_STAGE
    `DC_LATCHES
    `DC_STAGE
    `MEM_LATCHES
    `MEM_STAGE
    `EXE_LATCHES
    `EXE_STAGE
    `WB_LATCHES
    `WB_STAGE
    



    // ---- top-level icache port drives (from Fetch.outs_fetch_2_icache_*) ----
    assign icache_en           = fetch_outputs_fetch_2_icache_icache_en;
    assign p_addr              = fetch_outputs_fetch_2_icache_p_addr;
    assign v_addr_i            = fetch_outputs_fetch_2_icache_v_addr_i;
    assign num_valid_IDM_slots = fetch_outputs_fetch_2_icache_num_valid_IDM_slots;

    // ---- top-level dcache port drives ----
    //   ld_addr_*  (from DC.outputs.ld_addr_*)
    //   stq_heads  (from WB.outputs.stq_heads[*])
    //   mio_head   (from WB.outputs.mio_head)
    //   memStage CLR_REQ are driven by MEM_stage.vh directly, not here.

    // load addresses
    assign core_ld_addr_0_V_i  = dc_outputs_ld_addr_0_V;
    assign core_ld_addr_0_i    = dc_outputs_ld_addr_0;
    assign core_ld_addr_1_V_i  = dc_outputs_ld_addr_1_V;
    assign core_ld_addr_1_i    = dc_outputs_ld_addr_1;
    assign core_ld_addr_MIO_V_i= dc_outputs_ld_addr_MIO_V;
    assign core_ld_addr_MIO_i  = dc_outputs_ld_addr_MIO;

    // stq_heads[0..3]
    assign core_stq_full_0_i   = wb_outputs_stq_heads_0_full;
    assign core_stq_empty_0_i  = wb_outputs_stq_heads_0_empty;
    assign core_stq_addr_0_i   = wb_outputs_stq_heads_0_address;
    assign core_stq_bitvec_0_i = wb_outputs_stq_heads_0_bit_vec;
    assign core_stq_data_0_i   = wb_outputs_stq_heads_0_data;

    assign core_stq_full_1_i   = wb_outputs_stq_heads_1_full;
    assign core_stq_empty_1_i  = wb_outputs_stq_heads_1_empty;
    assign core_stq_addr_1_i   = wb_outputs_stq_heads_1_address;
    assign core_stq_bitvec_1_i = wb_outputs_stq_heads_1_bit_vec;
    assign core_stq_data_1_i   = wb_outputs_stq_heads_1_data;

    assign core_stq_full_2_i   = wb_outputs_stq_heads_2_full;
    assign core_stq_empty_2_i  = wb_outputs_stq_heads_2_empty;
    assign core_stq_addr_2_i   = wb_outputs_stq_heads_2_address;
    assign core_stq_bitvec_2_i = wb_outputs_stq_heads_2_bit_vec;
    assign core_stq_data_2_i   = wb_outputs_stq_heads_2_data;

    assign core_stq_full_3_i   = wb_outputs_stq_heads_3_full;
    assign core_stq_empty_3_i  = wb_outputs_stq_heads_3_empty;
    assign core_stq_addr_3_i   = wb_outputs_stq_heads_3_address;
    assign core_stq_bitvec_3_i = wb_outputs_stq_heads_3_bit_vec;
    assign core_stq_data_3_i   = wb_outputs_stq_heads_3_data;

    // mio_head
    assign core_stq_info_mio_empty_i = wb_outputs_mio_head_empty;
    assign core_stq_info_mio_addr_i  = wb_outputs_mio_head_address;
    assign core_stq_info_mio_data_i  = wb_outputs_mio_head_data;










endmodule
