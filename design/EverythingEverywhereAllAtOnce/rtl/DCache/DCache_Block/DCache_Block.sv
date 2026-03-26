import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

module DCache_Block (
    input wire clk_i,
    input wire rst_i,  //active low

    //from dcahce arb
    input block_req_t block_req_i,

    //DTE input
    input bool mem_Valid_FromDte_i,
    input bool evictionBuf_V_clr_FromDTE_i,
    input bool permissionToDriveDataBus_evictionBuf[CACHE_LINES_SIZE_Bits/DATA_BUS_WIDTH_BITS],
    input bool permissionToDriveAddrBus_Ld,
    input bool permissionToDriveAddrBus_eb,

    //for sceduling
    input wire st_override_for_sch_req,

    //
    inout wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,

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

    DCache_Bank dcache_bank_unit (
        .clk(clk_i),
        .rst(rst_i),
        .V_Cache_i(vcache_outputs),
        .mem_Valid_FromDte_i(mem_Valid_FromDte_i),
        .blockReq_i(block_req_i),
        .dataBus(dataBus),
        .outputs_o(dcache_bank_outputs)
    );

    VCache vcache_unit (
        .clk_i(clk_i),
        .rst_i(rst_i),  //active low
        .blockReq_i(block_req_i),
        .eb_outs_i(eb_outputs),
        .dcache_outs_i(dcache_bank_outputs),
        .outputs_o(vcache_outputs)
    );

    EvictionBuf evictionBuf_unit (
        .clk_i(clk_i),
        .rst_i(rst_i),  //active low
        .clr_v_i(evictionBuf_V_clr_FromDTE_i),
        .vcache_outputs_i(vcache_outputs),
        .outputs_o(eb_outputs)
    );

    always_comb begin
        outputs_o.dataLineOut = '{default: '0};  // default (or leave if you prefer fail-fast X)
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

    assign outputs_o.eb_addr = eb_outputs.addr;
    //assign outputs_o.eb_V_o = eb_outputs.valid;
    //assign outputs_o.eb_line_O = eb_outputs.lineOut;

    assign makeBlockReq = dcache_bank_outputs.MakeReq;
    assign eb_blocking = vcache_outputs.beingBlocked;
    assign eb_V = eb_outputs.valid;

    always_comb begin
        outputs_o.req_2_sch = NO_REQ;
        if (eb_V) begin
            outputs_o.req_2_sch = DCACHE_EB_WR;
            if (eb_blocking) begin
                if (st_override_for_sch_req) outputs_o.req_2_sch = DCACHE_EB_BLOCKING_ST_OVERRIDE;
                else if (block_req_i.oe) outputs_o.req_2_sch = DCACHE_EB_BLOCKING_LD;
                else if (block_req_i.we) outputs_o.req_2_sch = DCACHE_EB_BLOCK_ST;
            end
        end else if (makeBlockReq) begin
            if (st_override_for_sch_req) outputs_o.req_2_sch = DCACHE_FILL_ST_OVERRIDE;
            else if (block_req_i.oe) outputs_o.req_2_sch = DCACHE_FILL_LD;
            else if (block_req_i.we) outputs_o.req_2_sch = DCACHE_FILL_ST;
        end
    end

    //bus logic
    //addr bus
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus_fake;
    assign address_bus_fake = permissionToDriveAddrBus_Ld ? block_req_i.p_addr : eb_outputs.addr;
    assign address_bus = permissionToDriveAddrBus_Ld || permissionToDriveAddrBus_eb ? address_bus_fake : 'z;
    int startingOffset;
    logic [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus_fake;

    assign dataBus = 
        permissionToDriveDataBus_evictionBuf[0] 
        || permissionToDriveDataBus_evictionBuf[1] 
        || permissionToDriveDataBus_evictionBuf[2] 
        || permissionToDriveDataBus_evictionBuf[3]? dataBus_fake : 'z;
    //data bus
    always_comb begin
        startingOffset = 0;
        for (int i = 0; i < CACHE_LINES_SIZE_Bits / DATA_BUS_WIDTH_BITS; i++) begin
            dataBus_fake = '0;
            if (permissionToDriveDataBus_evictionBuf[i]) begin
                startingOffset = i * CACHE_LINES_SIZE_Bits / DATA_BUS_WIDTH_BITS;
                dataBus_fake = {
                    eb_outputs.lineOut[startingOffset],
                    eb_outputs.lineOut[startingOffset+1],
                    eb_outputs.lineOut[startingOffset+2],
                    eb_outputs.lineOut[startingOffset+3]
                };
            end
        end
    end








endmodule
