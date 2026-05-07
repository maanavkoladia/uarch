import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import reg_ids_pkg::*;

module EveryThing_TOP (
    input wire clk,
    input wire rst,

    //icache 2 core
    input wire         out_hit,
    input wire [127:0] out_instruction_line,

    //dma to core
    input wire inFromDMA_i

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
    output  wire [2:0]   num_valid_IDM_slots,
);

    `FETCH_OUTPUTS
endmodule
