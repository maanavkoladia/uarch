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
    input bool evictionBuf_clr_FromDTE_i,
    input bool evictionBuf_setCommiting_FromDTE_i,
    input bool permissionToDriveDataBus_evictionBuf[CACHE_LINES_SIZE_BITS/DATA_BUS_WIDTH_BITS],
    input bool permissionToDriveAddrBus_Ld,
    input bool permissionToDriveAddrBus_eb,

    //for sceduling
    input wire st_override_for_sch_req,

    //
    inout wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,

    // output byte_t dataLineOut[CACHE_LINES_SIZE_B],
    // output bool   hit_o,
    // i dont think miss is needed, bc its not going to sch, dte, or MEM/wb
    // output bool miss,

    // output byte_t eb_V_o,
    // output p_address_t eb_addr,
    // output byte_t eb_line_O[CACHE_LINES_SIZE_B],

    // output dcache_req_types_2_scheduler_e req_2_sch,

    output dcache_block_outputs_t outputs_o

);


    d_cache_bank_outputs_t dcache_bank_outputs;
    v_cache_outputs_t vcache_outputs;
    eb_outputs_t eb_outputs;

    bool block_busy;
    assign block_busy = dcache_bank_outputs.busy || vcache_outputs.busy;

    DCache_Bank dcache_bank_unit (
        .clk(clk_i),
        .rst(rst_i),
        .V_Cache_i(vcache_outputs),
        .eb_i(eb_outputs),
        .mem_Valid_FromDte_i(mem_Valid_FromDte_i),
        .blockReq_i(block_req_i),
        .block_busy_i(block_busy),
        .dataBus(dataBus),
        .outputs_o(dcache_bank_outputs)
    );

    VCache vcache_unit (
        .clk(clk_i),
        .rst(rst_i),  //active low
        .blockReq_i(block_req_i),
        .block_busy_i(block_busy),
        .eb_outs_i(eb_outputs),
        .dcache_outs_i(dcache_bank_outputs),
        .outputs_o(vcache_outputs)
    );

    EvictionBuf evictionBuf_unit (
        .clk_i(clk_i),
        .rst_i(rst_i),  //active low
        .eb_clr_i(evictionBuf_clr_FromDTE_i),
        .set_commiting(evictionBuf_setCommiting_FromDTE_i),
        .vcache_outputs_i(vcache_outputs),
        .blockReq_i(block_req_i),
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
                if (rst_i) $fatal;
            end
            default: if(rst_i) $fatal;
        endcase
    end

    assign outputs_o.hit_o = dcache_bank_outputs.hit || vcache_outputs.hit;

    assign outputs_o.eb_addr = eb_outputs.addr;
    //assign outputs_o.eb_V_o = eb_outputs.valid;
    //assign outputs_o.eb_line_O = eb_outputs.lineOut;

    bool makeBlockReq, eb_blockingVCache, eb_V, eb_curr_commiting,eb_blocking_Bank;
    assign makeBlockReq = dcache_bank_outputs.MakeReq;
    assign eb_blockingVCache = vcache_outputs.beingBlocked;
    assign eb_V = eb_outputs.valid;
    assign eb_curr_commiting = eb_outputs.commiting;
    assign eb_blocking_Bank = dcache_bank_outputs.eb_stalling;

    //need to add support for DCACHE_EB_BLOCKING_BANK
    always_comb begin
        outputs_o.req_2_sch = NO_REQ;
        if (eb_V) begin
            if (eb_blocking_Bank && !eb_curr_commiting) begin
                outputs_o.req_2_sch = DCACHE_EB_BLOCKING_BANK;
            end else if (eb_blockingVCache && !eb_curr_commiting) begin  //blocking
                if (st_override_for_sch_req) outputs_o.req_2_sch = DCACHE_EB_BLOCKING_ST_OVERRIDE;
                else if (block_req_i.oe) outputs_o.req_2_sch = DCACHE_EB_BLOCKING_LD;
                else if (block_req_i.we) outputs_o.req_2_sch = DCACHE_EB_BLOCK_ST;
            end else if (eb_blockingVCache && eb_curr_commiting) begin
                if (st_override_for_sch_req) outputs_o.req_2_sch = NO_REQ;
                else if (block_req_i.oe) outputs_o.req_2_sch = NO_REQ;
                else if (block_req_i.we) outputs_o.req_2_sch = NO_REQ;
            end else if (!eb_curr_commiting) begin
                outputs_o.req_2_sch = DCACHE_EB_WR;
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
    assign #5 address_bus = permissionToDriveAddrBus_Ld || permissionToDriveAddrBus_eb ? address_bus_fake : 'z;
    int startingOffset;
    logic [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus_fake;

    // assign dataBus =
    //     permissionToDriveDataBus_evictionBuf[0]
    //     || permissionToDriveDataBus_evictionBuf[1]
    //     || permissionToDriveDataBus_evictionBuf[2]
    //     || permissionToDriveDataBus_evictionBuf[3]? dataBus_fake : 'z;
    // //data bus
    // always_comb begin
    //     startingOffset = 0;
    //     for (int i = 0; i < CACHE_LINES_SIZE_BITS / DATA_BUS_WIDTH_BITS; i++) begin
    //         dataBus_fake = '0;
    //         if (permissionToDriveDataBus_evictionBuf[i]) begin
    //             startingOffset = i * CACHE_LINES_SIZE_BITS / DATA_BUS_WIDTH_BITS;
    //             dataBus_fake = {
    //                 eb_outputs.lineOut[startingOffset],
    //                 eb_outputs.lineOut[startingOffset+1],
    //                 eb_outputs.lineOut[startingOffset+2],
    //                 eb_outputs.lineOut[startingOffset+3]
    //             };
    //         end
    //     end
    // end

    wire [3:0] perm2DriveDataBus_bar;

    assign perm2DriveDataBus_bar = {
        ~permissionToDriveDataBus_evictionBuf[3],
        ~permissionToDriveDataBus_evictionBuf[2],
        ~permissionToDriveDataBus_evictionBuf[1],
        ~permissionToDriveDataBus_evictionBuf[0]
    };

    logic [127:0] eb_lineOut_vec;
    assign eb_lineOut_vec = {
        eb_outputs.lineOut[15],
        eb_outputs.lineOut[14],
        eb_outputs.lineOut[13],
        eb_outputs.lineOut[12],
        eb_outputs.lineOut[11],
        eb_outputs.lineOut[10],
        eb_outputs.lineOut[9],
        eb_outputs.lineOut[8],
        eb_outputs.lineOut[7],
        eb_outputs.lineOut[6],
        eb_outputs.lineOut[5],
        eb_outputs.lineOut[4],
        eb_outputs.lineOut[3],
        eb_outputs.lineOut[2],
        eb_outputs.lineOut[1],
        eb_outputs.lineOut[0]
    };

    `BUS_TRISTATE(memBus_tri_0, 32, perm2DriveDataBus_bar[0], eb_lineOut_vec[31:0], dataBus);
    `BUS_TRISTATE(memBus_tri_1, 32, perm2DriveDataBus_bar[1], eb_lineOut_vec[63:32], dataBus);
    `BUS_TRISTATE(memBus_tri_2, 32, perm2DriveDataBus_bar[2], eb_lineOut_vec[95:64], dataBus);
    `BUS_TRISTATE(memBus_tri_3, 32, perm2DriveDataBus_bar[3], eb_lineOut_vec[127:96], dataBus);





endmodule
