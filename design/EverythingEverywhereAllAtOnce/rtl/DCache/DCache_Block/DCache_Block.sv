import common_pkg::*;
import DCache_pkg::*;
import interconnect_pkg::*;

module DCache_Block (
    input wire clk_i,
    input wire rst_i,  //active low

    input block_req_t block_req_i,
    input bool mem_Valid_FromDte_i,
    input bool evictionBuf_V_clr_FromDTE_i,
    input wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    input wire st_override_for_sch_req,

    //output byte_t dataLineOut[CACHE_LINES_SIZE_B],
    //output bool   hit_o,
    //i dont think miss is needed, bc its not going to sch, dte, or MEM/wb
    //output bool miss,

    //output byte_t eb_V_o,
    //output p_address_t eb_addr,
    //output byte_t eb_line_O[CACHE_LINES_SIZE_B],

    //output dcache_req_types_2_scheduler_e req_2_sch,

    output dcache_block_outputs_t outputs_o

);
    d_cache_bank_outputs_t dcache_bank_outputs;
    v_cache_outputs_t vcache_outputs;
    eb_outputs_t eb_outputs;

    DCache_Bank dcache_bank (
        .clk(clk_i),
        .rst(rst_i),
        .V_Cache_i(vcache_outputs),
        .mem_Valid_FromDte_i(mem_Valid_FromDte_i),
        .blockReq_i(block_req_i),
        .dataBus(dataBus),
        .outputs_o(dcache_bank_outputs)
    );

    VCache vcache (
        .clk_i(clk_i),
        .rst_i(rst_i),  //active low
        .blockReq_i(blockReq_i),
        .eb_outs_i(eb_outputs),
        .dcache_outs_i(dcache_bank_outputs),
        .outputs_o(vcache_outputs)
    );

    EvictionBuf evictionBuf (
        .clk_i(clk_i),
        .rst_i(rst_i),  //active low
        .clr_v_i(evictionBuf_V_clr_FromDTE_i),
        .vcache_outputs_i(vcache_outputs),
        .outputs_o(eb_outputs)
    );

    always_comb begin
        outputs_o.dataLineOut = '0;  // default (or leave if you prefer fail-fast X)
        unique case ({
            dcache_bank_outputs.hit, vcache_outputs.hit
        })
            2'b00, 2'b10: begin
                outputs_o.dataLineOut = dcache_bank_outputs.data_lineOut;
            end

            2'b01: begin
                outputs_o.dataLineOut = vcache_outputs.lineOut;
            end

            2'b11: begin
                $fatal;
            end
        endcase
    end

    assign outputs_o.hit_o = dcache_bank_outputs.hit || vcache_outputs.hit;

    //assign outputs_o.eb_V_o = eb_outputs.valid;
    assign outputs_o.eb_addr = eb_outputs.addr;
    assign outputs_o.eb_line_O = eb_outputs.lineOut;

    always_comb begin
        //outputs_o.req_2_sch = DCACHE_IDLE;

        //if (eb_outputs.valid) begin
        //    outputs_o.req_2_sch = DCACHE_LOW_PRI_REQ;
        //    if (dcache_bank_outputs.busy || vcache_outputs.busy)
        //        outputs_o.req_2_sch = DCACHE_HIGH_PRI;
        //end
        //chat write this
    end

endmodule
